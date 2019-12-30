// When creating shaders for Lightweight Render Pipeline you can you the ShaderGraph which is super AWESOME!
// However, if you want to author shaders in shading language you can use this teamplate as a base.
// Please note, this shader does not match perfomance of the built-in LWRP Lit shader.
// This shader works with LWRP 5.7.2 version and above
Shader "ZDShader/LWRP/Character"
{
    Properties
    {
        _diffuse ("BaseColor", 2D) = "white" { }
        [HDR]_Color ("BaseColor", Color) = (0.72, 0.72, 0.72, 1)

        _Flash ("Flash", Float) = 0
        _mask ("ESSGMask", 2D) = "white" { }
        [HDR]_EmissionColor ("EmissionColor", Color) = (0, 0, 0)
        [MaterialToggle] _EmissionxBase ("Emission x Base", Float) = 0
        [MaterialToggle] _EmissionOn ("EmissionOn", Float) = 0

        _Gloss ("Gloss (texture=1)", Range(0, 1)) = 0.5
        [HDR]_SpecularColor ("SpecularColor", Color) = (0.6176471, 0.6145149, 0.5722318, 1)
        _ShadowRamp ("ShadowRamp", Range(0, 20)) = 1
        _Picker_0 ("Picker_0", Color) = (0.9686275, 0.8039216, 0.7882354, 1)
        _Picker_1 ("Picker_1", Color) = (0.5764706, 0.6235294, 0.8705883, 1)
        _ShadowColor0 ("ShadowColor0", Color) = (1, 0.7344488, 0.514151, 1)
        _ShadowColor1 ("ShadowColor1", Color) = (0.3160377, 0.4365495, 1, 1)
        _ShadowColorElse ("ShadowColorElse", Color) = (0.5471698, 0.5471698, 0.5471698, 1)


        [Toggle] _DiscolorationOn ("DiscolorationOn", Float) = 0
        _Discoloration ("Discoloration", Color) = (0.7058824, 0.7058824, 0.7058824, 1)

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

        [Toggle]_CustomLighting ("Custom Lighting", Float) = 0.0
        [HDR]_CustomLightColor ("Custom Light Color", Color) = (1, 1, 1, 1)
        _CustomLightDirection ("Custom Light Direction", Vector) = (0.5747975, 0.4099231, -0.7082168, 0.0)

        _ShadowRefraction ("Shadow Refraction", Range(0, 10)) = 1
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

                CBUFFER_START(UnityPerMaterial)
                float4 _diffuse_ST;
                float4 _mask_ST;
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
                half _ShadowRamp;
                half _DiscolorationOn;
                half4 _Discoloration;
                half _ReceiveShadow;
                half _ShadowRefraction;

                half _CustomLighting;
                half4 _CustomLightColor;
                half4 _CustomLightDirection;
                
                
                CBUFFER_END

                TEXTURE2D(_mask);            SAMPLER(sampler_mask);
                TEXTURE2D(_GrabTexture);            SAMPLER(sampler_GrabTexture);
                TEXTURE2D(_diffuse);                SAMPLER(sampler_diffuse);
            #endif // LIGHTWEIGHT_INPUT_SURFACE_PBR_INCLUDED
            

            struct Attributes
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
                float4 tangentOS: TANGENT;
                float2 uv: TEXCOORD0;
                float2 uvLM: TEXCOORD1;
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
                float4 positionCS: SV_POSITION;

                float4 posWorld: TEXCOORD7;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
            {
                half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                outSurfaceData.alpha = Alpha(albedoAlpha.a, float4(1, 1, 1, 1), _Cutoff);

                outSurfaceData.albedo = albedoAlpha.rgb ;
                
                outSurfaceData.metallic = 0.0h;
                outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);

                outSurfaceData.smoothness = 0.0;
                outSurfaceData.normalTS = half3(0, 0, 0);
                outSurfaceData.occlusion = half3(0, 0, 0);
                outSurfaceData.emission = half3(0, 0, 0);
            }

            Varyings LitPassVertex(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

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
                output.uv = TRANSFORM_TEX(input.uv, _diffuse);
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

                output.posWorld = mul(unity_ObjectToWorld, input.positionOS);

                return output;
            }

            float PBRShadow(Varyings i, Light mainLight)
            {
                SurfaceData surfaceData;
                InitializeStandardLitSurfaceData(i.uv, surfaceData);

                #if _NORMALMAP
                    half3 normalWS = TransformTangentToWorld(surfaceData.normalTS,
                    half3x3(input.tangentWS, input.bitangentWS, input.normalWS));
                #else
                    half3 normalWS = i.normalWS;
                #endif
                normalWS = normalize(normalWS);

                #ifdef LIGHTMAP_ON
                    half3 bakedGI = SampleLightmap(i.uvLM, normalWS);
                #else

                    half3 bakedGI = SampleSH(normalWS);
                #endif

                float3 positionWS = i.positionWSAndFogFactor.xyz;
                half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);
                
                BRDFData brdfData;
                InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

                return LightingPhysicallyBased(brdfData, mainLight, normalWS, viewDirectionWS).r;
            }
            float Remap(float value, float from1, float to1, float from2, float to2)
            {
                return(value - from1) / (to1 - from1) * (to2 - from2) + from2;
            }
            half4 LitPassFragment(Varyings i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                #ifdef _MAIN_LIGHT_SHADOWS
                    Light mainLight = GetMainLight(i.shadowCoord);
                #else
                    Light mainLight = GetMainLight();
                #endif

                if (_CustomLighting == 1.0)
                {
                    mainLight.color = _CustomLightColor;
                    //mainLight.direction = _CustomLightDirection;
                }

                //mainLight.shadowAttenuation = 0.1;

                float pbr = PBRShadow(i, mainLight);
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
                float4 _ESSGMask_var = _mask.Sample(sampler_mask, TRANSFORM_TEX(i.uv, _mask)); // R-Em  G-Shadow B-Specular A-Gloss
                float glossMask = _ESSGMask_var.a;
                float specStep = 2.0;
                float specularArea = floor(pow(max(0, dot(i.normalWS, halfDirection)), exp2(lerp(1, 11, (_Gloss_var * glossMask)))) * specStep) / (specStep - 1);
                float4 _SpecularColor_var = _SpecularColor;
                float specularMask = _ESSGMask_var.b;
                float4 _Color_var = _Color;
                float4 _diffuse_var = _diffuse.Sample(sampler_diffuse, TRANSFORM_TEX(i.uv, _diffuse));
                float4 _Picker_1_var = _Picker_1;
                float shadowStrength = 5.0;
                float shadowPow1 = pow((1.0 - saturate(distance(_diffuse_var.rgb, _Picker_1_var.rgb))), shadowStrength);
                float4 _Picker_0_var = _Picker_0;
                float shadowPow0 = pow((1.0 - saturate(distance(_diffuse_var.rgb, _Picker_0_var.rgb))), shadowStrength);
                float shadowRefr = _ESSGMask_var.g ;

                pbr = saturate(pbr);
                
                //PBRShadowArea
                float PBRShadowArea = saturate((dot(i.normalWS, mainLight.direction) + (shadowRefr - 0.5) * 2.0 * _ShadowRefraction) * (_ReceiveShadow == 1.0 ? pbr: 1.0)) ;
                //PBRShadowArea = saturate(step(1.0, 1.0 - PBRShadowArea));
                PBRShadowArea = saturate(pow(1.0 - PBRShadowArea, Remap(_ShadowRamp, 0, 1, 30, 1000)));
                PBRShadowArea = saturate((1.0 - PBRShadowArea)) ;
                
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

                float shadowTotal = saturate(shadowArea0 + shadowArea1 + shadowAreaElse) * (1.0 - PBRShadowArea);
                float3 diffuseColor = lerp(_diffuse_var, _diffuse_var * saturate(shadowArea0 * _ShadowColor0 + shadowArea1 * _ShadowColor1 + shadowAreaElse * _ShadowColorElse), shadowTotal);
                


                float3 emissive = (((lightColor.rgb * 0.4) * step((1.0 - 0.1), _Flash_var))
                + specularColor + diffuseColor) * mainLight.color * _Color.rgb +
                (_EmissionColor_var.rgb * _EmissionxBase_var * _EmissionOn_var) +
                (float3(1, 0.3171664, 0.2549019) * _Flash_var * _Flash_var)
                ;
                
                if (_DiscolorationOn == 1.0)
                {
                    float discolorationArea = saturate(_diffuse_var.a);
                    emissive = (1.0 - discolorationArea) * emissive + discolorationArea * emissive * _Discoloration ;
                }
                emissive += fresnel * (1.0 - shadowTotal);

                //Fog
                float fogFactor = i.positionWSAndFogFactor.w;

                float3 finalColor = emissive ;
                finalColor = MixFog(finalColor, fogFactor);
                
                float4 finalRGBA = float4(emissive, 1);
                
                return finalRGBA;
            }
            ENDHLSL
            
        }

        UsePass "Lightweight Render Pipeline/Lit/ShadowCaster"
        UsePass "Lightweight Render Pipeline/Lit/DepthOnly"
    }

    // Uses a custom shader GUI to display settings. Re-use the same from Lit shader as they have the
    // same properties.
    CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.ZDCharacter"
}