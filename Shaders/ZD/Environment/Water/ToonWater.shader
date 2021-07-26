// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "ZDShader/URP/Environment/ToonWater"
{
    Properties
    {
        _Color ("Color", Color) = (0.18, 0.45, 0.57, 1)
        _ColorFar ("ColorFar", Color) = (0.21, 0.57, 0.55, 1)
        [NoScaleOffset]_NormalMap ("NormalMap", 2D) = "(0.0,0.0,0.5,0.0)" { }
        _RefractionScale ("Refraction Scale (1=1 meter)", Float) = 7.2
        _RefractionIntensity ("Refraction Intensity", Range(0, 1)) = .05
        _WaveSpeed ("WaveSpeed", Range(0.01, 2.5)) = 1
        _WaveDirection ("Wave Angle (World Y axis)", Range(0, 360)) = 232
        [HDR]_FoamColor ("FoamColor", Color) = (0.54, 0.69, 0.81, 1)
        [NoScaleOffset]_FoamMap ("FoamMap", 2D) = "white" { }
        _FoamScale ("Foam Scale (1=1 meter)", Float) = 10
        _Reflection ("Reflection", Range(0, 1)) = 0.5
        _Depth ("Depth", Float) = 23.65
        _Specular ("Specular", Range(0, 1)) = 0.337
        _DepthArea ("DepthArea", Float) = 2.63
        _DepthHard ("DepthHard", Float) = 7.3
        [HDR]_SpecularColor ("SpecularColor", Color) = (.01, .12, .30, 1)
        _RampMap ("Ramp Map", 2D) = "white" { }
    }
    
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" "IgnoreProjector" = "True" }
        
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Offset 0, 0
            ColorMask RGBA
            
            
            HLSLPROGRAM
            
            #define _RECEIVE_SHADOWS_OFF 1
            #define ASE_SRP_VERSION 60902
            #define REQUIRE_DEPTH_TEXTURE 1
            #define REQUIRE_OPAQUE_TEXTURE 1
            
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            
            // -------------------------------------
            // Lightweight Pipeline keywords
            #pragma shader_feature _SAMPLE_GI
            
            // -------------------------------------
            // Unity defined keywords
            #ifdef ASE_FOG
                #pragma multi_compile_fog
            #endif
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _MobileSSPR
            
            #pragma vertex vert
            #pragma fragment frag
            
            
            // Lighting include is needed because of GI
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            
            
            sampler2D _NormalMap;
            
            sampler2D _FoamMap;
            sampler2D _RampMap;
            //textures
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            
            //textures
            TEXTURE2D(_MobileSSPR_ColorRT);
            sampler LinearClampSampler;
            
            CBUFFER_START(UnityPerMaterial)
            float _WaveDirection;
            float _WaveSpeed;
            float _RefractionScale;
            float _Specular;
            float _Depth;
            float4 _SpecularColor;
            float _RefractionIntensity;
            float _Reflection;
            float4 _Color;
            float4 _ColorFar;
            float4 _FoamColor;
            float _FoamScale;
            float _DepthArea;
            float _DepthHard;
            CBUFFER_END
            
            
            struct GraphVertexInput
            {
                float4 vertex: POSITION;
                float4 ase_normal: NORMAL;
                float4 tangent: TANGENT;
                float2 texcoord: TEXCOORD0;
                float4 color: COLOR0;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct GraphVertexOutput
            {
                float4 position: POSITION;
                
                float fogCoord: TEXCOORD0;
                
                float4 positionWS: TEXCOORD1;
                float4 ase_texcoord2: TEXCOORD2;
                float4 normalWS: TEXCOORD3;
                float4 color: TEXCOORD4;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            inline float4 ASE_ComputeGrabScreenPos(float4 pos)
            {
                #if UNITY_UV_STARTS_AT_TOP
                    float scale = -1.0;
                #else
                    float scale = 1.0;
                #endif
                float4 o = pos;
                o.y = pos.w * 0.5f;
                o.y = (pos.y - o.y) * _ProjectionParams.x * scale + o.y;
                return o;
            }
            
            
            float3 mod2D289(float3 x)
            {
                return x - floor(x * (1.0 / 289.0)) * 289.0;
            }
            float2 mod2D289(float2 x)
            {
                return x - floor(x * (1.0 / 289.0)) * 289.0;
            }
            float3 permute(float3 x)
            {
                return mod2D289(((x * 34.0) + 1.0) * x);
            }
            float snoise(float2 v)
            {
                const float4 C = float4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
                float2 i = floor(v + dot(v, C.yy));
                float2 x0 = v - i + dot(i, C.xx);
                float2 i1;
                i1 = (x0.x > x0.y) ? float2(1.0, 0.0): float2(0.0, 1.0);
                float4 x12 = x0.xyxy + C.xxzz;
                x12.xy -= i1;
                i = mod2D289(i);
                float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0)) + i.x + float3(0.0, i1.x, 1.0));
                float3 m = max(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
                m = m * m;
                m = m * m;
                float3 x = 2.0 * frac(p * C.www) - 1.0;
                float3 h = abs(x) - 0.5;
                float3 ox = floor(x + 0.5);
                float3 a0 = x - ox;
                m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
                float3 g;
                g.x = a0.x * x0.x + h.x * x0.y;
                g.yz = a0.yz * x12.xz + h.yz * x12.yw;
                return 130.0 * dot(m, g);
            }
            
            
            GraphVertexOutput vert(GraphVertexInput v)
            {
                GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
                o.positionWS.xyz = ase_worldPos;
                float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
                float4 screenPos = ComputeScreenPos(ase_clipPos);
                o.ase_texcoord2 = screenPos;
                float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal.xyz);
                o.normalWS.xyz = ase_worldNormal;
                
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.positionWS.w = 0;
                o.normalWS.w = 0;
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
                
                o.color = v.color;
                o.position = TransformObjectToHClip(v.vertex.xyz);
                
                o.fogCoord = ComputeFogFactor(o.position.z);
                
                
                return o;
            }
            
            half4 frag(GraphVertexOutput IN): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                
                float3 ase_worldPos = IN.positionWS.xyz;
                float3 ase_worldViewDir = (_WorldSpaceCameraPos.xyz - ase_worldPos);
                ase_worldViewDir = normalize(ase_worldViewDir);
                float3 normalizeResult293 = normalize((_MainLightPosition.xyz + (ase_worldViewDir * float3(-1, -1, -1))));
                float temp_output_218_0 = ((_WaveDirection * PI) / 180.0);
                float2 appendResult214 = (float2(cos(temp_output_218_0), sin(temp_output_218_0)));
                float2 temp_output_70_0 = (appendResult214 * _WaveSpeed);
                float2 temp_output_20_0 = (ase_worldPos).xz;
                float2 panner11 = (0.8146843 * _Time.y * temp_output_70_0 + temp_output_20_0);
                float2 uv_Ref085 = (panner11 / _RefractionScale);
                float4 tex2DNode2 = tex2D(_NormalMap, uv_Ref085);
                float2 appendResult75 = (float2((length(temp_output_70_0) * - 1.0), 0.0));
                float2 panner23 = (0.513432 * _Time.y * appendResult75 + temp_output_20_0);
                float2 uv_Ref186 = (panner23 / _RefractionScale);
                float4 tex2DNode21 = tex2D(_NormalMap, uv_Ref186);
                float2 temp_output_35_0 = ((tex2DNode2).rg - (tex2DNode21).rg);
                float3 appendResult299 = (float3(temp_output_35_0, 0.5));
                float dotResult288 = dot(normalizeResult293, (appendResult299 * 3.33));
                //---
                
                float mulTime16 = _TimeParameters.x * _WaveSpeed;
                float2 panner15 = (mulTime16 * float2(0.70707, 0.13314) + float4(IN.positionWS.xy / _RefractionScale, 0, 0).xy);
                float simplePerlin2D10 = snoise(panner15) * 0.5 + 0.5;
                
                float4 screenPos = IN.ase_texcoord2;
                float4 ase_screenPosNorm = screenPos / screenPos.w;
                ase_screenPosNorm.z = (UNITY_NEAR_CLIP_VALUE >= 0) ? ase_screenPosNorm.z: ase_screenPosNorm.z * 0.5 + 0.5;
                float depthQ = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(ase_screenPosNorm.xy), _ZBufferParams);
                float depthT = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH_TRANSPARENT(ase_screenPosNorm.xy), _ZBufferParams);
                
                float screenDepth16 = min(depthQ, depthT);
                
                screenDepth16 = (simplePerlin2D10 - 1.0) * IN.color.a + screenDepth16 - screenPos.w;
                //return float4(screenDepth16.xxx, 1.0);
                float smDisDepth = screenDepth16 / _Depth;
                smDisDepth = min(1.0, smDisDepth);
                
                //
                float temp_output_115_0 = smDisDepth;
                float2 appendResult31 = (float2(ase_screenPosNorm.x, ase_screenPosNorm.y));
                float4 lerpResult207 = lerp(_Color, _ColorFar, temp_output_115_0);
                float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos(screenPos);
                float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
                float4 fetchOpaqueVal111 = float4(SHADERGRAPH_SAMPLE_SCENE_COLOR(ase_grabScreenPosNorm.xy), 1.0);
                float4 lerpResult109 = lerp((lerpResult207), fetchOpaqueVal111, (1.0 - temp_output_115_0));
                
                
                //SSR
                float3 worldPos = ase_worldPos;
                float3 worldNormal = IN.normalWS.xyz;
                worldNormal.xy += temp_output_35_0 * _RefractionIntensity;
                float3 worldViewDir = ase_worldViewDir;
                
                half NoV = saturate(dot(worldNormal, worldViewDir));
                half3 R = normalize(reflect(-worldViewDir, worldNormal));
                
                float2 screenUV = ase_screenPosNorm.xy;
                
                #if defined(UNITY_SINGLE_PASS_STEREO)
                    screenUV.xy = UnityStereoTransformScreenSpaceTex(screenUV.xy);
                #endif
                
                
                half4 ssrColor = 0.0;
                
                #if _MobileSSPR
                    ssrColor = SAMPLE_TEXTURE2D(_MobileSSPR_ColorRT, LinearClampSampler, screenUV + temp_output_35_0 * _RefractionIntensity);
                #endif
                
                
                float2 uv_Foam0134 = (panner11 / _FoamScale);
                float2 uv_Foam1135 = (panner23 / _FoamScale);
                float screenDepth52 = screenDepth16;
                float distanceDepth52 = ((screenDepth52) / (_DepthArea));
                float depthArea90 = (pow(saturate((1.0 - distanceDepth52)), _DepthHard) * 5.0);
                float3 ase_worldNormal = IN.normalWS.xyz;
                float fresnelNdotV129 = dot(ase_worldNormal, ase_worldViewDir);
                float fresnelNode129 = (0.0 + 0.65 * pow(1.0 - fresnelNdotV129, 1.0));
                float temp_output_102_0 = saturate(((((tex2D(_FoamMap, uv_Foam0134)).rgb + ((tex2D(_FoamMap, uv_Foam1135)).rgb * float3(0.5, 0.5, 0.5)))).x * depthArea90 * 0.5 * _FoamColor.a));
                float4 lerpResult118 = lerp(lerpResult109, (_FoamColor * temp_output_102_0), temp_output_102_0);
                
                float3 Color = ((saturate((pow(saturate(dotResult288), (0.0 + (_Specular - 0.0) * (10.0 - 0.0) / (1.0 - 0.0))) * pow(abs(temp_output_115_0), 10.0))) * _SpecularColor) + lerpResult118).rgb;
                
                float Alpha = 1;
                half3 environmentColor = GlossyEnvironmentReflection(R, 1.0 - 1.0, 1.0);
                Color = lerp(lerp(Color, environmentColor, _Reflection * (1.0 - temp_output_102_0)), ssrColor.rgb, ssrColor.a * _Reflection * (1.0 - temp_output_102_0));
                Color = MixFog(Color, IN.fogCoord);
                return half4(Color.rgb, step(0.0, screenDepth16));
            }
            ENDHLSL
            
        }
    }
    
    CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.ToonWater"
}