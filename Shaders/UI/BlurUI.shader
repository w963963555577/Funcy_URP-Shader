Shader "ZDShader/UI/Blur"
{
    Properties
    {
        [PerRendererData]_MainTex ("Base (RGB)", 2D) = "white" { }
        _Color ("Tint", Color) = (1, 1, 1, 1)
        _Offset ("Offset", Range(0, 0.5)) = 0.1
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
                float4 blurUV1: TEXCOORD2;
                float4 blurUV2: TEXCOORD3;
                float4 blurUV3: TEXCOORD4;
                float4 blurUV4: TEXCOORD5;
                float4 color: COLOR;
                float4 vertex: SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            sampler2D _MainTex;
            fixed4 _Color;
            fixed _Offset;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            
            
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.worldPosition = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.blurUV1.xy = o.uv + _Offset.xx * 0.0629412;
                o.blurUV1.zw = o.uv - _Offset.xx * 0.0629412;
                o.blurUV2.xy = o.uv + _Offset.xx * 0.1407333;
                o.blurUV2.zw = o.uv - _Offset.xx * 0.1407333;
                o.blurUV3.xy = o.uv + _Offset.xx * 0.2298176;
                o.blurUV3.zw = o.uv - _Offset.xx * 0.2298176;
                o.blurUV4.xy = o.uv + _Offset.xx * 0.3294215;
                o.blurUV4.zw = o.uv - _Offset.xx * 0.3294215;
                
                o.worldPosition.xy += (v.uv - 0.5) * 1.41414 * _Offset.xx * 0.3294215;
                
                o.vertex = UnityObjectToClipPos(o.worldPosition);
                
                o.color = v.color * _Color;
                
                
                return o;
            }
            fixed4 frag(v2f i): SV_Target
            {
                half4 col = (tex2D(_MainTex, i.uv) + _TextureSampleAdd);
                col *= 0.201341;
                col += (tex2D(_MainTex, i.blurUV1.xy) + _TextureSampleAdd) * 0.223659;
                col += (tex2D(_MainTex, i.blurUV1.zw) + _TextureSampleAdd) * 0.223659;
                col += (tex2D(_MainTex, i.blurUV2.xy) + _TextureSampleAdd) * 0.116383;
                col += (tex2D(_MainTex, i.blurUV2.zw) + _TextureSampleAdd) * 0.116383;
                col += (tex2D(_MainTex, i.blurUV3.xy) + _TextureSampleAdd) * 0.043617;
                col += (tex2D(_MainTex, i.blurUV3.zw) + _TextureSampleAdd) * 0.043617;
                col += (tex2D(_MainTex, i.blurUV4.xy) + _TextureSampleAdd) * 0.015;
                col += (tex2D(_MainTex, i.blurUV4.zw) + _TextureSampleAdd) * 0.015;
                
                col *= i.color;
                
                #ifdef UNITY_UI_CLIP_RECT
                    col.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
                #endif
                
                #ifdef UNITY_UI_ALPHACLIP
                    clip(col.a - 0.001);
                #endif
                
                return col;
            }
            ENDCG
            
        }
    }
}