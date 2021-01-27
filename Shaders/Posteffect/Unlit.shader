// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "Hidden/Renderfeature/Unlit"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        
        Pass
        {
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct VertexData
            {
                float4 positionOS: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct FragmentData
            {
                float2 uv: TEXCOORD0;
                float4 positionCS: SV_POSITION;
            };
            
            FragmentData vert(VertexData v)
            {
                FragmentData o = (FragmentData)0;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);

                o.uv = v.uv;
                
                return o;
            }

            half4 frag(FragmentData input): SV_Target
            {
                float2 uv = input.uv;                
                return 1.0;
            }
            ENDHLSL
            
        }
    }
}

