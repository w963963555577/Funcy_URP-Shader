Shader "ZDShader/URP/PBR-Base"
{
    Properties
    {
        [MaterialToggle]  _EditorAppearMode ("Editor Appear Mode", Float) = 1.0
        // Specular vs Metallic workflow
        [HideInInspector] _WorkflowMode ("Workflow Mode", Float) = 1.0
        
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
        [Toggle] _SSPREnabled ("Screen Space Planar Reflections", Float) = 0.0
        [Toggle] _FlowEmissionEnabled ("Flow Emossion", Float) = 0.0
        
        _BumpScale ("Scale", Float) = 1.0
        _BumpMap ("Normal Map", 2D) = "bump" { }
        
        _OcclusionStrength ("Strength", Range(0.0, 1.0)) = 1.0
        _OcclusionMap ("Occlusion", 2D) = "white" { }
        
        _EmissionColor ("Color", Color) = (0, 0, 0)
        _EmissionMap ("Emission", 2D) = "white" { }
        
        //Wind
        [MaterialToggle]  _WindEnabled ("Wind", Float) = 0.0
        _Speed ("Speed", Float) = 1.5
        _Amount ("Amount", Float) = 5
        _Distance ("Distance", Range(0, 1)) = 0.5
        _PositionMask ("PositionMask", 2D) = "white" { }
        
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
            
            // Required to compile gles 2.0 with standard SRP library
            // All shaders must be compiled with HLSLcc and currently only gles is not using HLSLcc by default
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
            
            #pragma multi_compile _ _DrawMeshInstancedProcedural
            
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
                TEXTURE2D(_MobileSSPR_ColorRT);
                sampler LinearClampSampler;
                
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
                half _SSPREnabled;
                half _FlowEmissionEnabled;
                half4 _PositionMask_ST;
                half _WindEnabled;
                half _Speed;
                half _Amount;
                half _Distance;
                #ifdef _DrawMeshInstancedProcedural
                    StructuredBuffer<float4x4> _ObjectToWorldBuffer;
                    StructuredBuffer<float4x4> _WorldToObjectBuffer;
                    StructuredBuffer<uint> _VisibleInstanceOnlyTransformIDBuffer;
                #endif
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
                
                inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData, out half emissionFlowMask)
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
                    #ifndef _EMISSION
                        outSurfaceData.emission = 0;
                        emissionFlowMask = 0;
                    #else
                        half4 emissionMap = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv);
                        outSurfaceData.emission = emissionMap.rgb * _EmissionColor.rgb;
                        emissionFlowMask = emissionMap.a;
                    #endif
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
                    float2 effectcoord: TEXCOORD2;
                    
                    #ifdef _DrawMeshInstancedProcedural
                        uint mid: SV_INSTANCEID;
                    #else
                        UNITY_VERTEX_INPUT_INSTANCE_ID
                    #endif
                };
                
                struct Varyings
                {
                    float4 uv: TEXCOORD0;
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
                    
                    float4 positionSS: TEXCOORD8;
                    
                    float4 positionCS: SV_POSITION;
                    
                    #ifdef _DrawMeshInstancedProcedural
                    #else
                        UNITY_VERTEX_INPUT_INSTANCE_ID
                        UNITY_VERTEX_OUTPUT_STEREO
                    #endif
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
                #ifdef _DrawMeshInstancedProcedural
                    VertexPositionInputs InitVertexPositionInputs(float3 positionOS, uint id)
                    {
                        VertexPositionInputs input;
                        input.positionWS = mul(_ObjectToWorldBuffer[id], float4(positionOS, 1.0)).xyz;
                        input.positionVS = TransformWorldToView(input.positionWS);
                        input.positionCS = TransformWorldToHClip(input.positionWS);
                        
                        float4 ndc = input.positionCS * 0.5f;
                        input.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
                        input.positionNDC.zw = input.positionCS.zw;
                        
                        return input;
                    }
                    
                    VertexNormalInputs InitVertexNormalInputs(float3 normalOS, float4 tangentOS, uint id)
                    {
                        VertexNormalInputs tbn;
                        
                        // mikkts space compliant. only normalize when extracting normal at frag.
                        real sign = tangentOS.w * GetOddNegativeScale();
                        #ifdef UNITY_ASSUME_UNIFORM_SCALING
                            tbn.normalWS.xyz = SafeNormalize(mul((real3x3)_ObjectToWorldBuffer[id], normalOS.xyz));
                        #else
                            tbn.normalWS.xyz = SafeNormalize(mul(normalOS, (real3x3)_WorldToObjectBuffer[id]));
                        #endif
                        tbn.tangentWS.xyz = SafeNormalize(mul((real3x3)_ObjectToWorldBuffer[id], tangentOS.xyz));
                        tbn.bitangentWS = cross(tbn.normalWS, tbn.tangentWS) * sign;
                        return tbn;
                    }
                #endif
                // Used in Standard (Physically Based) shader
                Varyings LitPassVertex(Attributes input)
                {
                    Varyings output = (Varyings)0;
                    #ifdef _DrawMeshInstancedProcedural
                        uint id = _VisibleInstanceOnlyTransformIDBuffer[input.mid];
                    #else
                        UNITY_SETUP_INSTANCE_ID(input);
                        UNITY_TRANSFER_INSTANCE_ID(input, output);
                        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                    #endif
                    
                    float4 offset = input.positionOS;
                    #ifdef _DrawMeshInstancedProcedural
                        input.positionOS = lerp(input.positionOS, WindAnimation(input.positionOS, _ObjectToWorldBuffer[id], _WorldToObjectBuffer[id]), _WindEnabled);
                    #else
                        input.positionOS = lerp(input.positionOS, WindAnimation(input.positionOS, GetObjectToWorldMatrix(), GetWorldToObjectMatrix()), _WindEnabled);
                    #endif
                    offset -= input.positionOS;
                    input.normalOS = input.normalOS + offset.xyz * 0.5 * _WindEnabled;
                    
                    
                    VertexPositionInputs vertexInput;
                    VertexNormalInputs normalInput;
                    
                    #ifdef _DrawMeshInstancedProcedural
                        vertexInput = InitVertexPositionInputs(input.positionOS.xyz, id);
                        normalInput = InitVertexNormalInputs(input.normalOS, input.tangentOS, id);
                    #else
                        vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                        normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                    #endif
                    
                    half3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
                    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                    
                    output.uv.xy = TRANSFORM_TEX(input.texcoord, _BaseMap);
                    
                    output.uv.zw = input.effectcoord.xy;
                    
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
                    
                    output.positionSS = ComputeScreenPos(output.positionCS);
                    
                    return output;
                }
                
                half3 GlobalIllumination_SSPR(BRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS, half3 viewDirectionWS, float2 screenUV)
                {
                    half3 reflectVector = reflect(-viewDirectionWS, normalWS);
                    half fresnelTerm = Pow4(1.0 - saturate(dot(normalWS, viewDirectionWS)));
                    
                    half3 indirectDiffuse = bakedGI * occlusion;
                    half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion);
                    
                    half4 ssrColor = SAMPLE_TEXTURE2D(_MobileSSPR_ColorRT, LinearClampSampler, screenUV);
                    ssrColor.a *= saturate(dot(normalWS, half3(0.0, 1.0, 0.0))) * _SSPREnabled;
                    indirectSpecular = lerp(indirectSpecular, ssrColor.rgb, ssrColor.a);
                    
                    return EnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
                }
                
                half4 UniversalFragmentPBR_SSPR(InputData inputData, half3 albedo, half metallic, half3 specular,
                half smoothness, half occlusion, half3 emission, half alpha, float2 screenUV)
                {
                    BRDFData brdfData;
                    InitializeBRDFData(albedo, metallic, specular, smoothness, alpha, brdfData);
                    
                    Light mainLight = GetMainLight(inputData.shadowCoord);
                    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, half4(0, 0, 0, 0));
                    
                    half3 color = GlobalIllumination_SSPR(brdfData, inputData.bakedGI, occlusion, inputData.normalWS, inputData.viewDirectionWS, screenUV);
                    color += LightingPhysicallyBased(brdfData, mainLight, inputData.normalWS, inputData.viewDirectionWS);
                    
                    #ifdef _ADDITIONAL_LIGHTS
                        uint pixelLightCount = GetAdditionalLightsCount();
                        for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++ lightIndex)
                        {
                            Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
                            color += LightingPhysicallyBased(brdfData, light, inputData.normalWS, inputData.viewDirectionWS);
                        }
                    #endif
                    
                    #ifdef _ADDITIONAL_LIGHTS_VERTEX
                        color += inputData.vertexLighting * brdfData.diffuse;
                    #endif
                    
                    color += emission;
                    return half4(color, alpha);
                }
                
                
                // Used in Standard (Physically Based) shader
                half4 LitPassFragment(Varyings input): SV_Target
                {
                    #ifdef _DrawMeshInstancedProcedural
                    #else
                        UNITY_SETUP_INSTANCE_ID(input);
                        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                    #endif
                    SurfaceData surfaceData;
                    half emissionFlowMask = 0.0;
                    InitializeStandardLitSurfaceData(input.uv.xy, surfaceData, emissionFlowMask);
                    
                    InputData inputData;
                    InitializeInputData(input, surfaceData.normalTS, inputData);
                    float2 screenUV = 0.0;
                    
                    input.positionSS /= input.positionSS.w;
                    input.positionSS.z = (UNITY_NEAR_CLIP_VALUE >= 0) ? input.positionSS.z: input.positionSS.z * 0.5 + 0.5;
                    screenUV = input.positionSS.xy;
                    #if defined(UNITY_SINGLE_PASS_STEREO)
                        screenUV.xy = UnityStereoTransformScreenSpaceTex(screenUV.xy);
                    #endif
                    
                    
                    half4 color = UniversalFragmentPBR_SSPR(inputData,
                    surfaceData.albedo,
                    surfaceData.metallic,
                    surfaceData.specular,
                    surfaceData.smoothness,
                    surfaceData.occlusion,
                    surfaceData.emission +
                    surfaceData.emission * sin(input.uv.z * 6.28 * 2.0 + _Time.y * 3.0) * emissionFlowMask * _FlowEmissionEnabled,
                    surfaceData.alpha,
                    screenUV);
                    
                    color.rgb = MixFog(color.rgb, inputData.fogCoord);
                    
                    return color;
                }
                
            #endif
            
            ENDHLSL
            
        }
        
        // Used for rendering shadowmaps
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
            #pragma multi_compile _ _DrawMeshInstancedProcedural
            
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
            half _SSPREnabled;
            half _FlowEmissionEnabled;
            half4 _PositionMask_ST;
            half _WindEnabled;
            half _Speed;
            half _Amount;
            half _Distance;
            #ifdef _DrawMeshInstancedProcedural
                StructuredBuffer<float4x4> _ObjectToWorldBuffer;
                StructuredBuffer<float4x4> _WorldToObjectBuffer;
                StructuredBuffer<uint> _VisibleInstanceOnlyTransformIDBuffer;
            #endif
            CBUFFER_END
            
            #include "../../../ShaderLibrary/VertexAnimation.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            
            float3 _LightDirection;
            
            struct Attributes
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
                float2 texcoord: TEXCOORD0;
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
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    UNITY_VERTEX_OUTPUT_STEREO
                #endif
            };
            
            float4 GetShadowPositionHClip(Attributes input)
            {
                #ifdef _DrawMeshInstancedProcedural
                    uint id = _VisibleInstanceOnlyTransformIDBuffer[input.mid];
                    
                    float3 positionWS = mul(_ObjectToWorldBuffer[id], float4(input.positionOS.xyz, 1.0)).xyz;
                    float3 normalWS = float3(0, 0, 0);
                    
                    #ifdef UNITY_ASSUME_UNIFORM_SCALING
                        normalWS = SafeNormalize(mul((real3x3)_ObjectToWorldBuffer[id], input.normalOS));
                    #else
                        normalWS = SafeNormalize(mul(input.normalOS, (real3x3)_WorldToObjectBuffer[id]));
                    #endif
                #else
                    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                    
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
                Varyings output = (Varyings)0;
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_SETUP_INSTANCE_ID(input);
                #endif
                
                float4 offset = input.positionOS;
                #ifdef _DrawMeshInstancedProcedural
                    input.positionOS = lerp(input.positionOS, WindAnimation(input.positionOS, _ObjectToWorldBuffer[input.mid], _WorldToObjectBuffer[input.mid]), _WindEnabled);
                #else
                    input.positionOS = lerp(input.positionOS, WindAnimation(input.positionOS, GetObjectToWorldMatrix(), GetWorldToObjectMatrix()), _WindEnabled);
                #endif
                
                offset -= input.positionOS;
                input.normalOS = input.normalOS + offset.xyz * 0.5 * _WindEnabled;
                
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
            #pragma multi_compile _ _DrawMeshInstancedProcedural
            
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
            half _SSPREnabled;
            half _FlowEmissionEnabled;
            half4 _PositionMask_ST;
            half _WindEnabled;
            half _Speed;
            half _Amount;
            half _Distance;
            #ifdef _DrawMeshInstancedProcedural
                StructuredBuffer<float4x4> _ObjectToWorldBuffer;
                StructuredBuffer<float4x4> _WorldToObjectBuffer;
                StructuredBuffer<uint> _VisibleInstanceOnlyTransformIDBuffer;
            #endif
            CBUFFER_END
            
            #include "../../../ShaderLibrary/VertexAnimation.hlsl"
            
            struct Attributes
            {
                float4 position: POSITION;
                float2 texcoord: TEXCOORD0;
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
                    uint id = _VisibleInstanceOnlyTransformIDBuffer[input.mid];
                #else
                    UNITY_SETUP_INSTANCE_ID(input);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                #endif
                
                #ifdef _DrawMeshInstancedProcedural
                    input.position = lerp(input.position, WindAnimation(input.position, _ObjectToWorldBuffer[input.mid], _WorldToObjectBuffer[input.mid]), _WindEnabled);
                #else
                    input.position = lerp(input.position, WindAnimation(input.position, GetObjectToWorldMatrix(), GetWorldToObjectMatrix()), _WindEnabled);
                #endif
                
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                
                float3 positionWS = float3(0.0, 0.0, 0.0);
                #ifdef _DrawMeshInstancedProcedural
                    positionWS = mul(_ObjectToWorldBuffer[id], float4(input.position.xyz, 1.0)).xyz;
                #else
                    positionWS = TransformObjectToWorld(input.position.xyz);
                #endif
                
                output.positionCS = TransformWorldToHClip(positionWS);
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
            #pragma multi_compile _ _DrawMeshInstancedProcedural
            
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
            half _SSPREnabled;
            half _FlowEmissionEnabled;
            half4 _PositionMask_ST;
            half _WindEnabled;
            half _Speed;
            half _Amount;
            half _Distance;
            #ifdef _DrawMeshInstancedProcedural
                StructuredBuffer<float4x4> _ObjectToWorldBuffer;
                StructuredBuffer<float4x4> _WorldToObjectBuffer;
                StructuredBuffer<uint> _VisibleInstanceOnlyTransformIDBuffer;
            #endif
            CBUFFER_END
            
            #include "../../../ShaderLibrary/VertexAnimation.hlsl"
            
            struct Attributes
            {
                float4 position: POSITION;
                float2 texcoord: TEXCOORD0;
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
                    uint id = _VisibleInstanceOnlyTransformIDBuffer[input.mid];
                #else
                    UNITY_SETUP_INSTANCE_ID(input);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                #endif
                
                #ifdef _DrawMeshInstancedProcedural
                    input.position = lerp(input.position, WindAnimation(input.position, _ObjectToWorldBuffer[input.mid], _WorldToObjectBuffer[input.mid]), _WindEnabled);
                #else
                    input.position = lerp(input.position, WindAnimation(input.position, GetObjectToWorldMatrix(), GetWorldToObjectMatrix()), _WindEnabled);
                #endif
                
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                
                float3 positionWS = float3(0.0, 0.0, 0.0);
                #ifdef _DrawMeshInstancedProcedural
                    positionWS = mul(_ObjectToWorldBuffer[id], float4(input.position.xyz, 1.0)).xyz;
                #else
                    positionWS = TransformObjectToWorld(input.position.xyz);
                #endif
                
                output.positionCS = TransformWorldToHClip(positionWS);
                return output;
            }
            
            half4 DepthOnlyFragment(Varyings input): SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
                return 1.0;
            }
            
            
            ENDHLSL
            
        }
        //UsePass "Universal Render Pipeline/Lit/Meta"
    }
    
    // Uses a custom shader GUI to display settings. Re-use the same from Lit shader as they have the
    // same properties.
    CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.LitShader"
}