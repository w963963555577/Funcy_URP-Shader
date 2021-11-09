CBUFFER_START(UnityPerMaterial)
half4 _PositionMask_ST;
half4 _BaseMap_ST;


half _ClipThreshod;
half _LambertOffset;
half _SpecularOffset;

half _Speed;
half _Amount;
half _Distance;

half4 _BlendColor_SelfShadow;
half4 _BlendColor_Dark;
half4 _BlendColor_Mid;
half4 _BlendColor_Light;
half4 _SpecColor;

half _ViewRendererMode;

half4 _TreePropertiesMap_TexelSize;
#ifdef _DrawMeshInstancedProcedural
    StructuredBuffer<half4x4> _ObjectToWorldBuffer;
    StructuredBuffer<half4x4> _WorldToObjectBuffer;
    StructuredBuffer<uint> _VisibleInstanceOnlyTransformIDBuffer;
#endif
CBUFFER_END

TEXTURE2D_ARRAY(_TreePropertiesMap);             SAMPLER(sampler_TreePropertiesMap);

half2 remap(half2 x, half2 t1, half2 t2, half2 s1, half2 s2)
{
    return(x - t1) / (t2 - t1) * (s2 - s1) + s1;
}


void GetBaseProperties(float2 uv1, out float3 p0, out float3 p1)
{
    float2 uvp0 = float2(uv1.x, 0.5 * _TreePropertiesMap_TexelSize.y);
    p0 = SAMPLE_TEXTURE2D_ARRAY_LOD(_TreePropertiesMap, sampler_TreePropertiesMap, uvp0, 0, 0).xyz;
    
    float2 uvp1 = float2(uv1.x, 1.5 * _TreePropertiesMap_TexelSize.y);
    p1 = SAMPLE_TEXTURE2D_ARRAY_LOD(_TreePropertiesMap, sampler_TreePropertiesMap, uvp1, 0, 0).xyz;
}


void GetProperties(float2 uv1, out float3 p0, out float3 p1,
out float4 blendColor_Light, out float4 blendColor_Mid, out float4 blendColor_Dark, out float4 blendColor_SelfShadow, out float4 specColor)
{
    GetBaseProperties(uv1, p0, p1);
    float2 uvp2 = float2(uv1.x, 2.5 * _TreePropertiesMap_TexelSize.y);
    blendColor_Light = SAMPLE_TEXTURE2D_ARRAY_LOD(_TreePropertiesMap, sampler_TreePropertiesMap, uvp2, 0, 0);
    
    float2 uvp3 = float2(uv1.x, 3.5 * _TreePropertiesMap_TexelSize.y);
    blendColor_Mid = SAMPLE_TEXTURE2D_ARRAY_LOD(_TreePropertiesMap, sampler_TreePropertiesMap, uvp3, 0, 0);
    
    float2 uvp4 = float2(uv1.x, 4.5 * _TreePropertiesMap_TexelSize.y);
    blendColor_Dark = SAMPLE_TEXTURE2D_ARRAY_LOD(_TreePropertiesMap, sampler_TreePropertiesMap, uvp4, 0, 0);
    
    float2 uvp5 = float2(uv1.x, 5.5 * _TreePropertiesMap_TexelSize.y);
    blendColor_SelfShadow = SAMPLE_TEXTURE2D_ARRAY_LOD(_TreePropertiesMap, sampler_TreePropertiesMap, uvp5, 0, 0);
    
    float2 uvp6 = float2(uv1.x, 6.5 * _TreePropertiesMap_TexelSize.y);
    specColor = SAMPLE_TEXTURE2D_ARRAY_LOD(_TreePropertiesMap, sampler_TreePropertiesMap, uvp6, 0, 0);
}

#include "../../../../ShaderLibrary/VertexAnimation.hlsl"
#include "../../../../ShaderLibrary/GlobalFog.hlsl"