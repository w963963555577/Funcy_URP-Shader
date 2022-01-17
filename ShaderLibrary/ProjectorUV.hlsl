void InitProjectorVertexData(float4 positionOS, float4x4 o2w, float4x4 w2o, out float4 viewRay, out float3 cameraPos)
{
    float3 vr = mul(UNITY_MATRIX_V, mul(o2w, float4(positionOS.xyz, 1.0))).xyz;
    
    viewRay.w = vr.z;
    
    
    float4x4 ViewToObjectMatrix = mul(w2o, UNITY_MATRIX_I_V);
    
    viewRay.xyz = mul((float3x3)ViewToObjectMatrix, -vr);
    cameraPos = ViewToObjectMatrix._m03_m13_m23;
}

float2 rotate2D(float2 uv, half2 pivot, half angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return mul(uv - pivot, float2x2(c, -s, s, c)) + pivot;
}

float2 projectorUV(float4 viewRayOS, float3 cameraPosOS, float4 screenUV, float2 scale, float rotateAngle)
{
    viewRayOS *= rcp(viewRayOS.w);
    screenUV /= screenUV.w;
    #if defined(UNITY_SINGLE_PASS_STEREO)
        screenUV.xy = UnityStereoTransformScreenSpaceTex(screenUV.xy);
    #endif
    float depthQ = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(screenUV.xy), _ZBufferParams);
    float depthT = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH_TRANSPARENT(screenUV.xy), _ZBufferParams);
    
    float depth = min(depthQ, depthT);
    
    
    float3 decalSpaceScenePos = cameraPosOS + viewRayOS.xyz * depth;
    decalSpaceScenePos.xz = rotate2D(decalSpaceScenePos.xz, 0.0.xx, rotateAngle);
    decalSpaceScenePos.xz *= rcp(scale);
    float2 decalSpaceUV = decalSpaceScenePos.xz + 0.5;
    
    
    //  Clip decal to volume
    clip(float3(0.5, 0.5, 0.5) - abs(decalSpaceScenePos.xyz));
    
    // sample the decal texture
    return decalSpaceUV.xy;
}
