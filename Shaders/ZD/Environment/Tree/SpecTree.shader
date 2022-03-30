Shader "ZDShader/URP/Environment/SpecialTree"
{
    Properties
    {
        [HideInInspector] _EmissionColor ("Emission Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _AlphaCutoff ("Alpha Cutoff ", Range(0, 1)) = 0.5
        _BaseMap ("BaseMap", 2D) = "white" { }
        _ClipThreshod ("ClipThreshod", Range(0, 1)) = 0.4
        _LambertOffset ("LambertOffset", Float) = 0.5
        [HDR]_BlendColor_Light ("BlendColor_Light", Color) = (0.227451, 0.8784314, 0.4121743, 0)
        [HDR]_BlendColor_Mid ("BlendColor_Mid", Color) = (0.03555536, 0.4433962, 0.1661608, 0)
        [HDR]_BlendColor_Dark ("BlendColor_Dark", Color) = (0, 0.254717, 0.1783019, 0)
        [HDR]_BlendColor_SelfShadow ("BlendColor_SelfShadow", Color) = (0, 0.1776338, 0.2, 0)
        [HDR]_SpecColor ("SpecColor", Color) = (0.227451, 1.498039, 0, 1)
        _SpecularOffset ("SpecularOffset", Float) = 0.44
        _Speed ("Speed", Float) = 1.5
        _Amount ("Amount", Float) = 5
        _Distance ("Distance", Range(0, 1)) = 0.5
        
        _PositionMask ("PositionMask", 2D) = "white" { }
        
        [Toggle]_ViewRendererMode ("View Renderer Mode", Range(0, 1)) = 0
        [HideInInspector] _texcoord ("", 2D) = "white" { }
    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }
        
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "MRTOpaque" }
            
            Blend One Zero, One Zero
            ZWrite On
            ZTest LEqual
            Cull Off
            Offset 0, 0
            ColorMask RGBA
            
            HLSLPROGRAM
            
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            
            
            #pragma vertex vert
            #pragma fragment frag
            
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #define _MAIN_LIGHT_SHADOWS 1
            //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #define _MAIN_LIGHT_SHADOWS_CASCADE 1
            //#pragma multi_compile _ _SHADOWS_SOFT
            #define _SHADOWS_SOFT 1
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            
            #pragma multi_compile _ _DrawMeshInstancedProcedural
            
            #pragma multi_compile_fog
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            
            struct VertexInput
            {
                half4 vertex: POSITION;
                half3 normal: NORMAL;
                half4 ase_texcoord: TEXCOORD0;
                
                #ifdef _DrawMeshInstancedProcedural
                    uint mid: SV_INSTANCEID;
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                #endif
            };
            
            struct VertexOutput
            {
                half4 clipPos: SV_POSITION;
                half3 worldPos: TEXCOORD0;
                half4 shadowCoord: TEXCOORD1;
                half fogFactor: TEXCOORD2;
                half4 ase_texcoord3: TEXCOORD3;
                half4 ase_texcoord4: TEXCOORD4;
                
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    UNITY_VERTEX_OUTPUT_STEREO
                #endif
            };
            
            #include "SpecTree-CBufferProperties.hlsl"
            
            TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
            
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                #ifdef _DrawMeshInstancedProcedural
                    uint id = _VisibleInstanceOnlyTransformIDBuffer[v.mid];
                #else
                    UNITY_SETUP_INSTANCE_ID(v);
                    UNITY_TRANSFER_INSTANCE_ID(v, o);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                #endif
                half3 viewOffset = half3(remap(v.ase_texcoord.xy, 0.0.xx, 1.0.xx, -1.0.xx, 1.0.xx) * 2.0, 0.0);
                viewOffset = mul(half4(viewOffset.xyz, 0.0), UNITY_MATRIX_V).xyz;
                
                half4 offset = v.vertex;
                #ifdef _DrawMeshInstancedProcedural
                    viewOffset = mul(half4(viewOffset.xyz, 0.0), _ObjectToWorldBuffer[id]).xyz;
                    v.vertex.xyz += normalize(viewOffset) * _ViewRendererMode;
                    v.vertex = WindAnimation(v.vertex, _ObjectToWorldBuffer[id], _WorldToObjectBuffer[id]);
                    
                #else
                    viewOffset = mul(half4(viewOffset.xyz, 0.0), GetObjectToWorldMatrix()).xyz;
                    v.vertex.xyz += normalize(viewOffset) * _ViewRendererMode;
                    v.vertex = WindAnimation(v.vertex, GetObjectToWorldMatrix(), GetWorldToObjectMatrix());
                #endif
                offset -= v.vertex;
                v.normal = v.normal + offset.xyz * 0.5;
                
                half3 ase_worldNormal = half3(0.0, 0.0, 0.0);
                #ifdef _DrawMeshInstancedProcedural
                    #ifdef UNITY_ASSUME_UNIFORM_SCALING
                        ase_worldNormal = SafeNormalize(mul((real3x3)_ObjectToWorldBuffer[id], v.normal));
                    #else
                        ase_worldNormal = SafeNormalize(mul(v.normal, (real3x3)_WorldToObjectBuffer[id]));
                    #endif
                #else
                    ase_worldNormal = TransformObjectToWorldNormal(v.normal);
                #endif
                
                o.ase_texcoord4.xyz = ase_worldNormal;
                
                o.ase_texcoord3.xy = v.ase_texcoord.xy;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord3.zw = 0;
                o.ase_texcoord4.w = 0;
                
                //half3 vertexValue = SAMPLE_TEXTURE2D_LOD(_PositionMask, sampler_PositionMask, ((appendResult182.xy * _PositionMask_ST.xy) + _PositionMask_ST.zw), unity_LODFade).r * appendResult132.xyz / ase_objectScale.xyz;
                
                //v.vertex.xyz += vertexValue;
                
                
                half3 positionWS = half3(0.0, 0.0, 0.0);
                
                #ifdef _DrawMeshInstancedProcedural
                    positionWS = mul(_ObjectToWorldBuffer[id], half4(v.vertex.xyz, 1.0)).xyz;
                #else
                    positionWS = TransformObjectToWorld(v.vertex.xyz);
                #endif
                
                half4 positionCS = TransformWorldToHClip(positionWS);
                
                
                o.worldPos = positionWS;
                
                VertexPositionInputs vertexInput = (VertexPositionInputs)0;
                vertexInput.positionWS = positionWS;
                vertexInput.positionCS = positionCS;
                o.shadowCoord = GetShadowCoord(vertexInput);
                
                o.fogFactor = ComputeFogFactor(positionCS.z);
                
                o.clipPos = positionCS;
                return o;
            }
            
            half3 SpecTreeColor(VertexOutput IN, half4 baseColor)
            {
                Light mainLight = GetMainLight();
                half3 WorldPosition = IN.worldPos;
                half3 viewDirection = normalize(WorldPosition - _WorldSpaceCameraPos.xyz);
                half4 ShadowCoords = TransformWorldToShadowCoord(WorldPosition);
                
                half3 ase_worldNormal = IN.ase_texcoord4.xyz;
                half dotResult41 = dot(ase_worldNormal, mainLight.direction);
                half lightFresnel = smoothstep(0.0, 1.0, saturate(dot(viewDirection, - (ase_worldNormal * 0.82 - mainLight.direction))));
                
                half temp_output_47_0 = saturate((dotResult41 + _LambertOffset));
                
                half smoothstepResult82 = smoothstep(0.0, 0.5, temp_output_47_0);
                half4 lerpResult83 = lerp(_BlendColor_Dark, _BlendColor_Mid, smoothstepResult82);
                half smoothstepResult80 = smoothstep(0.5, 1.0, temp_output_47_0);
                half4 lerpResult57 = lerp(lerpResult83, _BlendColor_Light, smoothstepResult80);
                
                lerpResult57.rgb = lerp(lerpResult57.rgb, _BlendColor_Light.rgb, lightFresnel);
                
                half ase_lightAtten = 0;
                Light ase_lightAtten_mainLight = GetMainLight(ShadowCoords);
                ase_lightAtten = ase_lightAtten_mainLight.distanceAttenuation * ase_lightAtten_mainLight.shadowAttenuation;
                half temp_output_147_0 = saturate((ase_lightAtten + temp_output_47_0));
                half4 lerpResult145 = lerp(_BlendColor_SelfShadow, lerpResult57, temp_output_147_0);
                half temp_output_3_0_g5 = (baseColor.a - _ClipThreshod);
                half temp_output_3_0_g4 = (baseColor.a - saturate((1.5 * _ClipThreshod)));
                half temp_output_200_0 = saturate((dotResult41 + (_SpecularOffset * - 1.0)));
                
                return(baseColor * lerpResult145).rgb + _SpecColor.rgb * _ViewRendererMode * smoothstep(0.8, 0.81, 1.0 - pow(dot(viewDirection, ase_worldNormal), 2.0)).xxx * temp_output_47_0 ;
            }
            
            half4 frag(VertexOutput IN): SV_Target
            {
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_SETUP_INSTANCE_ID(IN);
                    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                #endif
                
                half2 uv_BaseMap = IN.ase_texcoord3.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv_BaseMap);
                
                clip(baseColor.a - _ClipThreshod);
                
                half3 BakedAlbedo = 0;
                half3 BakedEmission = 0;
                half3 Color = SpecTreeColor(IN, baseColor);
                half Alpha = 1.0;
                half AlphaClipThreshold = 0.5;
                
                
                //clip(Alpha - AlphaClipThreshold);
                
                //LODDitheringTransition(IN.clipPos.xyz, unity_LODFade.x);
                
                Color = MixFog(Color, IN.fogFactor);
                
                return MixGlobalFog(half4(Color, Alpha), IN.worldPos);
            }
            
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
            
            #include "SpecTree-CBufferProperties.hlsl"
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            
            half3 _LightDirection;
            
            struct Attributes
            {
                half4 positionOS: POSITION;
                half3 normalOS: NORMAL;
                half2 texcoord: TEXCOORD0;
                #ifdef _DrawMeshInstancedProcedural
                    uint mid: SV_INSTANCEID;
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                #endif
            };
            
            struct Varyings
            {
                half2 uv: TEXCOORD0;
                half4 positionCS: SV_POSITION;
                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    UNITY_VERTEX_OUTPUT_STEREO
                #endif
            };
            
            half4 GetShadowPositionHClip(Attributes input)
            {
                half3 viewOffset = half3(remap(input.texcoord.xy, 0.0.xx, 1.0.xx, -1.0.xx, 1.0.xx) * 2.0, 0.0);
                viewOffset = mul(half4(viewOffset, 0.0), UNITY_MATRIX_V).xyz;
                
                #ifdef _DrawMeshInstancedProcedural
                    uint id = _VisibleInstanceOnlyTransformIDBuffer[input.mid];
                    viewOffset = mul(half4(viewOffset, 0.0), _ObjectToWorldBuffer[id]).xyz;
                    input.positionOS.xyz += normalize(viewOffset) * _ViewRendererMode;
                    half3 positionWS = mul(_ObjectToWorldBuffer[id], half4(input.positionOS.xyz, 1.0)).xyz;
                    half3 normalWS = half3(0, 0, 0);
                    
                    #ifdef UNITY_ASSUME_UNIFORM_SCALING
                        normalWS = SafeNormalize(mul((real3x3)_ObjectToWorldBuffer[id], input.normalOS));
                    #else
                        normalWS = SafeNormalize(mul(input.normalOS, (real3x3)_WorldToObjectBuffer[id]));
                    #endif
                #else
                    viewOffset = mul(half4(viewOffset, 0.0), GetObjectToWorldMatrix()).xyz;
                    input.positionOS.xyz += normalize(viewOffset) * _ViewRendererMode;
                    half3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                    half3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                    
                #endif
                
                half4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
                
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
                
                half4 offset = input.positionOS;
                #ifdef _DrawMeshInstancedProcedural
                    input.positionOS = WindAnimation(input.positionOS, _ObjectToWorldBuffer[input.mid], _WorldToObjectBuffer[input.mid]);
                #else
                    input.positionOS = WindAnimation(input.positionOS, GetObjectToWorldMatrix(), GetWorldToObjectMatrix());
                #endif
                
                offset -= input.positionOS;
                input.normalOS = input.normalOS + offset.xyz * 0.5 ;
                
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionCS = GetShadowPositionHClip(input);
                return output;
            }
            
            
            half alpha(half albedoAlpha, half4 color, half cutoff)
            {
                #if !defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A) && !defined(_GLOSSINESS_FROM_BASE_ALPHA)
                    half alpha = albedoAlpha * color.a;
                #else
                    half alpha = color.a;
                #endif
                
                clip(alpha - cutoff);
                
                return alpha;
            }
            
            half4 ShadowPassFragment(Varyings input): SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, 1.0.xxxx, _ClipThreshod);
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
            
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ _DrawMeshInstancedProcedural
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            
            
            #include "SpecTree-CBufferProperties.hlsl"
            
            struct Attributes
            {
                half4 position: POSITION;
                half2 texcoord: TEXCOORD0;
                #ifdef _DrawMeshInstancedProcedural
                    uint mid: SV_INSTANCEID;
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                #endif
            };
            
            struct Varyings
            {
                half2 uv: TEXCOORD0;
                half4 positionCS: SV_POSITION;
                
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
                half3 viewOffset = half3(remap(input.texcoord.xy, 0.0.xx, 1.0.xx, -1.0.xx, 1.0.xx) * 2.0, 0.0);
                viewOffset = mul(half4(viewOffset, 0.0), UNITY_MATRIX_V).xyz;
                
                #ifdef _DrawMeshInstancedProcedural
                    viewOffset = mul(half4(viewOffset, 0.0), _ObjectToWorldBuffer[id]).xyz;
                    input.position.xyz += normalize(viewOffset) * _ViewRendererMode;
                    input.position = WindAnimation(input.position, _ObjectToWorldBuffer[input.mid], _WorldToObjectBuffer[input.mid]);
                #else
                    viewOffset = mul(half4(viewOffset, 0.0), GetObjectToWorldMatrix()).xyz;
                    input.position.xyz += normalize(viewOffset) * _ViewRendererMode;
                    input.position = WindAnimation(input.position, GetObjectToWorldMatrix(), GetWorldToObjectMatrix());
                #endif
                
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                
                half3 positionWS = half3(0.0, 0.0, 0.0);
                #ifdef _DrawMeshInstancedProcedural
                    positionWS = mul(_ObjectToWorldBuffer[id], half4(input.position.xyz, 1.0)).xyz;
                #else
                    positionWS = TransformObjectToWorld(input.position.xyz);
                #endif
                
                output.positionCS = TransformWorldToHClip(positionWS);
                return output;
            }
            
            half alpha(half albedoAlpha, half4 color, half cutoff)
            {
                #if !defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A) && !defined(_GLOSSINESS_FROM_BASE_ALPHA)
                    half alpha = albedoAlpha * color.a;
                #else
                    half alpha = color.a;
                #endif
                
                clip(alpha - cutoff);
                
                return alpha;
            }
            
            half4 DepthOnlyFragment(Varyings input): SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, 1.0.xxxx, _ClipThreshod);
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
            
            #include "SpecTree-CBufferProperties.hlsl"
            
            int _ObjectId;
            int _PassValue;
            
            struct VertexInput
            {
                half4 positionOS: POSITION;
                half3 normalOS: NORMAL;
                half4 tangentOS: TANGENT;
                half2 texcoord: TEXCOORD0;
                half2 lightmapUV: TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                half2 uv: TEXCOORD0;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
                
                
                half3 positionWS: TEXCOORD2;
                
                #ifdef _NORMALMAP
                    half4 normalWS: TEXCOORD3;    // xyz: normal, w: viewDir.x
                    half4 tangentWS: TEXCOORD4;    // xyz: tangent, w: viewDir.y
                    half4 bitangentWS: TEXCOORD5;    // xyz: bitangent, w: viewDir.z
                #else
                    half3 normalWS: TEXCOORD3;
                    half3 viewDirWS: TEXCOORD4;
                #endif
                
                half4 fogFactorAndVertexLight: TEXCOORD6; // x: fogFactor, yzw: vertex light
                
                #ifdef _MAIN_LIGHT_SHADOWS
                    half4 shadowCoord: TEXCOORD7;
                #endif
                
                half4 positionOS: TEXCOORD8;
                
                half4 positionCS: SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            VertexOutput vert(VertexInput input)
            {
                VertexOutput output = (VertexOutput)0;
                
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                //WindAnimation
                half3 viewOffset = half3(remap(input.texcoord.xy, 0.0.xx, 1.0.xx, -1.0.xx, 1.0.xx) * 2.0, 0.0);
                viewOffset = mul(half4(viewOffset, 0.0), UNITY_MATRIX_V).xyz;
                viewOffset = mul(half4(viewOffset, 0.0), GetObjectToWorldMatrix()).xyz;
                input.positionOS.xyz += normalize(viewOffset) * _ViewRendererMode;
                
                input.positionOS = WindAnimation(input.positionOS, GetObjectToWorldMatrix(), GetWorldToObjectMatrix());
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
                    inputData.shadowCoord = half4(0, 0, 0, 0);
                #endif
                inputData.fogCoord = input.fogFactorAndVertexLight.x;
                inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
                inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
                #if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
                    inputData.bakedAtten = SAMPLE_TEXTURE2D(unity_ShadowMask, samplerunity_ShadowMask, input.lightmapUV);
                #endif
            }
            
            half4 frag(VertexOutput IN, out half outDepth: SV_Depth): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                half4 albedoAlpha = SampleAlbedoAlpha(IN.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                half alpha = Alpha(albedoAlpha.a, half4(1, 1, 1, 1), _ClipThreshod);
                
                half4 clipPos = 0;
                half3 worldPos = 0;
                
                //OctaImpostorFragment(o, clipPos, worldPos, IN.uvsFrame1, IN.uvsFrame2, IN.uvsFrame3, IN.octaFrame, IN.viewPos);
                IN.positionCS.zw = clipPos.zw;
                
                outDepth = IN.positionCS.z + 1.0;
                
                InputData inputData;
                InitializeInputData(IN, IN.normalWS, inputData);
                
                half4 color = UniversalFragmentPBR(inputData, albedoAlpha.rgb, 0, 0, 0, 0, 0, alpha);
                clip(color.a - 0.5);
                
                return half4(_ObjectId, _PassValue, 1.0, 1.0);
            }
            
            ENDHLSL
            
        }
        
        //UsePass "Universal Render Pipeline/Lit/Meta"
    }
}