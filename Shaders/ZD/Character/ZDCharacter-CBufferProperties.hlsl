CBUFFER_START(UnityPerMaterial)
half4 _diffuse_ST;
half _SelfMaskEnable;
half4 _SelfMask_ST;
half _SubsurfaceScattering;
half _SubsurfaceRadius;
half _SelfMaskDirection;

half4 _mask_ST;
half4 _Color;
half4 _EmissionColor;
half4 _SpecularColor;

half4 _Picker_0;
half4 _Picker_1;
half4 _Picker_2;
half4 _Picker_3;
half4 _Picker_4;
half4 _Picker_5;
half4 _Picker_6;
half4 _Picker_7;
half4 _Picker_8;
half4 _Picker_9;
half4 _Picker_10;
half4 _Picker_11;

half4 _ShadowColor0;
half4 _ShadowColor1;
half4 _ShadowColor2;
half4 _ShadowColor3;
half4 _ShadowColor4;
half4 _ShadowColor5;
half4 _ShadowColor6;
half4 _ShadowColor7;
half4 _ShadowColor8;
half4 _ShadowColor9;
half4 _ShadowColor10;
half4 _ShadowColor11;

half4 _ShadowColorElse;
half _Cutoff;
half _Gloss;
half _EmissionxBase;
half _EmissionOn;
half _EmissionFlow;
half _Flash;
half _EdgeLightWidth;
half _EdgeLightIntensity;
half _NormalScale;
half _ShadowRamp;
half _SelfShadowRamp;
half _ReceiveShadow;
half _ShadowRefraction;
half _ShadowOffset;

half4 _CustomLightColor;
half4 _CustomLightDirection;
half _CustomLightIntensity;

half4 _DiscolorationColor_0;
half4 _DiscolorationColor_1;
half4 _DiscolorationColor_2;
half4 _DiscolorationColor_3;
half4 _DiscolorationColor_4;
half4 _DiscolorationColor_5;
half4 _DiscolorationColor_6;
half4 _DiscolorationColor_7;
half4 _DiscolorationColor_8;
half4 _DiscolorationColor_9;

half4 _OutlineColor;
half _DiffuseBlend;

half _OutlineEnable;
half4 _OutlineDistProp;

half _SelectExpressionMap;
half _SelectMouth;
half _SelectFace;
half _SelectBrow;

half4 _BrowRect;
half4 _FaceRect;
half4 _MouthRect;

half _FloatModel;
half4 _EffectiveColor;
half _FaceLightMapCombineMode;

half _DistanceDisslove;
half4 _VertexDataMap_TexelSize;
half4 _BoneMatrixMap_TexelSize;

#ifdef _DrawMeshInstancedProcedural
    StructuredBuffer<float4x4> _ObjectToWorldBuffer;
    StructuredBuffer<float4x4> _WorldToObjectBuffer;
    StructuredBuffer<uint> _VisibleInstanceOnlyTransformIDBuffer;
    StructuredBuffer<float4> _TimeBuffer;
#endif
CBUFFER_END

#ifdef _DrawMeshInstancedProcedural
    
#else
    float4 _TimeData;
#endif

TEXTURE2D(_EffectiveMap);                    SAMPLER(sampler_EffectiveMap);
TEXTURE2D_ARRAY(_BoneMatrixMap);             SAMPLER(sampler_BoneMatrixMap);

float4 ComputeScreenPos(float4 pos, float projectionSign)
{
    float4 o = pos * 0.5f;
    o.xy = float2(o.x, o.y * projectionSign) + o.w;
    o.zw = pos.zw;
    return o;
}

half smoothstepBetterPerformace(half edge0, half edge1, half x, half d)
{
    half t = saturate((x - edge0) * d);
    return t * t * (3.0 - 2.0 * t);
}

half Remap(half value, half from1, half to1, half from2, half to2)
{
    return(value - from1) / (to1 - from1) * (to2 - from2) + from2;
}

half3 RGB2HSV(half3 c)
{
    half4 K = half4(0.0, -0.3333333333333333, 0.6666666666666667, -1.0);
    half4 p = lerp(half4(c.bg, K.wz), half4(c.gb, K.xy), step(c.b, c.g));
    half4 q = lerp(half4(p.xyw, c.r), half4(c.r, p.yzx), step(p.x, c.r));
    
    half d = q.x - min(q.w, q.y);
    half e = 1.0e-10;
    return half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

half3 HSV2RGB(half3 c)
{
    half4 K = half4(1.0, 0.6666666666666667, 0.3333333333333333, 3.0);
    half3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}


#if _DiscolorationSystem
    void Step8Color(half gray, half2 eyeAreaReplace, half2 browReplace, half2 mouthReplace, out half4 color, out half blackArea, out half skinArea, out half eyeArea)
    {
        half gray_oneminus = (1.0 - gray);
        #if _ExpressionEnable
            half eyeCenter = smoothstep(0.5, 1.0, eyeAreaReplace.x) * eyeAreaReplace.y;
        #endif
        half grayArea_9 = min(1.0, (smoothstepBetterPerformace(0.90, 1.00, gray, 10.0) * 2.0));
        half grayArea_8 = min(1.0, (smoothstepBetterPerformace(0.70, 0.80, gray, 10.0) * 2.0));
        half grayArea_7 = min(1.0, (smoothstepBetterPerformace(0.60, 0.70, gray, 10.0) * 2.0));
        half grayArea_6 = min(1.0, (smoothstepBetterPerformace(0.45, 0.60, gray, 6.66) * 2.0));
        half grayArea_5 = min(1.0, (smoothstepBetterPerformace(0.35, 0.45, gray, 10.0) * 2.0));
        half grayArea_4 = 1.00 - grayArea_5;
        half grayArea_3 = min(1.0, (smoothstepBetterPerformace(0.70, 0.80, gray_oneminus, 10.0) * 2.0));
        half grayArea_2 = min(1.0, (smoothstepBetterPerformace(0.80, 0.90, gray_oneminus, 10.0) * 2.0));
        half grayArea_1 = min(1.0, (smoothstepBetterPerformace(0.90, 0.95, gray_oneminus, 20.0) * 2.0));
        
        half grayArea_0 = min(1.0, (smoothstepBetterPerformace(0.95, 1.00, gray_oneminus, 20.0) * 2.0));
        #if _ExpressionEnable
            grayArea_0 = max(grayArea_0, min(1.0, smoothstepBetterPerformace(0.4, 0.5, eyeAreaReplace.x, 10.0) * eyeAreaReplace.y - eyeCenter));
            #if _ExpressionFormat_FaceSheet
                grayArea_0 = max(grayArea_0, smoothstepBetterPerformace(0.5, 1.0, browReplace.x, 2.0) * browReplace.y);
                grayArea_0 = max(grayArea_0, smoothstepBetterPerformace(0.5, 1.0, mouthReplace.x, 2.0) * mouthReplace.y);
            #endif
        #endif
        
        half fillArea_9 = grayArea_9;
        half fillArea_8 = grayArea_8 - grayArea_9;
        half fillArea_7 = grayArea_7 - grayArea_8;
        half fillArea_6 = grayArea_6 - grayArea_7;
        half fillArea_5 = grayArea_5 - grayArea_6;
        half fillArea_4 = grayArea_4 - grayArea_3;
        half fillArea_3 = grayArea_3 - grayArea_2;
        #if _ExpressionEnable
            half fillArea_2 = eyeCenter;
            grayArea_1 = max(grayArea_1, grayArea_2) * (1.0 - eyeCenter);
        #else
            half fillArea_2 = grayArea_2 - grayArea_1;
        #endif
        
        half fillArea_1 = grayArea_1 - grayArea_0;
        
        half fillArea_0 = grayArea_0;
        
        blackArea = fillArea_0;
        skinArea = fillArea_1;
        
        eyeArea = fillArea_2;
        color = _DiscolorationColor_8 * fillArea_8 + _DiscolorationColor_9 * fillArea_9 +
        _DiscolorationColor_7 * fillArea_7 + _DiscolorationColor_6 * fillArea_6 +
        _DiscolorationColor_5 * fillArea_5 + _DiscolorationColor_4 * fillArea_4 +
        _DiscolorationColor_3 * fillArea_3 + _DiscolorationColor_2 * fillArea_2 +
        _DiscolorationColor_1 * fillArea_1 + _DiscolorationColor_0 * fillArea_0
        ;
        
        half hdr = max(max(color.r, color.g), color.b) ;
        color.a = hdr - 1.0;
    }
#endif


void DistanceDisslove(half2 screenUV, half vertexDist)
{
    half as = _ScreenParams.y / _ScreenParams.x;
    half2 maskUV = half2(screenUV.x * as, screenUV.y) * 200.0;
    half rowID = fmod(floor(maskUV.y), 2.0);
    half2 distanceRect = abs(frac(lerp(maskUV, maskUV + 0.5, rowID))) * 0.70707;
    
    half distanceDissloveMask = 1.0 - max(distanceRect.x, distanceRect.y) * _DistanceDisslove;
    distanceDissloveMask *= distanceDissloveMask * distanceDissloveMask * distanceDissloveMask;
    //clip(distanceDissloveMask - (1.0 - min(1.0, vertexDist * 1.5384)));
}

half CaculateShadowArea(half4 src, half4 picker, half setpB)
{
    half3 compare = src.rgb - picker.rgb;
    return 1.0 - smoothstep(picker.a, setpB, length(compare));
}

#ifdef _DrawMeshInstancedProcedural
    VertexPositionInputs InitVertexPositionInputs(float3 positionOS, uint id)
    {
        VertexPositionInputs input;
        input.positionWS = mul(_ObjectToWorldBuffer[id], float4(positionOS, 1.0)).xyz;
        input.positionVS = TransformWorldToView(input.positionWS);
        input.positionCS = TransformWorldToHClip(input.positionWS);
        
        float4 ndc = input.positionCS * 0.5f;
        input.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
        input.positionNDC.zw = input.positionCS.zw;
        
        return input;
    }
    
    VertexNormalInputs InitVertexNormalInputs(float3 normalOS, float4 tangentOS, uint id)
    {
        VertexNormalInputs tbn;
        
        // mikkts space compliant. only normalize when extracting normal at frag.
        real sign = tangentOS.w * GetOddNegativeScale();
        #ifdef UNITY_ASSUME_UNIFORM_SCALING
            tbn.normalWS.xyz = SafeNormalize(mul((real3x3)_ObjectToWorldBuffer[id], normalOS.xyz));
        #else
            tbn.normalWS.xyz = SafeNormalize(mul(normalOS, (real3x3)_WorldToObjectBuffer[id]));
        #endif
        tbn.tangentWS.xyz = SafeNormalize(mul((real3x3)_ObjectToWorldBuffer[id], tangentOS.xyz));
        tbn.bitangentWS = cross(tbn.normalWS, tbn.tangentWS) * sign;
        return tbn;
    }
#endif

#ifndef _SKINBONE_ATTACHED
    float4x4 BoneMatrix(float boneIndex, float time, uint mid)
    {
        #ifdef _DrawMeshInstancedProcedural
            float blend = _TimeBuffer[mid].y;
            uint currentAnimation = _TimeBuffer[mid].z;
            uint nextAnimation = _TimeBuffer[mid].w;
        #else
            float blend = _TimeData.y;
            uint currentAnimation = _TimeData.z;
            uint nextAnimation = _TimeData.w;
        #endif
        
        float loop = 0.33333333333;
        float t = fmod(time * loop, loop);
        t += 0.5 * _BoneMatrixMap_TexelSize.x;
        float2 uv = float2(t, (boneIndex + 0.5) * _BoneMatrixMap_TexelSize.y);
        
        float4 c1 = SAMPLE_TEXTURE2D_ARRAY_LOD(_BoneMatrixMap, sampler_BoneMatrixMap, uv, currentAnimation, 0);
        c1 = lerp(c1, SAMPLE_TEXTURE2D_ARRAY_LOD(_BoneMatrixMap, sampler_BoneMatrixMap, uv, nextAnimation, 0), blend);
        uv.x += loop;
        float4 c2 = SAMPLE_TEXTURE2D_ARRAY_LOD(_BoneMatrixMap, sampler_BoneMatrixMap, uv, currentAnimation, 0);
        c2 = lerp(c2, SAMPLE_TEXTURE2D_ARRAY_LOD(_BoneMatrixMap, sampler_BoneMatrixMap, uv, nextAnimation, 0), blend);
        uv.x += loop;
        float4 c3 = SAMPLE_TEXTURE2D_ARRAY_LOD(_BoneMatrixMap, sampler_BoneMatrixMap, uv, currentAnimation, 0);
        c3 = lerp(c3, SAMPLE_TEXTURE2D_ARRAY_LOD(_BoneMatrixMap, sampler_BoneMatrixMap, uv, nextAnimation, 0), blend);
        float4 c4 = float4(0, 0, 0, 1);
        
        float4x4 m;
        
        m._11_12_13_14 = c1;
        m._21_22_23_24 = c2;
        m._31_32_33_34 = c3;
        m._41_42_43_44 = c4;
        
        return m;
    }
    float4x4 AnimationInstancingMatrix(float4 boneID, float4 boneWeight, uint mid)
    {
        #ifdef _DrawMeshInstancedProcedural
            float time = _TimeBuffer[mid].x;
        #else
            float time = _TimeData.x;
        #endif
        time = floor(time * 100.0) * 0.01;
        float4x4 o2w = BoneMatrix(boneID.x, time, mid) * boneWeight.x;
        o2w += BoneMatrix(boneID.y, time, mid) * boneWeight.y;
        o2w += BoneMatrix(boneID.z, time, mid) * boneWeight.z;
        o2w += BoneMatrix(boneID.w, time, mid) * boneWeight.w;
        
        return o2w;
    }
#endif
