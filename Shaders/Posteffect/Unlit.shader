// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "Hidden/Renderfeature/Unlit"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }
        
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #pragma multi_compile_instancing
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
                return half4(1.0.xxx, 1.0);
            }
            ENDHLSL
            
        }
    }
}

