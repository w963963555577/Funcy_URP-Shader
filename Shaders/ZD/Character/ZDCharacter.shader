Shader "ZDShader/URP/Character"
{
    Properties
    {
        _BoneMatrixMap ("Bone Matrix Map", 2DArray) = "black" { }
        
        _diffuse ("BaseColor", 2D) = "white" { }
        [HDR]_Color ("BaseColor", Color) = (1.0, 1.0, 1.0, 1)
        [Toggle(_ClippingAlbedoAlpha)] _ClippingAlbedoAlpha ("Enable Clipping", float) = 0
        
        _SubsurfaceScattering ("Scatter", Range(0, 1)) = 0.2
        _SubsurfaceRadius ("Radius", Range(0, 5.0)) = 2.0
        
        _EdgeLightWidth ("Edge Light Width", Range(0, 1)) = 1
        _EdgeLightIntensity ("Edge Light Intensity", Range(0, 1)) = 1
        
        _Flash ("Flash", Float) = 0
        _mask ("ESSGMask", 2D) = "(0, 0.5, 0, 0)" { }
        [HideInInspector] [Toggle(_Mask_Texture_Enabled)] _Mask_Texture_Enabled ("_Mask_Texture_Enabled", float) = 1
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
        _Picker_10 ("Picker_10", Color) = (0.0, 0.5, 0.0, 0.0)
        _Picker_11 ("Picker_11", Color) = (0.0, 0.5, 0.0, 0.0)
        
        _ShadowColor0 ("ShadowColor0", Color) = (1, 0.7344488, 0.514151, 0.0)
        _ShadowColor1 ("ShadowColor1", Color) = (0.3160377, 0.4365495, 1, 0.0)
        _ShadowColor2 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.0)
        _ShadowColor3 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.0)
        _ShadowColor4 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.0)
        _ShadowColor5 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.0)
        _ShadowColor6 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.0)
        _ShadowColor7 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.0)
        _ShadowColor8 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.0)
        _ShadowColor9 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.0)
        _ShadowColor10 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.0)
        _ShadowColor11 ("ShadowColor1", Color) = (0.0, 0.0, 0.0, 0.0)
        _ShadowColorElse ("ShadowColorElse", Color) = (0.5471698, 0.5471698, 0.5471698, 1)
        
        [Toggle(_OutlineEnable)] _OutlineEnable ("Enable Outline", float) = 1
        
        _OutlineWidthControl ("Outline Width Control", 2D) = "white" { }
        
        // _DiscolorationSystem
        [Toggle]_Discoloration ("Enabled", Range(0, 1)) = 1
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
        
        
        [HDR]_OutlineColor ("Color", Color) = (0.0075, 0.0006, 0.0006, 1)
        _DiffuseBlend ("Diffuse Blend", Range(0, 1)) = 0.2
        _OutlineDistProp ("Outline Ctrl Properties", Vector) = (0.5, 1.0, 0.3, 0.0)
        
        //Expression
        [NoScaleOffset]_ExpressionMap ("Face Sheet", 2D) = "black" { }
        [NoScaleOffset]_ExpressionQMap ("Q Face Sheet", 2D) = "black" { }
        
        [IntRange]_SelectBrow ("Select Brow", Range(0, 4)) = 0
        _BrowRect ("Brow UV Rect", Vector) = (0, 0.45, 0.855, 0.3)
        [IntRange]_SelectFace ("Select Face", Range(0, 17)) = 0
        _FaceRect ("Eyes UV Rect", Vector) = (0, -0.02, 0.855, 0.37)
        [IntRange]_SelectMouth ("Select Mouth ", Range(0, 16)) = 0
        _MouthRect ("Mouth UV Rect", Vector) = (0, -0.97, 0.427, 0.28)
        [IntRange]_SelectBlush ("Select Blush ", Range(0, 2)) = 0
        _BlushRect ("Blush UV Rect", Vector) = (0, 0, 1, 1)
        
        [MaterialToggle] _FloatModel ("Float Model", float) = 0
        
        //OS Disslove
        _DissloveMap ("DissloveMap Map", 2D) = "white" { }
        [HDR]_EffectiveColor_Light ("_EffectiveColor", Color) = (0.0, 6.0, 4.3, 1.0)
        [HDR]_EffectiveColor_Dark ("_EffectiveColor Dark", Color) = (2.07, 0.6, 6.0, 1.0)
        _EffectiveDisslove ("Disslove", Range(0.0, 1.0)) = 1.0
        [Toggle] _DissliveWithDiretion ("From Direction", float) = 0
        _DissliveAngle ("Angle", Range(-180, 180)) = 0
        
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
            #pragma multi_compile _ _DrawMeshInstancedProcedural
            #pragma shader_feature_local _AnimationInstancing
            #pragma shader_feature_local _ClippingAlbedoAlpha
            #pragma shader_feature_local _InsightDisable
            
            #pragma target 3.0
            
            uniform half4 _CharacterOutlineColorAndBlend;
            uniform half4 _CharacterOutlineElseColorAndBlend;
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float2 uv: TEXCOORD0;
                float2 effectcoord: TEXCOORD2;
                
                #ifndef _SKINBONE_ATTACHED
                    float4 boneWeight: BLENDWEIGHTS;
                    uint4 boneIndex: BLENDINDICES;
                #endif
                
                #ifdef _DrawMeshInstancedProcedural
                    uint mid: SV_INSTANCEID;
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                #endif
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float2 uv: TEXCOORD0;
                float4 positionSS: TEXCOORD1;
                float vertexDist: TEXCOORD2;
                
                /*OS Disslove*/
                float3 OSuvMask: TEXCOORD3;
                float4 OSuv1: TEXCOORD4;
                float4 OSuv2: TEXCOORD5;
                
                float4 outlineColor: COLOR;
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    UNITY_VERTEX_OUTPUT_STEREO
                #endif
            };
            
            
            #include "Packages/com.zd.urp.funcy/Shaders/ZD/Character/ZDCharacter-CBufferProperties.hlsl"
            
            v2f vert(appdata v)
            {
                v2f o = (v2f)0;
                #ifdef _DrawMeshInstancedProcedural
                    uint mid = _VisibleInstanceOnlyTransformIDBuffer[v.mid];
                #else
                    uint mid = 0;
                    UNITY_SETUP_INSTANCE_ID(v);
                    UNITY_TRANSFER_INSTANCE_ID(v, o);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                #endif
                
                #if _AnimationInstancing
                    float4x4 am = AnimationInstancingMatrix(v.boneIndex, v.boneWeight, mid);
                    float4 positionOS = mul(am, v.vertex);
                    float3 normalOS = mul((float3x3)am, v.normal);
                    
                    v.vertex = positionOS;
                    v.normal = normalOS.xyz;
                #endif
                
                
                v.vertex.y += (sin(_Time.y + v.effectcoord.x + v.effectcoord.y) + 0.5) * 0.3 * _FloatModel;
                
                /*OS Disslove*/
                GetDissloveInput(v.vertex, v.normal, _DissloveMap_ST, o.OSuv1, o.OSuv2, o.OSuvMask);
                
                
                half RTD_OL_OLWABVD_OO = 1.0;
                half4 _OutlineWidthControl_var = SAMPLE_TEXTURE2D_LOD(_OutlineWidthControl, sampler_OutlineWidthControl, v.uv, 0);
                
                half2 RTD_OL_DNOL_OO = v.uv;
                half2 node_8743 = RTD_OL_DNOL_OO;
                float2 node_1283_skew = node_8743 + 0.2127 + node_8743.x * 0.3713 * node_8743.y;
                float2 node_1283_rnd = 4.789 * sin(489.123 * (node_1283_skew));
                half node_1283 = frac(node_1283_rnd.x * node_1283_rnd.y * (1 + node_1283_skew.x));
                
                float3 _OEM = v.normal;
                
                half RTD_OL = (RTD_OL_OLWABVD_OO * 0.01) * lerp(1.0, node_1283, 0.3) * _OutlineWidthControl_var.r;
                
                #ifdef _DrawMeshInstancedProcedural
                    half dist = distance(v.vertex.xyz, mul(_WorldToObjectBuffer[mid], float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                #else
                    half dist = distance(v.vertex.xyz, mul(GetWorldToObjectMatrix(), float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                #endif
                half4 widthRange = _OutlineDistProp;
                
                RTD_OL *= max(widthRange.x, min(widthRange.y * 2.0, dist * widthRange.z));
                #ifdef _DrawMeshInstancedProcedural
                    dist = distance(0.0.xxx, mul(_WorldToObjectBuffer[mid], float4(GetCameraPositionWS().xyz, 1.0)).xyz);
                #else
                    dist = distance(0.0.xxx, mul(GetWorldToObjectMatrix(), float4(GetCameraPositionWS().xyz, 1.0)).xyz);
                #endif
                
                float4 positionCS;
                #ifdef _DrawMeshInstancedProcedural
                    float3 positionWS = mul(_ObjectToWorldBuffer[mid], float4(v.vertex.xyz + _OEM * RTD_OL, 1.0)).xyz;
                    positionCS = TransformWorldToHClip(float4(positionWS, 1).xyz);
                #else
                    positionCS = TransformObjectToHClip(float4(v.vertex.xyz + _OEM * RTD_OL, 1).xyz);
                #endif
                
                half4 _diffuse_var = SAMPLE_TEXTURE2D_LOD(_diffuse, sampler_diffuse, v.uv, 0);
                #if _InsightDisable
                    o.outlineColor.rgb = _OutlineColor.rgb + _diffuse_var.rgb * _DiffuseBlend;
                #else
                    o.outlineColor.rgb = lerp(_OutlineColor.rgb + _diffuse_var.rgb * _DiffuseBlend, lerp(_CharacterOutlineElseColorAndBlend.rgb, _CharacterOutlineColorAndBlend.rgb, max(_InsightSystemIsSelf, _InsightSystemIsSelect)), _CharacterOutlineColorAndBlend.a);
                #endif
                
                o.vertex = positionCS;
                #ifdef SHADER_API_D3D11
                    o.vertex /= _OutlineEnable;
                #endif
                
                o.positionSS = ComputeScreenPos(positionCS, _ProjectionParams.x);
                
                o.uv = v.uv;
                o.vertexDist = dist;
                
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_SETUP_INSTANCE_ID(i);
                    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                #endif
                
                float2 screenUV = i.positionSS.xy / i.positionSS.w;
                #if _DrawMeshInstancedProcedural
                #else
                    DistanceDisslove(screenUV, i.vertexDist);
                #endif
                
                half4 effectiveMask = SAMPLE_TEXTURE2D(_EffectiveMap, sampler_EffectiveMap, i.uv.xy);
                half4 effectiveDisslive = _EffectiveColor;
                
                half alphaMinus = 1.0 - _EffectiveColor.a;
                effectiveDisslive.a = smoothstep(alphaMinus - 0.1, alphaMinus + 0.1, (1.0 - effectiveMask.r + 0.1 * (_EffectiveColor.a - 0.5) * 2.0));
                
                /*OS Disslove*/
                half osEffectiveDisslive = _EffectiveDisslove;
                half osEdgeArea;
                half osValue = osEffectiveDisslive;
                half4 osEffectiveMask;
                osEffectiveDisslive = GetDissloveAlpha(i.OSuv1, i.OSuv2, i.OSuvMask, osEffectiveDisslive, osEdgeArea, osEffectiveMask);
                
                half gradient = smoothstep(osValue + 0.2, osValue - 0.2, (lerp(osEffectiveMask.r, i.OSuv2.w + 0.2 + (0.5 - osValue) + 0.15 * (1.0 - osValue), _DissliveWithDiretion)));
                i.outlineColor.rgb = lerp(i.outlineColor.rgb, lerp(_EffectiveColor_Light.rgb, _EffectiveColor_Dark.rgb, gradient), osEdgeArea);
                /*OS Disslove*/
                
                half4 col = float4(i.outlineColor.rgb, _Color.a * effectiveDisslive.a) * osEffectiveDisslive;
                #if defined(_ClippingAlbedoAlpha)
                    half4 _diffuse_var = SAMPLE_TEXTURE2D(_diffuse, sampler_diffuse, i.uv.xy);
                    clip(_diffuse_var.a * osEffectiveDisslive - 0.5);
                #endif
                //col = MixGlobalFog(col, i.positionWS_And_FogFactor.xyz, i.positionWS_And_FogFactor.w);
                return col;
            }
            ENDHLSL
            
        }
        
        
        Pass
        {
            // "Lightmode" tag must be "LightweightForward" or not be defined in order for
            // to render objects.
            Name "Forward"
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
            #pragma target 4.0
            
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #define _MAIN_LIGHT_SHADOWS 1
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #define _MAIN_LIGHT_SHADOWS_CASCADE 1
            //#pragma multi_compile _ _SHADOWS_SOFT
            #define _SHADOWS_SOFT 1
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _AlphaClip
            
            //#pragma multi_compile _ _DiscolorationSystem
            #define _DiscolorationSystem 1
            //#pragma shader_feature_local _ExpressionEnable
            #define _ExpressionEnable 1
            
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
                #pragma shader_feature_local _PickerDebug_10
                #pragma shader_feature_local _PickerDebug_11
                #pragma shader_feature_local _Desaturation
            #endif
            
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ _DrawMeshInstancedProcedural
            #pragma shader_feature_local _AnimationInstancing
            #pragma shader_feature_local _ClippingAlbedoAlpha
            #pragma shader_feature_local _InsightDisable
            
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            
            uniform half4 _CharacterColorAndBlend;
            
            #include "Packages/com.zd.urp.funcy/Shaders/ZD/Character/ZDCharacter-CBufferProperties.hlsl"
            
            
            TEXTURE2D(_mask);                       SAMPLER(sampler_mask);
            TEXTURE2D(_NormalMap);                  SAMPLER(sampler_NormalMap);
            TEXTURE2D(_SelfMask);                   SAMPLER(sampler_SelfMask);
            TEXTURE2D(_ExpressionMap);              SAMPLER(sampler_ExpressionMap);
            TEXTURE2D(_ExpressionQMap);
            
            struct Attributes
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
                float2 uv0: TEXCOORD0;
                float2 uv1: TEXCOORD1;
                float2 effectcoord: TEXCOORD2;
                float2 selfShadowCoord: TEXCOORD3;
                
                #ifndef _SKINBONE_ATTACHED
                    float4 boneWeight: BLENDWEIGHTS;
                    uint4 boneIndex: BLENDINDICES;
                #endif
                
                #ifdef _DrawMeshInstancedProcedural
                    uint mid: SV_INSTANCEID;
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                #endif
            };
            
            struct Varyings
            {
                float4 uv01: TEXCOORD0;
                float4 effectcoord: TEXCOORD1;
                float4 positionWSAndFogFactor: TEXCOORD2;
                float4 normalWS: TEXCOORD3;                 /*w:Expression map Face Index*/
                float4 positionSS: TEXCOORD4;               /*z:w:Expression map Mouth Index*/
                float3 faceLMProp: TEXCOORD5;
                float4 vertexDist_And_viewDir: TEXCOORD6;
                
                #if _ExpressionEnable
                    float4 expressionUVEyes: TEXCOORD7;
                    float4 expressionUVBrow: TEXCOORD8;
                    float4 expressionUVMouth: TEXCOORD9;
                    float4 expressionUVBlush: TEXCOORD10;
                #endif
                
                /*OS Disslove*/
                //float3 OSuvMask: TEXCOORD11;
                //float4 OSuv1: TEXCOORD12;
                //float4 OSuv2: TEXCOORD13;
                half4 mainLightColor: TEXCOORD14;
                float3 mainLightDirection: TEXCOORD15;
                
                float4 positionCS: SV_POSITION;
                
                
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    UNITY_VERTEX_OUTPUT_STEREO
                #endif
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
                    selectMouth = fmod(selectMouth - 1.0, 8.0);
                    float pX = (uv.x * 0.5 + floor(selectMouth * 0.25) * 0.5 + 1.0) * 0.5;
                    float pY = (uv.y * 0.5 + (mouthCount - fmod(selectMouth, 4.0) * 0.5) + 1.5) / (mouthCount * 0.5);
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
                
                #ifdef _DrawMeshInstancedProcedural
                    uint mid = _VisibleInstanceOnlyTransformIDBuffer[input.mid];
                #else
                    uint mid = 0;
                    UNITY_SETUP_INSTANCE_ID(input);
                    UNITY_TRANSFER_INSTANCE_ID(input, output);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                #endif
                
                #if _AnimationInstancing
                    float4x4 am = AnimationInstancingMatrix(input.boneIndex, input.boneWeight, mid);
                    float4 positionOS = mul(am, input.positionOS);
                    float3 normalOS = mul((float3x3)am, input.normalOS);
                #else
                    float4 positionOS = input.positionOS;
                    float3 normalOS = input.normalOS;
                #endif
                
                positionOS.y += (sin(_Time.y + input.effectcoord.x + input.effectcoord.y) + 0.5) * 0.3 * _FloatModel;
                
                VertexPositionInputs vertexInput;
                VertexNormalInputs vertexNormalInput;
                #ifdef _DrawMeshInstancedProcedural
                    vertexInput = InitVertexPositionInputs(positionOS.xyz, mid);
                    vertexNormalInput = InitVertexNormalInputs(normalOS.xyz, mid);
                #else
                    vertexInput = GetVertexPositionInputs(positionOS.xyz);
                    vertexNormalInput = GetVertexNormalInputs(normalOS.xyz);
                #endif
                
                /*OS Disslove*/
                //GetDissloveInput(positionOS, normalOS, _DissloveMap_ST, output.OSuv1, output.OSuv2, output.OSuvMask);
                
                // Computes fog factor per-vertex.
                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                
                // TRANSFORM_TEX is the same as the old shader library.
                output.uv01.xy = TRANSFORM_TEX(input.uv0, _diffuse);
                output.uv01.zw = input.uv1;
                input.selfShadowCoord = lerp(input.uv1, input.selfShadowCoord, _FaceLightMapCombineMode);
                output.effectcoord = float4(input.effectcoord, input.selfShadowCoord);
                output.positionWSAndFogFactor = float4(vertexInput.positionWS, fogFactor);
                output.normalWS.xyz = vertexNormalInput.normalWS;
                
                //SelfMask
                half indexSelf = _SelfMaskDirection;
                half3 dirPZPY = half3(0, 0, 1);half3 upPZPY = half3(0, 1, 0);
                half3 dirPYNX = half3(0, 1, 0);half3 upPYNX = half3(-1, 0, 0);
                half3 useDir = lerp(dirPZPY, dirPYNX, min(1, indexSelf));
                half3 useUp = lerp(upPZPY, upPYNX, min(1, indexSelf));
                
                #ifdef _DrawMeshInstancedProcedural
                    half3 objectDirection = mul(_ObjectToWorldBuffer[mid], float4(useDir.xyz, 0.0)).xyz;
                #else
                    half3 objectDirection = mul(GetObjectToWorldMatrix(), float4(useDir.xyz, 0.0)).xyz;
                #endif
                objectDirection.y = 0;
                
                Light mainLight = LerpLightDirection(objectDirection.xyz);
                // unity_LightData.z is 1 when not culled by the culling mask, otherwise 0.
                mainLight.distanceAttenuation = 1;
                #if defined(LIGHTMAP_ON) || defined(_MIXED_LIGHTING_SUBTRACTIVE)
                    // unity_ProbesOcclusion.x is the mixed light probe occlusion data
                    mainLight.distanceAttenuation *= unity_ProbesOcclusion.x;
                #endif
                mainLight.shadowAttenuation = 1.0;
                
                output.mainLightColor.a = lerp(1.0, max(1e-04, max(_MainLightColor.r, max(_MainLightColor.b, _MainLightColor.g))), unity_LightData.z);
                output.mainLightColor.rgb = lerp(1.0, _MainLightColor.rgb / (output.mainLightColor.a), unity_LightData.z);
                
                half3 objectUp = mul(GetObjectToWorldMatrix(), float4(useUp.xyz, 0.0)).xyz;
                half3 lightXZDirection = -normalize(float3(mainLight.direction.x, 0.0, mainLight.direction.z));
                
                half cm = clamp(normalize(cross(objectDirection.xyz, lightXZDirection.xyz)).y, -1., 1.);
                half odl = -dot(objectDirection.xyz, lightXZDirection.xyz);
                half angle01 = acos(odl) * 0.318309886;
                angle01 = Remap(angle01, 0, 1, 0.01, 0.99);
                half upNear = dot(objectUp.xyz, half3(0, 1, 0));
                output.faceLMProp = float3(cm, angle01, upNear);
                
                /*
                x,y,z = eulerAngles:X-Y-Z
                transform.forward = mainLight.direction = f[cos(x) * sin(y), -sin(x), cos(x) * cos(y)]
                */
                float radiusX = 170 * 0.0174532925;/*170 * deg2rad = 170 * 0.0174532925*/
                float fy = sin(radiusX);/*when sincos(x) when x as const, then command call 1 times*/
                float ratio = sqrt((1.0 - fy * fy) / (mainLight.direction.x * mainLight.direction.x + mainLight.direction.z * mainLight.direction.z));
                output.mainLightDirection = float3(mainLight.direction.x * ratio, fy, mainLight.direction.z * ratio);
                
                #ifdef _DrawMeshInstancedProcedural
                    output.vertexDist_And_viewDir.x = distance(float3(0.0, 0.0, 0.0), mul(_WorldToObjectBuffer[mid], float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                #else
                    output.vertexDist_And_viewDir.x = distance(float3(0.0, 0.0, 0.0), mul(GetWorldToObjectMatrix(), float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                #endif
                
                output.vertexDist_And_viewDir.yzw = normalize(GetCameraPositionWS().xyz - vertexInput.positionWS);
                
                output.positionCS = vertexInput.positionCS;
                output.positionSS = ComputeScreenPos(vertexInput.positionCS, _ProjectionParams.x);
                
                #if _ExpressionEnable
                    _SelectBrow = round(_SelectBrow);
                    _SelectFace = round(_SelectFace);
                    _SelectMouth = round(_SelectMouth);
                    
                    float faceMapBlend = step(9, _SelectFace);
                    float mouthMapBlend = step(9, _SelectMouth);
                    output.normalWS.w = faceMapBlend;
                    output.positionSS.z = mouthMapBlend;
                    
                    half4 _BrowTRS = half4(1.0 / _BrowRect.zw, -_BrowRect.xy);
                    half2 browOffset = half2(0.5, 1.0 / 8.0);
                    half2 browArea = GetBrowArea(output.uv01.zw, 8.0, _SelectBrow, browOffset);
                    half2 browPivot = GetBrowArea(half2(0.5, 0.5), 8.0, _SelectBrow, browOffset);
                    half2 browUV = ((browArea - browPivot) * _BrowTRS.xy) + browPivot + half2(_BrowTRS.z * browOffset.x, _BrowTRS.w * browOffset.y);
                    half2 browMaskUV = (output.uv01.zw - half2(0.5, 0.5)) * _BrowTRS.xy + half2(0.5, 0.5) + _BrowTRS.zw;
                    half2 browMaskRect = abs(((browMaskUV - half2(0.5, 0.5)) * half2(2, 2)));
                    output.expressionUVBrow = half4(browUV, browMaskRect);
                    
                    
                    half4 _EyesTRS = half4(1.0 / _FaceRect.zw, -_FaceRect.xy);
                    half2 eyeOffset = half2(0.5, 0.125);
                    half2 eyesArea = GetEyesArea(output.uv01.zw, 8.0, _SelectFace, eyeOffset);
                    half2 eyesPivot = GetEyesArea(half2(0.5, 0.5), 8.0, _SelectFace, eyeOffset);
                    half2 eyesUV = ((eyesArea - eyesPivot) * _EyesTRS.xy) + eyesPivot + half2(_EyesTRS.z * eyeOffset.x, _EyesTRS.w * eyeOffset.y);
                    half2 eyesMaskUV = (output.uv01.zw - half2(0.5, 0.5)) * _EyesTRS.xy + half2(0.5, 0.5) + _EyesTRS.zw;
                    half2 eyesMaskRect = abs(((eyesMaskUV - half2(0.5, 0.5)) * half2(2, 2)));
                    output.expressionUVEyes = half4(eyesUV, eyesMaskRect);
                    
                    
                    half4 _MouthsTRS = half4(1.0 / _MouthRect.zw, -_MouthRect.xy);
                    half2 mouthOffset = half2(0.25, 0.125);
                    half2 mouthArea = GetMouthArea(output.uv01.zw, 8.0, _SelectMouth, mouthOffset);
                    half2 mouthPivot = GetMouthArea(half2(0.5, 0.5), 8.0, _SelectMouth, mouthOffset);
                    half2 mouthUV = ((mouthArea - mouthPivot) * _MouthsTRS.xy) + mouthPivot + half2(_MouthsTRS.z * mouthOffset.x, _MouthsTRS.w * mouthOffset.y);
                    half2 mouthMaskUV = (output.uv01.zw - half2(0.5, 0.5)) * _MouthsTRS.xy + half2(0.5, 0.5) + _MouthsTRS.zw;
                    half2 mouthMaskRect = abs(((mouthMaskUV - half2(0.5, 0.5)) * half2(2, 2)));
                    output.expressionUVMouth = half4(mouthUV, mouthMaskRect);
                    
                    
                    half4 _BlushTRS = half4(1.0 / _BlushRect.zw, -_BlushRect.xy);
                    half2 blushArea = GetBrowArea(output.uv01.zw, 4.0, _SelectBlush, browOffset);
                    half2 blushPivot = GetBrowArea(half2(0.5, 0.5), 4.0, _SelectBlush, browOffset);
                    half2 blushUV = ((blushArea - blushPivot) * _BlushTRS.xy) + blushPivot + half2(_BlushTRS.z * browOffset.x, _BlushTRS.w * browOffset.y);
                    half2 blushMaskUV = (output.uv01.zw - half2(0.5, 0.5)) * _BlushTRS.xy + half2(0.5, 0.5) + _BlushTRS.zw;
                    half2 blushMaskRect = abs(((blushMaskUV - half2(0.5, 0.5)) * half2(2, 2)));
                    output.expressionUVBlush = half4(blushUV, blushMaskRect);
                    
                #endif
                
                return output;
            }
            
            float LigntMapAreaInUV1(Varyings i, float origShadow)
            {
                float cm = i.faceLMProp.x;
                float angle01 = i.faceLMProp.y;
                float upNear = i.faceLMProp.z;
                
                float4 _SelfMask_UV1_var = SAMPLE_TEXTURE2D(_SelfMask, sampler_SelfMask, float2(i.uv01.z * cm, i.uv01.w));
                half faceLightMapScaleRange = lerp(1.0, 0.0625, _FaceLightMapCombineMode) * 0.1;
                
                half _SelfShadow_UV1_var = SAMPLE_TEXTURE2D(_EffectiveMap, sampler_EffectiveMap, float2(i.effectcoord.z + cm * angle01 * faceLightMapScaleRange, i.effectcoord.w)).g;
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
                    float grayArea_9 = min(1.0, (smoothstep(0.90, 1.00, gray) * 2.0));
                    float grayArea_8 = min(1.0, (smoothstep(0.70, 0.80, gray) * 2.0));
                    float grayArea_7 = min(1.0, (smoothstep(0.60, 0.70, gray) * 2.0));
                    float grayArea_6 = min(1.0, (smoothstep(0.45, 0.60, gray) * 2.0));
                    float grayArea_5 = min(1.0, (smoothstep(0.35, 0.45, gray) * 2.0));
                    float grayArea_4 = 1.00 - grayArea_5;
                    float grayArea_3 = min(1.0, (smoothstep(0.70, 0.80, gray_oneminus) * 2.0));
                    float grayArea_2 = min(1.0, (smoothstep(0.80, 0.90, gray_oneminus) * 2.0));
                    float grayArea_1 = min(1.0, (smoothstep(0.90, 0.95, gray_oneminus) * 2.0));
                    
                    float grayArea_0 = min(1.0, (smoothstep(0.95, 1.00, gray_oneminus) * 2.0));
                    #if _ExpressionEnable
                        grayArea_0 = max(grayArea_0, min(1.0, smoothstep(0.4, 0.5, eyeAreaReplace.x) * eyeAreaReplace.y - eyeCenter));
                        grayArea_0 = max(grayArea_0, smoothstep(0.5, 1.0, browReplace.x) * browReplace.y);
                        grayArea_0 = max(grayArea_0, smoothstep(0.5, 1.0, mouthReplace.x) * mouthReplace.y);
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
            
            half4 WorldToShadowCoord(float3 positionWS)
            {
                #ifdef _MAIN_LIGHT_SHADOWS_CASCADE
                    half cascadeIndex = ComputeCascadeIndex(positionWS);
                #else
                    half cascadeIndex = 0;
                #endif
                float4x4 m = _MainLightWorldToShadow[cascadeIndex];
                
                return mul(m, half4(positionWS, 1.0));
            }
            /*Not using*/
            /*
            half BRDFSpecular(half metallic, half smoothness, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
            {
                float3 halfDir = SafeNormalize(float3(lightDirectionWS) + float3(viewDirectionWS));
                
                float NoH = max(0.0, dot(normalWS, halfDir));
                half LoH = max(0.0, dot(lightDirectionWS, halfDir));
                
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
            */
            half4 LitPassFragment(Varyings i): SV_Target
            {
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_SETUP_INSTANCE_ID(i);
                    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                #endif
                
                half3 positionWS = i.positionWSAndFogFactor.xyz;
                half4 positionSS = i.positionSS;
                half2 screenUV = positionSS.xy /= positionSS.w;
                half vertexDist = i.vertexDist_And_viewDir.x;
                #if _DrawMeshInstancedProcedural
                #else
                    DistanceDisslove(screenUV, vertexDist);
                #endif
                /*get textures color*/
                half4 _diffuse_var = SAMPLE_TEXTURE2D(_diffuse, sampler_diffuse, i.uv01.xy);
                half4 _ESSGMask_var = lerp(half4(0, 0.5, 0, 0), SAMPLE_TEXTURE2D(_mask, sampler_mask, i.uv01.xy), _Mask_Texture_Enabled); // R-emission, G-Shadow refract ratio, B-specular, A-gloss,
                half4 _SelfMask_UV0_var = SAMPLE_TEXTURE2D(_SelfMask, sampler_SelfMask, i.uv01.xy);
                
                Light mainLight;
                mainLight.direction = i.mainLightDirection;
                // unity_LightData.z is 1 when not culled by the culling mask, otherwise 0.
                mainLight.distanceAttenuation = 1;
                #if defined(LIGHTMAP_ON) || defined(_MIXED_LIGHTING_SUBTRACTIVE)
                    // unity_ProbesOcclusion.x is the mixed light probe occlusion data
                    mainLight.distanceAttenuation *= unity_ProbesOcclusion.x;
                #endif
                
                mainLight.shadowAttenuation = 1.0;
                /*push face CastShadow to remove weird shadow*/
                half4 shadowCoords = WorldToShadowCoord(lerp(positionWS + mainLight.direction * min(vertexDist, 1.0), positionWS, _SelfMask_UV0_var.b));
                mainLight.shadowAttenuation = MainLightRealtimeShadow(shadowCoords);
                
                half3 additionalLightColor = 0.0h.rrr;
                // Additional lights loop
                #ifdef _ADDITIONAL_LIGHTS
                    BRDFData brdfData;
                    InitializeBRDFData(1.0.rrr, 0.0, 0.0, 0.0, 1.0, brdfData);
                    
                    int additionalLightsCount = GetAdditionalLightsCount();
                    half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);
                    
                    for (int iter = 0; iter < additionalLightsCount; iter ++)
                    {
                        Light light = GetAdditionalLight(iter, positionWS);
                        
                        half3 currentLightColor = LightingPhysicallyBased(brdfData, light, i.normalWS.xyz, viewDirectionWS) ;
                        additionalLightColor += currentLightColor;
                    }
                    additionalLightColor = min(1.0.xxx, additionalLightColor);
                #endif
                
                half3 viewDirection = i.vertexDist_And_viewDir.yzw;
                half3 normalDirection = i.normalWS.xyz;
                
                half glossMask = _ESSGMask_var.a;
                half specularMask = _ESSGMask_var.b;
                
                half NdotL = dot(i.normalWS.xyz, mainLight.direction.xyz);
                half selfShadow = mainLight.distanceAttenuation * mainLight.shadowAttenuation ;
                half fresnel = max(1.0 - dot(viewDirection, normalDirection), max(0.0, dot(viewDirection, mainLight.direction - normalDirection * 0.82))) ;
                half SSS = max(NdotL, fresnel) * _SubsurfaceRadius * (1.0 - glossMask);
                
                
                #if _ExpressionEnable
                    half faceMapBlend = i.normalWS.w;
                    half mouthMapBlend = i.positionSS.z;


                    half2 browUV = i.expressionUVBrow.xy;
                    half2 browMaskRect = i.expressionUVBrow.zw;
                    half browMask = 1.0 - step(1.0, max(browMaskRect.x, browMaskRect.y));
                    half4 Brow = SAMPLE_TEXTURE2D(_ExpressionMap, sampler_ExpressionMap, browUV);
                    //SAMPLE_TEXTURE2D(_ExpressionQMap, sampler_ExpressionQMap, browUV);


                    half2 blushUV = i.expressionUVBlush.xy;
                    half2 blushMaskRect = i.expressionUVBlush.zw;
                    half blushMask = 1.0 - step(1.0, max(blushMaskRect.x, blushMaskRect.y));
                    half4 Blush = SAMPLE_TEXTURE2D(_ExpressionQMap, sampler_ExpressionMap, blushUV);
                    //SAMPLE_TEXTURE2D(_ExpressionQMap, sampler_ExpressionQMap, browUV);


                    half2 eyesUV = i.expressionUVEyes.xy;
                    half2 eyesMaskRect = i.expressionUVEyes.zw;
                    half eyesMask = 1.0 - step(1.0, max(eyesMaskRect.x, eyesMaskRect.y));
                    half generateIndex9 = saturate(_SelectFace - 9.0);
                    half generateIndex10 = saturate(_SelectFace - 10.0);
                    half2 generateIndex9UVOffset = half2(0.0, 0.125) * generateIndex9;
                    half4 eyesColor1 = SAMPLE_TEXTURE2D(_ExpressionMap, sampler_ExpressionMap, eyesUV + generateIndex9UVOffset);
                    half4 eyesColor2 = SAMPLE_TEXTURE2D(_ExpressionQMap, sampler_ExpressionMap, eyesUV + generateIndex9UVOffset);
                    half eyesRightArea = step(eyesUV.x, 0.25);
                    half eyesLeftArea = 1.0 - eyesRightArea;
                    half4 Eyes = lerp(eyesColor1, eyesColor2, max(generateIndex10, faceMapBlend * lerp(eyesLeftArea, eyesRightArea, generateIndex9)));
                    //Eyes = lerp(Eyes, SAMPLE_TEXTURE2D(_ExpressionQMap, sampler_ExpressionQMap, eyesUV), _SelectExpressionMap);


                    half4 _MouthsTRS = half4(1.0 / _MouthRect.zw, -_MouthRect.xy);
                    half2 mouthUV = i.expressionUVMouth.xy;
                    half2 mouthMaskRect = i.expressionUVMouth.zw;
                    half mouthMask = 1.0 - step(1.0, max(mouthMaskRect.x, mouthMaskRect.y));
                    half4 mouthColor1 = SAMPLE_TEXTURE2D(_ExpressionMap, sampler_ExpressionMap, mouthUV);
                    half4 mouthColor2 = SAMPLE_TEXTURE2D(_ExpressionQMap, sampler_ExpressionMap, mouthUV);
                    half4 Mouth = lerp(mouthColor1, mouthColor2, mouthMapBlend);
                    //Mouth = lerp(Mouth, SAMPLE_TEXTURE2D(_ExpressionQMap, sampler_ExpressionQMap, mouthUV), _SelectExpressionMap);


                    _diffuse_var.rgb = lerp(_diffuse_var.rgb, Mouth.rgb, mouthMask * Mouth.a * min(1.0, _SelectMouth));
                    _diffuse_var.rgb = lerp(_diffuse_var.rgb, Eyes.rgb, eyesMask * smoothstep(0.0, 0.5, Eyes.a) * min(1.0, _SelectFace));
                    _diffuse_var.rgb = lerp(_diffuse_var.rgb, Brow.rgb, browMask * Brow.a * min(1.0, _SelectBrow));
                    _diffuse_var.rgb = lerp(_diffuse_var.rgb, Blush.rgb, blushMask * Blush.a * min(1.0, _SelectBlush));
                #endif


                half3 halfDirection = normalize(viewDirection + mainLight.direction);
                half specularValue = floor(pow(max(0, dot(i.normalWS.xyz, halfDirection)), exp2(lerp(1., 11., (_Gloss * glossMask)))) * 2.0);
                
                /*BDRF Specular but in this shader was nonconformity
                glossMask = min(max(0, glossMask + _Gloss), 1.0);
                float specularValue1 = BRDFSpecular(1.0, glossMask, i.normalWS.xyz, mainLight.direction, viewDirection) * NdotL;
                float specularValue2 = pow(dot(i.normalWS.xyz, halfDirection) * 0.5 + 0.5, exp2(lerp(1, 11, (glossMask)))) ;
                float specularValue = lerp(specularValue2, specularValue1, glossMask);
                specularValue = smoothstep(0.003, 0.004, specularValue) ;
                */
                
                half4 _SpecularColor_var = _SpecularColor;
                half4 _Color_var = _Color;


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
                        browReplace = half2(Brow.a, browMask);
                        mouthReplace = half2(Mouth.a, mouthMask);
                    #endif
                    
                    Step8Color(_SelfMask_UV0_var.a * _Discoloration, eyeAreaReplace, browReplace, mouthReplace, step_var, blackArea, skinArea, eyeArea);
                    
                    half3 colorRGB_A = step_var.rgb;
                    half3 colorRGB_B = _diffuse_var.rgb;
                    
                    half3 colorHSV_A = RGB2HSV(colorRGB_A);
                    half3 colorHSV_B = RGB2HSV(colorRGB_B);
                    
                    half3 mupArea = lerp(_diffuse_var.rgb, colorRGB_B * _DiscolorationColor_1.rgb * skinArea +
                    colorRGB_B * eyeArea * _DiscolorationColor_2.rgb +
                    colorRGB_B * (1.0 - skinArea - eyeArea), skinArea + eyeArea);
                    
                    _diffuse_var.rgb = lerp(HSV2RGB(half3(colorHSV_A.rg, colorHSV_B.b * (step_var.a + 1.0) + max(0, step_var.a))), mupArea, skinArea + eyeArea + blackArea);
                    
                #endif
                //ShadowReplacer
                half shadowArea0 = CaculateShadowArea(_diffuse_var, _Picker_0, _ShadowColor0.a);
                half shadowArea1 = CaculateShadowArea(_diffuse_var, _Picker_1, _ShadowColor1.a);
                half shadowArea2 = CaculateShadowArea(_diffuse_var, _Picker_2, _ShadowColor2.a);
                half shadowArea3 = CaculateShadowArea(_diffuse_var, _Picker_3, _ShadowColor3.a);
                half shadowArea4 = CaculateShadowArea(_diffuse_var, _Picker_4, _ShadowColor4.a);
                half shadowArea5 = CaculateShadowArea(_diffuse_var, _Picker_5, _ShadowColor5.a);
                half shadowArea6 = CaculateShadowArea(_diffuse_var, _Picker_6, _ShadowColor6.a);
                half shadowArea7 = CaculateShadowArea(_diffuse_var, _Picker_7, _ShadowColor7.a);
                half shadowArea8 = CaculateShadowArea(_diffuse_var, _Picker_8, _ShadowColor8.a);
                half shadowArea9 = CaculateShadowArea(_diffuse_var, _Picker_9, _ShadowColor9.a);
                half shadowArea10 = CaculateShadowArea(_diffuse_var, _Picker_10, _ShadowColor10.a);
                half shadowArea11 = CaculateShadowArea(_diffuse_var, _Picker_11, _ShadowColor11.a);
                half shadowTotalArea = min(1.0, shadowArea0 + shadowArea1 + shadowArea2 + shadowArea3 + shadowArea4 + shadowArea5 + shadowArea6 + shadowArea7 + shadowArea8 + shadowArea9 + shadowArea10 + shadowArea11);
                half shadowAreaElse = (1.0 - shadowTotalArea);
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
                    #if _PickerDebug_10
                        return float4(shadowArea10.xxx, 1.0);
                    #endif
                    #if _PickerDebug_11
                        return float4(shadowArea11.xxx, 1.0);
                    #endif
                #endif
                
                //PBRShadowArea
                half shadowRefr = _ESSGMask_var.g + (_ShadowOffset -0.5h) * 2.0h;
                half refractionShadowArea = NdotL + (shadowRefr - 0.5h) * 2.0h * _ShadowRefraction;
                half uvUseArea = lerp(0.0, LigntMapAreaInUV1(i, refractionShadowArea), _SelfMaskEnable);
                
                refractionShadowArea = lerp(refractionShadowArea, uvUseArea, _SelfMask_UV0_var.g);
                refractionShadowArea = 1.0 - smoothstep(0.5 - (1.0 - _ShadowRamp), 0.5 + (1.0 - _ShadowRamp) * 0.25, 1.0 - refractionShadowArea);
                selfShadow = 1.0 - smoothstep(0.5 - (1.0 - _SelfShadowRamp), 0.5 + (1.0 - _SelfShadowRamp), 1.0 - selfShadow);
                
                half mainLightIntensity_1_0 = max(0, 1.0 - i.mainLightColor.a);
                half mainLightIntensity_0_1 = 1.0 - mainLightIntensity_1_0;
                float PBRShadowArea = refractionShadowArea * lerp(1.0, selfShadow, _ReceiveShadow);
                PBRShadowArea = lerp(PBRShadowArea, 0.0, min(1.0, mainLightIntensity_1_0 * 3.125));
                PBRShadowArea *= PBRShadowArea = lerp(PBRShadowArea, SSS, _SubsurfaceScattering * specularMask * (1.0 - glossMask));
                half light2Dark = max(0.0, mainLightIntensity_1_0 - 0.32);
                mainLight.color = lerp(i.mainLightColor.rgb * (1.0 - light2Dark), 0.0, light2Dark) * lerp(1.0, i.mainLightColor.a, max(PBRShadowArea, 1.0 - _CustomLightIntensity)) * _CustomLightColor.rgb;
                
                float4 _EmissionColor_var = _EmissionColor;
                float emissionMask = _ESSGMask_var.r;
                float emMask = emissionMask;
                float3 _EmissionxBase_var = lerp(emMask, (_diffuse_var.rgb * emMask), _EmissionxBase);
                float _EmissionOn_var = _EmissionOn;
                float _Flash_var = (1.0 - max(0, dot(normalDirection, viewDirection))) * _Flash;
                float3 specularColor = _SpecularColor_var.rgb * specularValue * specularMask;
                
                
                //MixShadowReplacer
                float3 _diffuse_hsv = RGB2HSV(_diffuse_var.rgb);
                
                float3 shadowColor = shadowArea0 * _ShadowColor0.rgb + shadowArea1 * _ShadowColor1.rgb +
                shadowArea2 * _ShadowColor2.rgb + shadowArea3 * _ShadowColor3.rgb +
                shadowArea4 * _ShadowColor4.rgb + shadowArea5 * _ShadowColor5.rgb +
                shadowArea6 * _ShadowColor6.rgb + shadowArea7 * _ShadowColor7.rgb +
                shadowArea8 * _ShadowColor8.rgb + shadowArea9 * _ShadowColor9.rgb +
                shadowArea10 * _ShadowColor10.rgb + shadowArea11 * _ShadowColor11.rgb +
                shadowAreaElse * _ShadowColorElse.rgb;
                
                shadowColor.xyz = RGB2HSV(shadowColor.rgb);
                
                float endOfBrightness = min(1.0, shadowColor.z);
                float overexposed = shadowColor.z - endOfBrightness;
                //return float4(overexposed.xxx, 1.0);
                shadowColor.z = endOfBrightness;
                
                //shadowColor.y = lerp(shadowColor.y, _diffuse_hsv.y, 1.0 - _ShadowColorElse.a);
                shadowColor.rgb = HSV2RGB(shadowColor.xyz);
                
                
                float3 diffuseColor = lerp(_diffuse_var.rgb, _diffuse_var.rgb * shadowColor, 1.0 - PBRShadowArea);


                half clampMask = 1.0 - smoothstep(0.99, 1.0, abs(i.effectcoord.y - 0.5) * 2.0);
                float3 emissionColor = (_EmissionColor_var.rgb * _EmissionxBase_var * _EmissionOn_var);


                float3 emissive = (((mainLight.color.rgb * 0.4) * step((1.0 - 0.1), _Flash_var))
                + diffuseColor) * mainLight.color * _Color.rgb + specularColor +
                emissionColor + emissionColor * sin((sin(i.effectcoord.x * 2.0 * 6.28 + _Time.y * 3.0)) - 1.5 + _EmissionColor_var.a) * _EmissionFlow * clampMask +
                (float3(1, 0.3171664, 0.2549019) * _Flash_var * _Flash_var);
                
                
                half fresnelArea = smoothstep(1.0 - _EdgeLightWidth, 1.0 - _EdgeLightWidth * 0.7, fresnel);
                emissive = lerp(emissive, float3(1, 1, 1), fresnelArea * _EdgeLightIntensity);
                
                //Fog
                float fogFactor = i.positionWSAndFogFactor.w * i.positionWSAndFogFactor.w;
                fogFactor *= fogFactor;
                
                float3 finalColor = emissive.rgb + additionalLightColor * diffuseColor;
                #ifndef _InsightDisable
                    finalColor = lerp(finalColor, lerp(_CharacterColorAndBlend.rgb, _InsightSystemSelectColor.rgb, _InsightSystemSelectColor.a), min(_CharacterColorAndBlend.a, 1.0 - _InsightSystemIsSelf));
                #endif
                
                finalColor = MixFog(finalColor, fogFactor);
                
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
                
                /*OS Disslove*/
                /*
                half osEffectiveDisslive = _EffectiveDisslove;
                half osEdgeArea;
                half osValue = osEffectiveDisslive;
                half4 osEffectiveMask;
                osEffectiveDisslive = GetDissloveAlpha(i.OSuv1, i.OSuv2, i.OSuvMask, osEffectiveDisslive, osEdgeArea, osEffectiveMask);
                
                
                half gradient = smoothstep(osValue + 0.2, osValue - 0.2, (lerp(osEffectiveMask.r, i.OSuv2.w + 0.2 + (0.5 - osValue) + 0.15 * (1.0 - osValue), _DissliveWithDiretion)));
                finalColor = lerp(finalColor, lerp(_EffectiveColor_Light.rgb, _EffectiveColor_Dark.rgb, gradient), osEdgeArea);
                */
                /*OS Disslove*/
                
                float4 finalRGBA = float4(finalColor, _Color.a /* effectiveDisslive.a * osEffectiveDisslive*/);
                
                #if defined(_ClippingAlbedoAlpha)
                    clip(_diffuse_var.a /* osEffectiveDisslive*/ - 0.5);
                #endif
                //finalRGBA = MixGlobalFog(finalRGBA, positionWS.xyz, fogFactor);
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
            #pragma multi_compile _ _DrawMeshInstancedProcedural
            #pragma shader_feature_local _AnimationInstancing
            #pragma shader_feature_local _ClippingAlbedoAlpha
            
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            
            
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            
            
            #include "Packages/com.zd.urp.funcy/Shaders/ZD/Character/ZDCharacter-CBufferProperties.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            
            float3 _LightDirection;
            
            struct Attributes
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
                float2 texcoord: TEXCOORD0;
                float2 effectcoord: TEXCOORD2;
                
                #ifndef _SKINBONE_ATTACHED
                    float4 boneWeight: BLENDWEIGHTS;
                    uint4 boneIndex: BLENDINDICES;
                #endif
                
                #ifdef _DrawMeshInstancedProcedural
                    uint mid: SV_INSTANCEID;
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                #endif
            };
            
            struct Varyings
            {
                float2 uv: TEXCOORD0;
                /*OS Disslove*/
                float3 OSuvMask: TEXCOORD1;
                float4 OSuv1: TEXCOORD2;
                float4 OSuv2: TEXCOORD3;
                float4 positionCS: SV_POSITION;
                
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    UNITY_VERTEX_OUTPUT_STEREO
                #endif
            };
            
            float4 GetShadowPositionHClip(Attributes input, uint mid)
            {
                #if _AnimationInstancing
                    float4x4 am = AnimationInstancingMatrix(input.boneIndex, input.boneWeight, mid);
                    float4 positionOS = mul(am, input.positionOS);
                    float3 normalOS = mul((float3x3)am, input.normalOS);
                    
                    input.positionOS = positionOS;
                    input.normalOS = normalOS.xyz;
                #endif
                
                #ifdef _DrawMeshInstancedProcedural
                    float3 positionWS = mul(_ObjectToWorldBuffer[mid], float4(input.positionOS.xyz, 1.0)).xyz;
                    float3 normalWS = mul(_ObjectToWorldBuffer[mid], float4(input.normalOS.xyz, 0.0)).xyz;
                #else
                    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                    float3 normalWS = TransformObjectToWorldNormal(input.normalOS.xyz);
                #endif
                
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
                #ifdef _DrawMeshInstancedProcedural
                    uint mid = _VisibleInstanceOnlyTransformIDBuffer[input.mid];
                #else
                    uint mid = 0;
                    UNITY_SETUP_INSTANCE_ID(input);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                #endif
                Varyings output = (Varyings)0;
                input.positionOS.y += (sin(_Time.y + input.effectcoord.x + input.effectcoord.y) + 0.5) * 0.3 * _FloatModel;
                output.uv = input.texcoord;
                
                /*OS Disslove*/
                GetDissloveInput(input.positionOS, input.normalOS, _DissloveMap_ST, output.OSuv1, output.OSuv2, output.OSuvMask);
                
                
                output.positionCS = GetShadowPositionHClip(input, mid);
                return output;
            }
            
            half4 ShadowPassFragment(Varyings input): SV_TARGET
            {
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_SETUP_INSTANCE_ID(input);
                    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                #endif
                #if defined(_AlphaClip) || defined(_ClippingAlbedoAlpha)
                    half clippingResult = 1.0;
                    #if defined(_AlphaClip)
                        half4 effectiveMask = SAMPLE_TEXTURE2D(_EffectiveMap, sampler_EffectiveMap, input.uv.xy);
                        half4 effectiveDisslive = _EffectiveColor;
                        half alphaMinus = 1.0 - _EffectiveColor.a;
                        effectiveDisslive.a = smoothstep(alphaMinus - 0.1, alphaMinus + 0.1, (1.0 - effectiveMask.r + 0.1 * (_EffectiveColor.a - 0.5) * 2.0));
                        clippingResult *= effectiveDisslive.a;
                    #endif
                    #if defined(_ClippingAlbedoAlpha)
                        float4 _diffuse_var = SAMPLE_TEXTURE2D(_diffuse, sampler_diffuse, input.uv.xy);
                        clippingResult *= _diffuse_var.a;
                        
                        /*OS Disslove*/
                        half osEffectiveDisslive = _EffectiveDisslove;
                        half osEdgeArea;
                        half osValue = osEffectiveDisslive;
                        half4 osEffectiveMask;
                        osEffectiveDisslive = GetDissloveAlpha(input.OSuv1, input.OSuv2, input.OSuvMask, osEffectiveDisslive, osEdgeArea, osEffectiveMask);
                        clippingResult *= osEffectiveDisslive;
                    #endif
                    clip(clippingResult - 0.5);
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
            #pragma multi_compile _ _DrawMeshInstancedProcedural
            #pragma shader_feature_local _AnimationInstancing
            #pragma shader_feature_local _ClippingAlbedoAlpha
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            
            #include "Packages/com.zd.urp.funcy/Shaders/ZD/Character/ZDCharacter-CBufferProperties.hlsl"
            
            struct Attributes
            {
                float4 position: POSITION;
                float3 normal: NORMAL;
                float2 texcoord: TEXCOORD0;
                float2 effectcoord: TEXCOORD2;
                
                #ifndef _SKINBONE_ATTACHED
                    float4 boneWeight: BLENDWEIGHTS;
                    uint4 boneIndex: BLENDINDICES;
                #endif
                
                #ifdef _DrawMeshInstancedProcedural
                    uint mid: SV_INSTANCEID;
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                #endif
            };
            
            struct Varyings
            {
                float2 uv: TEXCOORD0;
                float4 positionCS: SV_POSITION;
                float vertexDist: TEXCOORD1;
                float4 positionSS: TEXCOORD2;
                
                /*OS Disslove*/
                float3 OSuvMask: TEXCOORD3;
                float4 OSuv1: TEXCOORD4;
                float4 OSuv2: TEXCOORD5;
                
                
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    UNITY_VERTEX_OUTPUT_STEREO
                #endif
            };
            
            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                
                #ifdef _DrawMeshInstancedProcedural
                    uint mid = _VisibleInstanceOnlyTransformIDBuffer[input.mid];
                #else
                    uint mid = 0;
                    UNITY_SETUP_INSTANCE_ID(input);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                #endif
                
                #if _AnimationInstancing
                    float4x4 am = AnimationInstancingMatrix(input.boneIndex, input.boneWeight, mid);
                    float4 positionOS = mul(am, input.position);
                #else
                    float4 positionOS = input.position;
                #endif
                input.position = positionOS;
                
                
                input.position.y += (sin(_Time.y + input.effectcoord.x + input.effectcoord.y) + 0.5) * 0.3 * _FloatModel;
                output.uv = input.texcoord;
                
                /*OS Disslove*/
                GetDissloveInput(input.position, input.normal, _DissloveMap_ST, output.OSuv1, output.OSuv2, output.OSuvMask);
                
                #ifdef _DrawMeshInstancedProcedural
                    float3 positionWS = mul(_ObjectToWorldBuffer[mid], float4(positionOS.xyz, 0.0)).xyz;
                #else
                    float3 positionWS = mul(GetObjectToWorldMatrix(), float4(positionOS.xyz, 0.0)).xyz;
                #endif
                
                positionWS.y = lerp(positionWS.y, -0.99, step(positionWS.y, -0.99));
                #ifdef _DrawMeshInstancedProcedural
                    input.position.xyz = mul(_WorldToObjectBuffer[mid], float4(positionWS, 0.0)).xyz;
                #else
                    input.position.xyz = mul(GetWorldToObjectMatrix(), float4(positionWS, 0.0)).xyz;
                #endif
                output.positionCS = TransformObjectToHClip(input.position.xyz);
                output.positionSS = ComputeScreenPos(output.positionCS, _ProjectionParams.x);
                
                #ifdef _DrawMeshInstancedProcedural
                    output.vertexDist = distance(float3(0.0, 0.0, 0.0), mul(_WorldToObjectBuffer[mid], float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                #else
                    output.vertexDist = distance(float3(0.0, 0.0, 0.0), mul(GetWorldToObjectMatrix(), float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                #endif
                
                return output;
            }
            
            half4 DepthOnlyFragment(Varyings input): SV_TARGET
            {
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                #endif
                float2 screenUV = input.positionSS.xy / input.positionSS.w;
                #if _DrawMeshInstancedProcedural
                #else
                    DistanceDisslove(screenUV, input.vertexDist);
                #endif
                #if defined(_AlphaClip) || defined(_ClippingAlbedoAlpha)
                    half clippingResult = 1.0;
                    #if defined(_AlphaClip)
                        half4 effectiveMask = SAMPLE_TEXTURE2D(_EffectiveMap, sampler_EffectiveMap, input.uv.xy);
                        half4 effectiveDisslive = _EffectiveColor;
                        half alphaMinus = 1.0 - _EffectiveColor.a;
                        effectiveDisslive.a = smoothstep(alphaMinus - 0.1, alphaMinus + 0.1, (1.0 - effectiveMask.r + 0.1 * (_EffectiveColor.a - 0.5) * 2.0));
                        clippingResult *= effectiveDisslive.a;
                    #endif
                    #if defined(_ClippingAlbedoAlpha)
                        float4 _diffuse_var = SAMPLE_TEXTURE2D(_diffuse, sampler_diffuse, input.uv.xy);
                        clippingResult *= _diffuse_var.a;
                        /*OS Disslove*/
                        half osEffectiveDisslive = _EffectiveDisslove;
                        half osEdgeArea;
                        half osValue = osEffectiveDisslive;
                        half4 osEffectiveMask;
                        osEffectiveDisslive = GetDissloveAlpha(input.OSuv1, input.OSuv2, input.OSuvMask, osEffectiveDisslive, osEdgeArea, osEffectiveMask);
                        clippingResult *= osEffectiveDisslive;
                    #endif
                    clip(clippingResult - 0.5);
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
            #pragma multi_compile _ _DrawMeshInstancedProcedural
            #pragma shader_feature_local _AnimationInstancing
            
            #pragma target 3.0
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float2 uv: TEXCOORD0;
                float2 effectcoord: TEXCOORD2;
                
                #ifndef _SKINBONE_ATTACHED
                    float4 boneWeight: BLENDWEIGHTS;
                    uint4 boneIndex: BLENDINDICES;
                #endif
                
                #ifdef _DrawMeshInstancedProcedural
                    uint mid: SV_INSTANCEID;
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                #endif
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float2 uv: TEXCOORD0;
                float4 positionSS: TEXCOORD1;
                float vertexDist: TEXCOORD2;
                
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    UNITY_VERTEX_OUTPUT_STEREO
                #endif
            };
            
            
            #include "Packages/com.zd.urp.funcy/Shaders/ZD/Character/ZDCharacter-CBufferProperties.hlsl"
            
            v2f vert(appdata v)
            {
                v2f o;
                #ifdef _DrawMeshInstancedProcedural
                    uint mid = _VisibleInstanceOnlyTransformIDBuffer[v.mid];
                #else
                    uint mid = 0;
                    UNITY_SETUP_INSTANCE_ID(v);
                    UNITY_TRANSFER_INSTANCE_ID(v, o);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                #endif
                
                #if _AnimationInstancing
                    float4x4 am = AnimationInstancingMatrix(v.boneIndex, v.boneWeight, mid);
                    float4 positionOS = mul(am, v.vertex);
                    float3 normalOS = mul((float3x3)am, v.normal);
                    
                    v.vertex = positionOS;
                    v.normal = normalOS.xyz;
                #endif
                
                
                v.vertex.y += (sin(_Time.y + v.effectcoord.x + v.effectcoord.y) + 0.5) * 0.3 * _FloatModel;
                
                half RTD_OL_OLWABVD_OO = 1.0;
                half4 _OutlineWidthControl_var = SAMPLE_TEXTURE2D_LOD(_OutlineWidthControl, sampler_OutlineWidthControl, v.uv, 0);
                
                half2 RTD_OL_DNOL_OO = v.uv;
                half2 node_8743 = RTD_OL_DNOL_OO;
                float2 node_1283_skew = node_8743 + 0.2127 + node_8743.x * 0.3713 * node_8743.y;
                float2 node_1283_rnd = 4.789 * sin(489.123 * (node_1283_skew));
                half node_1283 = frac(node_1283_rnd.x * node_1283_rnd.y * (1 + node_1283_skew.x));
                
                float3 _OEM = v.normal;
                
                half RTD_OL = (RTD_OL_OLWABVD_OO * 0.01) * lerp(1.0, node_1283, 0.3) * _OutlineWidthControl_var.r;
                
                #ifdef _DrawMeshInstancedProcedural
                    half dist = distance(v.vertex.xyz, mul(_WorldToObjectBuffer[mid], float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                #else
                    half dist = distance(v.vertex.xyz, mul(GetWorldToObjectMatrix(), float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                #endif
                half4 widthRange = _OutlineDistProp;
                
                RTD_OL *= max(widthRange.x, min(widthRange.y * 2.0, dist * widthRange.z));
                #ifdef _DrawMeshInstancedProcedural
                    dist = distance(0.0.xxx, mul(_WorldToObjectBuffer[mid], float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                #else
                    dist = distance(0.0.xxx, mul(GetWorldToObjectMatrix(), float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz);
                #endif
                
                float4 positionCS;
                #ifdef _DrawMeshInstancedProcedural
                    float3 positionWS = mul(_ObjectToWorldBuffer[mid], float4(v.vertex.xyz + _OEM * RTD_OL, 1.0)).xyz;
                    positionCS = TransformWorldToHClip(float4(positionWS, 1).xyz);
                #else
                    positionCS = TransformObjectToHClip(float4(v.vertex.xyz + _OEM * RTD_OL, 1).xyz);
                #endif
                
                
                o.vertex = positionCS / _OutlineEnable;
                o.positionSS = ComputeScreenPos(positionCS, _ProjectionParams.x);
                
                
                o.uv = v.uv;
                o.vertexDist = dist;
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_SETUP_INSTANCE_ID(i);
                    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                #endif
                
                float2 screenUV = i.positionSS.xy / i.positionSS.w;
                
                
                half4 effectiveMask = SAMPLE_TEXTURE2D(_EffectiveMap, sampler_EffectiveMap, i.uv.xy);
                half4 effectiveDisslive = _EffectiveColor;
                
                half alphaMinus = 1.0 - _EffectiveColor.a;
                effectiveDisslive.a = smoothstep(alphaMinus - 0.1, alphaMinus + 0.1, (1.0 - effectiveMask.r + 0.1 * (_EffectiveColor.a - 0.5) * 2.0));
                
                float4 _diffuse_var = SAMPLE_TEXTURE2D(_diffuse, sampler_diffuse, i.uv);
                half4 col = float4(_OutlineColor.rgb + _diffuse_var.rgb * _DiffuseBlend, _Color.a * effectiveDisslive.a);
                //half4 col = float4(0.05.rrr, 1.0);
                #if defined(_ClippingAlbedoAlpha)
                    clip(_diffuse_var.a - 0.5);
                #endif
                return 1.0;
            }
            ENDHLSL
            
        }
    }
    
    // Uses a custom shader GUI to display settings. Re-use the same from Lit shader as they have the
    // same properties.
    CustomEditor "UnityEditor.Rendering.Funcy.URP.ShaderGUI.ZDCharacter"
}