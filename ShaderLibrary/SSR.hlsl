void SSRRayConvert(float3 worldPos, out float4 clipPos, out float3 screenPos)
{
    clipPos = TransformWorldToHClip(worldPos);
    float k = ((1.0) / (clipPos.w));
    
    screenPos.xy = ComputeScreenPos(clipPos).xy * k;
    screenPos.z = k;
    
    #if defined(UNITY_SINGLE_PASS_STEREO)
        screenPos.xy = UnityStereoTransformScreenSpaceTex(screenPos.xy);
    #endif
}

float Ramp(float2 uv, sampler2D rampMap)
{
    return tex2D(rampMap, uv.xy * 32.0).r;
}

float3 SSRRayMarch(float3 worldPos, half3 R, half sampleDetensity, sampler2D rampMap)
{
    float4 startClipPos;
    float3 startScreenPos;
    
    SSRRayConvert(worldPos, startClipPos, startScreenPos);
    
    float4 endClipPos;
    float3 endScreenPos;
    
    SSRRayConvert(worldPos + R, endClipPos, endScreenPos);
    
    if (endClipPos.w < startClipPos.w)
    {
        return float3(0, 0, 0);
    }
    
    float3 screenDir = endScreenPos - startScreenPos;
    
    float screenDirX = abs(screenDir.x);
    float screenDirY = abs(screenDir.y);
    
    screenDir *= 64.0;
    
    half lastRayDepth = startClipPos.w;
    
    half sampleCount = 64.0 * sampleDetensity / Ramp(screenDir.xy, rampMap);
    
    #if defined(SHADER_API_OPENGL) || defined(SHADER_API_D3D11) || defined(SHADER_API_D3D12)
        [unroll(64)]
    #else
        UNITY_LOOP
    #endif
    for (int i = 0; i < sampleCount; i ++)
    {
        float3 screenMatchUVZ = startScreenPos + screenDir * i / sampleCount;
        
        if((screenMatchUVZ.x <= 0) || (screenMatchUVZ.x >= 1) || (screenMatchUVZ.y <= 0) || (screenMatchUVZ.y >= 1))
        {
            break;
        }
        
        float sceneDepth = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(screenMatchUVZ.xy), _ZBufferParams);
        half rayDepth = 1.0 / screenMatchUVZ.z;
        half deltaDepth = rayDepth - sceneDepth;
        
        if((deltaDepth > 0) && (sceneDepth > startClipPos.w) && (deltaDepth < (abs(rayDepth - lastRayDepth) * 2)))
        {
            return float3(screenMatchUVZ.xy, 1);
        }
        
        lastRayDepth = rayDepth;
    }
    
    float4 farClipPos;
    float3 farScreenPos;
    
    SSRRayConvert(worldPos + R * 5000.0, farClipPos, farScreenPos);
    
    if((farScreenPos.x > 0) && (farScreenPos.x < 1) && (farScreenPos.y > 0) && (farScreenPos.y < 1))
    {
        float farDepth = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(farScreenPos.xy), _ZBufferParams);
        
        if(farDepth > startClipPos.w)
        {
            return float3(farScreenPos.xy, 1);
        }
    }
    
    return float3(0, 0, 0);
}


float3 GetSSRUVZ(float3 worldPos, half NoV, half3 R, float2 screenUV, half sampleDetensity, sampler2D rampMap)
{
    float3 uvz = 0.0.rrr;
    half ssrWeight = 1.0;
    
    #ifdef UNITY_SINGLE_PASS_STEREO
        half NoVs = NoV * 2;
        ssrWeight *= (1.0 - NoVs * NoVs);
    #else
        float2 screenUVs = screenUV * 2.0 - 1.0;
        screenUVs *= screenUVs;
        
        ssrWeight = saturate(1 - dot(screenUVs, screenUVs));
        
        half NoVs = NoV * 2.5;
        ssrWeight *= (1 - NoVs * NoVs);
    #endif
    
    if(ssrWeight > 0.005)
    {
        uvz = SSRRayMarch(worldPos, R, sampleDetensity, rampMap);
        uvz.z *= ssrWeight;
        return uvz.xyz;
    }
    
    return float3(0, 0, 0);
}

