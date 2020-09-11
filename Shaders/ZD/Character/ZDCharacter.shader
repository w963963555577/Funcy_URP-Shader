Shader "ZDShader/LWRP/Character"
{
    Properties
    {
        _diffuse ("BaseColor", 2D) = "white" { }
        [HDR]_Color ("BaseColor", Color) = (1.0, 1.0, 1.0, 1)
        
        _EdgeLightWidth ("Edge Light Width", Range(0, 1)) = 1
        _EdgeLightIntensity ("Edge Light Intensity", Range(0, 1)) = 1
        
        _Flash ("Flash", Float) = 0
        _mask ("ESSGMask", 2D) = "(0,0.5,0,0)" { }
        _SelfMask ("Self Mask", 2D) = "black" { }
        [Toggle(_SelfMaskEnable)] _SelfMaskEnable ("Self Mask Enable", float) = 0
        
        [Enum(positiveZ positiveY, 0, positiveY negativeX, 1)]_SelfMaskDirection ("Self Mask Direction", Float) = 0
        
        [HDR]_EmissionColor ("EmissionColor", Color) = (0, 0, 0)
        [MaterialToggle] _EmissionxBase ("Emission x Base", Float) = 0
        [MaterialToggle] _EmissionOn ("EmissionOn", Float) = 0
        
        _Gloss ("Gloss (texture=1)", Range(0, 1)) = 0.5
        [HDR]_SpecularColor ("SpecularColor", Color) = (0.6176471, 0.6145149, 0.5722318, 1)
        _ShadowRamp ("Shadow Ramp", Range(0, 1)) = 1
        _SelfShadowRamp ("Self Shadow Ramp", Range(0, 1)) = 0.8
        _Picker_0 ("Picker_0", Color) = (0.9686275, 0.8039216, 0.7882354, 1)
        _Picker_1 ("Picker_1", Color) = (0.5764706, 0.6235294, 0.8705883, 1)
        _ShadowColor0 ("ShadowColor0", Color) = (1, 0.7344488, 0.514151, 1)
        _ShadowColor1 ("ShadowColor1", Color) = (0.3160377, 0.4365495, 1, 1)
        _ShadowColorElse ("ShadowColorElse", Color) = (0.5471698, 0.5471698, 0.5471698, 1)
        
        [Toggle(_OutlineEnable)] _OutlineEnable ("Enable Outline", float) = 1
        
        _OutlineWidthControl ("Outline Width Control", 2D) = "white" { }
        
        // _DiscolorationSystem
        [Toggle(_DiscolorationSystem)] _DiscolorationSystem ("Enable Discoloration System", float) = 0
        _DiscolorationColorCount ("Use Color Count", Range(1, 10)) = 2
        [HDR]_DiscolorationColor_0 ("DiscolorationColor_0", Color) = (1, 1, 1, 1)
        [HDR]_DiscolorationColor_1 ("DiscolorationColor_1", Color) = (1, 1, 1, 1)
        [HDR]_DiscolorationColor_2 ("DiscolorationColor_2", Color) = (1, 1, 1, 1)
        [HDR]_DiscolorationColor_3 ("DiscolorationColor_3", Color) = (1, 1, 1, 1)
        [HDR]_DiscolorationColor_4 ("DiscolorationColor_4", Color) = (1, 1, 1, 1)
        [HDR]_DiscolorationColor_5 ("DiscolorationColor_5", Color) = (1, 1, 1, 1)
        [HDR]_DiscolorationColor_6 ("DiscolorationColor_6", Color) = (1, 1, 1, 1)
        [HDR]_DiscolorationColor_7 ("DiscolorationColor_7", Color) = (1, 1, 1, 1)
        [HDR]_DiscolorationColor_8 ("DiscolorationColor_8", Color) = (1, 1, 1, 1)
        [HDR]_DiscolorationColor_9 ("DiscolorationColor_9", Color) = (1, 1, 1, 1)
        
        // Blending state
        [HideInInspector] _Surface ("__surface", Float) = 0.0
        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip ("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [Enum(Off, 0, On, 1)]  _ZWrite ("ZWrite", Float) = 1.0
        [Enum(UnityEngine.Rendering.CompareFunction)]  _ZTest ("ZTest", Float) = 4
        
        [HideInInspector] _Cull ("__cull", Float) = 2.0
        
        // Editmode props
        [HideInInspector] _QueueOffset ("Queue offset", Float) = 0.0
        [Toggle]_ReceiveShadow ("Receive Shadow", Float) = 1.0
        
        
        [Toggle(_CustomLighting)]_CustomLighting ("Custom Lighting", Float) = 1.0
        _CustomLightIntensity ("Custom Light Intensity", Float) = 1.0
        _CustomLightColor ("Custom Light Color", Color) = (1, 1, 1, 1)
        
        _ShadowRefraction ("Shadow Refraction", Range(0, 10)) = 1
        _ShadowOffset ("Shadow Offset", Range(0, 1)) = 0.6
        
        
        _OutlineColor ("Color", Color) = (0.0075, 0.0006, 0.0006, 1)
        _DiffuseBlend ("Diffuse Blend", Range(0, 1)) = 0.2
        _OutlineWidth_MinWidth_MaxWidth_Dist_DistBlur ("Outline Ctrl Properties", Vector) = (0.0, 0.5, 0.5, 0.0)
        
        
        //Expression
        [Toggle(_ExpressionEnable)] _ExpressionEnable ("Enable Expression", float) = 0
        [NoScaleOffset]_ExpressionMap ("Map", 2D) = "white" { }
        
        [Toggle(_ExpressionFormat_Wink)] _ExpressionFormat_Wink ("Wink", float) = 0
        [Toggle(_ExpressionFormat_FaceSheet)] _ExpressionFormat_FaceSheet ("FaceSheet", float) = 1
        
        /*[IntRange]*/_SelectBrow ("Select Brow", Range(1, 4)) = 1
        _BrowRect ("Brow UV Rect", Vector) = (0, 0.45, 0.855, 0.3)
        [IntRange]_SelectFace ("Select Face", Range(1, 8)) = 1
        _FaceRect ("Eyes UV Rect", Vector) = (0, -0.02, 0.855, 0.37)
        [IntRange]_SelectMouth ("Select Mouth ", Range(1, 8)) = 1
        _MouthRect ("Mouth UV Rect", Vector) = (0, -0.97, 0.427, 0.28)
    }
    
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry+2" "IgnoreProjector" = "True" }
        
        Pass
        {
            Name "Outline"
            
            Stencil
            {
                Ref 128
                Comp GEqual
            }
            
            ZWrite On
            ZTest LEqual
            Cull Front
            Blend Off
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma shader_feature_local _OutlineEnable
            
            #pragma target 3.0
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float3 color: COLOR0;
                float2 uv: TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float2 uv: TEXCOORD0;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            sampler2D _diffuse;
            sampler2D _OutlineWidthControl;
            sampler2D _ExpressionMap;
            
            CBUFFER_START(UnityPerMaterial)
            half4 _diffuse_ST;
            half4 _SelfMask_ST;
            half _SelfMaskDirection;
            
            half4 _mask_ST;
            half4 _Color;
            half4 _EmissionColor;
            half4 _SpecularColor;
            half4 _Picker_0;
            half4 _Picker_1;
            half4 _ShadowColor0;
            half4 _ShadowColor1;
            half4 _ShadowColorElse;
            half _Cutoff;
            half _Gloss;
            half _EmissionxBase;
            half _EmissionOn;
            half _Flash;
            half _EdgeLightWidth;
            half _EdgeLightIntensity;
            half _NormalScale;
            half _ShadowRamp;
            half _SelfShadowRamp;
            half _ReceiveShadow;
            half _ShadowRefraction;
            half _ShadowOffset;
            
            half4 _CustomLightColor;
            half4 _CustomLightDirection;
            half _CustomLightIntensity;
            
            float4 _DiscolorationColor_0;
            float4 _DiscolorationColor_1;
            float4 _DiscolorationColor_2;
            float4 _DiscolorationColor_3;
            float4 _DiscolorationColor_4;
            float4 _DiscolorationColor_5;
            float4 _DiscolorationColor_6;
            float4 _DiscolorationColor_7;
            float4 _DiscolorationColor_8;
            float4 _DiscolorationColor_9;
            
            float4 _OutlineColor;
            float _DiffuseBlend;
            
            half4 _OutlineWidth_MinWidth_MaxWidth_Dist_DistBlur;
            
            float _SelectMouth;
            float _SelectFace;
            float _SelectBrow;
            
            half4 _BrowRect;
            half4 _FaceRect;
            half4 _MouthRect;
            CBUFFER_END
            
            
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                half RTD_OL_OLWABVD_OO = 1.0;
                half4 _OutlineWidthControl_var = tex2Dlod(_OutlineWidthControl, float4(v.uv, 0.0, 0));
                
                half2 RTD_OL_DNOL_OO = v.uv;
                half2 node_8743 = RTD_OL_DNOL_OO;
                float2 node_1283_skew = node_8743 + 0.2127 + node_8743.x * 0.3713 * node_8743.y;
                float2 node_1283_rnd = 4.789 * sin(489.123 * (node_1283_skew));
                half node_1283 = frac(node_1283_rnd.x * node_1283_rnd.y * (1 + node_1283_skew.x));
                
                float3 _OEM = v.normal;
                
                half RTD_OL = (RTD_OL_OLWABVD_OO * 0.01) * lerp(1.0, node_1283, 0.8) * _OutlineWidthControl_var.r;
                
                half dist = distance(v.vertex.xyz, mul(GetWorldToObjectMatrix(), float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                half4 widthRange = _OutlineWidth_MinWidth_MaxWidth_Dist_DistBlur;
                
                RTD_OL *= (lerp(widthRange.x, widthRange.y, saturate(dist - 0.05) * widthRange.z));
                
                o.vertex = TransformObjectToHClip(float4(v.vertex.xyz + _OEM * RTD_OL, 1).xyz);
                o.uv = v.uv;
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                #if _OutlineEnable
                    
                #else
                    discard;
                #endif
                float4 _diffuse_var = tex2D(_diffuse, i.uv);
                half4 col = float4(_OutlineColor.rgb + _diffuse_var.rgb * _DiffuseBlend, _OutlineColor.a);
                //half4 col = float4(0.05.rrr, 1.0);
                return col;
            }
            ENDHLSL
            
        }
        
        Pass
        {
            // "Lightmode" tag must be "LightweightForward" or not be defined in order for
            // to render objects.
            Name "StandardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            ZTest [_ZTest]
            Cull Back
            
            Stencil
            {
                Ref 128
                Comp Always
                Pass Replace
            }
            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            
            
            #pragma shader_feature_local _CustomLighting
            #pragma shader_feature_local _SelfMaskEnable
            #pragma shader_feature_local _DiscolorationSystem
            #pragma shader_feature_local _ExpressionEnable
            #if _ExpressionEnable
                #pragma shader_feature_local _ExpressionFormat_Wink
                #pragma shader_feature_local _ExpressionFormat_FaceSheet
            #endif
            #pragma multi_compile_fog
            
            
            #pragma multi_compile_instancing
            
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            
            sampler2D _diffuse;
            CBUFFER_START(UnityPerMaterial)
            half4 _diffuse_ST;
            half4 _SelfMask_ST;
            half _SelfMaskDirection;
            
            half4 _mask_ST;
            half4 _Color;
            half4 _EmissionColor;
            half4 _SpecularColor;
            half4 _Picker_0;
            half4 _Picker_1;
            half4 _ShadowColor0;
            half4 _ShadowColor1;
            half4 _ShadowColorElse;
            half _Cutoff;
            half _Gloss;
            half _EmissionxBase;
            half _EmissionOn;
            half _Flash;
            half _EdgeLightWidth;
            half _EdgeLightIntensity;
            half _NormalScale;
            half _ShadowRamp;
            half _SelfShadowRamp;
            half _ReceiveShadow;
            half _ShadowRefraction;
            half _ShadowOffset;
            
            half4 _CustomLightColor;
            half4 _CustomLightDirection;
            half _CustomLightIntensity;
            
            float4 _DiscolorationColor_0;
            float4 _DiscolorationColor_1;
            float4 _DiscolorationColor_2;
            float4 _DiscolorationColor_3;
            float4 _DiscolorationColor_4;
            float4 _DiscolorationColor_5;
            float4 _DiscolorationColor_6;
            float4 _DiscolorationColor_7;
            float4 _DiscolorationColor_8;
            float4 _DiscolorationColor_9;
            
            float4 _OutlineColor;
            float _DiffuseBlend;
            
            half4 _OutlineWidth_MinWidth_MaxWidth_Dist_DistBlur;
            
            float _SelectMouth;
            float _SelectFace;
            float _SelectBrow;
            
            half4 _BrowRect;
            half4 _FaceRect;
            half4 _MouthRect;
            CBUFFER_END
            
            
            TEXTURE2D(_mask);                       SAMPLER(sampler_mask);
            TEXTURE2D(_NormalMap);                  SAMPLER(sampler_NormalMap);
            TEXTURE2D(_SelfMask);                   SAMPLER(sampler_SelfMask);
            TEXTURE2D(_ExpressionMap);              SAMPLER(sampler_ExpressionMap);
            
            struct Attributes
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
                float4 tangentOS: TANGENT;
                float2 uv0: TEXCOORD0;
                float2 uv1: TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct Varyings
            {
                float4 uv01: TEXCOORD0;
                float4 positionWSAndFogFactor: TEXCOORD2; // xyz: positionWS, w: vertex fog factor
                half3 normalWS: TEXCOORD3;
                
                
                #ifdef _SelfMaskEnable
                    float3 objectDirection: TEXCOORD4;
                    float3 lightXZDirection: TEXCOORD5;
                    float3 objectUp: TEXCOORD6;
                #endif
                
                float4 positionCS: SV_POSITION;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            Varyings LitPassVertex(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                // Computes fog factor per-vertex.
                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                
                // TRANSFORM_TEX is the same as the old shader library.
                output.uv01.xy = TRANSFORM_TEX(input.uv0, _diffuse);
                output.uv01.zw = input.uv1;
                
                output.positionWSAndFogFactor = float4(vertexInput.positionWS, fogFactor);
                output.normalWS = vertexNormalInput.normalWS;
                
                #ifdef _NORMALMAP
                    output.tangentWS = vertexNormalInput.tangentWS;
                    output.bitangentWS = vertexNormalInput.bitangentWS;
                #endif
                
                #if _SelfMaskEnable
                    Light mainLight = GetMainLight();
                    
                    half index = _SelfMaskDirection;
                    
                    half3 dirPZPY = half3(0, 0, 1);half3 upPZPY = half3(0, 1, 0);
                    half3 dirPYNX = half3(0, 1, 0);half3 upPYNX = half3(-1, 0, 0);
                    
                    half3 useDir = lerp(dirPZPY, dirPYNX, saturate(index));
                    half3 useUp = lerp(upPZPY, upPYNX, saturate(index));
                    
                    
                    output.objectDirection.xyz = mul(GetObjectToWorldMatrix(), float4(useDir.xyz, 0.0)).xyz;
                    output.objectDirection.y = 0;
                    output.objectUp.xyz = mul(GetObjectToWorldMatrix(), float4(useUp.xyz, 0.0)).xyz;
                    
                    output.lightXZDirection = normalize(float3(-mainLight.direction.x, 0.0, -mainLight.direction.z));
                #endif
                
                output.positionCS = vertexInput.positionCS;
                
                return output;
            }
            
            float Remap(float value, float from1, float to1, float from2, float to2)
            {
                return(value - from1) / (to1 - from1) * (to2 - from2) + from2;
            }
            
            #if _SelfMaskEnable
                float LigntMapAreaInUV1(Varyings i, float origShadow)
                {
                    float cm = normalize(cross(i.objectDirection, i.lightXZDirection)).y;
                    float4 _SelfMask_UV1_var = SAMPLE_TEXTURE2D(_SelfMask, sampler_SelfMask, float2(i.uv01.z * cm, i.uv01.w));
                    
                    float angle01 = acos(-dot(i.objectDirection, i.lightXZDirection)) / 3.14159265359h;
                    angle01 = Remap(angle01, 0, 1, 0.01, 0.99);
                    
                    half upNear = dot(i.objectUp, half3(0, 1, 0));
                    _SelfMask_UV1_var.r = lerp(origShadow, _SelfMask_UV1_var.r, upNear * 0.5 + 0.5);
                    
                    return 1.0 - smoothstep(_SelfMask_UV1_var.r - 0.01, _SelfMask_UV1_var.r + 0.01, angle01);
                }
            #endif
            
            #if _DiscolorationSystem
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
                
                void Step8Color(half gray, half2 eyeAreaReplace, half2 browReplace, half2 mouthReplace, out float4 color, out float blackArea, out float skinArea, out float eyeArea)
                {
                    float gray_oneminus = (1.0 - gray);
                    #if _ExpressionEnable
                        float eyeCenter = smoothstep(0.5, 1.0, eyeAreaReplace.x) * eyeAreaReplace.y;
                    #endif
                    float grayArea_9 = saturate((smoothstep(0.90, 1.00, gray) * 2.0));
                    float grayArea_8 = saturate((smoothstep(0.70, 0.80, gray) * 2.0));
                    float grayArea_7 = saturate((smoothstep(0.60, 0.70, gray) * 2.0));
                    float grayArea_6 = saturate((smoothstep(0.45, 0.60, gray) * 2.0));
                    float grayArea_5 = saturate((smoothstep(0.35, 0.45, gray) * 2.0));
                    float grayArea_4 = 1.00 - grayArea_5;
                    float grayArea_3 = saturate((smoothstep(0.70, 0.80, gray_oneminus) * 2.0));
                    float grayArea_2 = saturate((smoothstep(0.80, 0.90, gray_oneminus) * 2.0));
                    float grayArea_1 = saturate((smoothstep(0.90, 0.95, gray_oneminus) * 2.0));
                    
                    float grayArea_0 = saturate((smoothstep(0.95, 1.00, gray_oneminus) * 2.0));
                    #if _ExpressionEnable
                        grayArea_0 = max(grayArea_0, saturate(smoothstep(0.4, 0.5, eyeAreaReplace.x) * eyeAreaReplace.y - eyeCenter));
                        #if _ExpressionFormat_FaceSheet
                            grayArea_0 = max(grayArea_0, smoothstep(0.5, 1.0, browReplace.x) * browReplace.y);
                            grayArea_0 = max(grayArea_0, smoothstep(0.5, 1.0, mouthReplace.x) * mouthReplace.y);
                        #endif
                    #endif
                    
                    float fillArea_9 = grayArea_9;
                    float fillArea_8 = grayArea_8 - grayArea_9;
                    float fillArea_7 = grayArea_7 - grayArea_8;
                    float fillArea_6 = grayArea_6 - grayArea_7;
                    float fillArea_5 = grayArea_5 - grayArea_6;
                    float fillArea_4 = grayArea_4 - grayArea_3;
                    float fillArea_3 = grayArea_3 - grayArea_2;
                    #if _ExpressionEnable
                        float fillArea_2 = eyeCenter;
                        grayArea_1 = max(grayArea_1, grayArea_2) * (1.0 - eyeCenter);
                    #else
                        float fillArea_2 = grayArea_2 - grayArea_1;
                    #endif
                    
                    float fillArea_1 = grayArea_1 - grayArea_0;
                    
                    float fillArea_0 = grayArea_0;
                    
                    blackArea = fillArea_0;
                    skinArea = fillArea_1;
                    
                    eyeArea = fillArea_2;
                    color = _DiscolorationColor_8 * fillArea_8 + _DiscolorationColor_9 * fillArea_9 +
                    _DiscolorationColor_7 * fillArea_7 + _DiscolorationColor_6 * fillArea_6 +
                    _DiscolorationColor_5 * fillArea_5 + _DiscolorationColor_4 * fillArea_4 +
                    _DiscolorationColor_3 * fillArea_3 + _DiscolorationColor_2 * fillArea_2 +
                    _DiscolorationColor_1 * fillArea_1 + _DiscolorationColor_0 * fillArea_0
                    ;
                    
                    half hdr = max(max(color.r, color.g), color.b) ;
                    color.a = hdr - 1.0;
                }
            #endif
            
            #if _ExpressionEnable
                
                float2 GetBrowArea(float2 uv, float browCount, float selectBrow, half2 offsetScale)
                {
                    return float2(uv.x * offsetScale.x + 0.5, (uv.y * offsetScale.y + 0.5 - offsetScale.y * 0.5) + ((browCount - (selectBrow * 2.0 - 1.0)) / (browCount * 2.0)));
                }
                
                float2 GetEyesArea(float2 uv, float eyesCount, float selectFace, half2 offsetScale)
                {
                    return float2(uv.x * offsetScale.x, uv.y * offsetScale.y + ((eyesCount - (selectFace)) / eyesCount));
                }
                
                float2 GetMouthArea(float2 uv, float mouthCount, float selectMouth, half2 offsetScale)
                {
                    float pX = (uv.x * 0.5 + floor((selectMouth - 1.0) / 4.0) * 0.5 + 1.0) / 2.0;
                    float pY = (uv.y * 0.5 + (mouthCount - fmod(selectMouth - 1.0, 4.0) / 2.0) + 1.5) / (mouthCount / 2.0);
                    return float2(pX, pY);
                }
                
            #endif
            
            half4 LitPassFragment(Varyings i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                float4 shadowCoords = TransformWorldToShadowCoord(i.positionWSAndFogFactor.xyz);
                Light mainLight = GetMainLight(shadowCoords);
                
                mainLight.color = _CustomLightColor.rgb * _CustomLightIntensity;
                
                float4 _diffuse_var = tex2D(_diffuse, i.uv01.xy);
                
                float4 _SelfMask_UV0_var = SAMPLE_TEXTURE2D(_SelfMask, sampler_SelfMask, i.uv01.xy);
                half NdotL = dot(i.normalWS, mainLight.direction);
                half pbr = mainLight.distanceAttenuation * mainLight.shadowAttenuation ;
                
                #if _ExpressionEnable
                    
                    _SelectBrow = round(_SelectBrow);
                    _SelectFace = round(_SelectFace);
                    _SelectMouth = round(_SelectMouth);
                    
                    half maskBlur = 0.01;
                    #if _ExpressionFormat_FaceSheet
                        half4 _BrowTRS = half4(1.0 / _BrowRect.zw, -_BrowRect.xy);
                        half2 browOffset = half2(0.5, 1.0 / 8.0);
                        half2 browArea = GetBrowArea(i.uv01.zw, 8.0, _SelectBrow, browOffset);
                        half2 browPivot = GetBrowArea(half2(0.5, 0.5), 8.0,
                        _SelectBrow, browOffset);
                        half2 browUV = ((browArea - browPivot) * _BrowTRS.xy) + browPivot + half2(_BrowTRS.z * browOffset.x, _BrowTRS.w * browOffset.y);
                        half2 browMaskUV = (i.uv01.zw - half2(0.5, 0.5)) * _BrowTRS.xy + half2(0.5, 0.5) + _BrowTRS.zw;
                        half2 browMaskRect = abs(((browMaskUV - half2(0.5, 0.5)) * half2(2, 2)));
                        half browMask = 1.0 - (max(smoothstep(1.0 - maskBlur * _BrowTRS.x, 1.0, browMaskRect.x), smoothstep(0.5 - maskBlur * _BrowTRS.y, 0.5, browMaskRect.y)));
                        half4 Brow = SAMPLE_TEXTURE2D(_ExpressionMap, sampler_ExpressionMap, browUV);
                    #endif
                    
                    #if _ExpressionFormat_FaceSheet || _ExpressionFormat_Wink
                        half4 _EyesTRS = half4(1.0 / _FaceRect.zw, -_FaceRect.xy);
                        
                        #if _ExpressionFormat_FaceSheet
                            half2 eyeOffset = half2(0.5, 0.125);
                            half2 eyesArea = GetEyesArea(i.uv01.zw, 8.0, _SelectFace, eyeOffset);
                            half2 eyesPivot = GetEyesArea(half2(0.5, 0.5), 8.0, _SelectFace, eyeOffset);
                        #endif
                        #if _ExpressionFormat_Wink
                            half2 eyeOffset = half2(1.0, 0.5);
                            half2 eyesArea = GetEyesArea(i.uv01.zw, 2.0, _SelectFace, eyeOffset);
                            half2 eyesPivot = GetEyesArea(half2(0.5, 0.5), 2.0, _SelectFace, eyeOffset);
                        #endif
                        
                        half2 eyesUV = ((eyesArea - eyesPivot) * _EyesTRS.xy) + eyesPivot + half2(_EyesTRS.z * eyeOffset.x, _EyesTRS.w * eyeOffset.y);
                        half2 eyesMaskUV = (i.uv01.zw - half2(0.5, 0.5)) * _EyesTRS.xy + half2(0.5, 0.5) + _EyesTRS.zw;
                        half2 eyesMaskRect = abs(((eyesMaskUV - half2(0.5, 0.5)) * half2(2, 2)));
                        half eyesMask = 1.0 - (max(smoothstep(1.0 - maskBlur * _EyesTRS.x, 1.0, eyesMaskRect.x), smoothstep(1.0 - maskBlur * _EyesTRS.y, 1.0, eyesMaskRect.y)));
                        half4 Eyes = SAMPLE_TEXTURE2D(_ExpressionMap, sampler_ExpressionMap, eyesUV);
                    #endif
                    
                    #if _ExpressionFormat_FaceSheet
                        half4 _MouthsTRS = half4(1.0 / _MouthRect.zw, -_MouthRect.xy);
                        half2 mouthOffset = half2(0.25, 0.125);
                        half2 mouthArea = GetMouthArea(i.uv01.zw, 8.0, _SelectMouth, mouthOffset);
                        half2 mouthPivot = GetMouthArea(half2(0.5, 0.5), 8.0, _SelectMouth, mouthOffset);
                        half2 mouthUV = ((mouthArea - mouthPivot) * _MouthsTRS.xy) + mouthPivot + half2(_MouthsTRS.z * mouthOffset.x, _MouthsTRS.w * mouthOffset.y);
                        half2 mouthMaskUV = (i.uv01.zw - half2(0.5, 0.5)) * _MouthsTRS.xy + half2(0.5, 0.5) + _MouthsTRS.zw;
                        half2 mouthMaskRect = abs(((mouthMaskUV - half2(0.5, 0.5)) * half2(2, 2)));
                        half mouthMask = 1.0 - (max(smoothstep(1.0 - maskBlur * _MouthsTRS.x, 1.0, mouthMaskRect.x), smoothstep(1.0 - maskBlur * _MouthsTRS.y, 1.0, mouthMaskRect.y)));
                        half4 Mouth = SAMPLE_TEXTURE2D(_ExpressionMap, sampler_ExpressionMap, mouthUV);
                    #endif
                    half alpha = 0.0;
                    #if _ExpressionFormat_FaceSheet
                        alpha = _diffuse_var.rgb = lerp(_diffuse_var.rgb, Mouth.rgb, mouthMask * Mouth.a);
                    #endif
                    
                    #if _ExpressionFormat_FaceSheet || _ExpressionFormat_Wink
                        _diffuse_var.rgb = lerp(_diffuse_var.rgb, Eyes.rgb, eyesMask * smoothstep(0.0, 0.5, Eyes.a));
                    #endif
                    
                    #if _ExpressionFormat_FaceSheet
                        _diffuse_var.rgb = lerp(_diffuse_var.rgb, Brow.rgb, browMask * Brow.a);
                    #endif
                    
                #endif
                
                //Prepare Property....
                //......................
                
                float3 positionWS = i.positionWSAndFogFactor.xyz;
                //i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - positionWS.xyz);
                float3 normalDirection = i.normalWS;
                float fresnel = pow(1.0 - saturate(dot(viewDirection, normalDirection)), 8);
                float3 lightColor = mainLight.color.rgb;
                float3 halfDirection = normalize(viewDirection + mainLight.direction);
                ////// Lighting:
                float attenuation = 1;
                ////// Emissive:
                float _Gloss_var = _Gloss;
                float4 _ESSGMask_var = SAMPLE_TEXTURE2D(_mask, sampler_mask, i.uv01.xy); // R-Em  G-Shadow B-Specular A-Gloss
                float glossMask = _ESSGMask_var.a;
                float specStep = 2.0;
                float specularArea = floor(pow(max(0, dot(i.normalWS, halfDirection)), exp2(lerp(1, 11, (_Gloss_var * glossMask)))) * specStep) / (specStep - 1);
                float4 _SpecularColor_var = _SpecularColor;
                float specularMask = _ESSGMask_var.b;
                float4 _Color_var = _Color;
                
                float4 _Picker_1_var = _Picker_1;
                float shadowStrength = 5.0;
                float shadowPow1 = pow((1.0 - saturate(distance(_diffuse_var.rgb, _Picker_1_var.rgb))), shadowStrength);
                float4 _Picker_0_var = _Picker_0;
                float shadowPow0 = pow((1.0 - saturate(distance(_diffuse_var.rgb, _Picker_0_var.rgb))), shadowStrength);
                float shadowRefr = _ESSGMask_var.g + (_ShadowOffset -0.5h) * 2.0h;
                
                #if _DiscolorationSystem
                    //Discoloration
                    half4 step_var ;
                    half blackArea;
                    half skinArea;
                    half eyeArea;
                    half2 eyeAreaReplace = 0.0;
                    half2 browReplace = 0.0;
                    half2 mouthReplace = 0.0;
                    #if _ExpressionEnable
                        eyeAreaReplace = half2(Eyes.a, eyesMask);
                        #if _ExpressionFormat_FaceSheet
                            browReplace = half2(Brow.a, browMask);
                            mouthReplace = half2(Mouth.a, mouthMask);
                        #endif
                    #endif
                    
                    Step8Color(_SelfMask_UV0_var.a, eyeAreaReplace, browReplace, mouthReplace, step_var, blackArea, skinArea, eyeArea);
                    
                    half3 colorRGB_A = step_var.rgb;
                    half3 colorRGB_B = _diffuse_var.rgb;
                    
                    half3 colorHSV_A = RGB2HSV(colorRGB_A);
                    half3 colorHSV_B = RGB2HSV(colorRGB_B);
                    
                    half3 mupArea = lerp(_diffuse_var.rgb, colorRGB_B * _DiscolorationColor_1.rgb * skinArea +
                    colorRGB_B * eyeArea * _DiscolorationColor_2.rgb +
                    colorRGB_B * (1.0 - skinArea - eyeArea), skinArea + eyeArea);
                    
                    _diffuse_var.rgb = lerp(HSV2RGB(half3(colorHSV_A.rg, colorHSV_B.b * (step_var.a + 1.0) + max(0, step_var.a))), mupArea, skinArea + eyeArea + blackArea);
                    
                #endif
                
                pbr = saturate(pbr);
                
                //PBRShadowArea
                float refractionShadowArea = NdotL + (shadowRefr - 0.5h) * 2.0h * _ShadowRefraction;
                half uvUseArea;
                #if _SelfMaskEnable
                    uvUseArea = LigntMapAreaInUV1(i, refractionShadowArea);
                #else
                    uvUseArea = 0.0;
                #endif
                refractionShadowArea = lerp(refractionShadowArea, uvUseArea, _SelfMask_UV0_var.g);
                
                refractionShadowArea = saturate(refractionShadowArea);
                refractionShadowArea = smoothstep(0.5 - (1.0 - _ShadowRamp), 0.5 + (1.0 - _ShadowRamp), saturate(1.0 - refractionShadowArea));
                refractionShadowArea = saturate((1.0 - refractionShadowArea)) ;
                
                pbr = smoothstep(0.5 - (1.0 - _SelfShadowRamp), 0.5 + (1.0 - _SelfShadowRamp), 1.0 - pbr);
                pbr = 1.0 - pbr;
                
                float PBRShadowArea = refractionShadowArea * (_ReceiveShadow == 1.0 ? pbr: 1.0) ;
                
                float node_8468 = 2.0;
                float shadowArea0 = saturate(((1.0 - shadowPow1) * shadowPow0 * node_8468)) ;
                float4 _ShadowColor0_var = _ShadowColor0;
                float shadowArea1 = saturate((shadowPow1 * (1.0 - shadowPow0) * node_8468)) ;
                float shadowAreaElse = (1.0 - saturate(shadowArea0 + shadowArea1));
                float4 _ShadowColor1_var = _ShadowColor1;
                float4 _ShadowColorElse_var = _ShadowColorElse;
                float4 _EmissionColor_var = _EmissionColor;
                float emissionMask = _ESSGMask_var.r;
                float emMask = emissionMask;
                float3 _EmissionxBase_var = lerp(emMask, (_diffuse_var.rgb * emMask), _EmissionxBase);
                float _EmissionOn_var = _EmissionOn;
                
                float _Flash_var = (1.0 - max(0, dot(normalDirection, viewDirection))) * _Flash;
                float3 specularColor = lerp(float3(0, 0, 0), float3(specularArea, specularArea, specularArea), (_SpecularColor_var.rgb * specularMask));
                specularColor = clamp(specularColor, 0.0.xxx, 1.0.xxx);
                float shadowTotal = saturate(shadowArea0 + shadowArea1 + shadowAreaElse) * (1.0 - PBRShadowArea);
                float3 diffuseColor = lerp(_diffuse_var.rgb, _diffuse_var.rgb * saturate(shadowArea0 * _ShadowColor0.rgb + shadowArea1 * _ShadowColor1.rgb + shadowAreaElse * _ShadowColorElse.rgb), shadowTotal);
                
                
                float3 emissive = (((lightColor.rgb * 0.4) * step((1.0 - 0.1), _Flash_var))
                + specularColor + diffuseColor) * mainLight.color * _Color.rgb +
                (_EmissionColor_var.rgb * _EmissionxBase_var * _EmissionOn_var) +
                (float3(1, 0.3171664, 0.2549019) * _Flash_var * _Flash_var)
                ;
                emissive += (fresnel) * (1.0 - shadowTotal);
                emissive.rgb = clamp(emissive.rgb, 0.0.xxxx, diffuseColor * 2.0);
                
                
                emissive = emissive + lerp(0, smoothstep(1.0 - _EdgeLightWidth, 1, saturate(fresnel * 10.0 * (1.0 - shadowTotal))), _EdgeLightIntensity);
                
                //Fog
                float fogFactor = i.positionWSAndFogFactor.w;
                
                // Additional lights loop
                #ifdef _ADDITIONAL_LIGHTS
                    
                    BRDFData brdfData;
                    InitializeBRDFData(1.0.rrr, 0.0, 0.0, 0.0, 1.0, brdfData);
                    
                    int additionalLightsCount = GetAdditionalLightsCount();
                    half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);
                    float3 additionalLightColor = 0.0h.rrr;
                    for (int iter = 0; iter < additionalLightsCount; iter ++)
                    {
                        Light light = GetAdditionalLight(iter, positionWS);
                        
                        float3 currentLightColor = LightingPhysicallyBased(brdfData, light, i.normalWS, viewDirectionWS) ;
                        additionalLightColor += currentLightColor;
                    }
                    
                    emissive += additionalLightColor * diffuseColor;
                #endif
                
                
                float3 finalColor = emissive.rgb;
                
                

                finalColor = MixFog(finalColor, fogFactor);
                
                float4 finalRGBA = float4(finalColor, 1);
                
                return finalRGBA;
            }
            ENDHLSL
            
        }
        
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            
            ZWrite On
            ZTest LEqual
            
            HLSLPROGRAM
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog
            #define ASE_FOG 1
            #define ASE_SRP_VERSION 60902
            
            #pragma shader_feature_local _SelfMaskEnable
            
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            
            
            
            struct GraphVertexInput
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                float3 ase_normal: NORMAL;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                float2 uv: TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            
            
            // x: global clip space bias, y: normal world space bias
            float3 _LightDirection;
            sampler2D _SelfMask;
            VertexOutput ShadowPassVertex(GraphVertexInput v)
            {
                VertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.uv = v.uv;
                float4 _SelfMask_var = tex2Dlod(_SelfMask, float4(v.uv, 0, 0));
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 normalWS = TransformObjectToWorldDir(v.ase_normal);
                
                float invNdotL = 1.0 - saturate(dot(_LightDirection, normalWS));
                float scale = invNdotL * _ShadowBias.y;
                //invNdotL=smoothstep(0.5,0.6,invNdotL);
                // normal bias is negative since we want to apply an inset normal offset
                positionWS = _LightDirection * _ShadowBias.xxx + positionWS;
                positionWS = normalWS * scale.xxx + positionWS;
                float4 clipPos = TransformWorldToHClip(positionWS);
                
                // _ShadowBias.x sign depens on if platform has reversed z buffer
                //clipPos.z += _ShadowBias.x;
                
                #if UNITY_REVERSED_Z
                    clipPos.z = min(clipPos.z, clipPos.w * (UNITY_NEAR_CLIP_VALUE
                    #if _SelfMaskEnable
                        * _SelfMask_var.b
                    #endif
                    ));
                #else
                    clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
                #endif
                o.clipPos = clipPos;
                
                return o;
            }
            
            half4 ShadowPassFragment(VertexOutput IN): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                float Alpha = 1;
                float AlphaClipThreshold = AlphaClipThreshold;
                
                #if _AlphaClip
                    clip(Alpha - AlphaClipThreshold);
                #endif
                
                return 0;
            }
            
            ENDHLSL
            
        }
        
        
        Pass
        {
            
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            
            ZWrite On
            ColorMask 0
            
            HLSLPROGRAM
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog
            
            
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma vertex vert
            #pragma fragment frag
            
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            
            
            struct GraphVertexInput
            {
                float4 vertex: POSITION;
                float3 ase_normal: NORMAL;
                float2 uv: TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                float2 uv: TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            VertexOutput vert(GraphVertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.uv = v.uv;
                v.ase_normal = v.ase_normal ;
                
                if (v.vertex.y < 0.5)
                {
                    v.vertex.y = 0.5;
                }
                o.clipPos = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }
            
            half4 frag(VertexOutput IN): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                
                float Alpha = 1;
                float AlphaClipThreshold = AlphaClipThreshold;
                
                #if _AlphaClip
                    clip(Alpha - AlphaClipThreshold);
                #endif
                
                return 0;
            }
            ENDHLSL
            
        }
    }
    
    // Uses a custom shader GUI to display settings. Re-use the same from Lit shader as they have the
    // same properties.
    CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.ZDCharacter"
}