Shader "Hidden/URP/Brush_WroldToUVPoint"
{
    Properties
    {
        _BrushHardness ("Brush Hardness", Range(0, 1)) = 0.5
        _BrushSize ("Brush Size", Range(0, 100)) = 50
    }

    SubShader
    {
        // =====================================================================================================================
        // TAGS AND SETUP ------------------------------------------
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue"="Overlay" "IgnoreProjector" = "True" }
        LOD 300
        
        ZTest  Always
        ZWrite Off
        Cull   Off

        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            HLSLPROGRAM
            
            #pragma vertex   vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS: POSITION;
                float2 uv: TEXCOORD0;
                float2 uvLM: TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv: TEXCOORD0;
                float2 uvLM: TEXCOORD1;
                float3 positionWS: TEXCOORD2;
                float4 positionOS: TEXCOORD3;
                float4 positionCS: SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float4 _Point;
            float4x4 mesh_Object2World;
            float _BrushHardness;
            float _BrushSize;

            // =====================================================================================================================
            // VERTEX FRAGMENT ----------------------------------

            
            float Remap(float value, float from1, float to1, float from2, float to2)
            {
                return(value - from1) / (to1 - from1) * (to2 - from2) + from2;
            }

            Varyings vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionOS = input.positionOS;
                // VertexPositionInputs contains position in multiple spaces (world, view, homogeneous clip space)
                // Our compiler will strip all unused references (say you don't use view space).
                // Therefore there is more flexibility at no additional cost with this struct.
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionWS = vertexInput.positionWS;
                // TRANSFORM_TEX is the same as the old shader library.
                output.uvLM = input.uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                
                
                float2 uvRemapped = input.uv;
                
                uvRemapped.y = 1. - uvRemapped.y;
                uvRemapped = uvRemapped * 2. - 1.;
                

                output.positionCS = float4(uvRemapped.xy, 0.0, 1.0);
                output.positionWS = mul(mesh_Object2World, input.positionOS);
                output.uv = input.uv;
                

                return output;
            }

            float4 frag(Varyings input): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float size = Remap(_BrushSize, 0.0, 100.0, 0.0, 1.0);
                float soft = _BrushHardness;
                float f = saturate(distance(_Point.xyz, input.positionWS));
                f = 1.0 - smoothstep(0.0, size, f);
                f = saturate(f * Remap(_BrushHardness, 0, 1, 1, 10));
                return float4(float3(1, 1, 1), f.r);
            }
            
            ENDHLSL
            
        }
    }
    CustomEditor "UnityEditor.Rendering.Funcy.URP.ShaderGUI.Brush_WroldToUVPoint"
}
