// When creating shaders for Lightweight Render Pipeline you can you the ShaderGraph which is super AWESOME!
// However, if you want to author shaders in shading language you can use this teamplate as a base.
// Please note, this shader does not match perfomance of the built-in LWRP Lit shader.
// This shader works with LWRP 5.7.2 version and above
Shader "ZDShader/LWRP/PBR Base(SSS)"
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
        
        _SubsurfaceScattering ("Scatter", Range(0, 1)) = 0.0
        _SubsurfaceRadius ("Radius", Float) = 2.0
        [HDR]_SubsurfaceColor ("Color", Color) = (1, 1, 1)
        _SubsurfaceMap ("SSS Map", 2D) = "White" { }
        
        [HDR]_RimLightColor ("Color", Color) = (.7, .85, 1.0)
        _RimLightSoftness ("Softness", Range(0.0, 1.0)) = 0.6
        _MaxHDR ("Max HDR", Range(0.0, 10.0)) = 10.0
        
        
        _WireframeViewSplit ("Wireframe Map", Range(0, 1)) = 0.0
        
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
    }
    
    SubShader
    {
        
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True" }
        LOD 300
        
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
            #pragma target 3.0
            
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
            
            #pragma multi_compile _MobileSSPR
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
                half4 _SubsurfaceColor;
                half _SubsurfaceScattering;
                half _SubsurfaceRadius;
                half4 _RimLightColor;
                half _RimLightSoftness;
                half _MaxHDR;
                
                half _WireframeViewSplit;
                CBUFFER_END
                
                TEXTURE2D(_OcclusionMap);       SAMPLER(sampler_OcclusionMap);
                TEXTURE2D(_MetallicGlossMap);   SAMPLER(sampler_MetallicGlossMap);
                TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);
                TEXTURE2D(_SubsurfaceMap);      SAMPLER(sampler_SubsurfaceMap);
                
                TEXTURE2D(_MobileSSPR_ColorRT); sampler LinearClampSampler;
                
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
                    float4 texcoord: TEXCOORD0;
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
                    float4 srcPos: TEXCOORD8;
                    
                    half3 barycentricCoordinates: TEXCOORD9;
                    
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
                    
                    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                    half3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
                    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                    
                    output.uv = TRANSFORM_TEX(input.texcoord.xy, _BaseMap);
                    
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
                    output.srcPos = ComputeScreenPos(output.positionCS);
                    
                    output.barycentricCoordinates = float3(floor(input.texcoord.z), frac(input.texcoord.z) * 10, input.texcoord.w);
                    return output;
                }
                
                
                // Calculates the subsurface light radiating out from the current fragment. This is a simple approximation using wrapped lighting.
                // Note: This does not use distance attenuation, as it is intented to be used with a sun light.
                // Note: This does not subtract out cast shadows (light.shadowAttenuation), as it is intended to be used on non-shadowed objects. (for now)
                half3 LightingSubsurface(Light light, half3 normalWS, half3 subsurfaceColor, half subsurfaceRadius, out half NdotL)
                {
                    // Calculate normalized wrapped lighting. This spreads the light without adding energy.
                    // This is a normal lambertian lighting calculation (using N dot L), but warping NdotL
                    // to wrap the light further around an object.
                    //
                    // A normalization term is applied to make sure we do not add energy.
                    // http://www.cim.mcgill.ca/~derek/files/jgt_wrap.pdf
                    
                    NdotL = dot(normalWS, light.direction);
                    half alpha = subsurfaceRadius;
                    //half theta_m = acos(-alpha); // boundary of the lighting function
                    
                    half theta = max(0, NdotL + alpha) - alpha;
                    half normalization_jgt = (2 + alpha) / (2 * (1 + alpha));
                    half wrapped_jgt = (pow(((theta + alpha) / (1 + alpha)), 1.0 + alpha)) * normalization_jgt;
                    
                    //half wrapped_valve = 0.25 * (NdotL + 1) * (NdotL + 1);
                    //half wrapped_simple = (NdotL + alpha) / (1 + alpha);
                    
                    half3 subsurface_radiance = light.color * subsurfaceColor * wrapped_jgt;
                    
                    return subsurface_radiance;
                }
                
                half4 UniversalFragmentPBR_SSS(InputData inputData, half3 albedo, half metallic, half3 specular,
                half smoothness, half occlusion, half3 emission, half3 sssColor, half alpha)
                {
                    BRDFData brdfData;
                    InitializeBRDFData(albedo, metallic, specular, smoothness, alpha, brdfData);
                    
                    Light mainLight = GetMainLight(inputData.shadowCoord);
                    
                    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, half4(0, 0, 0, 0));
                    
                    half3 GI = GlobalIllumination(brdfData, inputData.bakedGI, occlusion, inputData.normalWS, inputData.viewDirectionWS);
                    half3 color = GI;
                    half NdotLTutorial = 0.0;
                    half Ndot = 0.0;
                    half3 mainLightContribution = LightingPhysicallyBased(brdfData, mainLight, inputData.normalWS, inputData.viewDirectionWS);
                    half3 subsurfaceContribution = LightingSubsurface(mainLight, inputData.normalWS, sssColor, _SubsurfaceRadius, Ndot);
                    NdotLTutorial += Ndot;
                    
                    color += lerp(mainLightContribution, subsurfaceContribution, _SubsurfaceScattering * (1.0 - metallic));
                    
                    
                    #ifdef _ADDITIONAL_LIGHTS
                        uint pixelLightCount = GetAdditionalLightsCount();
                        for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++ lightIndex)
                        {
                            Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
                            
                            mainLightContribution = LightingPhysicallyBased(brdfData, light, inputData.normalWS, inputData.viewDirectionWS);
                            subsurfaceContribution = LightingSubsurface(light, inputData.normalWS, sssColor, _SubsurfaceRadius, Ndot);
                            NdotLTutorial = max(Ndot, NdotLTutorial);
                            
                            color += lerp(mainLightContribution, subsurfaceContribution, _SubsurfaceScattering * (1.0 - metallic));
                        }
                    #endif
                    NdotLTutorial = saturate(NdotLTutorial);
                    #ifdef _ADDITIONAL_LIGHTS_VERTEX
                        color += inputData.vertexLighting * brdfData.diffuse;
                    #endif
                    
                    color += emission;
                    
                    half fresnel = smoothstep(_RimLightSoftness, 1.0, 1.0 - saturate(dot(inputData.normalWS, inputData.viewDirectionWS)));
                    half3 rimLighting = albedo * NdotLTutorial * fresnel * 1.0 * _RimLightColor;
                    
                    color += rimLighting;
                    alpha = max(fresnel * _RimLightColor.a, alpha);
                    color.rgb = clamp(color, 0.0.xxxx, (max(albedo, GI)) * _MaxHDR);
                    return half4(color, alpha);
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
                    input.srcPos.xyz = input.srcPos.xyz / input.srcPos.w;
                    #if _MobileSSPR
                        half4 SSPR = SAMPLE_TEXTURE2D(_MobileSSPR_ColorRT, LinearClampSampler, input.srcPos.xy); //use LinearClampSampler to make it blurry
                    #endif
                    //_MainLightShadowParams.x *= inputData.shadowCoord.x;
                    half3 sssColor = SAMPLE_TEXTURE2D(_SubsurfaceMap, sampler_SubsurfaceMap, input.uv).rgb * _SubsurfaceColor.rgb;
                    half4 color = UniversalFragmentPBR_SSS(inputData, surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.occlusion, surfaceData.emission, sssColor, surfaceData.alpha);
                    color.rgb = MixFog(color.rgb, inputData.fogCoord);
                    
                    half size = 1.3;
                    float3 mass = input.barycentricCoordinates.xyz;
                    half3 width = abs(ddx(mass)) + abs(ddy(mass));
                    half3 eF = smoothstep(0, width * size, mass);
                    half wireframe = min(min(eF.x, eF.y), eF.z);
                    half3 wireframeColor = lerp(color.rgb, half3(0.3, 0.5, 1.0) * 0.5 + color.rgb, 1.0 - wireframe);
                    color.rgb = lerp(color.rgb, wireframeColor, step(input.srcPos.x, _WireframeViewSplit - 0.0075));
                    
                    return color;
                }
                
            #endif
            
            ENDHLSL
            
        }
        
        
        // Used for rendering shadowmaps
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
            half4 _SubsurfaceColor;
            half _SubsurfaceScattering;
            half _SubsurfaceRadius;
            half4 _RimLightColor;
            half _RimLightSoftness;
            half _MaxHDR;
            
            half _WireframeViewSplit;
            CBUFFER_END
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            
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
                    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE * 10);
                #else
                    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE * 10);
                #endif
                
                return positionCS;
            }
            
            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
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
            half4 _SubsurfaceColor;
            half _SubsurfaceScattering;
            half _SubsurfaceRadius;
            half4 _RimLightColor;
            half _RimLightSoftness;
            half _MaxHDR;
            
            half _WireframeViewSplit;
            CBUFFER_END
            
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
    }
    
    // Uses a custom shader GUI to display settings. Re-use the same from Lit shader as they have the
    // same properties.
    CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.LitShader_SSS"
}