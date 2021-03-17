Shader "ZDShader/UI/ShapeMask"
{
    Properties
    {
        [PerRendererData]_MainTex ("Base (RGB)", 2D) = "white" { }
        [HDR]_Color ("Tint", Color) = (1, 1, 1, 1)
        
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
                float2 uv1: TEXCOORD1;
                float4 color: COLOR;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float2 uv1: TEXCOORD1;
                float4 worldPosition: TEXCOORD4;
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
            
            
            half3 RGB2HSV(half3 c)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
                
                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }
            
            half3 HSV2RGB(half3 c)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.worldPosition = v.vertex;
                o.vertex = UnityObjectToClipPos(o.worldPosition);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv1 = v.uv1;
                o.color = v.color * _Color;
                return o;
            }
            
            float Remap(float value, float from1, float to1, float from2, float to2)
            {
                return(value - from1) / (to1 - from1) * (to2 - from2) + from2;
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
                
                //properties
                half skillTime_fillAmount = saturate(i.uv1.x);
                half skill_doingAmount = Remap(i.uv1.y, 0.0, 1.0, -0.34, 1.0) ;
                
                
                
                half2 centerUV = (i.uv - 0.5.xx) * 2.0;
                half sphereMask = length(centerUV);
                
                half alphaFade = smoothstep(_MaskClip - _EdgeLength, _MaskClip, 1.0 - sphereMask);
                half alphaHard = smoothstep(_MaskClip - _EdgeLength * 0.5, _MaskClip, 1.0 - sphereMask);
                half edge = saturate((alphaFade - alphaHard) * 2.0);
                col.a *= alphaFade * i.color.a;
                col.rgb = lerp(col.rgb, i.color.rgb, edge);
                
                
                half3 col_bw = RGB2HSV(col.rgb);
                col_bw.g = 0.0;
                col_bw.b *= 0.5;
                col_bw = HSV2RGB(col_bw);
                half2 polarCoord = atan2(i.uv.x - 0.5, 1.0 - i.uv.y - 0.5);
                half circle_Mask = (atan2(i.uv.x - 0.5, 1.0 - i.uv.y - 0.5) * 0.3183098861928886 + 1.0) * 0.5;
                
                half AA_blur = min(1.0 - max(0.995, skillTime_fillAmount), skillTime_fillAmount);
                
                col.rgb = lerp(col.rgb, col_bw, 1.0 - smoothstep(skillTime_fillAmount - AA_blur, skillTime_fillAmount + AA_blur, circle_Mask));
                
                
                half wave = min((1.0 + sin(sphereMask * 18.0 - skill_doingAmount * 18.0)) * 0.5, smoothstep(skill_doingAmount - 0.01, skill_doingAmount + 0.01, sphereMask));
                wave *= 1.0 - smoothstep(skill_doingAmount + 0.2, skill_doingAmount + 0.25, sphereMask);
                col.rgb += wave * 0.8;
                
                return col;
            }
            ENDCG
            
        }
    }
}