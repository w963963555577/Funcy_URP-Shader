Shader "ZDShader/UI/TextureMask"
{
    Properties
    {
        [PerRendererData]_MainTex ("Base (RGB)", 2D) = "white" { }
        _MaskTex ("Base (RGB)", 2D) = "white" { }
        [HDR]_Color ("Tint", Color) = (1, 1, 1, 1)
        
        
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
                float4 uv: TEXCOORD0;
                float4 uv1: TEXCOORD1;
                float4 uv2: TEXCOORD2;
                float4 uv3: TEXCOORD3;
                float4 worldPosition: TEXCOORD4;
                float4 color: COLOR;
                float4 vertex: SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            sampler2D _MainTex;
            sampler2D _MaskTex;
            uniform fixed4 _Color;
            uniform fixed4 _FlowColor;
            uniform fixed4 _TextureSampleAdd;
            uniform float4 _ClipRect;
            float4 _MainTex_ST;
            float4 _MaskTex_ST;
            
            
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv.xy, _MaskTex);
                o.uv1 = half4(v.uv1, 0.0.xx);
                o.uv2 = half4(v.uv2, 0.0.xx);
                o.uv3 = half4(v.uv3, 0.0.xx);
                
                
                
                o.worldPosition = v.vertex;
                o.vertex = UnityObjectToClipPos(o.worldPosition);
                
                o.color = v.color * _Color;
                return o;
            }
            
            
            
            fixed4 frag(v2f i): SV_Target
            {
                half4 col = (tex2D(_MainTex, i.uv.xy) + _TextureSampleAdd);
                half4 mask = (tex2D(_MaskTex, i.uv.zw) + _TextureSampleAdd);
                col *= i.color;
                col.a *= mask.r;
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