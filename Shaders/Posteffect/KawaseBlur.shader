Shader "Hidden/Renderfeature/KawaseBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }        
    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        
        LOD 100
        Pass
        {
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
            };
            float _offset;
            
            TEXTURE2D(_MainTex);        SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_TexelSize;
            float4 _MainTex_ST;
            
            CBUFFER_END
            
            v2f vert(appdata v)
            {
                v2f o = (v2f)0;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            half4 frag(v2f input): SV_Target
            {
                float2 res = _MainTex_TexelSize.xy;
                float i = _offset;
                
                half4 col;
                col.rgb = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv).rgb;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv + float2(i, i) * res).rgb;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv + float2(i, -i) * res).rgb;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv + float2(-i, i) * res).rgb;
                col.rgb += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv + float2(-i, -i) * res).rgb;
                col.rgb /= 5.0f;
                
                return col;
            }
            ENDHLSL
            
        }
    }
}
