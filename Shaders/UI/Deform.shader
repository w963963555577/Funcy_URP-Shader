﻿Shader "ZDShader/UI/Deform"
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
        
        
        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
        [Toggle(_DEFORM_VERTICES_SUPPORT)] _DEFORM_VERTICES_SUPPORT ("Deform Vertices Support", Float) = 1
        [Toggle(_ROTATE_UV_SUPPORT)] _ROTATE_UV_SUPPORT ("Rotate UV Support", Float) = 0
    }
    
    SubShader
    {
        LOD 0
        
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }
        
        Stencil
        {
            Ref [_Stencil]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
            CompFront [_StencilComp]
            PassFront [_StencilOp]
            FailFront Keep
            ZFailFront Keep
            CompBack Always
            PassBack Keep
            FailBack Keep
            ZFailBack Keep
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
            
            #pragma shader_feature_local _DEFORM_VERTICES_SUPPORT
            #pragma shader_feature_local _ROTATE_UV_SUPPORT
            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP
            
            #include "UnityShaderVariables.cginc"
            
            #define PI 3.1415926535
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                float2 uv1: TEXCOORD1;
                float2 uv2: TEXCOORD2;
                float2 uv3: TEXCOORD3;
                float4 color: COLOR;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 uv1: TEXCOORD1;
                float4 uv2: TEXCOORD2;
                float4 uv3: TEXCOORD3;
                float4 worldPosition: TEXCOORD4;
                float4 color: COLOR;
                float4 vertex: SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            sampler2D _MainTex;
            uniform fixed4 _Color;
            uniform fixed4 _FlowColor;
            uniform fixed4 _TextureSampleAdd;
            uniform float4 _ClipRect;
            float4 _MainTex_ST;
            
            float2 GetTypeDeform(half2 rect, half intensity, half deformType)
            {
                float m1 = rect.y;
                float m2 = rect.x;
                
                float mask = lerp(m1, m2, min(deformType, 1.0));
                
                
                float2 t1 = float2(mask, 0.0);
                float2 t2 = float2(0.0, mask);
                
                
                return lerp(t1, t2, min(deformType, 1.0)) * intensity;
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv1 = half4(v.uv1, 0.0.xx);
                o.uv2 = half4(1.0 / v.uv2, v.uv2);
                o.uv3 = half4(v.uv3, 0.0.xx);
                
                o.uv1.zw = o.uv1.xy - o.uv2.zw * 0.5;   //rect max
                o.uv3.zw = o.uv1.xy + o.uv2.zw * 0.5;   //rect min
                
                half deformType = o.uv3.y;
                
                half4 sizeDelta = o.uv2;
                half2 anchoredPosition = o.uv1.xy;
                
                half2 pos = (v.vertex.xy - anchoredPosition.xy);
                half2 rect = pos * 2.0 * sizeDelta.xy;
                #if _DEFORM_VERTICES_SUPPORT
                    v.vertex.xy += GetTypeDeform(rect, o.uv3.x, deformType) * lerp(1.0.xx, smoothstep(0.0, 1.0, 1.0 - abs((rect.y + 1.0) * 0.5)), saturate(v.uv3.y - 1.0));
                #endif
                o.worldPosition = v.vertex;
                o.vertex = UnityObjectToClipPos(o.worldPosition);
                
                o.color = v.color * _Color;
                return o;
            }
            
            float2 rotate2D(float2 uv, half2 pivot, half angle)
            {
                float c = cos(angle);
                float s = sin(angle);
                return mul(uv - pivot, float2x2(c, -s, s, c)) + pivot;
            }
            
            fixed4 frag(v2f i): SV_Target
            {
                #if _ROTATE_UV_SUPPORT
                    i.uv = rotate2D(i.uv, 0.5.xx, -i.uv1.x * PI);
                #endif
                half4 col = (tex2D(_MainTex, i.uv) + _TextureSampleAdd);
                col *= i.color;
                
                #ifdef UNITY_UI_CLIP_RECT
                    col.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
                #endif
                
                #ifdef UNITY_UI_ALPHACLIP
                    clip(col.a - 0.001);
                #endif
                
                half2 anchoredPosition = i.uv1.xy;
                half2 rMin = i.uv1.zw;
                half2 rMax = i.uv3.zw;
                half4 sizeDelta = i.uv2;
                
                half2 pos = (i.worldPosition.xy - anchoredPosition.xy);
                half2 rect = pos * 2.0 * sizeDelta.xy;
                
                
                return col;
            }
            ENDCG
            
        }
    }
}