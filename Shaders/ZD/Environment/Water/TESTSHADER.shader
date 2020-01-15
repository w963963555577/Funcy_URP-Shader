// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "TESTSHADER"
{
    Properties { }

    SubShader
    {
        LOD 0

        

        Tags { "RenderPipeline" = "LightweightPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }
        Cull Back
        HLSLINCLUDE
        #pragma target 3.0
        ENDHLSL
        
        Pass
        {
            Tags { "LightMode" = "LightweightForward" }
            Name "Base"

            Blend One Zero, One Zero
            ZWrite On
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
            
            #pragma vertex vert
            #pragma fragment frag


            // Lighting include is needed because of GI
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/Shaders/UnlitInput.hlsl"

            
            #include "Assets/Funcy_LWRP/ShaderLibrary/SSR.hlsl"



            

            struct GraphVertexInput
            {
                float4 vertex: POSITION;
                float4 normal: NORMAL;
                float4 tangent: TANGENT;
                float2 texcoord: TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct GraphVertexOutput
            {
                float4 pos: SV_POSITION;

                float4 worldNormalDir: TEXCOORD2;
                float4 worldTangentDir: TEXCOORD3;
                float4 worldBitangentDir: TEXCOORD4;

                float4 screenPos: TEXCOORD5;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            
            GraphVertexOutput vert(GraphVertexInput v)
            {
                GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.pos = TransformObjectToHClip(v.vertex);
                
                
                float3 worldPos = TransformObjectToWorld(v.vertex);
                
                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);
                
                o.worldNormalDir = float4(normalInput.normalWS, worldPos.x);
                o.worldTangentDir = float4(normalInput.tangentWS, worldPos.y);
                o.worldBitangentDir = float4(normalInput.bitangentWS, worldPos.z);
                
                
                o.screenPos = ComputeScreenPos(o.pos);
                o.screenPos.z = -TransformWorldToView(worldPos).z;
                
                return o;
            }

            half4 frag(GraphVertexOutput IN): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                float3 worldPos;
                float3 worldNormal;
                float3 worldViewDir;

                half NoV;
                half3 R;

                float2 screenUV;
                
                worldPos = float3(IN.worldNormalDir.w, IN.worldTangentDir.w, IN.worldBitangentDir.w);
                worldNormal = IN.worldNormalDir;
                worldViewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);
                NoV = saturate(dot(worldNormal, worldViewDir));
                R = normalize(reflect(-worldViewDir, worldNormal));
                screenUV = IN.screenPos.xy / IN.screenPos.w;
                                
                #if defined(UNITY_SINGLE_PASS_STEREO)
                    screenUV.xy = UnityStereoTransformScreenSpaceTex(screenUV.xy);
                #endif
                
                float3 uvz = GetSSRUVZ(IN.pos, worldPos, NoV, R, screenUV);
                half3 ssrColor = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, uvz.xy) * uvz.z;
                
                half3 reflection = ssrColor.rgb;

                half3 finalColor = reflection;
                
                return half4(finalColor, 1);
            }
            ENDHLSL
            
        }
    }
    Fallback "Hidden/InternalErrorShader"
    CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17500
1489;126;1179;512;759.5;229.5;1;True;False
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;3;TESTSHADER;e2514bdcf5e5399499a9eb24d175b9db;True;Base;0;0;Base;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;4;Include;;False;;Native;Custom;TEXTURE2D(_CameraDepthTexture)@ SAMPLER(sampler_CameraDepthTexture)@;False;;Custom;Custom;TEXTURE2D(_CameraOpaqueTexture)@ SAMPLER(sampler_CameraOpaqueTexture)@;False;;Custom;Include;./BGWaterSSR.hlsl;False;;Custom;Hidden/InternalErrorShader;0;0;Standard;8;Surface;0;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;Built-in Fog;0;LOD CrossFade;0;Vertex Position,InvertActionOnDeselection;1;0;3;True;False;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;e2514bdcf5e5399499a9eb24d175b9db;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;e2514bdcf5e5399499a9eb24d175b9db;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthOnly;True;0;0;Hidden/InternalErrorShader;0;0;Standard;0;0
ASEEND*/
// CHKSM = 7C54C7D3E78B3BC3424A64E91A0CC6D3AE2CA6DB