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
    
    float sceneCameraSpaceDepth = min(depthQ, depthT);
    float3 decalSpaceScenePos = cameraPosOS + viewRayOS.xyz * sceneCameraSpaceDepth;
    decalSpaceScenePos.xy = rotate2D(decalSpaceScenePos.xy, 0.0.xx, rotateAngle);
    decalSpaceScenePos.xy *= scale;
    float2 decalSpaceUV = decalSpaceScenePos.xy + 0.5;
    
    float mask = (abs(decalSpaceScenePos.y) < 0.5)* (abs(decalSpaceScenePos.x) < 0.5) /* (abs(decalSpaceScenePos.y) < 0.5) * (abs(decalSpaceScenePos.z) < 0.5)*/;
    
    
    float3 decalSpaceHardNormal = normalize(cross(ddx(decalSpaceScenePos), ddy(decalSpaceScenePos)));
    mask *= decalSpaceHardNormal.z > - 1.0 ? 1.0: 0.0;//compare scene hard normal with decal projector's dir, decalSpaceHardNormal.z equals dot(decalForwardDir,sceneHardNormalDir)
    
    //call discard
    clip(mask - 0.5);//if ZWrite is off, clip() is fast enough on mobile, because it won't access the DepthBuffer, so no pipeline stall.
    //===================================================
    
    // sample the decal texture
    return decalSpaceUV.xy;
}
