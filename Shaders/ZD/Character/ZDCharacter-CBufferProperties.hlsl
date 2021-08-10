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

float4 _DiscolorationColor_0;
float4 _DiscolorationColor_1;
float4 _DiscolorationColor_2;
float4 _DiscolorationColor_3;
float4 _DiscolorationColor_4;
float4 _DiscolorationColor_5;
float4 _DiscolorationColor_6;
float4 _DiscolorationColor_7;
float4 _DiscolorationColor_8;
float4 _DiscolorationColor_9;

float4 _OutlineColor;
float _DiffuseBlend;

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
    StructuredBuffer<float> _TimeBuffer;
#endif

CBUFFER_END

TEXTURE2D(_EffectiveMap);                    SAMPLER(sampler_EffectiveMap);
TEXTURE2D_ARRAY(_BoneMatrixMap);             SAMPLER(sampler_BoneMatrixMap);

float4 ComputeScreenPos(float4 pos, float projectionSign)
{
    float4 o = pos * 0.5f;
    o.xy = float2(o.x, o.y * projectionSign) + o.w;
    o.zw = pos.zw;
    return o;
}

half3 RGB2HSV(half3 c)
{
    float4 K = float4(0.0, -0.3333333333333333, 0.6666666666666667, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

half3 HSV2RGB(half3 c)
{
    float4 K = float4(1.0, 0.6666666666666667, 0.3333333333333333, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

void DistanceDisslove(float2 screenUV, half vertexDist)
{
    half as = _ScreenParams.y / _ScreenParams.x;
    half2 maskUV = half2(screenUV.x * as, screenUV.y) * 200.0;
    half rowID = fmod(floor(maskUV.y), 2.0);
    half2 distanceRect = abs(frac(lerp(maskUV, maskUV + 0.5, rowID))) * 0.70707;
    
    half distanceDissloveMask = 1.0 - max(distanceRect.x, distanceRect.y) * _DistanceDisslove;
    distanceDissloveMask *= distanceDissloveMask * distanceDissloveMask * distanceDissloveMask;
    clip(distanceDissloveMask - (1.0 - min(1.0, vertexDist * 1.5384)));
}

float CaculateShadowArea(float4 src, float4 picker, float setpB)
{
    float3 compare = src.rgb - picker.rgb;
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
    float4x4 BoneMatrix(float boneIndex, float time)
    {
        float loop = 0.333333333;
        float t = fmod(time, loop) + 0.5 * _BoneMatrixMap_TexelSize.x;
        float2 uv = float2(t, (boneIndex + 0.5) * _BoneMatrixMap_TexelSize.y);
        float4 c1 = SAMPLE_TEXTURE2D_ARRAY_LOD(_BoneMatrixMap, sampler_BoneMatrixMap, uv, 0, 0);
        uv.x += loop;
        float4 c2 = SAMPLE_TEXTURE2D_ARRAY_LOD(_BoneMatrixMap, sampler_BoneMatrixMap, uv, 0, 0);
        uv.x += loop;
        float4 c3 = SAMPLE_TEXTURE2D_ARRAY_LOD(_BoneMatrixMap, sampler_BoneMatrixMap, uv, 0, 0);
        float4 c4 = half4(0, 0, 0, 1);
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
            float time = _TimeBuffer[mid];
        #else
            float time = _Time.y;
        #endif
        
        float4x4 o2w = BoneMatrix(boneID.x, time) * boneWeight.x;
        o2w += BoneMatrix(boneID.y, time) * boneWeight.y;
        o2w += BoneMatrix(boneID.z, time) * boneWeight.z;
        o2w += BoneMatrix(boneID.w, time) * boneWeight.w;
        
        return o2w;
    }
#endif
