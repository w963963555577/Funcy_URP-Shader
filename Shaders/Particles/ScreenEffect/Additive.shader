Shader "ZDShader/URP/Particles/ScreenEffect/Additive"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" { }
        
        _Color ("Tint", Color) = (1, 1, 1, 1)
        
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        
        _ColorMask ("Color Mask", Float) = 15
        
        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }
        
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
        
        
        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha One
        ColorMask [_ColorMask]
        
        Pass
        {
            Name "StandardLit"
            Tags { "LightMode" = "UniversalForward" }
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                float4 texcoord1: TEXCOORD1;
                float4 color: COLOR;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 texcoord1: TEXCOORD1;
                float4 color: COLOR;
                float4 vertex: SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            TEXTURE2D(_MainTex);                 SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
            half4 _MainTex_ST;
            half4 _MainTex_TexelSize;
            half4 _Color;
            CBUFFER_END
            
            
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                float2 uvRemapped = v.uv;
                uvRemapped.y = 1. - uvRemapped.y;
                uvRemapped = uvRemapped * 2. - 1.;
                
                o.vertex = float4(uvRemapped, 1.0, 1.0);
                o.uv = v.uv;
                o.texcoord1 = v.texcoord1;
                o.color = v.color * _Color;
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * i.color;
                
                
                return color;
            }
            ENDHLSL
            
        }
    }
}