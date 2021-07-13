// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "DepthTransparent"
{
    SubShader
    {
        Tags { "RenderType" = "Transparent" }
        
        Cull Off
        ZWrite Off
        ZTest Off
        Blend Off

        Pass
        {
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #define REQUIRE_DEPTH_TEXTURE 1

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            struct a2v
            {
                float4 vertex: POSITION;
                float2 texcoord: TEXCOORD0;
            };
            struct v2f
            {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
            };

            
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = v.texcoord;
                return o;
            }            
            
            half4 frag(v2f i): SV_Target
            {
                return half4((SHADERGRAPH_SAMPLE_SCENE_DEPTH(i.uv)).xxx, 1.0);
            }
            ENDHLSL
            
        }
    }
}