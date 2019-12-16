Shader "ZDShader/LWRP/Environment/Real Water"
{
    Properties
    {
        
        [NoScaleOffset]_NormalTexture ("Normal Texture", 2D) = "white" { }
        _NormalTiling ("Normal Tiling", Float) = 1
        _DeepWaterColor ("Deep Water Color", Color) = (0.07843138, 0.3921569, 0.7843137, 1)
        _ShallowWaterColor ("Shallow Water Color", Color) = (0.4411765, 0.9537525, 1, 1)
        _DepthTransparency ("Depth Transparency", Float) = 1.5
        _ShoreFade ("Shore Fade", Float) = 0.3
        _ShoreTransparency ("Shore Transparency", Float) = 0.04
        _ShallowDeepBlend ("Shallow-Deep-Blend", Float) = 3.6
        _Fade ("Shallow-Deep-Fade", Float) = 3
        [HideInInspector]_ReflectionTex ("Reflection Tex", 2D) = "white" { }
        [MaterialToggle] _UseReflections ("Enable Reflections", Float) = 0.08586914
        _Reflectionintensity ("Reflection intensity", Range(0, 1)) = 0.5
        _Distortion ("Distortion", Range(0, 2)) = 0.3
        _Specular ("Specular", Float) = 1
        _SpecularColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
        _Gloss ("Gloss", Float) = 0.8
        _LightWrapping ("Light Wrapping", Float) = 1.5
        _Refraction ("Refraction", Range(0, 1)) = 0.5
        _WaveSpeed ("Wave Speed", Float) = 40
        [NoScaleOffset]_FoamTexture ("Foam Texture", 2D) = "white" { }
        _FoamTiling ("Foam Tiling", Float) = 3
        _FoamBlend ("Foam Blend", Float) = 0.15
        _FoamVisibility ("Foam Visibility", Range(0, 1)) = 0.3
        _FoamIntensity ("Foam Intensity", Float) = 5
        _FoamContrast ("Foam Contrast", Range(0, 0.5)) = 0.25
        _FoamColor ("Foam Color", Color) = (0.5, 0.5, 0.5, 1)
        _FoamSpeed ("Foam Speed", Float) = 120
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
        

        // Blending state
        [Enum(Off, 0, Front, 1, Back, 2)] _Cull ("Cull Mode", Float) = 2.0

        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip ("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [Enum(Off, 0, On, 1)]  _ZWrite ("ZWrite", Float) = 1.0
        [Enum(UnityEngine.Rendering.CompareFunction)]  _ZTest ("ZTest", Float) = 4
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
                float4 _ReflectionTex_ST;

                float _NormalTiling;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _DepthTransparency;
                float _ShoreFade;
                float _ShoreTransparency;
                float _ShallowDeepBlend;
                float _Fade;
                
                float _UseReflections;
                float _Reflectionintensity;
                float _Distortion;
                float _Specular;
                float4 _SpecularColor;
                float _Gloss;
                float _LightWrapping;
                float _Refraction;
                float _WaveSpeed;
                float _FoamTiling;
                float _FoamBlend;
                float _FoamVisibility;
                float _FoamIntensity;
                float _FoamContrast;
                float4 _FoamColor;
                float _FoamSpeed;
                CBUFFER_END

                TEXTURE2D(_NormalTexture);          SAMPLER(sampler_NormalTexture);
                TEXTURE2D(_ReflectionTex);          SAMPLER(sampler_ReflectionTex);
                TEXTURE2D(_FoamTexture);            SAMPLER(sampler_FoamTexture);
                TEXTURE2D(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);
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
                half3 tangentWS: TEXCOORD4;
                half3 bitangentWS: TEXCOORD5;
                float4 shadowCoord: TEXCOORD6; // compute shadow coord per-vertex for the main light
                float4 projPos: TEXCOORD7;

                float4 positionCS: SV_POSITION;
            };


            Varyings LitPassVertex(Attributes input)
            {
                Varyings output;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                output.uv = input.uv;
                output.uvLM = input.uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                output.positionWSAndFogFactor = float4(vertexInput.positionWS, fogFactor);
                output.normalWS = vertexNormalInput.normalWS;
                output.tangentWS = vertexNormalInput.tangentWS;
                output.bitangentWS = vertexNormalInput.bitangentWS;
                output.shadowCoord = GetShadowCoord(vertexInput);
                output.positionCS = vertexInput.positionCS;
                output.projPos = ComputeScreenPos(output.positionCS);
                output.projPos.z = -TransformWorldToView(vertexInput.positionWS).z;
                return output;
            }

            half4 LitPassFragment(Varyings i): SV_Target
            {
                #ifdef _MAIN_LIGHT_SHADOWS
                    Light mainLight = GetMainLight(i.shadowCoord);
                #else
                    Light mainLight = GetMainLight();
                #endif
                
                float3 recipObjScale = float3(length(unity_WorldToObject[0].xyz), length(unity_WorldToObject[1].xyz), length(unity_WorldToObject[2].xyz));
                float3 objScale = 1.0 / recipObjScale;
                i.normalWS = normalize(i.normalWS);
                float3x3 tangentTransform = float3x3(i.tangentWS, i.bitangentWS, i.normalWS);
                float3 viewDirection = normalize(GetCameraPositionWS() - i.positionWSAndFogFactor.xyz);
                float _rotator1_ang = 1.5708;
                float _rotator1_spd = 1.0;
                float _rotator1_cos = cos(_rotator1_spd * _rotator1_ang);
                float _rotator1_sin = sin(_rotator1_spd * _rotator1_ang);
                float2 _rotator1_piv = float2(0.5, 0.5);
                float2 _rotator1 = (mul(i.uv - _rotator1_piv, float2x2(_rotator1_cos, -_rotator1_sin, _rotator1_sin, _rotator1_cos)) + _rotator1_piv);
                float _WaveSpeed_var = (_WaveSpeed);
                float _NormalTiling_var = (_NormalTiling);
                float2 _division1 = ((objScale.rb * _NormalTiling_var) / 1000.0);
                float4 _timer1 = _Time;
                float3 _multiplier3 = (float3((_WaveSpeed_var / _division1), 0.0) * (_timer1.r / 100.0));
                float2 _multiplier1 = ((_rotator1 + _multiplier3) * _division1);
                float4 _texture1 = _NormalTexture.Sample(sampler_NormalTexture, _multiplier1);
                float2 _multiplier2 = ((i.uv + _multiplier3) * _division1);
                float4 _texture2 = _NormalTexture.Sample(sampler_NormalTexture, _multiplier2);
                float3 _subtractor1 = (_texture1.rgb - _texture2.rgb);
                float _Refraction_var = (_Refraction);
                float3 normalLocal = lerp(float3(0, 0, 1), _subtractor1, _Refraction_var);
                float3 normalDirection = normalize(mul(normalLocal, tangentTransform)); // Perturbed normals
                float2 sceneUVs = (i.projPos.xy / i.projPos.w);
                float sceneZ = max(0, LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, sceneUVs), _ZBufferParams));
                float partZ = max(0, i.projPos.z - _ProjectionParams.g);
                float3 lightDirection = normalize(mainLight.direction.xyz);
                float3 lightColor = mainLight.color.rgb;
                float3 halfDirection = normalize(viewDirection + lightDirection);
                ////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * mainLight.color.xyz;
                ///////// Gloss:
                float _Gloss_var = (_Gloss);
                float gloss = _Gloss_var;
                float specPow = exp2(gloss * 10.0 + 1.0);
                ////// Specular:
                float NdotL = saturate(dot(normalDirection, lightDirection));
                float _Specular_var = (_Specular);
                float4 _SpecularColor_var = (_SpecularColor);
                float3 specularColor = (_Specular_var * _SpecularColor_var.rgb);
                float3 directSpecular = attenColor * pow(max(0, dot(halfDirection, normalDirection)), specPow) * specularColor;
                float3 specular = directSpecular;
                /////// Diffuse:
                NdotL = dot(normalDirection, lightDirection);
                float _LightWrapping_var = (_LightWrapping);
                float3 w = float3(_LightWrapping_var, _LightWrapping_var, _LightWrapping_var) * 0.5; // Light wrapping
                float3 NdotLWrap = NdotL * (1.0 - w);
                float3 forwardLight = max(float3(0.0, 0.0, 0.0), NdotLWrap + w);
                NdotL = max(0.0, dot(normalDirection, lightDirection));
                float3 directDiffuse = forwardLight * attenColor;
                float3 indirectDiffuse = float3(0, 0, 0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
                float4 _DeepWaterColor_var = (_DeepWaterColor);
                float4 _ShallowWaterColor_var = (_ShallowWaterColor);
                float _ShallowDeepBlend_var = (_ShallowDeepBlend);
                float _Fade_var = (_Fade);
                float3 _power = pow(saturate(max(_DeepWaterColor_var.rgb, (_ShallowWaterColor_var.rgb * (saturate((sceneZ - partZ) / _ShallowDeepBlend_var) * - 1.0 + 1.0)))), _Fade_var);
                float2 _componentMask = _subtractor1.rg;
                float _Distortion_var = (_Distortion);
                float2 _remap = (((sceneUVs * 2 - 1).rg + (float2(_componentMask.r, _componentMask.g) * _Distortion_var)) * 0.5 + 0.5);
                float4 _ReflectionTex_var = _ReflectionTex.Sample(sampler_ReflectionTex, TRANSFORM_TEX(_remap, _ReflectionTex));
                float _Reflectionintensity_var = (_Reflectionintensity);
                float3 _UseReflections_var = lerp(_power, lerp(_ReflectionTex_var.rgb, _power, (1.0 - _Reflectionintensity_var)), (_UseReflections));
                float _rotator2_ang = 1.5708;
                float _rotator2_spd = 1.0;
                float _rotator2_cos = cos(_rotator2_spd * _rotator2_ang);
                float _rotator2_sin = sin(_rotator2_spd * _rotator2_ang);
                float2 _rotator2_piv = float2(0.5, 0.5);
                float2 _rotator2 = (mul(i.uv - _rotator2_piv, float2x2(_rotator2_cos, -_rotator2_sin, _rotator2_sin, _rotator2_cos)) + _rotator2_piv);
                float _FoamSpeed_var = (_FoamSpeed);
                float _FoamTiling_var = (_FoamTiling);
                float2 _division2 = ((objScale.rb * _FoamTiling_var) / 1000.0);
                float4 _multiplier8 = _Time;
                float3 _multiplier7 = (float3((_FoamSpeed_var / _division2), 0.0) * (_multiplier8.r / 100.0));
                float2 _multiplier5 = ((_rotator2 + _multiplier7) * _division2);
                float4 _texture3 = _FoamTexture.Sample(sampler_FoamTexture, _multiplier5);
                float2 _multiplier6 = ((i.uv + _multiplier7) * _division2);
                float4 _texture4 = _FoamTexture.Sample(sampler_FoamTexture, _multiplier6);
                float _FoamContrast_var = (_FoamContrast);
                float _value = 0.0;
                float4 _FoamColor_var = (_FoamColor);
                float _FoamIntensity_var = (_FoamIntensity);
                float _FoamBlend_var = (_FoamBlend);
                float3 _multiplier4 = ((((_value + ((dot((_texture3.rgb - _texture4.rgb), float3(0.3, 0.59, 0.11)) - _FoamContrast_var) * (1.0 - _value)) / ((1.0 - _FoamContrast_var) - _FoamContrast_var)) * _FoamColor_var.rgb) * (_FoamIntensity_var * (-1.0))) * (saturate((sceneZ - partZ) / _FoamBlend_var) * - 1.0 + 1.0));
                float _FoamVisibility_var = (_FoamVisibility);
                float3 diffuseColor = lerp(_UseReflections_var, (_multiplier4 * _multiplier4), _FoamVisibility_var);
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
                /// Final Color:
                float3 finalColor = diffuse + specular;
                finalColor = MixFog(finalColor, i.positionWSAndFogFactor.w);


                float _ShoreTransparency_var = (_ShoreTransparency);
                float _DepthTransparency_var = (_DepthTransparency);
                float _ShoreFade_var = (_ShoreFade);
                half4 finalRGBA = half4(_ReflectionTex_var.rgb, (saturate((sceneZ - partZ) / _ShoreTransparency_var) * pow(saturate((sceneZ - partZ) / _DepthTransparency_var), _ShoreFade_var)));

                return finalRGBA;
            }
            ENDHLSL
            
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
