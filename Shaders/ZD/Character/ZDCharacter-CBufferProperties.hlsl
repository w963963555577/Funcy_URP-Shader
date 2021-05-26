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
half4 _OutlineWidth_MinWidth_MaxWidth_Dist_DistBlur;

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
CBUFFER_END

TEXTURE2D(_EffectiveMap);              SAMPLER(sampler_EffectiveMap);


float4 ComputeScreenPos(float4 pos, float projectionSign)
{
    float4 o = pos * 0.5f;
    o.xy = float2(o.x, o.y * projectionSign) + o.w;
    o.zw = pos.zw;
    return o;
}

void DistanceDisslove(float2 screenUV, half vertexDist)
{
    half as = _ScreenParams.y / _ScreenParams.x;
    half2 maskUV = half2(screenUV.x, screenUV.y) * 250.0;
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