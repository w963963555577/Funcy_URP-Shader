CBUFFER_START(UnityPerMaterial)
half4 _PositionMask_ST;
half4 _BaseMap_ST;
half4 _BlendColor_SelfShadow;
half4 _BlendColor_Dark;
half4 _BlendColor_Mid;
half4 _BlendColor_Light;
half4 _SpecColor;
half _Speed;
half _Amount;
half _Distance;

half _LambertOffset;
half _ClipThreshod;
half _SpecularOffset;
half _ViewRendererMode;
#ifdef _DrawMeshInstancedProcedural
    StructuredBuffer<half4x4> _ObjectToWorldBuffer;
    StructuredBuffer<half4x4> _WorldToObjectBuffer;
    StructuredBuffer<uint> _VisibleInstanceOnlyTransformIDBuffer;
#endif
CBUFFER_END


half2 remap(half2 x, half2 t1, half2 t2, half2 s1, half2 s2)
{
    return(x - t1) / (t2 - t1) * (s2 - s1) + s1;
}


#include "../../../../ShaderLibrary/VertexAnimation.hlsl"
#include "../../../../ShaderLibrary/GlobalFog.hlsl"