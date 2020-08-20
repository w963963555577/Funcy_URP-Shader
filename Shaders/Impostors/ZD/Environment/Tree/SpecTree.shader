// Amplify Impostors
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>

Shader "ZDShader/Impostors/Environment/SpecialTree"
{
    Properties
    {
        _LambertOffset ("LambertOffset", Float) = 0.5
        [HDR]_BlendColor_Light ("BlendColor_Light", Color) = (0.227451, 0.8784314, 0.4121743, 0)
        [HDR]_BlendColor_Mid ("BlendColor_Mid", Color) = (0.03555536, 0.4433962, 0.1661608, 0)
        [HDR]_BlendColor_Dark ("BlendColor_Dark", Color) = (0, 0.254717, 0.1783019, 0)
        [HDR]_BlendColor_SelfShadow ("BlendColor_SelfShadow", Color) = (0, 0.1776338, 0.2, 0)
        [HDR]_SpecColor ("SpecColor", Color) = (0.227451, 1.498039, 0, 1)
        _SpecularOffset ("SpecularOffset", Float) = 0.44
        
        [NoScaleOffset]_Albedo ("Albedo & Alpha", 2D) = "white" { }
        [NoScaleOffset]_Normals ("Normals & Depth", 2D) = "white" { }
        [NoScaleOffset]_Specular ("Specular & Smoothness", 2D) = "black" { }
        _SpecularValue ("Specular", Range(0, 1)) = 1
        [NoScaleOffset]_Emission ("Emission & Occlusion", 2D) = "black" { }
        [HideInInspector]_Frames ("Frames", Float) = 16
        [HideInInspector]_ImpostorSize ("Impostor Size", Float) = 1
        [HideInInspector]_Offset ("Offset", Vector) = (0, 0, 0, 0)
        [HideInInspector]_AI_SizeOffset ("Size & Offset", Vector) = (0, 0, 0, 0)
        _TextureBias ("Texture Bias", Float) = -1
        _Parallax ("Parallax", Range(-1, 1)) = 1
        [HideInInspector]_DepthSize ("DepthSize", Float) = 1
        _ClipMask ("Clip", Range(0, 1)) = 0.5
        _AI_ShadowBias ("Shadow Bias", Range(0, 2)) = 0.25
        _AI_ShadowView ("Shadow View", Range(0, 1)) = 1
        [Toggle(_HEMI_ON)] _Hemi ("Hemi", Float) = 0
        [Toggle(EFFECT_HUE_VARIATION)] _Hue ("Use SpeedTree Hue", Float) = 0
        _HueVariation ("Hue Variation", Color) = (0, 0, 0, 0)
        [Toggle] _AI_AlphaToCoverage ("Alpha To Coverage", Float) = 0
    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" "DisableBatching" = "True" }
        
        Cull Back
        AlphaToMask[_AI_AlphaToCoverage]
        
        HLSLINCLUDE
        #pragma target 3.0
        
        struct SurfaceOutputStandardSpecular
        {
            half3 Albedo;
            half3 Metallic;
            half3 Specular;
            float3 Normal;
            half3 Emission;
            half Smoothness;
            half Occlusion;
            half Alpha;
        };
        ENDHLSL
        
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            
            Name "Base"
            Blend One Zero
            ZWrite On
            ZTest LEqual
            Offset 0, 0
            ColorMask RGBA
            
            HLSLPROGRAM
            
            // -------------------------------------
            // Material Keywords
            // unused shader_feature variants are stripped from build automatically
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICSPECGLOSSMAP
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _OCCLUSIONMAP
            
            #pragma shader_feature _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _GLOSSYREFLECTIONS_OFF
            #pragma shader_feature _SPECULAR_SETUP
            #pragma shader_feature _RECEIVE_SHADOWS_OFF
            
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _DrawMeshInstancedProcedural
            
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            
            #pragma vertex vert
            #pragma fragment frag
            
            #define _SPECULAR_SETUP 1
            
            
            #define AI_RENDERPIPELINE
            
            CBUFFER_START(UnityPerMaterial)
            float4 _BlendColor_SelfShadow;
            float4 _BlendColor_Dark;
            float4 _BlendColor_Mid;
            float4 _BlendColor_Light;
            float4 _SpecColor;
            float _LambertOffset;
            float _SpecularOffset;
            
            float _FramesX;
            float _FramesY;
            float _Frames;
            float _ImpostorSize;
            float _Parallax;
            float _TextureBias;
            float _ClipMask;
            float _DepthSize;
            float _AI_ShadowBias;
            float _AI_ShadowView;
            float4 _Offset;
            float4 _AI_SizeOffset;
            float _EnergyConservingSpecularColor;
            
            #ifdef EFFECT_HUE_VARIATION
                half4 _HueVariation;
            #endif
            CBUFFER_END
            
            #include "../../../../../ShaderLibrary/Impostors.hlsl"
            
            #pragma shader_feature _HEMI_ON
            #pragma shader_feature EFFECT_HUE_VARIATION
            
            struct VertexInput
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float4 tangent: TANGENT;
                //float4 texcoord  : TEXCOORD0;
                float4 texcoord1: TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                float4 lightmapUVOrVertexSH: TEXCOORD0;
                half4 fogFactorAndVertexLight: TEXCOORD1;
                float4 shadowCoord: TEXCOORD2;
                float4 uvsFrame1: TEXCOORD3;
                float4 uvsFrame2: TEXCOORD4;
                float4 uvsFrame3: TEXCOORD5;
                float4 octaFrame: TEXCOORD6;
                float4 viewPos: TEXCOORD7;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            void InitializeInputAndSurfaceData(VertexOutput IN, out InputData inputData, out SurfaceOutputStandardSpecular surfaceData)
            {
                surfaceData = (SurfaceOutputStandardSpecular)0;
                inputData = (InputData)0;
                
                float4 clipPos = 0;
                float3 worldPos = 0;
                
                OctaImpostorFragment(surfaceData, clipPos, worldPos, IN.uvsFrame1, IN.uvsFrame2, IN.uvsFrame3, IN.octaFrame, IN.viewPos);
                IN.clipPos.zw = clipPos.zw;
                
                float3 WorldSpaceViewDirection = SafeNormalize(_WorldSpaceCameraPos.xyz - worldPos);
                
                inputData.positionWS = worldPos;
                inputData.normalWS = surfaceData.Normal;
                inputData.viewDirectionWS = WorldSpaceViewDirection;
                
                #ifdef _MAIN_LIGHT_SHADOWS
                    #if SHADOWS_SCREEN
                    #else
                        IN.shadowCoord = TransformWorldToShadowCoord(worldPos);
                    #endif
                #endif
                
                inputData.shadowCoord = IN.shadowCoord;
                inputData.fogCoord = IN.fogFactorAndVertexLight.x;
                inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
                inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS);
            }
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                OctaImpostorVertex(v.vertex, v.normal, o.uvsFrame1, o.uvsFrame2, o.uvsFrame3, o.octaFrame, o.viewPos);
                
                float3 lwWNormal = TransformObjectToWorldNormal(v.normal);
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                
                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
                OUTPUT_SH(lwWNormal, o.lightmapUVOrVertexSH.xyz);
                
                half3 vertexLight = VertexLighting(vertexInput.positionWS, lwWNormal);
                half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
                o.clipPos = vertexInput.positionCS;
                
                #ifdef _MAIN_LIGHT_SHADOWS
                    o.shadowCoord = GetShadowCoord(vertexInput);
                #endif
                return o;
            }
            
            float3 SpecTreeColor(InputData IN, float4 baseColor)
            {
                Light mainLight = GetMainLight();
                float3 WorldPosition = IN.positionWS;
                float3 viewDirection = normalize(WorldPosition - _WorldSpaceCameraPos.xyz);
                float4 ShadowCoords = TransformWorldToShadowCoord(WorldPosition);
                
                float3 ase_worldNormal = IN.normalWS.xyz;
                float dotResult41 = dot(ase_worldNormal, mainLight.direction);
                float lightFresnel = smoothstep(0.0, 1.0, saturate(dot(viewDirection, - (ase_worldNormal * 0.82 - mainLight.direction))));
                
                float temp_output_47_0 = saturate((dotResult41 + _LambertOffset));
                float smoothstepResult82 = smoothstep(0.0, 0.5, temp_output_47_0);
                float4 lerpResult83 = lerp(_BlendColor_Dark, _BlendColor_Mid, smoothstepResult82);
                float smoothstepResult80 = smoothstep(0.5, 1.0, temp_output_47_0);
                float4 lerpResult57 = lerp(lerpResult83, _BlendColor_Light, smoothstepResult80);
                
                lerpResult57.rgb = lerp(lerpResult57.rgb, _BlendColor_Light.rgb, lightFresnel);
                
                float ase_lightAtten = 0;
                Light ase_lightAtten_mainLight = GetMainLight(ShadowCoords);
                ase_lightAtten = ase_lightAtten_mainLight.distanceAttenuation * ase_lightAtten_mainLight.shadowAttenuation;
                float temp_output_147_0 = saturate((ase_lightAtten + temp_output_47_0));
                float4 lerpResult145 = lerp(_BlendColor_SelfShadow, lerpResult57, temp_output_147_0);
                float temp_output_3_0_g5 = (baseColor.a - 0.5);
                float temp_output_3_0_g4 = (baseColor.a - saturate((1.5 * 0.5)));
                float temp_output_200_0 = saturate((dotResult41 + (_SpecularOffset * - 1.0)));
                
                return saturate(((baseColor * lerpResult145) + (saturate(((saturate((temp_output_3_0_g5 / fwidth(temp_output_3_0_g5))) - saturate((temp_output_3_0_g4 / fwidth(temp_output_3_0_g4)))) * temp_output_200_0 * temp_output_147_0 * baseColor.a)) * _SpecColor))).rgb;
            }
            
            half4 frag(VertexOutput IN, out float outDepth: SV_Depth): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                
                SurfaceOutputStandardSpecular o;
                InputData inputData;
                InitializeInputAndSurfaceData(IN, inputData, o);
                
                
                half4 color = half4(SpecTreeColor(inputData, float4(o.Albedo, o.Alpha)), 1.0);
                
                
                color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
                outDepth = IN.clipPos.z;
                return color;
            }
            
            ENDHLSL
            
        }
        /*
        Pass
        {
            
            Name "ShadowCasterImpostors"
            Tags { "LightMode" = "ShadowCaster" }
            
            ZWrite On
            ZTest LEqual
            
            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
            #ifndef UNITY_PASS_SHADOWCASTER
                #define UNITY_PASS_SHADOWCASTER
            #endif
            #pragma multi_compile_instancing
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            #define AI_RENDERPIPELINE
            CBUFFER_START(UnityPerMaterial)
            float4 _BlendColor_SelfShadow;
            float4 _BlendColor_Dark;
            float4 _BlendColor_Mid;
            float4 _BlendColor_Light;
            float4 _SpecColor;
            float _LambertOffset;
            float _SpecularOffset;
            
            float _FramesX;
            float _FramesY;
            float _Frames;
            float _ImpostorSize;
            float _Parallax;
            float _TextureBias;
            float _ClipMask;
            float _DepthSize;
            float _AI_ShadowBias;
            float _AI_ShadowView;
            float4 _Offset;
            float4 _AI_SizeOffset;
            float _EnergyConservingSpecularColor;
            
            #ifdef EFFECT_HUE_VARIATION
                half4 _HueVariation;
            #endif
            CBUFFER_END
            
            #include "../../../../../ShaderLibrary/Impostors.hlsl"
            
            #pragma shader_feature _HEMI_ON
            #pragma shader_feature EFFECT_HUE_VARIATION
            
            struct VertexInput
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                //float4 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                float4 uvsFrame1: TEXCOORD0;
                float4 uvsFrame2: TEXCOORD1;
                float4 uvsFrame3: TEXCOORD2;
                float4 octaFrame: TEXCOORD3;
                float4 viewPos: TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                OctaImpostorVertex(v.vertex, v.normal, o.uvsFrame1, o.uvsFrame2, o.uvsFrame3, o.octaFrame, o.viewPos);
                
                o.clipPos = TransformObjectToHClip(v.vertex.xyz);
                
                return o;
            }
            
            half4 frag(VertexOutput IN, out float outDepth: SV_Depth): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
                float4 clipPos = 0;
                float3 worldPos = 0;
                
                OctaImpostorFragment(o, clipPos, worldPos, IN.uvsFrame1, IN.uvsFrame2, IN.uvsFrame3, IN.octaFrame, IN.viewPos);
                IN.clipPos.zw = clipPos.zw;
                
                outDepth = clipPos.z;
                return 0;
            }
            ENDHLSL
            
        }
        
        Pass
        {
            Name "DepthOnlyImpostors"
            Tags { "LightMode" = "DepthOnly" }
            
            ZWrite On
            ColorMask 0
            
            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
            #pragma multi_compile_instancing
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            #define AI_RENDERPIPELINE
            CBUFFER_START(UnityPerMaterial)
            float4 _BlendColor_SelfShadow;
            float4 _BlendColor_Dark;
            float4 _BlendColor_Mid;
            float4 _BlendColor_Light;
            float4 _SpecColor;
            float _LambertOffset;
            float _SpecularOffset;
            
            float _FramesX;
            float _FramesY;
            float _Frames;
            float _ImpostorSize;
            float _Parallax;
            float _TextureBias;
            float _ClipMask;
            float _DepthSize;
            float _AI_ShadowBias;
            float _AI_ShadowView;
            float4 _Offset;
            float4 _AI_SizeOffset;
            float _EnergyConservingSpecularColor;
            
            #ifdef EFFECT_HUE_VARIATION
                half4 _HueVariation;
            #endif
            CBUFFER_END
            
            #include "../../../../../ShaderLibrary/Impostors.hlsl"
            
            #pragma shader_feature _HEMI_ON
            #pragma shader_feature EFFECT_HUE_VARIATION
            
            struct VertexInput
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                //float4 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                float4 uvsFrame1: TEXCOORD0;
                float4 uvsFrame2: TEXCOORD1;
                float4 uvsFrame3: TEXCOORD2;
                float4 octaFrame: TEXCOORD3;
                float4 viewPos: TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                OctaImpostorVertex(v.vertex, v.normal, o.uvsFrame1, o.uvsFrame2, o.uvsFrame3, o.octaFrame, o.viewPos);
                
                o.clipPos = TransformObjectToHClip(v.vertex.xyz);
                
                return o;
            }
            
            half4 frag(VertexOutput IN, out float outDepth: SV_Depth): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
                float4 clipPos = 0;
                float3 worldPos = 0;
                
                OctaImpostorFragment(o, clipPos, worldPos, IN.uvsFrame1, IN.uvsFrame2, IN.uvsFrame3, IN.octaFrame, IN.viewPos);
                IN.clipPos.zw = clipPos.zw;
                
                outDepth = clipPos.z;
                return 0;
            }
            
            ENDHLSL
            
        }
        
        Pass
        {
            Name "SceneSelectionPassImpostors"
            Tags { "LightMode" = "SceneSelectionPass" }
            
            ZWrite On
            ColorMask 0
            
            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
            #pragma multi_compile_instancing
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            #define AI_RENDERPIPELINE
            CBUFFER_START(UnityPerMaterial)
            float4 _BlendColor_SelfShadow;
            float4 _BlendColor_Dark;
            float4 _BlendColor_Mid;
            float4 _BlendColor_Light;
            float4 _SpecColor;
            float _LambertOffset;
            float _SpecularOffset;
            
            float _FramesX;
            float _FramesY;
            float _Frames;
            float _ImpostorSize;
            float _Parallax;
            float _TextureBias;
            float _ClipMask;
            float _DepthSize;
            float _AI_ShadowBias;
            float _AI_ShadowView;
            float4 _Offset;
            float4 _AI_SizeOffset;
            float _EnergyConservingSpecularColor;
            
            #ifdef EFFECT_HUE_VARIATION
                half4 _HueVariation;
            #endif
            CBUFFER_END
            
            #include "../../../../../ShaderLibrary/Impostors.hlsl"
            
            #pragma shader_feature EFFECT_HUE_VARIATION
            
            int _ObjectId;
            int _PassValue;
            
            struct VertexInput
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                //float4 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                float4 uvsFrame1: TEXCOORD0;
                float4 uvsFrame2: TEXCOORD1;
                float4 uvsFrame3: TEXCOORD2;
                float4 octaFrame: TEXCOORD3;
                float4 viewPos: TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                OctaImpostorVertex(v.vertex, v.normal, o.uvsFrame1, o.uvsFrame2, o.uvsFrame3, o.octaFrame, o.viewPos);
                
                o.clipPos = TransformObjectToHClip(v.vertex.xyz);
                
                return o;
            }
            
            half4 frag(VertexOutput IN, out float outDepth: SV_Depth): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
                float4 clipPos = 0;
                float3 worldPos = 0;
                
                OctaImpostorFragment(o, clipPos, worldPos, IN.uvsFrame1, IN.uvsFrame2, IN.uvsFrame3, IN.octaFrame, IN.viewPos);
                IN.clipPos.zw = clipPos.zw;
                
                outDepth = IN.clipPos.z;
                return float4(_ObjectId, _PassValue, 1.0, 1.0);
            }
            
            ENDHLSL
            
        }
        
        
        Pass
        {
            Name "MetaImpostors"
            Tags { "LightMode" = "Meta" }
            
            Cull Off
            
            HLSLPROGRAM
            
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma shader_feature _SPECULAR_SETUP
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICSPECGLOSSMAP
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            
            #pragma shader_feature _SPECGLOSSMAP
            
            uniform float4 _MainTex_ST;
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
            
            #define AI_RENDERPIPELINE
            CBUFFER_START(UnityPerMaterial)
            float4 _BlendColor_SelfShadow;
            float4 _BlendColor_Dark;
            float4 _BlendColor_Mid;
            float4 _BlendColor_Light;
            float4 _SpecColor;
            float _LambertOffset;
            float _SpecularOffset;
            
            float _FramesX;
            float _FramesY;
            float _Frames;
            float _ImpostorSize;
            float _Parallax;
            float _TextureBias;
            float _ClipMask;
            float _DepthSize;
            float _AI_ShadowBias;
            float _AI_ShadowView;
            float4 _Offset;
            float4 _AI_SizeOffset;
            float _EnergyConservingSpecularColor;
            
            #ifdef EFFECT_HUE_VARIATION
                half4 _HueVariation;
            #endif
            CBUFFER_END
            
            #include "../../../../../ShaderLibrary/Impostors.hlsl"
            
            #pragma shader_feature _HEMI_ON
            #pragma shader_feature EFFECT_HUE_VARIATION
            
            struct VertexInput
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                //float4 texcoord : TEXCOORD0;
                float2 uvLM: TEXCOORD1;
                float2 uvDLM: TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                float4 uvsFrame1: TEXCOORD0;
                float4 uvsFrame2: TEXCOORD1;
                float4 uvsFrame3: TEXCOORD2;
                float4 octaFrame: TEXCOORD3;
                float4 viewPos: TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                OctaImpostorVertex(v.vertex, v.normal, o.uvsFrame1, o.uvsFrame2, o.uvsFrame3, o.octaFrame, o.viewPos);
                
                #if AI_LWRP_VERSION > 51300
                    o.clipPos = MetaVertexPosition(v.vertex, v.uvLM, v.uvDLM, unity_LightmapST, unity_DynamicLightmapST);
                #else
                    o.clipPos = MetaVertexPosition(v.vertex, v.uvLM, v.uvDLM, unity_LightmapST);
                #endif
                
                return o;
            }
            
            half4 frag(VertexOutput IN, out float outDepth: SV_Depth): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
                float4 clipPos = 0;
                float3 worldPos = 0;
                
                OctaImpostorFragment(o, clipPos, worldPos, IN.uvsFrame1, IN.uvsFrame2, IN.uvsFrame3, IN.octaFrame, IN.viewPos);
                IN.clipPos.zw = clipPos.zw;
                
                MetaInput metaInput = (MetaInput)0;
                metaInput.Albedo = o.Albedo;
                metaInput.Emission = o.Emission;
                
                outDepth = clipPos.z;
                
                return MetaFragment(metaInput);
            }
            ENDHLSL
            
        }
        */
    }
}
