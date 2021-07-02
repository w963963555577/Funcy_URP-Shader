Shader "ZDShader/UI/Effect/FlowEdge"
{
    Properties
    {
        [PerRendererData]_MainTex ("Base (RGB)", 2D) = "white" { }
        [HDR]_Color ("Tint", Color) = (1, 1, 1, 1)
        [HDR]_FlowColor ("Flow Color", Color) = (1, 1, 1, 1)

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

            
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.worldPosition = v.vertex;
                o.vertex = UnityObjectToClipPos(o.worldPosition);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv1 = half4(v.uv1, 0.0.xx);
                o.uv2 = half4(1.0 / v.uv2, v.uv2);
                o.uv3 = half4(v.uv3, 0.0.xx);
                
                o.uv1.zw = o.uv1.xy - o.uv2.zw * 0.5;   //rect max
                o.uv3.zw = o.uv1.xy + o.uv2.zw * 0.5;   //rect min

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


                float currTime = _Time.y * i.uv3.y;
                
                float2 rotator = rotate2D(rect, 0.0.xx, currTime);
                float2 _v2Step = float2(-0.02, 0.02);
                float2 splitTo4Rect = smoothstep(_v2Step.xx, _v2Step.yy, rotator);
                half boxMask = max((splitTo4Rect.x * splitTo4Rect.y), (1.0 - max(splitTo4Rect.x, splitTo4Rect.y)));
                half rotationMask = (((1.0 - abs((rotator * float2(2, 2))))).x);
                rotationMask = smoothstep(-1.0, 1.0, rotationMask) * boxMask;
                
                col.rgb += rotationMask * 0.5 * _FlowColor.rgb * i.uv3.x;

                return col;
            }
            ENDCG
            
        }
    }
    CustomEditor "ASEMaterialInspector"
}