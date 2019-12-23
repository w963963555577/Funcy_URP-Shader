// When creating shaders for Lightweight Render Pipeline you can you the ShaderGraph which is super AWESOME!
// However, if you want to author shaders in shading language you can use this teamplate as a base.
// Please note, this shader does not match perfomance of the built-in LWRP Lit shader.
// This shader works with LWRP 5.7.2 version and above
Shader "ZDShader/LWRP/PBR Base(Simple Vertex Color)"
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
        
        [Toggle] _DebugMask ("Debug Mask", Int) = 0
    }

    SubShader
    {
        // With SRP we introduce a new "RenderPipeline" tag in Subshader. This allows to create shaders
        // that can match multiple render pipelines. If a RenderPipeline tag is not set it will match
        // any render pipeline. In case you want your subshader to only run in LWRP set the tag to
        // "LightweightPipeline"
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "LightweightPipeline" "IgnoreProjector" = "True" }
        LOD 300

        // ------------------------------------------------------------------
        // Forward pass. Shades GI, emission, fog and all lights in a single pass.
        // Compared to Builtin pipeline forward renderer, LWRP forward renderer will
        // render a scene with multiple lights with less drawcalls and less overdraw.
        Pass
        {
            // "Lightmode" tag must be "LightweightForward" or not be defined in order for
            // to render objects.
            Name "StandardLit"
            Tags { "LightMode" = "LightweightForward" }

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

            // -------------------------------------
            // Lightweight Render Pipeline keywords
            // When doing custom shaders you most often want to copy and past these #pragmas
            // These multi_compile variants are stripped from the build depending on:
            // 1) Settings in the LWRP Asset assigned in the GraphicsSettings at build time
            // e.g If you disable AdditionalLights in the asset then all _ADDITIONA_LIGHTS variants
            // will be stripped from build
            // 2) Invalid combinations are stripped. e.g variants with _MAIN_LIGHT_SHADOWS_CASCADE
            // but not _MAIN_LIGHT_SHADOWS are invalid and therefore stripped.
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
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

            // Including the following two function is enought for shading with Lightweight Pipeline. Everything is included in them.
            // Core.hlsl will include SRP shader library, all constant buffers not related to materials (perobject, percamera, perframe).
            // It also includes matrix/space conversion functions and fog.
            // Lighting.hlsl will include the light functions/data to abstract light constants. You should use GetMainLight and GetLight functions
            // that initialize Light struct. Lighting.hlsl also include GI, Light BDRF functions. It also includes Shadows.

            // Required by all Lightweight Render Pipeline shaders.
            // It will include Unity built-in shader variables (except the lighting variables)
            // (https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
            // It will also include many utilitary functions.
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"

            // Include this if you are doing a lit shader. This includes lighting shader variables,
            // lighting and shadow functions
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"

            // Material shader variables are not defined in SRP or LWRP shader library.
            // This means _BaseColor, _BaseMap, _BaseMap_ST, and all variables in the Properties section of a shader
            // must be defined by the shader itself. If you define all those properties in CBUFFER named
            // UnityPerMaterial, SRP can cache the material properties between frames and reduce significantly the cost
            // of each drawcall.
            // In this case, for sinmplicity LitInput.hlsl is included. This contains the CBUFFER for the material
            // properties defined above. As one can see this is not part of the ShaderLibrary, it specific to the
            // LWRP Lit shader.
            #ifndef LIGHTWEIGHT_LIT_INPUT_INCLUDED
                #define LIGHTWEIGHT_LIT_INPUT_INCLUDED

                #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
                #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/SurfaceInput.hlsl"
                #include "Packages/com.zd.lwrp.funcy/ShaderLibrary/VertexAnimation.hlsl"
                //#include "Assets/Funcy_LWRP/ShaderLibrary/VertexAnimation.hlsl"
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
                CBUFFER_END

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

            #endif // LIGHTWEIGHT_INPUT_SURFACE_PBR_INCLUDED
            

            struct Attributes
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
                float4 tangentOS: TANGENT;
                float2 uv: TEXCOORD0;
                float2 uvLM: TEXCOORD1;
                float4 color: COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv: TEXCOORD0;
                float2 uvLM: TEXCOORD1;
                float4 positionWSAndFogFactor: TEXCOORD2; // xyz: positionWS, w: vertex fog factor
                half3 normalWS: TEXCOORD3;

                #if _NORMALMAP
                    half3 tangentWS: TEXCOORD4;
                    half3 bitangentWS: TEXCOORD5;
                #endif

                #ifdef _MAIN_LIGHT_SHADOWS
                    float4 shadowCoord: TEXCOORD6; // compute shadow coord per-vertex for the main light
                #endif
                float4 positionOS: TEXCOORD7;
                float4 color: TEXCoord8;
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

                input.positionOS = WindAnimation(input.positionOS);
                output.positionOS = input.positionOS;
                output.color = input.color;
                // VertexPositionInputs contains position in multiple spaces (world, view, homogeneous clip space)
                // Our compiler will strip all unused references (say you don't use view space).
                // Therefore there is more flexibility at no additional cost with this struct.
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

                // Similar to VertexPositionInputs, VertexNormalInputs will contain normal, tangent and bitangent
                // in world space. If not used it will be stripped.
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                // Computes fog factor per-vertex.
                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                // TRANSFORM_TEX is the same as the old shader library.
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.uvLM = input.uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;

                output.positionWSAndFogFactor = float4(vertexInput.positionWS, fogFactor);
                output.normalWS = vertexNormalInput.normalWS;

                // Here comes the flexibility of the input structs.
                // In the variants that don't have normal map defined
                // tangentWS and bitangentWS will not be referenced and
                // GetVertexNormalInputs is only converting normal
                // from object to world space
                #ifdef _NORMALMAP
                    output.tangentWS = vertexNormalInput.tangentWS;
                    output.bitangentWS = vertexNormalInput.bitangentWS;
                #endif

                #ifdef _MAIN_LIGHT_SHADOWS
                    // shadow coord for the main light is computed in vertex.
                    // If cascades are enabled, LWRP will resolve shadows in screen space
                    // and this coord will be the uv coord of the screen space shadow texture.
                    // Otherwise LWRP will resolve shadows in light space (no depth pre-pass and shadow collect pass)
                    // In this case shadowCoord will be the position in light space.
                    output.shadowCoord = GetShadowCoord(vertexInput);
                #endif
                // We just use the homogeneous clip position from the vertex input
                output.positionCS = vertexInput.positionCS;
                return output;
            }

            half4 LitPassFragment(Varyings input): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                // Surface data contains albedo, metallic, specular, smoothness, occlusion, emission and alpha
                // InitializeStandarLitSurfaceData initializes based on the rules for standard shader.
                // You can write your own function to initialize the surface data of your shader.
                SurfaceData surfaceData;
                InitializeStandardLitSurfaceData(input.uv, surfaceData);

                #if _NORMALMAP
                    half3 normalWS = TransformTangentToWorld(surfaceData.normalTS,
                    half3x3(input.tangentWS, input.bitangentWS, input.normalWS));
                #else
                    half3 normalWS = input.normalWS;
                #endif
                normalWS = normalize(normalWS);

                #ifdef LIGHTMAP_ON
                    // Normal is required in case Directional lightmaps are baked
                    half3 bakedGI = SampleLightmap(input.uvLM, normalWS);
                #else
                    // Samples SH fully per-pixel. SampleSHVertex and SampleSHPixel functions
                    // are also defined in case you want to sample some terms per-vertex.
                    half3 bakedGI = SampleSH(normalWS);
                #endif

                float3 positionWS = input.positionWSAndFogFactor.xyz;
                half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);

                // BRDFData holds energy conserving diffuse and specular material reflections and its roughness.
                // It's easy to plugin your own shading fuction. You just need replace LightingPhysicallyBased function
                // below with your own.
                BRDFData brdfData;
                InitializeBRDFData(surfaceData.albedo * input.color, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

                // Light struct is provide by LWRP to abstract light shader variables.
                // It contains light direction, color, distanceAttenuation and shadowAttenuation.
                // LWRP take different shading approaches depending on light and platform.
                // You should never reference light shader variables in your shader, instead use the GetLight
                // funcitons to fill this Light struct.
                #ifdef _MAIN_LIGHT_SHADOWS
                    // Main light is the brightest directional light.
                    // It is shaded outside the light loop and it has a specific set of variables and shading path
                    // so we can be as fast as possible in the case when there's only a single directional light
                    // You can pass optionally a shadowCoord (computed per-vertex). If so, shadowAttenuation will be
                    // computed.
                    Light mainLight = GetMainLight(input.shadowCoord);
                #else
                    Light mainLight = GetMainLight();
                #endif

                // Mix diffuse GI with environment reflections.
                half3 color = GlobalIllumination(brdfData, bakedGI, surfaceData.occlusion, normalWS, viewDirectionWS);

                // LightingPhysicallyBased computes direct light contribution.
                color += LightingPhysicallyBased(brdfData, mainLight, normalWS, viewDirectionWS);

                // Additional lights loop
                #ifdef _ADDITIONAL_LIGHTS

                    // Returns the amount of lights affecting the object being renderer.
                    // These lights are culled per-object in the forward renderer
                    int additionalLightsCount = GetAdditionalLightsCount();
                    for (int i = 0; i < additionalLightsCount; ++ i)
                    {
                        // Similar to GetMainLight, but it takes a for-loop index. This figures out the
                        // per-object light index and samples the light buffer accordingly to initialized the
                        // Light struct. If _ADDITIONAL_LIGHT_SHADOWS is defined it will also compute shadows.
                        Light light = GetAdditionalLight(i, positionWS);

                        // Same functions used to shade the main light.
                        color += LightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
                    }
                #endif
                // Emission
                color += surfaceData.emission;

                float fogFactor = input.positionWSAndFogFactor.w;

                // Mix the pixel color with fogColor. You can optionaly use MixFogColor to override the fogColor
                // with a custom one.
                color = MixFog(color, fogFactor);

                if (_DebugMask == 1.0)
                {
                    float4 objectOrigin = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
                    float4 positionMask = _PositionMask.Sample(sampler_PositionMask, TRANSFORM_TEX(input.positionOS, _PositionMask));
                    color = positionMask.rrrr * positionMask.aaar;
                }
                
                return half4(color, surfaceData.alpha);
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

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment


            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.zd.lwrp.funcy/ShaderLibrary/VertexAnimation.hlsl"

            
            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            CBUFFER_END


            struct GraphVertexInput
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD;

                float3 ase_normal: NORMAL;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            CBUFFER_START(UnityPerMaterial)
            CBUFFER_END


            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                float2 uv: TEXCOORD;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            
            // x: global clip space bias, y: normal world space bias
            float3 _LightDirection;

            VertexOutput ShadowPassVertex(GraphVertexInput v)
            {
                VertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                v.vertex = WindAnimation(v.vertex);

                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    float3 defaultVertexValue = v.vertex.xyz;
                #else
                    float3 defaultVertexValue = float3(0, 0, 0);
                #endif
                float3 vertexValue = defaultVertexValue ;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    v.vertex.xyz = vertexValue;
                #else
                    v.vertex.xyz += vertexValue;
                #endif

                v.ase_normal = v.ase_normal ;

                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

                float invNdotL = 1.0 - saturate(dot(_LightDirection, normalWS));
                float scale = invNdotL * _ShadowBias.y;

                // normal bias is negative since we want to apply an inset normal offset
                positionWS = _LightDirection * _ShadowBias.xxx + positionWS;
                positionWS = normalWS * scale.xxx + positionWS;
                float4 clipPos = TransformWorldToHClip(positionWS);

                // _ShadowBias.x sign depens on if platform has reversed z buffer
                //clipPos.z += _ShadowBias.x;

                #if UNITY_REVERSED_Z
                    clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
                #else
                    clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
                #endif
                o.uv = v.uv;
                o.clipPos = clipPos;

                return o;
            }

            half4 ShadowPassFragment(VertexOutput IN): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                half4 albedoAlpha = _BaseMap.Sample(sampler_BaseMap, IN.uv);
                float alpha = albedoAlpha.a;

                if (alpha < 0.5)
                {
                    discard;
                }

                float Alpha = 1;
                float AlphaClipThreshold = AlphaClipThreshold;

                //clip(albedoAlpha.a);
                return half4(0, 0, 0, 0);
            }
            
            ENDHLSL
            
        }

        
        Pass
        {
            
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ZTest LEqual

            ColorMask 0
            
            HLSLPROGRAM
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag


            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.zd.lwrp.funcy/ShaderLibrary/VertexAnimation.hlsl"

            

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            CBUFFER_END


            struct GraphVertexInput
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD;
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

            

            VertexOutput vert(GraphVertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                v.vertex = WindAnimation(v.vertex);
                
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    float3 defaultVertexValue = v.vertex.xyz;
                #else
                    float3 defaultVertexValue = float3(0, 0, 0);
                #endif
                float3 vertexValue = defaultVertexValue ;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    v.vertex.xyz = vertexValue;
                #else
                    v.vertex.xyz += vertexValue;
                #endif

                v.ase_normal = v.ase_normal ;
                o.uv = v.uv;
                o.clipPos = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }

            half4 frag(VertexOutput IN): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                half4 albedoAlpha = _BaseMap.Sample(sampler_BaseMap, IN.uv);
                float alpha = albedoAlpha.a;

                if (alpha < 0.5)
                {
                    discard;
                }

                float Alpha = 1;
                float AlphaClipThreshold = AlphaClipThreshold;

                //clip(albedoAlpha.a);
                return half4(0, 0, 0, 0);
            }
            ENDHLSL
            
        }

        Pass
        {
            
            Name "Meta"
            Tags { "LightMode" = "Meta" }

            Cull Off
            
            HLSLPROGRAM
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/MetaInput.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            

            CBUFFER_START(UnityPerMaterial)
            float4 _Color0;
            CBUFFER_END


            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            
            struct GraphVertexInput
            {
                float4 vertex: POSITION;
                float3 ase_normal: NORMAL;
                float4 texcoord1: TEXCOORD1;
                float4 texcoord2: TEXCOORD2;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                float4 ase_texcoord: TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            
            VertexOutput vert(GraphVertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
                float4 screenPos = ComputeScreenPos(ase_clipPos);
                o.ase_texcoord = screenPos;
                
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    float3 defaultVertexValue = v.vertex.xyz;
                #else
                    float3 defaultVertexValue = float3(0, 0, 0);
                #endif
                float3 vertexValue = defaultVertexValue ;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    v.vertex.xyz = vertexValue;
                #else
                    v.vertex.xyz += vertexValue;
                #endif

                v.ase_normal = v.ase_normal ;
                #if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION > 51300
                    o.clipPos = MetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST);
                #else
                    o.clipPos = MetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST);
                #endif
                return o;
            }

            half4 frag(VertexOutput IN): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

                float4 screenPos = IN.ase_texcoord;
                float4 ase_screenPosNorm = screenPos / screenPos.w;
                ase_screenPosNorm.z = (UNITY_NEAR_CLIP_VALUE >= 0) ? ase_screenPosNorm.z: ase_screenPosNorm.z * 0.5 + 0.5;
                float4 fetchOpaqueVal51 = float4(SHADERGRAPH_SAMPLE_SCENE_COLOR(ase_screenPosNorm.xy), 1.0);
                
                
                float3 Albedo = _Color0.rgb;
                float3 Emission = fetchOpaqueVal51.rgb;
                float Alpha = 1;
                float AlphaClipThreshold = 0;

                #if _AlphaClip
                    clip(Alpha - AlphaClipThreshold);
                #endif

                MetaInput metaInput = (MetaInput)0;
                metaInput.Albedo = Albedo;
                metaInput.Emission = Emission;
                
                return MetaFragment(metaInput);
            }
            ENDHLSL
            
        }
    }

    // Uses a custom shader GUI to display settings. Re-use the same from Lit shader as they have the
    // same properties.
    CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.LitShader_Simple"
}