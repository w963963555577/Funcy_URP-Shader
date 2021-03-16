Shader "ZDShader/UI/ShapeMask"
{
    Properties
    {
        [PerRendererData]_MainTex ("Base (RGB)", 2D) = "white" { }
        _Color ("Tint", Color) = (1, 1, 1, 1)
        
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        
        _ColorMask ("Color Mask", Float) = 15
        
        _MaskClip ("_Mask Clip", Range(0.0, 1.0)) = 0.01
        _EdgeLength ("Edge Length", Range(0.0, 1.0)) = 0.0
        
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
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]
        
        Pass
        {
            Name "Default"
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            
            #include "UnityCG.cginc"
            #include "UnityUI.cginc"
            
            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                float4 color: COLOR;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 worldPosition: TEXCOORD1;
                float4 color: COLOR;
                float4 vertex: SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            
            fixed _EdgeLength;
            fixed _MaskClip;
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.worldPosition = v.vertex;
                o.vertex = UnityObjectToClipPos(o.worldPosition);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color * _Color;
                return o;
            }
            fixed4 frag(v2f i): SV_Target
            {
                half4 col = (tex2D(_MainTex, i.uv) + _TextureSampleAdd);
                //col *= i.color;
                
                #ifdef UNITY_UI_CLIP_RECT
                    col.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
                #endif
                
                #ifdef UNITY_UI_ALPHACLIP
                    clip(col.a - 0.001);
                #endif
                
                half sphereMask = 1.0 - length((i.uv - 0.5.xx) * 2.0);
                half alphaFade = smoothstep(_MaskClip - _EdgeLength, _MaskClip, sphereMask);
                half alphaHard = smoothstep(_MaskClip - _EdgeLength * 0.5, _MaskClip, sphereMask);
                half edge = saturate((alphaFade - alphaHard) * 2.0);
                col.a *= alphaFade * i.color.a;
                col.rgb = lerp(col.rgb, i.color.rgb, edge);
                return col;
            }
            ENDCG
            
        }
    }
}