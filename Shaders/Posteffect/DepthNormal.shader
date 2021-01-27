Shader "Hidden/Renderfeature/DepthNormal"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass
        {
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            #define COMPUTE_DEPTH_01 - (mul(UNITY_MATRIX_V, mul(GetObjectToWorldMatrix(), float4(v.positionOS.xyz, 1.0))).z * _ProjectionParams.w)
            #define COMPUTE_VIEW_NORMAL normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normalOS))
            
            struct VertexData
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
                float2 uv: TEXCOORD0;
            };
            
            struct FragmentData
            {
                float4 nz: TEXCOORD0;
                float4 positionCS: SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            
            float2 EncodeViewNormalStereo(float3 n)
            {
                float kScale = 1.7777;
                float2 enc;
                enc = n.xy / (n.z + 1);
                enc /= kScale;
                enc = enc * 0.5 + 0.5;
                return enc;
            }
            
            float2 EncodeFloatRG(float v)
            {
                float2 kEncodeMul = float2(1.0, 255.0);
                float kEncodeBit = 1.0 / 255.0;
                float2 enc = kEncodeMul * v;
                enc = frac(enc);
                enc.x -= enc.y * kEncodeBit;
                return enc;
            }
            float4 EncodeDepthNormal(float depth, float3 normal)
            {
                float4 enc;
                enc.xy = EncodeViewNormalStereo(normal);
                enc.zw = EncodeFloatRG(depth);
                return enc;
            }
            
            FragmentData vert(VertexData v)
            {
                FragmentData o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.nz.xyz = COMPUTE_VIEW_NORMAL;
                o.nz.w = COMPUTE_DEPTH_01;
                return o;
            }
            half4 frag(FragmentData i): SV_Target
            {
                return EncodeDepthNormal(i.nz.w, i.nz.xyz);
            }
            ENDHLSL
            
        }
    }
}