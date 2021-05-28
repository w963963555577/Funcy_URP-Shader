Shader "ZDShader/URP/Character"
{
    Properties
    {
        _diffuse ("BaseColor", 2D) = "white" { }
        [HDR]_Color ("BaseColor", Color) = (1.0, 1.0, 1.0, 1)
        
        _SubsurfaceScattering ("Scatter", Range(0, 1)) = 0.2
        _SubsurfaceRadius ("Radius", Range(0, 5.0)) = 2.0
        
        _EdgeLightWidth ("Edge Light Width", Range(0, 1)) = 1
        _EdgeLightIntensity ("Edge Light Intensity", Range(0, 1)) = 1
        
        _Flash ("Flash", Float) = 0
        _mask ("ESSGMask", 2D) = "(0,0.5,0,0)" { }
        _SelfMask ("Self Mask", 2D) = "black" { }
        
        
        [MaterialToggle] _SelfMaskEnable ("Self Mask Enable", float) = 0
        
        [Enum(positiveZ positiveY, 0, positiveY negativeX, 1)]_SelfMaskDirection ("Self Mask Direction", Float) = 0
        
        [HDR]_EmissionColor ("EmissionColor", Color) = (0, 0, 0)
        [MaterialToggle] _EmissionxBase ("Emission x Base", Float) = 0
        [MaterialToggle] _EmissionOn ("EmissionOn", Float) = 0
        [MaterialToggle] _EmissionFlow ("Flow Emission", Float) = 0
        
        _Gloss ("Gloss (texture=1)", Range(0, 1)) = 0.5
        [HDR]_SpecularColor ("SpecularColor", Color) = (0.6176471, 0.6145149, 0.5722318, 1)
        _ShadowRamp ("Shadow Ramp", Range(0, 1)) = 1
        _SelfShadowRamp ("Self Shadow Ramp", Range(0, 1)) = 0.8
        
        _Picker_0 ("Picker_0", Color) = (0.0, 0.5, 0.0, 0.0)
        _Picker_1 ("Picker_1", Color) = (0.0, 0.5, 0.0, 0.0)
        _Picker_2 ("Picker_2", Color) = (0.0, 0.5, 0.0, 0.0)
        _Picker_3 ("Picker_3", Color) = (0.0, 0.5, 0.0, 0.0)
        _Picker_4 ("Picker_4", Color) = (0.0, 0.5, 0.0, 0.0)
        _Picker_5 ("Picker_5", Color) = (0.0, 0.5, 0.0, 0.0)
        _Picker_6 ("Picker_6", Color) = (0.0, 0.5, 0.0, 0.0)
        _Picker_7 ("Picker_7", Color) = (0.0, 0.5, 0.0, 0.0)
        _Picker_8 ("Picker_8", Color) = (0.0, 0.5, 0.0, 0.0)
        _Picker_9 ("Picker_9", Color) = (0.0, 0.5, 0.0, 0.0)
        
        _ShadowColor0 ("ShadowColor0", Color) = (1, 0.7344488, 0.514151, 0.1)
        _ShadowColor1 ("ShadowColor1", Color) = (0.3160377, 0.4365495, 1, 0.1)
        _ShadowColor2 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.1)
        _ShadowColor3 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.1)
        _ShadowColor4 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.1)
        _ShadowColor5 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.1)
        _ShadowColor6 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.1)
        _ShadowColor7 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.1)
        _ShadowColor8 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.1)
        _ShadowColor9 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.1)
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
        
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst", Float) = 0.0
        [Enum(Off, 0, On, 1)]  _ZWrite ("ZWrite", Float) = 1.0
        [Enum(UnityEngine.Rendering.CompareFunction)]  _ZTest ("ZTest", Float) = 4
        
        [HideInInspector] _Cull ("__cull", Float) = 2.0
        
        // Editmode props
        [HideInInspector] _QueueOffset ("Queue offset", Float) = 0.0
        [Toggle]_ReceiveShadow ("Receive Shadow", Float) = 1.0
        
        
        
        _CustomLightIntensity ("Custom Light Intensity", Float) = 1.0
        _CustomLightColor ("Custom Light Color", Color) = (1, 1, 1, 1)
        
        _ShadowRefraction ("Shadow Refraction", Range(0, 10)) = 1
        _ShadowOffset ("Shadow Offset", Range(0, 1)) = 0.6
        
        
        _OutlineColor ("Color", Color) = (0.0075, 0.0006, 0.0006, 1)
        _DiffuseBlend ("Diffuse Blend", Range(0, 1)) = 0.2
        _OutlineWidth_MinWidth_MaxWidth_Dist_DistBlur ("Outline Ctrl Properties", Vector) = (0.0, 0.5, 0.5, 0.0)
        
        //Expression
        [Toggle(_ExpressionEnable)] _ExpressionEnable ("Enable Expression", float) = 0
        
        [IntRange]_SelectExpressionMap ("Select Map", Range(0, 1)) = 0
        [NoScaleOffset]_ExpressionMap ("Face Sheet", 2D) = "black" { }
        [NoScaleOffset]_ExpressionQMap ("Q Face Sheet", 2D) = "black" { }
        
        [Toggle(_ExpressionFormat_Wink)] _ExpressionFormat_Wink ("Wink", float) = 0
        [Toggle(_ExpressionFormat_FaceSheet)] _ExpressionFormat_FaceSheet ("FaceSheet", float) = 1
        
        [IntRange]_SelectBrow ("Select Brow", Range(0, 4)) = 1
        _BrowRect ("Brow UV Rect", Vector) = (0, 0.45, 0.855, 0.3)
        [IntRange]_SelectFace ("Select Face", Range(0, 8)) = 1
        _FaceRect ("Eyes UV Rect", Vector) = (0, -0.02, 0.855, 0.37)
        [IntRange]_SelectMouth ("Select Mouth ", Range(0, 8)) = 1
        _MouthRect ("Mouth UV Rect", Vector) = (0, -0.97, 0.427, 0.28)
        
        [MaterialToggle] _FloatModel ("Float Model", float) = 0
        
        //Effective Disslove
        _EffectiveMap ("Effective Map", 2D) = "white" { }
        [MaterialToggle] _FaceLightMapCombineMode ("Face LightMap Combined", float) = 0.0
        
        [HDR]_EffectiveColor ("_EffectiveColor", Color) = (1.0, 1.0, 1.0, 1.0)
        
        [MaterialToggle] _DistanceDisslove ("Distance Disslove", float) = 1
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
            Blend [_SrcBlend][_DstBlend]
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ _AlphaClip
            
            #pragma target 3.0
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float2 uv: TEXCOORD0;
                float2 effectcoord: TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float2 uv: TEXCOORD0;
                float4 positionSS: TEXCOORD1;
                float vertexDist: TEXCOORD2;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            sampler2D _diffuse;
            sampler2D _OutlineWidthControl;
            
            #include "ZDCharacter-CBufferProperties.hlsl"
            
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                half3 objPivot = mul(GetObjectToWorldMatrix(), half4(0.0, 0.0, 0.0, 1.0)).xyz;
                
                v.vertex.y += (sin(_Time.y + v.effectcoord.x + v.effectcoord.y) + 0.5) * 0.3 * _FloatModel;
                
                half RTD_OL_OLWABVD_OO = 1.0;
                half4 _OutlineWidthControl_var = tex2Dlod(_OutlineWidthControl, float4(v.uv, 0.0, 0));
                
                half2 RTD_OL_DNOL_OO = v.uv;
                half2 node_8743 = RTD_OL_DNOL_OO;
                float2 node_1283_skew = node_8743 + 0.2127 + node_8743.x * 0.3713 * node_8743.y;
                float2 node_1283_rnd = 4.789 * sin(489.123 * (node_1283_skew));
                half node_1283 = frac(node_1283_rnd.x * node_1283_rnd.y * (1 + node_1283_skew.x));
                
                float3 _OEM = v.normal;
                
                half RTD_OL = (RTD_OL_OLWABVD_OO * 0.01) * lerp(1.0, node_1283, 0.3) * _OutlineWidthControl_var.r;
                
                half dist = distance(float3(0.0, v.vertex.y, 0.0), mul(GetWorldToObjectMatrix(), float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                half4 widthRange = _OutlineWidth_MinWidth_MaxWidth_Dist_DistBlur;
                
                RTD_OL *= min(widthRange.y * 2.0, dist * widthRange.z)/* (lerp(widthRange.x, widthRange.y, saturate(dist - 0.05) * widthRange.z))*/;
                
                float4 positionCS = TransformObjectToHClip(float4(v.vertex.xyz + _OEM * RTD_OL, 1).xyz);
                o.vertex = positionCS / _OutlineEnable;
                o.positionSS = ComputeScreenPos(positionCS, _ProjectionParams.x);
                o.uv = v.uv;
                o.vertexDist = dist;
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                float2 screenUV = i.positionSS.xy / i.positionSS.w;
                
                DistanceDisslove(screenUV, i.vertexDist);
                
                half4 effectiveMask = SAMPLE_TEXTURE2D(_EffectiveMap, sampler_EffectiveMap, i.uv.xy);
                half4 effectiveDisslive = _EffectiveColor;
                
                half alphaMinus = 1.0 - _EffectiveColor.a;
                effectiveDisslive.a = smoothstep(alphaMinus - 0.1, alphaMinus + 0.1, (1.0 - effectiveMask.r + 0.1 * (_EffectiveColor.a - 0.5) * 2.0));
                
                float4 _diffuse_var = tex2D(_diffuse, i.uv);
                half4 col = float4(_OutlineColor.rgb + _diffuse_var.rgb * _DiffuseBlend, _Color.a * effectiveDisslive.a);
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
            
            Cull Back
            Blend [_SrcBlend][_DstBlend]
            
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
            #pragma multi_compile _ _AlphaClip
            
            #pragma multi_compile _ _DiscolorationSystem
            #pragma shader_feature_local _ExpressionEnable
            
            
            #if _ExpressionEnable
                #pragma shader_feature_local _ExpressionFormat_Wink
                #pragma shader_feature_local _ExpressionFormat_FaceSheet
            #endif
            
            #ifdef SHADER_API_D3D11
                #pragma shader_feature_local _PickerDebug_0
                #pragma shader_feature_local _PickerDebug_1
                #pragma shader_feature_local _PickerDebug_2
                #pragma shader_feature_local _PickerDebug_3
                #pragma shader_feature_local _PickerDebug_4
                #pragma shader_feature_local _PickerDebug_5
                #pragma shader_feature_local _PickerDebug_6
                #pragma shader_feature_local _PickerDebug_7
                #pragma shader_feature_local _PickerDebug_8
                #pragma shader_feature_local _PickerDebug_9
                
                #pragma shader_feature_local _Desaturation
            #endif
            
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            
            
            sampler2D _diffuse;
            
            #include "ZDCharacter-CBufferProperties.hlsl"
            
            
            TEXTURE2D(_mask);                       SAMPLER(sampler_mask);
            TEXTURE2D(_NormalMap);                  SAMPLER(sampler_NormalMap);
            TEXTURE2D(_SelfMask);                   SAMPLER(sampler_SelfMask);
            TEXTURE2D(_ExpressionMap);              SAMPLER(sampler_ExpressionMap);
            TEXTURE2D(_ExpressionQMap);             SAMPLER(sampler_ExpressionQMap);
            
            struct Attributes
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
                float4 tangentOS: TANGENT;
                float2 uv0: TEXCOORD0;
                float2 uv1: TEXCOORD1;
                float2 effectcoord: TEXCOORD2;
                float2 selfShadowCoord: TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct Varyings
            {
                float4 uv01: TEXCOORD0;
                float4 effectcoord: TEXCOORD1;
                float4 positionWSAndFogFactor: TEXCOORD2;
                float4 normalWS: TEXCOORD3;             //  w: screenPosition.x
                
                
                float4 objectDirection: TEXCOORD4;      //  w: screenPosition.y
                float4 lightXZDirection: TEXCOORD5;     //  w: screenPosition.z
                float4 objectUp: TEXCOORD6;             //  w: screenPosition.w
                
                
                float vertexDist: TEXCOORD7;
                
                #if _ExpressionEnable
                    float4 expressionUV01: TEXCOORD8;
                    #if _ExpressionFormat_FaceSheet
                        float4 expressionUV23: TEXCOORD9;
                    #endif
                #endif
                
                float4 positionCS: SV_POSITION;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            
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
            
            Light LerpLightDirection(float3 objectDirection)
            {
                Light light;
                light.direction = lerp(normalize(objectDirection + half3(objectDirection.x * 4.0, 6.0, objectDirection.z * 3.0)), _MainLightPosition.xyz, unity_LightData.z);
                return light;
            }
            
            Varyings LitPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                
                half3 objPivot = mul(GetObjectToWorldMatrix(), half4(0.0, 0.0, 0.0, 1.0)).xyz;
                
                input.positionOS.y += (sin(_Time.y + input.effectcoord.x + input.effectcoord.y) + 0.5) * 0.3 * _FloatModel;
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                // Computes fog factor per-vertex.
                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                
                // TRANSFORM_TEX is the same as the old shader library.
                output.uv01.xy = TRANSFORM_TEX(input.uv0, _diffuse);
                output.uv01.zw = input.uv1;
                input.selfShadowCoord = lerp(input.uv1, input.selfShadowCoord, _FaceLightMapCombineMode);
                output.effectcoord = float4(input.effectcoord, input.selfShadowCoord);
                output.positionWSAndFogFactor = float4(vertexInput.positionWS, fogFactor);
                output.normalWS.xyz = vertexNormalInput.normalWS;
                
                #ifdef _NORMALMAP
                    output.tangentWS = vertexNormalInput.tangentWS;
                    output.bitangentWS = vertexNormalInput.bitangentWS;
                #endif
                
                //SelfMask
                half index = _SelfMaskDirection;
                half3 dirPZPY = half3(0, 0, 1);half3 upPZPY = half3(0, 1, 0);
                half3 dirPYNX = half3(0, 1, 0);half3 upPYNX = half3(-1, 0, 0);
                half3 useDir = lerp(dirPZPY, dirPYNX, saturate(index));
                half3 useUp = lerp(upPZPY, upPYNX, saturate(index));
                output.objectDirection.xyz = mul(GetObjectToWorldMatrix(), float4(useDir.xyz, 0.0)).xyz;
                output.objectDirection.y = 0;
                
                Light mainLight = LerpLightDirection(output.objectDirection.xyz);
                
                // unity_LightData.z is 1 when not culled by the culling mask, otherwise 0.
                mainLight.distanceAttenuation = 1;
                #if defined(LIGHTMAP_ON) || defined(_MIXED_LIGHTING_SUBTRACTIVE)
                    // unity_ProbesOcclusion.x is the mixed light probe occlusion data
                    mainLight.distanceAttenuation *= unity_ProbesOcclusion.x;
                #endif
                mainLight.shadowAttenuation = 1.0;
                mainLight.color = _MainLightColor.rgb;
                
                output.objectUp.xyz = mul(GetObjectToWorldMatrix(), float4(useUp.xyz, 0.0)).xyz;
                output.lightXZDirection.xyz = normalize(float3(-mainLight.direction.x, 0.0, -mainLight.direction.z));
                
                output.vertexDist = distance(float3(0.0, input.positionOS.y, 0.0), mul(GetWorldToObjectMatrix(), float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                
                output.positionCS = vertexInput.positionCS;
                float4 positionSS = ComputeScreenPos(vertexInput.positionCS, _ProjectionParams.x);
                
                output.normalWS.w = positionSS.x;
                output.objectDirection.w = positionSS.y;
                output.lightXZDirection.w = positionSS.z;
                output.objectUp.w = positionSS.w;
                
                #if _ExpressionEnable
                    _SelectExpressionMap = round(_SelectExpressionMap);
                    _SelectBrow = round(_SelectBrow);
                    _SelectFace = round(_SelectFace);
                    _SelectMouth = round(_SelectMouth);
                    
                    half maskBlur = 0.01;
                    #if _ExpressionFormat_FaceSheet
                        half4 _BrowTRS = half4(1.0 / _BrowRect.zw, -_BrowRect.xy);
                        half2 browOffset = half2(0.5, 1.0 / 8.0);
                        half2 browArea = GetBrowArea(output.uv01.zw, 8.0, _SelectBrow, browOffset);
                        half2 browPivot = GetBrowArea(half2(0.5, 0.5), 8.0,
                        _SelectBrow, browOffset);
                        half2 browUV = ((browArea - browPivot) * _BrowTRS.xy) + browPivot + half2(_BrowTRS.z * browOffset.x, _BrowTRS.w * browOffset.y);
                        output.expressionUV23.xy = browUV;
                    #endif
                    
                    #if _ExpressionFormat_FaceSheet || _ExpressionFormat_Wink
                        half4 _EyesTRS = half4(1.0 / _FaceRect.zw, -_FaceRect.xy);
                        
                        #if _ExpressionFormat_FaceSheet
                            half2 eyeOffset = half2(0.5, 0.125);
                            half2 eyesArea = GetEyesArea(output.uv01.zw, 8.0, _SelectFace, eyeOffset);
                            half2 eyesPivot = GetEyesArea(half2(0.5, 0.5), 8.0, _SelectFace, eyeOffset);
                        #endif
                        #if _ExpressionFormat_Wink
                            half2 eyeOffset = half2(1.0, 0.5);
                            half2 eyesArea = GetEyesArea(output.uv01.zw, 2.0, _SelectFace, eyeOffset);
                            half2 eyesPivot = GetEyesArea(half2(0.5, 0.5), 2.0, _SelectFace, eyeOffset);
                        #endif
                        
                        half2 eyesUV = ((eyesArea - eyesPivot) * _EyesTRS.xy) + eyesPivot + half2(_EyesTRS.z * eyeOffset.x, _EyesTRS.w * eyeOffset.y);
                        output.expressionUV01.xy = eyesUV;
                        
                    #endif
                    
                    #if _ExpressionFormat_FaceSheet
                        half4 _MouthsTRS = half4(1.0 / _MouthRect.zw, -_MouthRect.xy);
                        half2 mouthOffset = half2(0.25, 0.125);
                        half2 mouthArea = GetMouthArea(output.uv01.zw, 8.0, _SelectMouth, mouthOffset);
                        half2 mouthPivot = GetMouthArea(half2(0.5, 0.5), 8.0, _SelectMouth, mouthOffset);
                        half2 mouthUV = ((mouthArea - mouthPivot) * _MouthsTRS.xy) + mouthPivot + half2(_MouthsTRS.z * mouthOffset.x, _MouthsTRS.w * mouthOffset.y);
                        output.expressionUV23.zw = mouthUV;
                    #endif
                    
                    
                #endif
                
                return output;
            }
            
            float Remap(float value, float from1, float to1, float from2, float to2)
            {
                return(value - from1) / (to1 - from1) * (to2 - from2) + from2;
            }
            
            
            float LigntMapAreaInUV1(Varyings i, float origShadow)
            {
                float cm = clamp(normalize(cross(i.objectDirection.xyz, i.lightXZDirection.xyz)).y, -1., 1.);
                float4 _SelfMask_UV1_var = SAMPLE_TEXTURE2D(_SelfMask, sampler_SelfMask, float2(i.uv01.z * cm, i.uv01.w));
                half odl = -dot(i.objectDirection.xyz, i.lightXZDirection.xyz);
                float angle01 = acos(odl) * 0.318309886h;
                angle01 = Remap(angle01, 0, 1, 0.01, 0.99);
                
                half faceLightMapScaleRange = lerp(1.0, 0.0625, _FaceLightMapCombineMode) * 0.1;
                
                half _SelfShadow_UV1_var = SAMPLE_TEXTURE2D(_EffectiveMap, sampler_EffectiveMap, float2(i.effectcoord.z + cm * angle01 * faceLightMapScaleRange, i.effectcoord.w)).g;
                half upNear = dot(i.objectUp.xyz, half3(0, 1, 0));
                _SelfMask_UV1_var.r = lerp(origShadow, _SelfMask_UV1_var.r, upNear * 0.5 + 0.5);
                
                return min(_SelfShadow_UV1_var, 1.0 - smoothstep(_SelfMask_UV1_var.r - 0.01, _SelfMask_UV1_var.r + 0.01, angle01));
            }
            
            #if _DiscolorationSystem
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
            
            float4 WorldToShadowCoord(float3 positionWS)
            {
                #ifdef _MAIN_LIGHT_SHADOWS_CASCADE
                    half cascadeIndex = ComputeCascadeIndex(positionWS);
                #else
                    half cascadeIndex = 0;
                #endif
                float4x4 m = _MainLightWorldToShadow[cascadeIndex];
                
                return mul(m, float4(positionWS, 1.0));
            }
            
            half BRDFSpecular(half metallic, half smoothness, float3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
            {
                float3 halfDir = SafeNormalize(float3(lightDirectionWS) + float3(viewDirectionWS));
                
                float NoH = saturate(dot(normalWS, halfDir));
                half LoH = saturate(dot(lightDirectionWS, halfDir));
                
                half perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(smoothness);
                half roughness = max(PerceptualRoughnessToRoughness(perceptualRoughness), HALF_MIN);
                half roughness2 = roughness * roughness;
                
                half normalizationTerm = roughness * 4.0h + 2.0h;
                half roughness2MinusOne = roughness2 - 1.0h;
                float d = NoH * NoH * roughness2MinusOne + 1.00001f;
                
                half LoH2 = LoH * LoH;
                half specularTerm = roughness2 / ((d * d) * max(0.1h, LoH2) * normalizationTerm);
                
                #if defined(SHADER_API_MOBILE) || defined(SHADER_API_SWITCH)
                    specularTerm = specularTerm - HALF_MIN;
                    specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
                #endif
                
                return specularTerm * lerp(0.04, 1.0, metallic);
            }
            
            half4 LitPassFragment(Varyings i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                float3 positionWS = i.positionWSAndFogFactor.xyz;
                float4 positionSS = float4(i.normalWS.w, i.objectDirection.w, i.lightXZDirection.w, i.objectUp.w);
                float2 screenUV = positionSS.xy /= positionSS.w;
                
                DistanceDisslove(screenUV, i.vertexDist);
                
                float4 _diffuse_var = tex2D(_diffuse, i.uv01.xy);
                float4 _ESSGMask_var = SAMPLE_TEXTURE2D(_mask, sampler_mask, i.uv01.xy); // R-Em  G-Shadow B-Specular A-Gloss
                float4 _SelfMask_UV0_var = SAMPLE_TEXTURE2D(_SelfMask, sampler_SelfMask, i.uv01.xy);
                
                
                Light mainLight = LerpLightDirection(i.objectDirection.xyz);
                
                // unity_LightData.z is 1 when not culled by the culling mask, otherwise 0.
                mainLight.distanceAttenuation = 1;
                #if defined(LIGHTMAP_ON) || defined(_MIXED_LIGHTING_SUBTRACTIVE)
                    // unity_ProbesOcclusion.x is the mixed light probe occlusion data
                    mainLight.distanceAttenuation *= unity_ProbesOcclusion.x;
                #endif
                mainLight.shadowAttenuation = 1.0;
                mainLight.color = _MainLightColor.rgb;
                mainLight.color = _CustomLightColor.rgb * _CustomLightIntensity;
                
                float4 shadowCoords = WorldToShadowCoord(lerp(positionWS + mainLight.direction * min(i.vertexDist, 1.0), positionWS, _SelfMask_UV0_var.b));
                mainLight.shadowAttenuation = MainLightRealtimeShadow(shadowCoords);
                
                
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - positionWS.xyz);
                float3 normalDirection = i.normalWS.xyz;
                
                float glossMask = _ESSGMask_var.a;
                
                half NdotL = dot(i.normalWS.xyz, mainLight.direction.xyz);
                half selfShadow = mainLight.distanceAttenuation * mainLight.shadowAttenuation ;
                float fresnel = max(1.0 - dot(viewDirection, normalDirection), saturate(dot(viewDirection, - (normalDirection * 0.82 - mainLight.direction)))) ;
                half SSS = max(NdotL, fresnel) * _SubsurfaceRadius * (1.0 - glossMask);
                
                
                //ShadowReplacer
                float shadowArea0 = CaculateShadowArea(_diffuse_var, _Picker_0, _ShadowColor0.a);
                float shadowArea1 = CaculateShadowArea(_diffuse_var, _Picker_1, _ShadowColor1.a);
                float shadowArea2 = CaculateShadowArea(_diffuse_var, _Picker_2, _ShadowColor2.a);
                float shadowArea3 = CaculateShadowArea(_diffuse_var, _Picker_3, _ShadowColor3.a);
                float shadowArea4 = CaculateShadowArea(_diffuse_var, _Picker_4, _ShadowColor4.a);
                float shadowArea5 = CaculateShadowArea(_diffuse_var, _Picker_5, _ShadowColor5.a);
                float shadowArea6 = CaculateShadowArea(_diffuse_var, _Picker_6, _ShadowColor6.a);
                float shadowArea7 = CaculateShadowArea(_diffuse_var, _Picker_7, _ShadowColor7.a);
                float shadowArea8 = CaculateShadowArea(_diffuse_var, _Picker_8, _ShadowColor8.a);
                float shadowArea9 = CaculateShadowArea(_diffuse_var, _Picker_9, _ShadowColor9.a);
                float shadowTotalArea = min(1.0, shadowArea0 + shadowArea1 + shadowArea2 + shadowArea3 + shadowArea4 + shadowArea5 + shadowArea6 + shadowArea7 + shadowArea8 + shadowArea9);
                float shadowAreaElse = (1.0 - shadowTotalArea);
                
                
                #ifdef SHADER_API_D3D11
                    #if _PickerDebug_0
                        return float4(shadowArea0.xxx, 1.0);
                    #endif
                    #if _PickerDebug_1
                        return float4(shadowArea1.xxx, 1.0);
                    #endif
                    #if _PickerDebug_2
                        return float4(shadowArea2.xxx, 1.0);
                    #endif
                    #if _PickerDebug_3
                        return float4(shadowArea3.xxx, 1.0);
                    #endif
                    #if _PickerDebug_4
                        return float4(shadowArea4.xxx, 1.0);
                    #endif
                    #if _PickerDebug_5
                        return float4(shadowArea5.xxx, 1.0);
                    #endif
                    #if _PickerDebug_6
                        return float4(shadowArea6.xxx, 1.0);
                    #endif
                    #if _PickerDebug_7
                        return float4(shadowArea7.xxx, 1.0);
                    #endif
                    #if _PickerDebug_8
                        return float4(shadowArea8.xxx, 1.0);
                    #endif
                    #if _PickerDebug_9
                        return float4(shadowArea9.xxx, 1.0);
                    #endif
                #endif
                
                #if _ExpressionEnable
                    
                    half maskBlur = 0.01;
                    #if _ExpressionFormat_FaceSheet
                        half4 _BrowTRS = half4(1.0 / _BrowRect.zw, -_BrowRect.xy);
                        half2 browUV = i.expressionUV23.xy;
                        half2 browMaskUV = (i.uv01.zw - half2(0.5, 0.5)) * _BrowTRS.xy + half2(0.5, 0.5) + _BrowTRS.zw;
                        half2 browMaskRect = abs(((browMaskUV - half2(0.5, 0.5)) * half2(2, 2)));
                        half browMask = 1.0 - (max(smoothstep(1.0 - maskBlur * _BrowTRS.x, 1.0, browMaskRect.x), smoothstep(0.5 - maskBlur * _BrowTRS.y, 0.5, browMaskRect.y)));
                        half4 Brow = SAMPLE_TEXTURE2D(_ExpressionMap, sampler_ExpressionMap, browUV);
                        Brow = lerp(Brow, SAMPLE_TEXTURE2D(_ExpressionQMap, sampler_ExpressionQMap, browUV), _SelectExpressionMap);
                    #endif
                    
                    #if _ExpressionFormat_FaceSheet || _ExpressionFormat_Wink
                        half4 _EyesTRS = half4(1.0 / _FaceRect.zw, -_FaceRect.xy);
                        half2 eyesUV = i.expressionUV01.xy;
                        half2 eyesMaskUV = (i.uv01.zw - half2(0.5, 0.5)) * _EyesTRS.xy + half2(0.5, 0.5) + _EyesTRS.zw;
                        half2 eyesMaskRect = abs(((eyesMaskUV - half2(0.5, 0.5)) * half2(2, 2)));
                        half eyesMask = 1.0 - (max(smoothstep(1.0 - maskBlur * _EyesTRS.x, 1.0, eyesMaskRect.x), smoothstep(1.0 - maskBlur * _EyesTRS.y, 1.0, eyesMaskRect.y)));
                        half4 Eyes = SAMPLE_TEXTURE2D(_ExpressionMap, sampler_ExpressionMap, eyesUV);
                        Eyes = lerp(Eyes, SAMPLE_TEXTURE2D(_ExpressionQMap, sampler_ExpressionQMap, eyesUV), _SelectExpressionMap);
                    #endif
                    
                    #if _ExpressionFormat_FaceSheet
                        half4 _MouthsTRS = half4(1.0 / _MouthRect.zw, -_MouthRect.xy);
                        half2 mouthUV = i.expressionUV23.zw;
                        half2 mouthMaskUV = (i.uv01.zw - half2(0.5, 0.5)) * _MouthsTRS.xy + half2(0.5, 0.5) + _MouthsTRS.zw;
                        half2 mouthMaskRect = abs(((mouthMaskUV - half2(0.5, 0.5)) * half2(2, 2)));
                        half mouthMask = 1.0 - (max(smoothstep(1.0 - maskBlur * _MouthsTRS.x, 1.0, mouthMaskRect.x), smoothstep(1.0 - maskBlur * _MouthsTRS.y, 1.0, mouthMaskRect.y)));
                        half4 Mouth = SAMPLE_TEXTURE2D(_ExpressionMap, sampler_ExpressionMap, mouthUV);
                        Mouth = lerp(Mouth, SAMPLE_TEXTURE2D(_ExpressionQMap, sampler_ExpressionQMap, mouthUV), _SelectExpressionMap);
                    #endif
                    
                    #if _ExpressionFormat_FaceSheet
                        _diffuse_var.rgb = lerp(_diffuse_var.rgb, Mouth.rgb, mouthMask * Mouth.a * saturate(_SelectMouth));
                    #endif
                    
                    #if _ExpressionFormat_FaceSheet || _ExpressionFormat_Wink
                        _diffuse_var.rgb = lerp(_diffuse_var.rgb, Eyes.rgb, eyesMask * smoothstep(0.0, 0.5, Eyes.a) * saturate(_SelectFace));
                    #endif
                    
                    #if _ExpressionFormat_FaceSheet
                        _diffuse_var.rgb = lerp(_diffuse_var.rgb, Brow.rgb, browMask * Brow.a * saturate(_SelectBrow));
                    #endif
                    
                #endif
                
                
                float3 lightColor = mainLight.color.rgb;
                float3 halfDirection = normalize(viewDirection + mainLight.direction);
                
                float specStep = 2.0;
                float specularValue = floor(pow(max(0, dot(i.normalWS.xyz, halfDirection)), exp2(lerp(1., 11., (_Gloss * glossMask)))) * specStep) / (specStep - 1);
                
                /*BDRF Specular but in this shader was nonconformity
                glossMask = min(max(0, glossMask + _Gloss), 1.0);
                float specularValue1 = BRDFSpecular(1.0, glossMask, i.normalWS.xyz, mainLight.direction, viewDirection) * NdotL;
                float specularValue2 = pow(dot(i.normalWS.xyz, halfDirection) * 0.5 + 0.5, exp2(lerp(1, 11, (glossMask)))) ;
                float specularValue = lerp(specularValue2, specularValue1, glossMask);
                specularValue = smoothstep(0.003, 0.004, specularValue) ;
                */
                
                float4 _SpecularColor_var = _SpecularColor;
                float specularMask = _ESSGMask_var.b;
                float4 _Color_var = _Color;
                
                
                
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
                
                float3 _diffuse_hsv = RGB2HSV(_diffuse_var.rgb);
                
                
                selfShadow = saturate(selfShadow);
                
                //PBRShadowArea
                float shadowRefr = _ESSGMask_var.g + (_ShadowOffset -0.5h) * 2.0h;
                float refractionShadowArea = NdotL + (shadowRefr - 0.5h) * 2.0h * _ShadowRefraction;
                half uvUseArea = lerp(0.0, LigntMapAreaInUV1(i, refractionShadowArea), _SelfMaskEnable);
                
                refractionShadowArea = lerp(refractionShadowArea, uvUseArea, _SelfMask_UV0_var.g);
                
                refractionShadowArea = saturate(refractionShadowArea);
                refractionShadowArea = smoothstep(0.5 - (1.0 - _ShadowRamp), 0.5 + (1.0 - _ShadowRamp) * 0.25, saturate(1.0 - refractionShadowArea));
                refractionShadowArea = saturate((1.0 - refractionShadowArea)) ;
                
                selfShadow = smoothstep(0.5 - (1.0 - _SelfShadowRamp), 0.5 + (1.0 - _SelfShadowRamp), 1.0 - selfShadow);
                selfShadow = 1.0 - selfShadow;
                
                float PBRShadowArea = refractionShadowArea * lerp(1.0, selfShadow, _ReceiveShadow) ;
                PBRShadowArea = lerp(PBRShadowArea, SSS, _SubsurfaceScattering * (1.0 - glossMask));
                
                
                
                float4 _EmissionColor_var = _EmissionColor;
                float emissionMask = _ESSGMask_var.r;
                float emMask = emissionMask;
                float3 _EmissionxBase_var = lerp(emMask, (_diffuse_var.rgb * emMask), _EmissionxBase);
                float _EmissionOn_var = _EmissionOn;
                float _Flash_var = (1.0 - max(0, dot(normalDirection, viewDirection))) * _Flash;
                float3 specularColor = _SpecularColor_var.rgb * specularValue * specularMask;
                
                
                //MixShadowReplacer
                float3 shadowColor = shadowArea0 * _ShadowColor0.rgb + shadowArea1 * _ShadowColor1.rgb +
                shadowArea2 * _ShadowColor2.rgb + shadowArea3 * _ShadowColor3.rgb +
                shadowArea4 * _ShadowColor4.rgb + shadowArea5 * _ShadowColor5.rgb +
                shadowArea6 * _ShadowColor6.rgb + shadowArea7 * _ShadowColor7.rgb +
                shadowArea8 * _ShadowColor8.rgb + shadowArea9 * _ShadowColor9.rgb +
                shadowAreaElse * _ShadowColorElse.rgb;
                
                shadowColor.xyz = RGB2HSV(shadowColor.rgb);
                
                float endOfBrightness = min(1.0, shadowColor.z);
                float overexposed = shadowColor.z - endOfBrightness;
                //return float4(overexposed.xxx, 1.0);
                shadowColor.z = endOfBrightness;
                
                shadowColor.y = lerp(shadowColor.y, _diffuse_hsv.y, 1.0 - _ShadowColorElse.a);
                shadowColor.rgb = HSV2RGB(shadowColor.xyz);
                
                
                float3 diffuseColor = lerp(_diffuse_var.rgb, _diffuse_var.rgb * shadowColor, 1.0 - PBRShadowArea);
                
                
                half clampMask = 1.0 - smoothstep(0.99, 1.0, abs(i.effectcoord.y - 0.5) * 2.0);
                float3 emissionColor = (_EmissionColor_var.rgb * _EmissionxBase_var * _EmissionOn_var);
                
                
                float3 emissive = (((lightColor.rgb * 0.4) * step((1.0 - 0.1), _Flash_var))
                + diffuseColor) * mainLight.color * _Color.rgb + specularColor +
                emissionColor + emissionColor * sin((sin(i.effectcoord.x * 2.0 * 6.28 + _Time.y * 3.0)) - 1.5 + _EmissionColor_var.a) * _EmissionFlow * clampMask +
                (float3(1, 0.3171664, 0.2549019) * _Flash_var * _Flash_var)
                ;
                
                
                half fresnelArea = smoothstep(1.0 - _EdgeLightWidth, 1 - _EdgeLightWidth * 0.7, fresnel);
                emissive = lerp(emissive, lerp(emissive, float3(1, 1, 1), _EdgeLightIntensity), fresnelArea);
                
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
                        
                        float3 currentLightColor = LightingPhysicallyBased(brdfData, light, i.normalWS.xyz, viewDirectionWS) ;
                        additionalLightColor += currentLightColor;
                    }
                    
                    emissive += additionalLightColor * diffuseColor;
                #endif
                
                
                float3 finalColor = emissive.rgb;
                
                finalColor = MixFog(finalColor, pow(fogFactor, 4.0));
                
                half4 effectiveMask = SAMPLE_TEXTURE2D(_EffectiveMap, sampler_EffectiveMap, i.uv01.xy * 0.5);
                half4 effectiveDisslive = _EffectiveColor;
                
                half alphaMinus = 1.0 - _EffectiveColor.a;
                effectiveDisslive.a = smoothstep(alphaMinus - 0.1, alphaMinus + 0.1, (1.0 - effectiveMask.r + 0.1 * (_EffectiveColor.a - 0.5) * 2.0));
                
                #ifdef SHADER_API_D3D11
                    #if _Desaturation
                        float3 s = RGB2HSV(finalColor.rgb);
                        s.g = 0.0;
                        return float4(HSV2RGB(s), _Color.a * effectiveDisslive.a);
                    #endif
                #endif
                
                float4 finalRGBA = float4(finalColor, _Color.a * effectiveDisslive.a);
                
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
            Cull[_Cull]
            
            HLSLPROGRAM
            
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
            #pragma multi_compile _ _AlphaClip
            // -------------------------------------
            // Material Keywords
            
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            
            
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            
            
            #include "ZDCharacter-CBufferProperties.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            
            float3 _LightDirection;
            
            struct Attributes
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
                float2 texcoord: TEXCOORD0;
                float2 effectcoord: TEXCOORD2;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct Varyings
            {
                float2 uv: TEXCOORD0;
                float4 positionCS: SV_POSITION;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            float4 GetShadowPositionHClip(Attributes input)
            {
                
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                
                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
                #if UNITY_REVERSED_Z
                    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #else
                    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #endif
                
                
                return positionCS;
            }
            
            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                input.positionOS.y += (sin(_Time.y + input.effectcoord.x + input.effectcoord.y) + 0.5) * 0.3 * _FloatModel;
                output.uv = input.texcoord;
                output.positionCS = GetShadowPositionHClip(input);
                return output;
            }
            
            half4 ShadowPassFragment(Varyings input): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                #if _AlphaClip
                    half4 effectiveMask = SAMPLE_TEXTURE2D(_EffectiveMap, sampler_EffectiveMap, input.uv.xy);
                    half4 effectiveDisslive = _EffectiveColor;
                    half alphaMinus = 1.0 - _EffectiveColor.a;
                    effectiveDisslive.a = smoothstep(alphaMinus - 0.1, alphaMinus + 0.1, (1.0 - effectiveMask.r + 0.1 * (_EffectiveColor.a - 0.5) * 2.0));
                    
                    clip(effectiveDisslive.a - 0.5);
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
            Cull[_Cull]
            
            HLSLPROGRAM
            
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile _ _AlphaClip
            
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            
            #include "ZDCharacter-CBufferProperties.hlsl"
            
            struct Attributes
            {
                float4 position: POSITION;
                float2 texcoord: TEXCOORD0;
                float2 effectcoord: TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct Varyings
            {
                float2 uv: TEXCOORD0;
                float4 positionCS: SV_POSITION;
                float vertexDist: TEXCOORD1;
                float4 positionSS: TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                
                input.position.y += (sin(_Time.y + input.effectcoord.x + input.effectcoord.y) + 0.5) * 0.3 * _FloatModel;
                output.uv = input.texcoord;
                
                float3 positionWS = mul(GetObjectToWorldMatrix(), float4(input.position.xyz, 0.0)).xyz;
                positionWS.y = lerp(positionWS.y, -0.99, step(positionWS.y, -0.99));
                input.position.xyz = mul(GetWorldToObjectMatrix(), float4(positionWS, 0.0)).xyz;
                output.positionCS = TransformObjectToHClip(input.position.xyz);
                output.positionSS = ComputeScreenPos(output.positionCS, _ProjectionParams.x);
                output.vertexDist = distance(float3(0.0, input.position.y, 0.0), mul(GetWorldToObjectMatrix(), float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                return output;
            }
            
            half4 DepthOnlyFragment(Varyings input): SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float2 screenUV = input.positionSS.xy / input.positionSS.w;
                DistanceDisslove(screenUV, input.vertexDist);
                
                #if _AlphaClip
                    half4 effectiveMask = SAMPLE_TEXTURE2D(_EffectiveMap, sampler_EffectiveMap, input.uv.xy);
                    half4 effectiveDisslive = _EffectiveColor;
                    half alphaMinus = 1.0 - _EffectiveColor.a;
                    effectiveDisslive.a = smoothstep(alphaMinus - 0.1, alphaMinus + 0.1, (1.0 - effectiveMask.r + 0.1 * (_EffectiveColor.a - 0.5) * 2.0));
                    
                    clip(effectiveDisslive.a - 0.5);
                #endif
                return 0;
            }
            
            
            ENDHLSL
            
        }
        
        Pass
        {
            Name "SceneSelectionPass"
            Tags { "LightMode" = "SceneSelectionPass" }
            
            ZWrite On
            ZTest Always
            Cull Off
            Blend One Zero
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ _AlphaClip
            
            #pragma target 3.0
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float3 color: COLOR0;
                float2 uv: TEXCOORD0;
                float2 effectcoord: TEXCOORD2;
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
            
            #include "ZDCharacter-CBufferProperties.hlsl"
            
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                v.vertex.y += (sin(_Time.y + v.effectcoord.x + v.effectcoord.y) + 0.5) * 0.3 * _FloatModel;
                
                half RTD_OL_OLWABVD_OO = 1.0;
                half4 _OutlineWidthControl_var = tex2Dlod(_OutlineWidthControl, float4(v.uv, 0.0, 0));
                
                half2 RTD_OL_DNOL_OO = v.uv;
                half2 node_8743 = RTD_OL_DNOL_OO;
                float2 node_1283_skew = node_8743 + 0.2127 + node_8743.x * 0.3713 * node_8743.y;
                float2 node_1283_rnd = 4.789 * sin(489.123 * (node_1283_skew));
                half node_1283 = frac(node_1283_rnd.x * node_1283_rnd.y * (1 + node_1283_skew.x));
                
                float3 _OEM = v.normal;
                
                half RTD_OL = (RTD_OL_OLWABVD_OO * 0.01) * lerp(1.0, node_1283, 0.3) * _OutlineWidthControl_var.r;
                
                half dist = distance(float3(0.0, v.vertex.y, 0.0), mul(GetWorldToObjectMatrix(), float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                half4 widthRange = _OutlineWidth_MinWidth_MaxWidth_Dist_DistBlur;
                
                RTD_OL *= min(widthRange.y * 2.0, dist * widthRange.z)/* (lerp(widthRange.x, widthRange.y, saturate(dist - 0.05) * widthRange.z))*/;
                
                o.vertex = TransformObjectToHClip(float4(v.vertex.xyz + _OEM * RTD_OL, 1).xyz) / _OutlineEnable;
                o.uv = v.uv;
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                #if _AlphaClip
                    half4 effectiveMask = SAMPLE_TEXTURE2D(_EffectiveMap, sampler_EffectiveMap, i.uv.xy);
                    half4 effectiveDisslive = _EffectiveColor;
                    
                    half alphaMinus = 1.0 - _EffectiveColor.a;
                    effectiveDisslive.a = smoothstep(alphaMinus - 0.1, alphaMinus + 0.1, (1.0 - effectiveMask.r + 0.1 * (_EffectiveColor.a - 0.5) * 2.0));
                    
                    clip(effectiveDisslive.a - 0.5);
                #endif
                
                return 1.0;
            }
            ENDHLSL
            
        }
    }
    
    // Uses a custom shader GUI to display settings. Re-use the same from Lit shader as they have the
    // same properties.
    CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.ZDCharacter"
}