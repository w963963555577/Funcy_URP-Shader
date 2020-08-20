Shader "ZDShader/LWRP/Unlit-Default"
{
    Properties
    {
        ///////////////////////////////////////////////////////////////////////////////
        //                  Spec Tree Properties                                     //
        ///////////////////////////////////////////////////////////////////////////////
        [MainTexture] _BaseMap ("Albedo", 2D) = "white" { }
        _Distance ("Distance", Range(0, 1)) = 0.5
        _Speed ("Speed", Float) = 1.5
        _Amount ("Amount", Float) = 5
        _ClipThreshod ("Distance", Range(0, 1)) = 0.5
        
        _PositionMask ("PositionMask", 2D) = "white" { }
        [HideInInspector] _texcoord ("", 2D) = "white" { }
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }
        
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend One Zero, One Zero
            ZWrite On
            ZTest LEqual
            Cull Off
            Offset 0, 0
            ColorMask RGBA
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            #pragma multi_compile_fog

            #pragma multi_compile _ _DrawMeshInstancedProcedural
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            struct Attributes
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
                float4 tangentOS: TANGENT;
                float2 texcoord: TEXCOORD0;
                float2 lightmapUV: TEXCOORD1;
                #ifdef _DrawMeshInstancedProcedural
                    uint mid: SV_INSTANCEID;
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                #endif
            };
            
            struct Varyings
            {
                float2 uv: TEXCOORD0;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
                
                float3 positionWS: TEXCOORD2;
                
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
                
                float4 color: TEXCOORD8;

                float4 positionCS: SV_POSITION;
                
                

                #ifdef _DrawMeshInstancedProcedural
                #else
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    UNITY_VERTEX_OUTPUT_STEREO
                #endif
            };

            CBUFFER_START(UnityPerMaterial)
            //SpecTree
            float4 _BaseMap_ST;
            float4 _PositionMask_ST;
            float _Speed;
            float _Amount;
            float _Distance;
            float _ClipThreshod;
            #ifdef _DrawMeshInstancedProcedural
                StructuredBuffer<float4x4> _ObjectToWorldBuffer;
                StructuredBuffer<float4x4> _WorldToObjectBuffer;
                StructuredBuffer<uint> _VisibleInstanceOnlyTransformIDBuffer;
            #endif
            CBUFFER_END
            
            #include "../../ShaderLibrary/VertexAnimation.hlsl"
            
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
            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                #ifdef _DrawMeshInstancedProcedural
                    uint id = _VisibleInstanceOnlyTransformIDBuffer[input.mid];
                #else
                    UNITY_SETUP_INSTANCE_ID(input);
                    UNITY_TRANSFER_INSTANCE_ID(input, output);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                #endif

                float3 offset = input.positionOS.xyz;
                #ifdef _DrawMeshInstancedProcedural
                    input.positionOS = WindAnimation(input.positionOS, _ObjectToWorldBuffer[id], _WorldToObjectBuffer[id]);
                #else
                    input.positionOS = WindAnimation(input.positionOS, GetObjectToWorldMatrix(), GetWorldToObjectMatrix());
                #endif
                offset -= input.positionOS.xyz;
                input.normalOS = input.normalOS + offset * 0.5;
                
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


            half4 frag(Varyings input): SV_Target
            {
                float Alpha = 1.0;
                float4 aledbo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                float3 Color = MixFog(aledbo.rgb, input.fogFactorAndVertexLight.x);
                //clip(aledbo.a - _ClipThreshod);
                return half4(Color, Alpha);
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
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

            CBUFFER_START(UnityPerMaterial)
            //SpecTree
            float4 _BaseMap_ST;
            float4 _PositionMask_ST;
            float _Speed;
            float _Amount;
            float _Distance;
            float _ClipThreshod;
            #ifdef _DrawMeshInstancedProcedural
                StructuredBuffer<float4x4> _ObjectToWorldBuffer;
                StructuredBuffer<float4x4> _WorldToObjectBuffer;
                StructuredBuffer<uint> _VisibleInstanceOnlyTransformIDBuffer;
            #endif
            CBUFFER_END
            
            #include "../../ShaderLibrary/VertexAnimation.hlsl"
            TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);

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
                Varyings output;
                #ifdef _DrawMeshInstancedProcedural
                    uint id = _VisibleInstanceOnlyTransformIDBuffer[input.mid];
                #else
                    UNITY_SETUP_INSTANCE_ID(input);
                #endif

                #ifdef _DrawMeshInstancedProcedural
                    input.positionOS = WindAnimation(input.positionOS, _ObjectToWorldBuffer[id], _WorldToObjectBuffer[id]);
                #else
                    input.positionOS = WindAnimation(input.positionOS, GetObjectToWorldMatrix(), GetWorldToObjectMatrix());
                #endif

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionCS = GetShadowPositionHClip(input);
                return output;
            }
            
            half Alpha(half albedoAlpha, half cutoff)
            {
                half alpha = albedoAlpha ;
                clip(alpha - cutoff);
                return alpha;
            }

            half4 SampleAlbedoAlpha(float2 uv, TEXTURE2D_PARAM(albedoAlphaMap, sampler_albedoAlphaMap))
            {
                return SAMPLE_TEXTURE2D(albedoAlphaMap, sampler_albedoAlphaMap, uv);
            }


            half4 ShadowPassFragment(Varyings input): SV_TARGET
            {
                Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _ClipThreshod);
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
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            
            
            CBUFFER_START(UnityPerMaterial)
            //SpecTree
            float4 _BaseMap_ST;
            float4 _PositionMask_ST;
            float _Speed;
            float _Amount;
            float _Distance;
            float _ClipThreshod;
            #ifdef _DrawMeshInstancedProcedural
                StructuredBuffer<float4x4> _ObjectToWorldBuffer;
                StructuredBuffer<float4x4> _WorldToObjectBuffer;
                StructuredBuffer<uint> _VisibleInstanceOnlyTransformIDBuffer;
            #endif
            CBUFFER_END
            
            #include "../../ShaderLibrary/VertexAnimation.hlsl"
            TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);

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
                    input.position = WindAnimation(input.position, _ObjectToWorldBuffer[id], _WorldToObjectBuffer[id]);
                #else
                    input.position = WindAnimation(input.position, GetObjectToWorldMatrix(), GetWorldToObjectMatrix());
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
            
            half Alpha(half albedoAlpha, half cutoff)
            {
                half alpha = albedoAlpha;
                clip(alpha - cutoff);
                return alpha;
            }

            half4 SampleAlbedoAlpha(float2 uv, TEXTURE2D_PARAM(albedoAlphaMap, sampler_albedoAlphaMap))
            {
                return SAMPLE_TEXTURE2D(albedoAlphaMap, sampler_albedoAlphaMap, uv);
            }


            half4 DepthOnlyFragment(Varyings input): SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _ClipThreshod);
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
            //SpecTree
            float4 _BaseMap_ST;
            float4 _PositionMask_ST;
            float _Speed;
            float _Amount;
            float _Distance;
            float _ClipThreshod;
            #ifdef _DrawMeshInstancedProcedural
                StructuredBuffer<float4x4> _ObjectToWorldBuffer;
                StructuredBuffer<float4x4> _WorldToObjectBuffer;
                StructuredBuffer<uint> _VisibleInstanceOnlyTransformIDBuffer;
            #endif
            CBUFFER_END
            
            #include "../../ShaderLibrary/VertexAnimation.hlsl"
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
                //WindAnimation
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
                half alpha = Alpha(albedoAlpha.a, float4(1, 1, 1, 1), _ClipThreshod);
                
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
        //UsePass "Universal Render Pipeline/Lit/Meta"
    }
}