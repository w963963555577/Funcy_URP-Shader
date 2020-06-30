// When creating shaders for Lightweight Render Pipeline you can you the ShaderGraph which is super AWESOME!
// However, if you want to author shaders in shading language you can use this teamplate as a base.
// Please note, this shader does not match perfomance of the built-in LWRP Lit shader.
// This shader works with LWRP 5.7.2 version and above
Shader "ZDShader/LWRP/PBR Base(Simple)"
{
    Properties
    {
        // Specular vs Metallic workflow
        [HideInInspector] _WorkflowMode ("WorkflowMode", Float) = 1.0
        
        [MainColor] _BaseColor ("Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap ("Albedo", 2D) = "white" { }
        
        _Cutoff ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        
        _Smoothness ("Smoothness", Range(0.0, 1.0)) = 0.0
        _GlossMapScale ("Smoothness Scale", Range(0.0, 1.0)) = 1.0
        _SmoothnessTextureChannel ("Smoothness texture channel", Float) = 0
        
        [Gamma] _Metallic ("Metallic", Range(0.0, 1.0)) = 0.0
        _MetallicGlossMap ("Metallic", 2D) = "white" { }
        
        _SpecColor ("Specular", Color) = (0.2, 0.2, 0.2)
        _SpecGlossMap ("Specular", 2D) = "white" { }
        
        [ToggleOff] _SpecularHighlights ("Specular Highlights", Float) = 1.0
        [ToggleOff] _EnvironmentReflections ("Environment Reflections", Float) = 1.0
        
        _BumpScale ("Scale", Float) = 1.0
        _BumpMap ("Normal Map", 2D) = "bump" { }
        
        _OcclusionStrength ("Strength", Range(0.0, 1.0)) = 1.0
        _OcclusionMap ("Occlusion", 2D) = "white" { }
        
        _EmissionColor ("Color", Color) = (0, 0, 0)
        _EmissionMap ("Emission", 2D) = "white" { }
        
        // Blending state
        [HideInInspector] _Surface ("__surface", Float) = 0.0
        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip ("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [Enum(Off, 0, On, 1)]  _ZWrite ("__zw", Float) = 1.0
        [Enum(UnityEngine.Rendering.CompareFunction)]  _ZTest ("__zt", Float) = 4
        
        [HideInInspector] _Cull ("__cull", Float) = 2.0
        
        _ReceiveShadows ("Receive Shadows", Float) = 1.0
        
        // Editmode props
        [HideInInspector] _QueueOffset ("Queue offset", Float) = 0.0
        
        
        _Speed ("Speed", Range(0.1, 10)) = 0.1
        _Amount ("Amount", Range(0.1, 10)) = .01
        _Distance ("Distance", Range(0, 0.5)) = 0.0
        _ZMotion ("Z Motion", Range(0, 1)) = 0.5
        _ZMotionSpeed ("Z Motion Speed", Range(0, 10)) = 10
        _OriginWeight ("Origin Weight", Range(0, 1)) = 0
        
        _PositionMask ("Position Mask", 2D) = "white" { }
        
        [Toggle(_DebugMask)] _DebugMask ("Debug Mask", Int) = 0
    }
    
    SubShader
    {
        
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True" }
        LOD 0
        
        // ------------------------------------------------------------------
        // Forward pass. Shades GI, emission, fog and all lights in a single pass.
        // Compared to Builtin pipeline forward renderer, LWRP forward renderer will
        // render a scene with multiple lights with less drawcalls and less overdraw.
        
        Pass
        {
            Name "StandardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            ZTest [_ZTest]
            Cull[_Cull]
            
            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
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
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            #pragma multi_compile _ _SHADOWS_SOFT
            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            
            #ifndef UNIVERSAL_LIT_INPUT_INCLUDED
                #define UNIVERSAL_LIT_INPUT_INCLUDED
                
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
                
                CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                half4 _SpecColor;
                half4 _EmissionColor;
                half _Cutoff;
                half _Smoothness;
                half _Metallic;
                half _BumpScale;
                half _OcclusionStrength;
                
                float4 _PositionMask_ST;
                float _Speed;
                float _Amount;
                float _Distance;
                float _ZMotion;
                float _ZMotionSpeed;
                float _OriginWeight;
                half _DebugMask;
                CBUFFER_END
                #include "../../../ShaderLibrary/VertexAnimation.hlsl"
                TEXTURE2D(_OcclusionMap);       SAMPLER(sampler_OcclusionMap);
                TEXTURE2D(_MetallicGlossMap);   SAMPLER(sampler_MetallicGlossMap);
                TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);
                
                #ifdef _SPECULAR_SETUP
                    #define SAMPLE_METALLICSPECULAR(uv) SAMPLE_TEXTURE2D(_SpecGlossMap, sampler_SpecGlossMap, uv)
                #else
                    #define SAMPLE_METALLICSPECULAR(uv) SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_MetallicGlossMap, uv)
                #endif
                
                half4 SampleMetallicSpecGloss(float2 uv, half albedoAlpha)
                {
                    half4 specGloss;
                    
                    #ifdef _METALLICSPECGLOSSMAP
                        specGloss = SAMPLE_METALLICSPECULAR(uv);
                        #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                            specGloss.a = albedoAlpha * _Smoothness;
                        #else
                            specGloss.a *= _Smoothness;
                        #endif
                    #else // _METALLICSPECGLOSSMAP
                        #if _SPECULAR_SETUP
                            specGloss.rgb = _SpecColor.rgb;
                        #else
                            specGloss.rgb = _Metallic.rrr;
                        #endif
                        
                        #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                            specGloss.a = albedoAlpha * _Smoothness;
                        #else
                            specGloss.a = _Smoothness;
                        #endif
                    #endif
                    
                    return specGloss;
                }
                
                half SampleOcclusion(float2 uv)
                {
                    #ifdef _OCCLUSIONMAP
                        // TODO: Controls things like these by exposing SHADER_QUALITY levels (low, medium, high)
                        #if defined(SHADER_API_GLES)
                            return SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).g;
                        #else
                            half occ = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, uv).g;
                            return LerpWhiteTo(occ, _OcclusionStrength);
                        #endif
                    #else
                        return 1.0;
                    #endif
                }
                
                inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
                {
                    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                    outSurfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);
                    
                    half4 specGloss = SampleMetallicSpecGloss(uv, albedoAlpha.a);
                    outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
                    
                    #if _SPECULAR_SETUP
                        outSurfaceData.metallic = 1.0h;
                        outSurfaceData.specular = specGloss.rgb;
                    #else
                        outSurfaceData.metallic = specGloss.r;
                        outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);
                    #endif
                    
                    outSurfaceData.smoothness = specGloss.a;
                    outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
                    outSurfaceData.occlusion = SampleOcclusion(uv);
                    outSurfaceData.emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
                }
                
            #endif // UNIVERSAL_INPUT_SURFACE_PBR_INCLUDED
            
            #ifndef UNIVERSAL_FORWARD_LIT_PASS_INCLUDED
                #define UNIVERSAL_FORWARD_LIT_PASS_INCLUDED
                
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                
                struct Attributes
                {
                    float4 positionOS: POSITION;
                    float3 normalOS: NORMAL;
                    float4 tangentOS: TANGENT;
                    float2 texcoord: TEXCOORD0;
                    float2 lightmapUV: TEXCOORD1;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };
                
                struct Varyings
                {
                    float2 uv: TEXCOORD0;
                    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
                    
                    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
                        float3 positionWS: TEXCOORD2;
                    #endif
                    
                    #ifdef _NORMALMAP
                        float4 normalWS: TEXCOORD3;    // xyz: normal, w: viewDir.x
                        float4 tangentWS: TEXCOORD4;    // xyz: tangent, w: viewDir.y
                        float4 bitangentWS: TEXCOORD5;    // xyz: bitangent, w: viewDir.z
                    #else
                        float3 normalWS: TEXCOORD3;
                        float3 viewDirWS: TEXCOORD4;
                    #endif
                    
                    half4 fogFactorAndVertexLight: TEXCOORD6; // x: fogFactor, yzw: vertex light
                    
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                        float4 shadowCoord: TEXCOORD7;
                    #endif
                    
                    float4 positionCS: SV_POSITION;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    UNITY_VERTEX_OUTPUT_STEREO
                };
                
                void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
                {
                    inputData = (InputData)0;
                    
                    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
                        inputData.positionWS = input.positionWS;
                    #endif
                    
                    #ifdef _NORMALMAP
                        half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
                        inputData.normalWS = TransformTangentToWorld(normalTS,
                        half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
                    #else
                        half3 viewDirWS = input.viewDirWS;
                        inputData.normalWS = input.normalWS;
                    #endif
                    
                    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                    viewDirWS = SafeNormalize(viewDirWS);
                    inputData.viewDirectionWS = viewDirWS;
                    
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                        inputData.shadowCoord = input.shadowCoord;
                    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                        inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                    #else
                        inputData.shadowCoord = float4(0, 0, 0, 0);
                    #endif
                    
                    inputData.fogCoord = input.fogFactorAndVertexLight.x;
                    inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
                    inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
                }
                
                ///////////////////////////////////////////////////////////////////////////////
                //                  Vertex and Fragment functions                            //
                ///////////////////////////////////////////////////////////////////////////////
                
                // Used in Standard (Physically Based) shader
                Varyings LitPassVertex(Attributes input)
                {
                    Varyings output = (Varyings)0;
                    
                    UNITY_SETUP_INSTANCE_ID(input);
                    UNITY_TRANSFER_INSTANCE_ID(input, output);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                    input.positionOS = WindAnimation(input.positionOS);
                    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                    half3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
                    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                    
                    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                    
                    #ifdef _NORMALMAP
                        output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
                        output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
                        output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);
                    #else
                        output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
                        output.viewDirWS = viewDirWS;
                    #endif
                    
                    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
                    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
                    
                    output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
                    
                    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
                        output.positionWS = vertexInput.positionWS;
                    #endif
                    
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                        output.shadowCoord = GetShadowCoord(vertexInput);
                    #endif
                    
                    output.positionCS = vertexInput.positionCS;
                    
                    return output;
                }
                
                // Used in Standard (Physically Based) shader
                half4 LitPassFragment(Varyings input): SV_Target
                {
                    UNITY_SETUP_INSTANCE_ID(input);
                    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                    
                    SurfaceData surfaceData;
                    InitializeStandardLitSurfaceData(input.uv, surfaceData);
                    
                    InputData inputData;
                    InitializeInputData(input, surfaceData.normalTS, inputData);
                    
                    half4 color = UniversalFragmentPBR(inputData, surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.occlusion, surfaceData.emission, surfaceData.alpha);
                    
                    color.rgb = MixFog(color.rgb, inputData.fogCoord);
                    return color;
                }
                
            #endif
            
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
            
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            
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
            
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            half4 _SpecColor;
            half4 _EmissionColor;
            half _Cutoff;
            half _Smoothness;
            half _Metallic;
            half _BumpScale;
            half _OcclusionStrength;
            
            float4 _PositionMask_ST;
            float _Speed;
            float _Amount;
            float _Distance;
            float _ZMotion;
            float _ZMotionSpeed;
            float _OriginWeight;
            half _DebugMask;
            CBUFFER_END
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "../../../ShaderLibrary/VertexAnimation.hlsl"
            float3 _LightDirection;
            
            struct Attributes
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
                float2 texcoord: TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct Varyings
            {
                float2 uv: TEXCOORD0;
                float4 positionCS: SV_POSITION;
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
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                //WindAnimation
                input.positionOS = WindAnimation(input.positionOS);
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionCS = GetShadowPositionHClip(input);
                return output;
            }
            
            half4 ShadowPassFragment(Varyings input): SV_TARGET
            {
                Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
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
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            
            
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            half4 _SpecColor;
            half4 _EmissionColor;
            half _Cutoff;
            half _Smoothness;
            half _Metallic;
            half _BumpScale;
            half _OcclusionStrength;
            
            float4 _PositionMask_ST;
            float _Speed;
            float _Amount;
            float _Distance;
            float _ZMotion;
            float _ZMotionSpeed;
            float _OriginWeight;
            half _DebugMask;
            CBUFFER_END
            #include "../../../ShaderLibrary/VertexAnimation.hlsl"
            struct Attributes
            {
                float4 position: POSITION;
                float2 texcoord: TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct Varyings
            {
                float2 uv: TEXCOORD0;
                float4 positionCS: SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                //WindAnimation
                input.position = WindAnimation(input.position);
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionCS = TransformObjectToHClip(input.position.xyz);
                return output;
            }
            
            half4 DepthOnlyFragment(Varyings input): SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
                return 0;
            }
            
            
            ENDHLSL
            
        }
        
        Pass
        {
            Name "SceneSelectionPass"
            Tags { "LightMode" = "SceneSelectionPass" }
            
            ZWrite On
            ColorMask 0
            Cull Off
            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
            #pragma multi_compile_instancing
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            half4 _SpecColor;
            half4 _EmissionColor;
            half _Cutoff;
            half _Smoothness;
            half _Metallic;
            half _BumpScale;
            half _OcclusionStrength;
            
            float4 _PositionMask_ST;
            float _Speed;
            float _Amount;
            float _Distance;
            float _ZMotion;
            float _ZMotionSpeed;
            float _OriginWeight;
            half _DebugMask;
            CBUFFER_END
            #include "../../../ShaderLibrary/VertexAnimation.hlsl"
            int _ObjectId;
            int _PassValue;
            
            struct VertexInput
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
                float4 tangentOS: TANGENT;
                float2 texcoord: TEXCOORD0;
                float2 lightmapUV: TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float2 uv: TEXCOORD0;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
                
                #ifdef _ADDITIONAL_LIGHTS
                    float3 positionWS: TEXCOORD2;
                #endif
                
                #ifdef _NORMALMAP
                    float4 normalWS: TEXCOORD3;    // xyz: normal, w: viewDir.x
                    float4 tangentWS: TEXCOORD4;    // xyz: tangent, w: viewDir.y
                    float4 bitangentWS: TEXCOORD5;    // xyz: bitangent, w: viewDir.z
                #else
                    float3 normalWS: TEXCOORD3;
                    float3 viewDirWS: TEXCOORD4;
                #endif
                
                half4 fogFactorAndVertexLight: TEXCOORD6; // x: fogFactor, yzw: vertex light
                
                #ifdef _MAIN_LIGHT_SHADOWS
                    float4 shadowCoord: TEXCOORD7;
                #endif
                
                float4 positionOS: TEXCOORD8;
                
                float4 positionCS: SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            VertexOutput vert(VertexInput input)
            {
                VertexOutput output = (VertexOutput)0;
                
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                input.positionOS = WindAnimation(input.positionOS);
                output.positionOS = input.positionOS;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                half3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
                half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                
                #ifdef _NORMALMAP
                    output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
                    output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
                    output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);
                #else
                    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
                    output.viewDirWS = viewDirWS;
                #endif
                
                OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
                
                output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
                
                #ifdef _ADDITIONAL_LIGHTS
                    output.positionWS = vertexInput.positionWS;
                #endif
                
                #if defined(_MAIN_LIGHT_SHADOWS) && !defined(_RECEIVE_SHADOWS_OFF)
                    output.shadowCoord = GetShadowCoord(vertexInput);
                #endif
                
                output.positionCS = vertexInput.positionCS;
                
                return output;
            }
            
            void InitializeInputData(VertexOutput input, half3 normalTS, out InputData inputData)
            {
                inputData = (InputData)0;
                
                #ifdef _ADDITIONAL_LIGHTS
                    inputData.positionWS = input.positionWS;
                #endif
                
                #ifdef _NORMALMAP
                    half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
                    inputData.normalWS = TransformTangentToWorld(normalTS,
                    half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
                #else
                    half3 viewDirWS = input.viewDirWS;
                    inputData.normalWS = input.normalWS;
                #endif
                
                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                viewDirWS = SafeNormalize(viewDirWS);
                
                inputData.viewDirectionWS = viewDirWS;
                #if defined(_MAIN_LIGHT_SHADOWS) && !defined(_RECEIVE_SHADOWS_OFF)
                    inputData.shadowCoord = input.shadowCoord;
                #else
                    inputData.shadowCoord = float4(0, 0, 0, 0);
                #endif
                inputData.fogCoord = input.fogFactorAndVertexLight.x;
                inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
                inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
                #if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
                    inputData.bakedAtten = SAMPLE_TEXTURE2D(unity_ShadowMask, samplerunity_ShadowMask, input.lightmapUV);
                #endif
            }
            
            half4 frag(VertexOutput IN, out float outDepth: SV_Depth): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                half4 albedoAlpha = SampleAlbedoAlpha(IN.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                half alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);
                
                
                float4 clipPos = 0;
                float3 worldPos = 0;
                
                //OctaImpostorFragment(o, clipPos, worldPos, IN.uvsFrame1, IN.uvsFrame2, IN.uvsFrame3, IN.octaFrame, IN.viewPos);
                IN.positionCS.zw = clipPos.zw;
                
                outDepth = IN.positionCS.z + 1.0;
                
                InputData inputData;
                InitializeInputData(IN, IN.normalWS, inputData);
                
                half4 color = UniversalFragmentPBR(inputData, albedoAlpha.rgb, 0, 0, 0, 0, 0, alpha);
                clip(color.a - 0.5);
                return float4(_ObjectId, _PassValue, 1.0, 1.0);
            }
            
            ENDHLSL
            
        }
        
        
        
        //UsePass "Hidden/LWRP/General/PlanarShadow"
    }
    
    // Uses a custom shader GUI to display settings. Re-use the same from Lit shader as they have the
    // same properties.
    CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.LitShader_Simple"
}