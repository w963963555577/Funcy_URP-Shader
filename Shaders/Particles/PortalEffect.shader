Shader "ZDShader/URP/Particles/PortalEffect"
{
    Properties
    {
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
            
            
            half4 _Color;
            
            
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
            float variation(half2 v1, half2 v2, float strength, float speed)
            {
                return sin(dot(normalize(v1), normalize(v2)) * strength + _Time.y * speed) * .01;
            }
            
            half3 paintCircle(half2 uv, half2 center, float rad, float width, float speed, float mIndex)
            {
                half2 diff = center - uv;
                float len = length(diff);
                float scale = rad;
                float mult = (fmod(mIndex, 2.0) - 0.5) * 2.0;
                len += variation(diff, half2(rad * mult, 1.0), 7.0 * scale, speed);
                len -= variation(diff, half2(1.0, rad * mult), 7.0 * scale, speed);
                float circle = smoothstep((rad - width) * scale, (rad) * scale, len) - smoothstep((rad) * scale, (rad + width) * scale, len);
                return circle.xxx;
            }
            
            half4 frag(v2f i): SV_Target
            {
                half3 color = 0.0;
                half2 uv = i.uv;
                
                const half2 center = 0.5.xx;
                const float spacing = 1.;
                const float slow = 0.1;
                const float cycleDur = 1.;
                const float tunnelElongation = .25;
                
                float radius = i.texcoord1.x;
                float speed = i.texcoord1.y;
                float mIndex = i.texcoord1.z;
                
                //this provides the smooth fade black border, which we will mix in later
                float border = 0.25;
                half2 bl = smoothstep(0., border, uv); // bottom left
                half2 tr = smoothstep(0., border, 1. - uv); // top right
                float edges = bl.x * bl.y * tr.x * tr.y;
                
                
                //paint color circle
                color = paintCircle(uv, center, radius, 0.075, speed, mIndex);
                color += paintCircle(uv, center, radius, 0.015, speed, mIndex);
                
                color *= i.color;
                
                return float4(color, 1.0);
            }
            ENDHLSL
            
        }
    }
}