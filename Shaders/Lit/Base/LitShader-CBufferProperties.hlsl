CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
half4 _BaseColor;
half4 _SpecColor;
half4 _EmissionColor;
half _Cutoff;
half _Smoothness;
half _Metallic;
half _BumpScale;
half _OcclusionStrength;
half _SSPREnabled;
half _FlowEmissionEnabled;
half4 _PositionMask_ST;
half _WindEnabled;
half _Speed;
half _Amount;
half _Distance;
#ifdef _DrawMeshInstancedProcedural
    StructuredBuffer<float4x4> _ObjectToWorldBuffer;
    StructuredBuffer<float4x4> _WorldToObjectBuffer;
    StructuredBuffer<uint> _VisibleInstanceOnlyTransformIDBuffer;
#endif
CBUFFER_END

#include "../../../ShaderLibrary/VertexAnimation.hlsl"
#include "../../../ShaderLibrary/GlobalFog.hlsl"