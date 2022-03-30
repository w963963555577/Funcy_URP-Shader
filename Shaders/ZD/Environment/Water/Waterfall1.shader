// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "ZDShader/URP/Environment/Waterfall1"
{
    Properties
    {
        [HideInInspector] _AlphaCutoff ("Alpha Cutoff ", Range(0, 1)) = 0.5
        [HideInInspector] _EmissionColor ("Emission Color", Color) = (1, 1, 1, 1)
        _MainTex ("MainTex", 2D) = "black" { }
        _VertexMin ("Vertex Min", Float) = 0.2
        _VertexMax ("Vertex Max", Float) = 1
        _Soft ("Soft", Range(0, 5)) = 1
        _FoatIntensity ("Foat Intensity", Range(0, 1)) = 0.5
        [HDR]_Color ("Color", Color) = (0.5333334, 0.8313726, 1.498039, 1)
        [HDR]_Color_Dark ("Color_Dark", Color) = (0.5333334, 0.8313726, 1.498039, 1)
        _Speed ("Speed Scale", Range(0, 1)) = 1
    }
    
    SubShader
    {
        LOD 0
        
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent-1" }
        
        Cull Back
        HLSLINCLUDE
        #pragma target 3.0
        ENDHLSL
        
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "MRTTransparent" }
            
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZWrite On
            ZTest LEqual
            Offset 0, 0
            ColorMask RGBA
            
            
            HLSLPROGRAM
            
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #define ASE_SRP_VERSION 70201
            #define REQUIRE_DEPTH_TEXTURE 1
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            
            #pragma vertex vert
            #pragma fragment frag
            
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "../../../../ShaderLibrary/GlobalFog.hlsl"
            
            #define ASE_NEEDS_VERT_NORMAL
                        
            sampler2D _MainTex;
            uniform float4 _CameraDepthTexture_TexelSize;
            CBUFFER_START(UnityPerMaterial)
            float _VertexMax;
            float4 _MainTex_ST;
            float _VertexMin;
            float4 _Color_Dark;
            float4 _Color;
            float _FoatIntensity;
            float _Soft;
            float _Speed;
            CBUFFER_END
            
            
            struct VertexInput
            {
                float4 vertex: POSITION;
                float3 ase_normal: NORMAL;
                float4 ase_texcoord: TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                #ifdef ASE_FOG
                    float fogFactor: TEXCOORD0;
                #endif
                float4 ase_texcoord1: TEXCOORD1;
                float4 ase_texcoord2: TEXCOORD2;
                float4 ase_texcoord3: TEXCOORD3;
                float3 positionWS: TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                float mulTime18 = _TimeParameters.x * 2.0;
                float4 transform54 = mul(GetObjectToWorldMatrix(), float4(0, 0, 0, 1));
                float temp_output_25_0 = (1.0 - v.ase_texcoord.y);
                float2 temp_output_49_0 = ((v.ase_texcoord.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
                float2 panner9 = (1.0 * _Time.y * float2(0, 1) + temp_output_49_0);
                float4 tex2DNode5 = tex2Dlod(_MainTex, float4(panner9, 0, 0.0));
                float2 panner12 = (1.0 * _Time.y * float2(0.2, 0.8) + temp_output_49_0);
                float temp_output_13_0 = max(tex2DNode5.r, tex2Dlod(_MainTex, float4(panner12, 0, 0.0)).g);
                float3 temp_output_16_0 = (v.ase_normal * max((_VertexMax * ((sin((((v.ase_texcoord.y * TWO_PI) * 2.0) + mulTime18 + transform54.x + transform54.y + transform54.z)) * 0.3) + (temp_output_25_0 * temp_output_25_0) + (temp_output_13_0 * 0.5))), _VertexMin));
                o.positionWS = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
                float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
                o.ase_texcoord1.xyz = ase_worldNormal;
                
                
                o.ase_texcoord2.xy = v.ase_texcoord.xy;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord1.w = 0;
                o.ase_texcoord2.zw = 0;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    float3 defaultVertexValue = v.vertex.xyz;
                #else
                    float3 defaultVertexValue = float3(0, 0, 0);
                #endif
                float3 vertexValue = temp_output_16_0;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    v.vertex.xyz = vertexValue;
                #else
                    v.vertex.xyz += vertexValue;
                #endif
                v.ase_normal = temp_output_16_0;
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                o.clipPos = vertexInput.positionCS;
                float4 screenPos = ComputeScreenPos(vertexInput.positionCS);
                o.ase_texcoord3 = screenPos;
                #ifdef ASE_FOG
                    o.fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                #endif
                return o;
            }
            
            half4 frag(VertexOutput IN): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                float3 ase_worldNormal = IN.ase_texcoord1.xyz;
                float dotResult5_g2 = dot(ase_worldNormal, _MainLightPosition.xyz);
                float4 lerpResult43 = lerp(_Color_Dark, _Color, (dotResult5_g2 * 0.5 + 0.5));
                float2 temp_output_49_0 = ((IN.ase_texcoord2.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
                float speed = _Speed;
                float2 panner9 = (speed * _Time.y * float2(0, 1) + temp_output_49_0);
                float4 tex2DNode5 = tex2D(_MainTex, panner9);
                float2 panner12 = (speed * _Time.y * float2(0.2, 0.8) + temp_output_49_0);
                float temp_output_13_0 = max(tex2DNode5.r, tex2D(_MainTex, panner12).g);
                
                float4 screenPos = IN.ase_texcoord3;
                float4 ase_screenPosNorm = screenPos / screenPos.w;
                ase_screenPosNorm.z = (UNITY_NEAR_CLIP_VALUE >= 0) ? ase_screenPosNorm.z: ase_screenPosNorm.z * 0.5 + 0.5;
                float screenDepth51 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(ase_screenPosNorm.xy), _ZBufferParams) - screenPos.w;
                float distanceDepth51 = abs((screenDepth51) / (_Soft));
                
                float3 BakedAlbedo = 0;
                float3 BakedEmission = 0;
                float3 Color = (lerpResult43 + (((((1.0 - IN.ase_texcoord2.xy.y) * tex2DNode5.b) + temp_output_13_0) + temp_output_13_0 + saturate(((temp_output_13_0 - 0.5) * 2.0))) * _FoatIntensity)).rgb;
                float Alpha = saturate(distanceDepth51);
                float AlphaClipThreshold = 0.5;
                
                #if _AlphaClip
                    clip(Alpha - AlphaClipThreshold);
                #endif
                
                #ifdef ASE_FOG
                    Color = MixFog(Color, IN.fogFactor);
                #endif
                
                #ifdef LOD_FADE_CROSSFADE
                    LODDitheringTransition(IN.clipPos.xyz, unity_LODFade.x);
                #endif
                
                return MixGlobalFog(half4(Color, Alpha), IN.positionWS);
            }
            
            ENDHLSL
            
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
    Fallback "Hidden/InternalErrorShader"
}
