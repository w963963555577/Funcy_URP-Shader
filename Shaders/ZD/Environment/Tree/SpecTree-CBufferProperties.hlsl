CBUFFER_START(UnityPerMaterial)
float4 _PositionMask_ST;
float4 _BaseMap_ST;
float4 _BlendColor_SelfShadow;
float4 _BlendColor_Dark;
float4 _BlendColor_Mid;
float4 _BlendColor_Light;
float4 _SpecColor;
float _Speed;
float _Amount;
float _Distance;

float _LambertOffset;
float _ClipThreshod;
float _SpecularOffset;
float _ViewRendererMode;
#ifdef _DrawMeshInstancedProcedural
    StructuredBuffer<float4x4> _ObjectToWorldBuffer;
    StructuredBuffer<float4x4> _WorldToObjectBuffer;
    StructuredBuffer<uint> _VisibleInstanceOnlyTransformIDBuffer;
#endif
CBUFFER_END


half2 remap(half2 x, half2 t1, half2 t2, half2 s1, half2 s2)
{
    return(x - t1) / (t2 - t1) * (s2 - s1) + s1;
}


#include "../../../../ShaderLibrary/VertexAnimation.hlsl"
#include "../../../../ShaderLibrary/GlobalFog.hlsl"