// Amplify Impostors
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>

Shader "Impostors/Octahedron URP Lit"
{
    Properties
    {
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
            #pragma multi_compile _ _SHADOWS_SOFT
            
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            
            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            
            #pragma vertex vert
            #pragma fragment frag
            
            #define _SPECULAR_SETUP 1
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            #define AI_RENDERPIPELINE
            
            #include "../../ShaderLibrary/Impostors.hlsl"
            
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
            
            half4 frag(VertexOutput IN, out float outDepth: SV_Depth): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                
                
                SurfaceOutputStandardSpecular o;
                InputData inputData;
                InitializeInputAndSurfaceData(IN, inputData, o);
                
                half4 color = UniversalFragmentPBR(
                    inputData,
                    o.Albedo,
                    o.Metallic,
                    o.Specular,
                    o.Smoothness,
                    o.Occlusion,
                    o.Emission,
                    o.Alpha
                );
                
                color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
                outDepth = IN.clipPos.z;
                return color;
            }
            
            ENDHLSL
            
        }
        
        UsePass "Hidden/LWRP/General/ShadowCasterImpostors"
        UsePass "Hidden/LWRP/General/DepthOnlyImpostors"
        UsePass "Hidden/LWRP/General/SceneSelectionPassImpostors"
        UsePass "Hidden/LWRP/General/MetaImpostors"
    }
}
