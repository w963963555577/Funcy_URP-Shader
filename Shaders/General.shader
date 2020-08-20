// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "Hidden/LWRP/General"
{
    Properties { }
    
    
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True" }
        LOD 0
        HLSLINCLUDE
        #pragma target 3.0
        
        struct SurfaceOutputStandardSpecular
        {
            half3 Albedo;
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
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            
            ZWrite On
            ZTest LEqual
            
            HLSLPROGRAM
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog
            #define ASE_FOG 1
            #define ASE_SRP_VERSION 60902
            
            
            
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            
            
            
            struct GraphVertexInput
            {
                float4 vertex: POSITION;
                float3 ase_normal: NORMAL;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                
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
                o.clipPos = clipPos;
                
                return o;
            }
            
            half4 ShadowPassFragment(VertexOutput IN): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                
                
                float Alpha = 1;
                float AlphaClipThreshold = AlphaClipThreshold;
                
                #if _AlphaClip
                    clip(Alpha - AlphaClipThreshold);
                #endif
                
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
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog
            
            
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma vertex vert
            #pragma fragment frag
            
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            
            
            
            
            
            struct GraphVertexInput
            {
                float4 vertex: POSITION;
                float3 ase_normal: NORMAL;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            
            
            VertexOutput vert(GraphVertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                
                v.ase_normal = v.ase_normal ;
                
                o.clipPos = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }
            
            half4 frag(VertexOutput IN): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                
                
                
                float Alpha = 1;
                float AlphaClipThreshold = AlphaClipThreshold;
                
                #if _AlphaClip
                    clip(Alpha - AlphaClipThreshold);
                #endif
                
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
            
            CBUFFER_END
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
                half4 albedo = _BaseMap.Sample(sampler_BaseMap, IN.uv);
                
                
                float4 clipPos = 0;
                float3 worldPos = 0;
                
                //OctaImpostorFragment(o, clipPos, worldPos, IN.uvsFrame1, IN.uvsFrame2, IN.uvsFrame3, IN.octaFrame, IN.viewPos);
                IN.positionCS.zw = clipPos.zw;
                
                outDepth = IN.positionCS.z + 1.0;
                
                InputData inputData;
                InitializeInputData(IN, IN.normalWS, inputData);
                
                half4 color = UniversalFragmentPBR(inputData, albedo.rgb, 0, 0, 0, 0, 0, albedo.a);
                clip(color.a - 0.5);
                return float4(_ObjectId, _PassValue, 1.0, 1.0);
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
            
            
            
            
            #pragma vertex vert
            #pragma fragment frag
            
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            
            
            
            
            
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
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            
            VertexOutput vert(GraphVertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                
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
                
                
                
                float3 Albedo = float3(0.5, 0.5, 0.5);
                float3 Emission = 0;
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
            
            #include "../ShaderLibrary/Impostors.hlsl"
            
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
            
            #include "../ShaderLibrary/Impostors.hlsl"
            
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
            
            #include "../ShaderLibrary/Impostors.hlsl"
            
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
            
            #include "../ShaderLibrary/Impostors.hlsl"
            
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
        
        
        Pass
        {
            Name "Outline"
            
            Stencil
            {
                Ref 128
                Comp GEqual
            }
            
            ZWrite On
            ZTest LEqual
            Cull Front
            Blend Off
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma shader_feature_local _OutlineEnable
            
            #pragma target 3.0
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float3 color: COLOR0;
                float2 uv: TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float2 uv: TEXCOORD0;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            sampler2D _diffuse;
            sampler2D _OutlineWidthControl;
            
            CBUFFER_START(UnityPerMaterial)
            half4 _diffuse_ST;
            float4 _OutlineColor;
            float _DiffuseBlend;
            CBUFFER_END
            
            
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                half RTD_OL_OLWABVD_OO = 1.0;
                half4 _OutlineWidthControl_var = tex2Dlod(_OutlineWidthControl, float4(v.uv, 0.0, 0));
                
                half2 RTD_OL_DNOL_OO = v.uv;
                half2 node_8743 = RTD_OL_DNOL_OO;
                float2 node_1283_skew = node_8743 + 0.2127 + node_8743.x * 0.3713 * node_8743.y;
                float2 node_1283_rnd = 4.789 * sin(489.123 * (node_1283_skew));
                half node_1283 = frac(node_1283_rnd.x * node_1283_rnd.y * (1 + node_1283_skew.x));
                
                float3 _OEM = v.normal;
                
                half RTD_OL = (RTD_OL_OLWABVD_OO * 0.01) * lerp(1.0, node_1283, 0.8) * _OutlineWidthControl_var.r;
                
                half dist = distance(v.vertex.xyz, mul(GetWorldToObjectMatrix(), float4(_WorldSpaceCameraPos.xyz, 1.0)));
                half4 widthRange = float4(0.5, 1.0, 0.5, 0.0);
                
                RTD_OL *= (lerp(widthRange.x, widthRange.y, saturate(dist - 0.05) * widthRange.z));
                
                o.vertex = TransformObjectToHClip(float4(v.vertex.xyz + _OEM * RTD_OL, 1).xyz);
                o.uv = v.uv;
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                #if _OutlineEnable
                    
                #else
                    discard;
                #endif
                float4 _diffuse_var = tex2D(_diffuse, i.uv);
                clip(_diffuse_var.a - 0.5);
                half4 col = float4(_OutlineColor.rgb + _diffuse_var.rgb * _DiffuseBlend, _OutlineColor.a);
                //half4 col = float4(0.05.rrr, 1.0);
                return col;
            }
            ENDHLSL
            
        }
        
        Pass
        {
            Name "Outline_AnimationPlayer"
            
            Stencil
            {
                Ref 128
                Comp GEqual
            }
            
            ZWrite On
            ZTest LEqual
            Cull Front
            Blend Off
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma shader_feature_local _OutlineEnable
            
            #pragma target 3.0
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float3 color: COLOR0;
                float2 uv: TEXCOORD0;
                uint id: SV_VERTEXID;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float2 uv: TEXCOORD0;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            sampler2D _diffuse;
            sampler2D _OutlineWidthControl;
            sampler2D _PosMap;
            uniform float4 _PosMap_TexelSize;
            sampler2D _NormalMap;
            uniform float4 _NormalMap_TexelSize;
            CBUFFER_START(UnityPerMaterial)
            half4 _diffuse_ST;
            float4 _OutlineColor;
            float _DiffuseBlend;
            int _FPS;
            int _FrameCount;
            CBUFFER_END
            
            
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                half temp_output_233_0 = (v.id + 0.5);
                half temp_output_234_0 = fmod((_FPS * _TimeParameters.x), (float)_FrameCount);
                half2 appendResult239 = (half2((temp_output_233_0 * _PosMap_TexelSize.x), (temp_output_234_0 * _PosMap_TexelSize.y)));
                
                half2 appendResult240 = (half2((temp_output_233_0 * _NormalMap_TexelSize.x), (temp_output_234_0 * _NormalMap_TexelSize.y)));
                v.vertex.xyz = (tex2Dlod(_PosMap, float4(appendResult239, 0, 0.0))).rgb;
                v.normal.xyz = (tex2Dlod(_NormalMap, float4(appendResult240, 0, 0.0))).rgb;
                
                
                half RTD_OL_OLWABVD_OO = 1.0;
                half4 _OutlineWidthControl_var = tex2Dlod(_OutlineWidthControl, float4(v.uv, 0.0, 0));
                
                half2 RTD_OL_DNOL_OO = v.uv;
                half2 node_8743 = RTD_OL_DNOL_OO;
                float2 node_1283_skew = node_8743 + 0.2127 + node_8743.x * 0.3713 * node_8743.y;
                float2 node_1283_rnd = 4.789 * sin(489.123 * (node_1283_skew));
                half node_1283 = frac(node_1283_rnd.x * node_1283_rnd.y * (1 + node_1283_skew.x));
                
                float3 _OEM = v.normal;
                
                half RTD_OL = (RTD_OL_OLWABVD_OO * 0.01) * lerp(1.0, node_1283, 0.8) * _OutlineWidthControl_var.r;
                
                half dist = distance(v.vertex.xyz, mul(GetWorldToObjectMatrix(), float4(_WorldSpaceCameraPos.xyz, 1.0)));
                half4 widthRange = float4(0.5, 1.0, 0.5, 0.0);
                
                RTD_OL *= (lerp(widthRange.x, widthRange.y, saturate(dist - 0.05) * widthRange.z));
                
                o.vertex = TransformObjectToHClip(float4(v.vertex.xyz + _OEM * RTD_OL, 1).xyz);
                o.uv = v.uv;
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                #if _OutlineEnable
                    
                #else
                    discard;
                #endif
                float4 _diffuse_var = tex2D(_diffuse, i.uv);
                half4 col = float4(_OutlineColor.rgb + _diffuse_var.rgb * _DiffuseBlend, _OutlineColor.a);
                //half4 col = float4(0.05.rrr, 1.0);
                return col;
            }
            ENDHLSL
            
        }
        
        
        Pass
        {
            Name "PlanarShadow"
            
            Blend  One OneMinusSrcAlpha
            ZWrite On
            ZTest NotEqual
            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            
            #pragma vertex vert
            #pragma fragment frag
            
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            
            TEXTURE2D(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);
            
            CBUFFER_START(UnityPerMaterial)
            float _ProjectionAngleDiscardThreshold;
            
            CBUFFER_END
            // Tranforms position from object to camera space
            inline float3 ObjectToViewPos(float3 pos)
            {
                return mul(UNITY_MATRIX_V, mul(GetObjectToWorldMatrix(), float4(pos, 1.0))).xyz;
            }
            
            struct VertexInput
            {
                float4 vertex: POSITION;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                float4 screenUV: TEXCOORD0;
                float4 viewRayOS: TEXCOORD2;
                float3 cameraPosOS: TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.clipPos = TransformObjectToHClip(v.vertex);
                o.screenUV = ComputeScreenPos(o.clipPos);
                
                float3 viewRay = ObjectToViewPos(v.vertex);
                
                o.viewRayOS.w = viewRay.z;
                
                viewRay *= -1;
                float4x4 ViewToObjectMatrix = mul(GetWorldToObjectMatrix(), UNITY_MATRIX_I_V);
                
                o.viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, viewRay);
                o.cameraPosOS = mul(ViewToObjectMatrix, float4(0.0h, 0.0h, 0.0h, 1.0h)).xyz;
                
                o.viewRayOS /= o.viewRayOS.w;
                o.screenUV = o.screenUV / o.screenUV.w;
                #if defined(UNITY_SINGLE_PASS_STEREO)
                    o.screenUV.xy = UnityStereoTransformScreenSpaceTex(o.screenUV.xy);
                #endif
                float sceneCameraSpaceDepth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(o.screenUV).r * 10;
                float3 decalSpaceScenePos = o.cameraPosOS + o.viewRayOS * sceneCameraSpaceDepth;
                
                
                //convert to world space for calculation
                float4 positionInWorldSpace = mul(GetObjectToWorldMatrix(), v.vertex);
                float3 lightDirectionInWorldSpace = normalize(_MainLightPosition.xyz);
                float distanceToOrigin = length(v.vertex);
                
                //project the world space vertex to the y=0 ground
                positionInWorldSpace.x -= positionInWorldSpace.y / lightDirectionInWorldSpace.y * lightDirectionInWorldSpace.x;
                positionInWorldSpace.z -= positionInWorldSpace.y / lightDirectionInWorldSpace.y * lightDirectionInWorldSpace.z;
                
                float originalWorldY = positionInWorldSpace.y; //save a copy of original world space Y (height),use to calculate shadow fading
                positionInWorldSpace.y = 0;//force the vertex's world space Y = 0 (on the ground)
                
                float4 result = mul(UNITY_MATRIX_VP, positionInWorldSpace); //complete to MVP matrix transform (we already change from local->world before, so this line only do VP)
                result.z -= 0.0001 + sceneCameraSpaceDepth; //push depth towards camera,above ground a bit. prevent Z-fighting to ground
                
                //pack up for output to fragment shader(pos & color)
                o.clipPos = result; //screen space Pos
                
                
                return o;
            }
            
            half4 frag(VertexOutput IN): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                
                
                return half4(0, 0, 0, .8);
            }
            
            ENDHLSL
            
        }
    }
}
