// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "ZDShader/URP/Particles/Dissolve"
{
    Properties
    {
        [HideInInspector] _AlphaCutoff ("Alpha Cutoff ", Range(0, 1)) = 0.5
        [HideInInspector] _EmissionColor ("Emission Color", Color) = (1, 1, 1, 1)
        [HDR]_Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("MainTex", 2D) = "white" { }
        _DissolveTex ("DissolveTex", 2D) = "white" { }
        [HDR]_DissolveColor ("DissolveColor", Color) = (1, 0.2351134, 0, 0)
        _EdgeNear ("EdgeNear", Float) = 5
    }
    
    SubShader
    {
        LOD 0
        
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }
        
        Cull Off
        
        Pass
        {
            
            Name "Forward"
            Tags { "LightMode" = "MRTTransparent" }
            
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Offset 0, 0
            ColorMask RGBA
            
            
            HLSLPROGRAM
            
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #define ASE_SRP_VERSION 70301
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            
            #if ASE_SRP_VERSION <= 70108
                #define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
            #endif
            
            
            
            struct VertexInput
            {
                float4 vertex: POSITION;
                float4 color: COLOR;
                float3 ase_normal: NORMAL;
                float4 ase_texcoord: TEXCOORD0;
                float4 ase_texcoord1: TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    float3 worldPos: TEXCOORD0;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    float4 shadowCoord: TEXCOORD1;
                #endif
                #ifdef ASE_FOG
                    float fogFactor: TEXCOORD2;
                #endif
                float4 ase_texcoord3: TEXCOORD3;
                float4 color: TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float4 _MainTex_ST;
            float4 _DissolveTex_ST;
            float4 _DissolveColor;
            float _EdgeNear;
            
            CBUFFER_END
            sampler2D _MainTex;
            sampler2D _DissolveTex;
            
            
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.ase_texcoord3.xy = v.ase_texcoord.xy;
                o.ase_texcoord3.zw = v.ase_texcoord1.xy;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    float3 defaultVertexValue = v.vertex.xyz;
                #else
                    float3 defaultVertexValue = float3(0, 0, 0);
                #endif
                float3 vertexValue = defaultVertexValue;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    v.vertex.xyz = vertexValue;
                #else
                    v.vertex.xyz += vertexValue;
                #endif
                o.color = v.color;
                
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float4 positionCS = TransformWorldToHClip(positionWS);
                
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    o.worldPos = positionWS;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    VertexPositionInputs vertexInput = (VertexPositionInputs)0;
                    vertexInput.positionWS = positionWS;
                    vertexInput.positionCS = positionCS;
                    o.shadowCoord = GetShadowCoord(vertexInput);
                #endif
                #ifdef ASE_FOG
                    o.fogFactor = ComputeFogFactor(positionCS.z);
                #endif
                o.clipPos = positionCS;
                return o;
            }
            
            
            half4 frag(VertexOutput IN): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    float3 WorldPosition = IN.worldPos;
                #endif
                float4 ShadowCoords = float4(0, 0, 0, 0);
                
                #if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                        ShadowCoords = IN.shadowCoord;
                    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                        ShadowCoords = TransformWorldToShadowCoord(WorldPosition);
                    #endif
                #endif
                float2 uv0_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                float2 appendResult109 = (float2(float4(IN.ase_texcoord3.zw, 0, 0).xy.x, 1.0));
                float4 tex2DNode5 = tex2D(_MainTex, (uv0_MainTex / appendResult109));
                float2 uv0_DissolveTex = float4(IN.ase_texcoord3.xy, 0, 0).xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
                float4 tex2DNode18 = tex2D(_DissolveTex, uv0_DissolveTex);
                float disslove78 = float4(IN.ase_texcoord3.zw, 0, 0).xy.y;
                float temp_output_54_0 = step(1.0, (tex2DNode18.r + disslove78));
                float temp_output_70_0 = pow(saturate((temp_output_54_0 * (1.0 - saturate(pow(((-1.0 + (disslove78 - 0.0) * (2.0)) + tex2DNode18.r), 5.0))))), _EdgeNear);
                float3 appendResult82 = (float3(_DissolveColor.rgb));
                float4 lerpResult126 = lerp((_Color * IN.color * tex2DNode5), float4((temp_output_70_0 * appendResult82 * disslove78), 0.0), temp_output_70_0);
                
                float smoothstepResult100 = smoothstep(-0.1, tex2DNode18.r, (1.0 - abs(((float4(IN.ase_texcoord3.xy, 0, 0).xy - float2(0.5, 0.5)) * float2(2, 2))).y));
                float smoothstepResult123 = smoothstep(0.45, 0.55, smoothstepResult100);
                float temp_output_56_0 = (tex2DNode5.r * tex2DNode5.a * temp_output_54_0 * smoothstepResult123);
                //clip(temp_output_56_0 - 0.01);
                
                float3 BakedAlbedo = 0;
                float3 BakedEmission = 0;
                float3 Color = lerpResult126.rgb;
                float Alpha = temp_output_56_0;
                float AlphaClipThreshold = 0.5;
                
                

                #ifdef ASE_FOG
                    Color = MixFog(Color, IN.fogFactor);
                #endif
                
                return half4(Color, Alpha);
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
            
            #pragma multi_compile_instancing
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #define ASE_SRP_VERSION 70301
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            
            
            
            struct VertexInput
            {
                float4 vertex: POSITION;
                float3 ase_normal: NORMAL;
                float4 ase_texcoord: TEXCOORD0;
                float4 ase_texcoord1: TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    float3 worldPos: TEXCOORD0;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    float4 shadowCoord: TEXCOORD1;
                #endif
                float4 ase_texcoord2: TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float4 _MainTex_ST;
            float4 _DissolveTex_ST;
            float4 _DissolveColor;
            float _EdgeNear;
            
            CBUFFER_END
            sampler2D _MainTex;
            sampler2D _DissolveTex;
            
            
            
            float3 _LightDirection;
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.ase_texcoord2.xy = v.ase_texcoord.xy;
                o.ase_texcoord2.zw = v.ase_texcoord1.xy;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    float3 defaultVertexValue = v.vertex.xyz;
                #else
                    float3 defaultVertexValue = float3(0, 0, 0);
                #endif
                float3 vertexValue = defaultVertexValue;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    v.vertex.xyz = vertexValue;
                #else
                    v.vertex.xyz += vertexValue;
                #endif
                
                
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    o.worldPos = positionWS;
                #endif
                
                float3 normalWS = TransformObjectToWorldDir(v.ase_normal);
                
                float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
                
                #if UNITY_REVERSED_Z
                    clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
                #else
                    clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
                #endif
                
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    VertexPositionInputs vertexInput = (VertexPositionInputs)0;
                    vertexInput.positionWS = positionWS;
                    vertexInput.positionCS = clipPos;
                    o.shadowCoord = GetShadowCoord(vertexInput);
                #endif
                o.clipPos = clipPos;
                
                return o;
            }
            
            
            half4 frag(VertexOutput IN): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    float3 WorldPosition = IN.worldPos;
                #endif
                float4 ShadowCoords = float4(0, 0, 0, 0);
                
                #if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                        ShadowCoords = IN.shadowCoord;
                    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                        ShadowCoords = TransformWorldToShadowCoord(WorldPosition);
                    #endif
                #endif
                
                float2 uv0_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                float2 appendResult109 = (float2(float4(IN.ase_texcoord2.zw, 0, 0).xy.x, 1.0));
                float4 tex2DNode5 = tex2D(_MainTex, (uv0_MainTex / appendResult109));
                float2 uv0_DissolveTex = float4(IN.ase_texcoord2.xy, 0, 0).xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
                float4 tex2DNode18 = tex2D(_DissolveTex, uv0_DissolveTex);
                float disslove78 = float4(IN.ase_texcoord2.zw, 0, 0).xy.y;
                float temp_output_54_0 = step(1.0, (tex2DNode18.r + disslove78));
                float smoothstepResult100 = smoothstep(-0.1, tex2DNode18.r, (1.0 - abs(((float4(IN.ase_texcoord2.xy, 0, 0).xy - float2(0.5, 0.5)) * float2(2, 2))).y));
                float smoothstepResult123 = smoothstep(0.45, 0.55, smoothstepResult100);
                float temp_output_56_0 = (tex2DNode5.r * temp_output_54_0 * smoothstepResult123);
                clip(temp_output_56_0 - 0.01);
                
                float Alpha = temp_output_56_0;
                float AlphaClipThreshold = 0.5;
                
                #ifdef _ALPHATEST_ON
                    clip(Alpha - AlphaClipThreshold);
                #endif
                
                #ifdef LOD_FADE_CROSSFADE
                    LODDitheringTransition(IN.clipPos.xyz, unity_LODFade.x);
                #endif
                return 0;
            }
            
            ENDHLSL
            
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
    Fallback "Hidden/InternalErrorShader"
}
/*ASEBEGIN
Version=18104
60;53;1353;728;535.7261;372.1906;1;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;122;-1009.369,1164.669;Inherit;True;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;95;-817.3688,1164.669;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-689.3688,1164.669;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;97;-561.3688,1164.669;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;17;-1687.714,268.873;Inherit;True;Property;_DissolveTex;DissolveTex;2;0;Create;True;0;0;False;0;False;6a1fffff897d00e459ab3c9226cbedc6;6a1fffff897d00e459ab3c9226cbedc6;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;106;-79.03009,-160.7593;Inherit;False;1;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;129;-1468.863,269.7954;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;4;-32,-384;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;False;0c0411f89f1834a4cb6aee0a7964126c;0c0411f89f1834a4cb6aee0a7964126c;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.BreakToComponentsNode;98;-449.3687,1164.669;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;78;259.2398,3.45651;Inherit;False;disslove;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;-1344,640;Inherit;False;78;disslove;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;130;208,-304;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;18;-1247.763,418.0475;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;99;-225.3688,1164.669;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;109;234.9699,-166.7593;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;111;415.9699,-174.7593;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;100;96,1152;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;-0.1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-720,256;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;54;-512,256;Inherit;True;2;0;FLOAT;1;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;123;320,1152;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.45;False;2;FLOAT;0.55;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;575.9699,-350.7593;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;1249.895,242.1115;Inherit;False;3;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;112;-368,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;58;-720,512;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;71;80,256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;64;229.0744,454.5971;Inherit;False;Property;_DissolveColor;DissolveColor;3;1;[HDR];Create;True;0;0;False;0;False;1,0.2351134,0,0;0.01750156,0.0006035022,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;82;437.0744,454.5971;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;76;575.9699,-526.7593;Inherit;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;False;1,1,1,1;18.11321,4.074788,1.110716,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-128,256;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;640,512;Inherit;False;78;disslove;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;87;1488,240;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;928,-352;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;59;-1136,624;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;61;-240,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;128,384;Inherit;False;Property;_EdgeNear;EdgeNear;4;0;Create;True;0;0;False;0;False;5;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;57;-512,512;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;126;1136,-224;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;70;560,112;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;8.49;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;800,112;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;132;27.66235,-6.179871;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;90;1945.539,280.3759;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;91;1945.539,280.3759;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;89;1945.539,280.3759;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;88;1696.208,-122.8519;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;ZDShader/URP/Particles/Dissolve;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;21;Surface;1;  Blend;0;Two Sided;0;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;1;Built-in Fog;0;Meta Pass;0;DOTS Instancing;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;False;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;131;1696.208,-122.8519;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;95;0;122;0
WireConnection;96;0;95;0
WireConnection;97;0;96;0
WireConnection;129;2;17;0
WireConnection;98;0;97;0
WireConnection;78;0;106;2
WireConnection;130;2;4;0
WireConnection;18;0;17;0
WireConnection;18;1;129;0
WireConnection;99;0;98;1
WireConnection;109;0;106;1
WireConnection;111;0;130;0
WireConnection;111;1;109;0
WireConnection;100;0;99;0
WireConnection;100;2;18;1
WireConnection;32;0;18;1
WireConnection;32;1;79;0
WireConnection;54;1;32;0
WireConnection;123;0;100;0
WireConnection;5;0;4;0
WireConnection;5;1;111;0
WireConnection;56;0;5;1
WireConnection;56;1;54;0
WireConnection;56;2;123;0
WireConnection;112;0;57;0
WireConnection;58;0;59;0
WireConnection;58;1;18;1
WireConnection;71;0;62;0
WireConnection;82;0;64;0
WireConnection;62;0;54;0
WireConnection;62;1;61;0
WireConnection;87;0;56;0
WireConnection;87;1;56;0
WireConnection;117;0;76;0
WireConnection;117;1;5;0
WireConnection;59;0;79;0
WireConnection;61;0;112;0
WireConnection;57;0;58;0
WireConnection;126;0;117;0
WireConnection;126;1;113;0
WireConnection;126;2;70;0
WireConnection;70;0;71;0
WireConnection;70;1;72;0
WireConnection;113;0;70;0
WireConnection;113;1;82;0
WireConnection;113;2;128;0
WireConnection;132;0;106;2
WireConnection;88;2;126;0
WireConnection;88;3;87;0
ASEEND*/
// CHKSM = 1F919E6F3699811D3798D12719BB30C87863B6CE