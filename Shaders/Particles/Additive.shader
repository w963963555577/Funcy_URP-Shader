// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "ZDShader/URP/Particles/Additive"
{
    Properties
    {
        [HideInInspector] _AlphaCutoff ("Alpha Cutoff ", Range(0, 1)) = 0.5
        [HideInInspector] _EmissionColor ("Emission Color", Color) = (1, 1, 1, 1)
        [HDR]_TintColor ("Tint Color", Color) = (1, 1, 1, 1)
        _MainTex ("MainTex", 2D) = "white" { }
        _Soft ("Soft", Range(0, 5)) = 1
        [HideInInspector] _texcoord ("", 2D) = "white" { }
        _Border ("Border", Vector) = (5.0, 5.0, 5.0, 5.0)
        [MaterialToggle] _Slice ("Slice UV", Float) = 0
        _Panner ("Panner", Vector) = (0.0, 0.0, 0.0, 0.0)
        [Enum(UnityEngine.Rendering.CompareFunction)]  _ZTest ("ZTest", Float) = 4
    }
    
    SubShader
    {
        LOD 0
        
        
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }
        
        Cull Off
        HLSLINCLUDE
        #pragma target 3.0
        ENDHLSL
        
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend SrcAlpha One
            ZWrite Off
            ZTest [_ZTest]
            Offset 0, 0
            ColorMask RGBA
            
            
            HLSLPROGRAM
            
            #define _RECEIVE_SHADOWS_OFF 1
            #pragma multi_compile_instancing
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
            
            
            
            sampler2D _MainTex;
            uniform float4 _CameraDepthTexture_TexelSize;
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float4 _TintColor;
            float _Soft;
            half4 _Border;
            half _Slice;
            half4 _Panner;
            CBUFFER_END
            
            
            struct VertexInput
            {
                float4 vertex: POSITION;
                float2 ase_texcoord0: TEXCOORD0;					//this shader support uv9slice
                float2 particleSize: TEXCOORD1;
                float borderScale: TEXCOORD2;
                float4 ase_color: COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                float4 ase_texcoord0: TEXCOORD0;
                float2 particleSize: TEXCOORD1;
                float4 ase_color: COLOR;
                float4 ase_texcoord2: TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            float2 uv9slice(float2 uv, half2 texelSize, half4 ST, half4 border, half borderScale, half2 scaleFilter)
            {
                half4 b = min(border * texelSize.xyxy, 0.499.xxxx);
                half2 s = scaleFilter * ST.xy * borderScale;
                
                float2 t = saturate((s * uv - b.xy) / (s - b.xy - b.zw));
                return lerp(uv * s, 1. - s * (1. - uv), t);
            }
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                
                o.ase_texcoord0 = half4(v.ase_texcoord0.xy, v.borderScale.x, 0.0);
                o.particleSize.xy = v.particleSize.xy;
                o.ase_color = v.ase_color;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                o.clipPos = vertexInput.positionCS;
                
                float4 screenPos = ComputeScreenPos(o.clipPos);
                o.ase_texcoord2 = screenPos;
                return o;
            }
            
            half4 frag(VertexOutput IN): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                float2 uv_MainTex = lerp(IN.ase_texcoord0.xy, uv9slice(IN.ase_texcoord0.xy, /*_MainTex_TexelSize.xy*/0.0625.xx, _MainTex_ST, _Border, IN.ase_texcoord0.z, IN.particleSize.xy * 0.1), _Slice) * _MainTex_ST.xy + _MainTex_ST.zw;
                float4 break13 = (tex2D(_MainTex, uv_MainTex + _Panner.xy * _Time.y * _Panner.z) * IN.ase_color * _TintColor);
                float3 appendResult14 = (float3(break13.r, break13.g, break13.b));
                
                float4 screenPos = IN.ase_texcoord2;
                float4 ase_screenPosNorm = screenPos / screenPos.w;
                ase_screenPosNorm.z = (UNITY_NEAR_CLIP_VALUE >= 0) ? ase_screenPosNorm.z: ase_screenPosNorm.z * 0.5 + 0.5;
                
                float depthQ = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(ase_screenPosNorm.xy), _ZBufferParams);
                
                float screenDepth16 = depthQ;
                
                float distanceDepth16 = abs((screenDepth16 - LinearEyeDepth(ase_screenPosNorm.z, _ZBufferParams)) / (_Soft));
                
                float3 BakedAlbedo = 0;
                float3 BakedEmission = 0;
                float3 Color = appendResult14;
                float Alpha = saturate((break13.a * saturate(distanceDepth16)));
                float AlphaClipThreshold = 0.5;
                
                #if _AlphaClip
                    clip(Alpha - AlphaClipThreshold);
                #endif
                
                
                #ifdef LOD_FADE_CROSSFADE
                    LODDitheringTransition(IN.clipPos.xyz, unity_LODFade.x);
                #endif
                
                return half4(Color, Alpha);
            }
            
            ENDHLSL
            
        }
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "MRTTransparent" }
            
            Blend SrcAlpha One
            ZWrite Off
            ZTest [_ZTest]
            Offset 0, 0
            ColorMask RGBA
            
            
            HLSLPROGRAM
            
            #define _RECEIVE_SHADOWS_OFF 1
            #pragma multi_compile_instancing
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
            
            
            
            sampler2D _MainTex;
            uniform float4 _CameraDepthTexture_TexelSize;
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float4 _TintColor;
            float _Soft;
            half4 _Border;
            half _Slice;
            half4 _Panner;
            CBUFFER_END
            
            
            struct VertexInput
            {
                float4 vertex: POSITION;
                float2 ase_texcoord0: TEXCOORD0;					//this shader support uv9slice
                float2 particleSize: TEXCOORD1;
                float borderScale: TEXCOORD2;
                float4 ase_color: COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                float4 ase_texcoord0: TEXCOORD0;
                float2 particleSize: TEXCOORD1;
                float4 ase_color: COLOR;
                float4 ase_texcoord2: TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            float2 uv9slice(float2 uv, half2 texelSize, half4 ST, half4 border, half borderScale, half2 scaleFilter)
            {
                half4 b = min(border * texelSize.xyxy, 0.499.xxxx);
                half2 s = scaleFilter * ST.xy * borderScale;
                
                float2 t = saturate((s * uv - b.xy) / (s - b.xy - b.zw));
                return lerp(uv * s, 1. - s * (1. - uv), t);
            }
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                
                o.ase_texcoord0 = half4(v.ase_texcoord0.xy, v.borderScale.x, 0.0);
                o.particleSize.xy = v.particleSize.xy;
                o.ase_color = v.ase_color;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                o.clipPos = vertexInput.positionCS;
                
                float4 screenPos = ComputeScreenPos(o.clipPos);
                o.ase_texcoord2 = screenPos;
                return o;
            }
            
            half4 frag(VertexOutput IN): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                float2 uv_MainTex = lerp(IN.ase_texcoord0.xy, uv9slice(IN.ase_texcoord0.xy, /*_MainTex_TexelSize.xy*/0.0625.xx, _MainTex_ST, _Border, IN.ase_texcoord0.z, IN.particleSize.xy * 0.1), _Slice) * _MainTex_ST.xy + _MainTex_ST.zw;
                float4 break13 = (tex2D(_MainTex, uv_MainTex + _Panner.xy * _Time.y * _Panner.z) * IN.ase_color * _TintColor);
                float3 appendResult14 = (float3(break13.r, break13.g, break13.b));
                
                float4 screenPos = IN.ase_texcoord2;
                float4 ase_screenPosNorm = screenPos / screenPos.w;
                ase_screenPosNorm.z = (UNITY_NEAR_CLIP_VALUE >= 0) ? ase_screenPosNorm.z: ase_screenPosNorm.z * 0.5 + 0.5;
                
                float depthQ = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(ase_screenPosNorm.xy), _ZBufferParams);
                
                float screenDepth16 = depthQ;
                
                float distanceDepth16 = abs((screenDepth16 - LinearEyeDepth(ase_screenPosNorm.z, _ZBufferParams)) / (_Soft));
                
                float3 BakedAlbedo = 0;
                float3 BakedEmission = 0;
                float3 Color = appendResult14;
                float Alpha = saturate((break13.a * saturate(distanceDepth16)));
                float AlphaClipThreshold = 0.5;
                
                #if _AlphaClip
                    clip(Alpha - AlphaClipThreshold);
                #endif
                
                
                #ifdef LOD_FADE_CROSSFADE
                    LODDitheringTransition(IN.clipPos.xyz, unity_LODFade.x);
                #endif
                
                return half4(Color, Alpha);
            }
            
            ENDHLSL
            
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
    Fallback "Hidden/InternalErrorShader"
}
/*ASEBEGIN
Version=17800
126;61;1421;789;1521.17;643.8129;1.799579;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;5;-657.1583,-164.4009;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;6;-432,-160;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-278.4665,453.5673;Inherit;False;Property;_Soft;Soft;2;0;Create;True;0;0;False;0;1;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;9;-304,48;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;22;-352,240;Inherit;False;Property;_TintColor;Tint Color;0;1;[HDR];Create;True;0;0;False;0;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-43.54217,-46.74561;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;16;2.900027,328.1001;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;13;96,-48;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SaturateNode;20;264.2838,294.3172;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;345.5336,158.4672;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;381.5995,-62.69722;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;19;497.6336,129.8672;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;719.7,-77.2;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;ZDShader/URP/Particles/Additive;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;0;Forward;7;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;8;5;False;-1;1;False;-1;0;4;False;-1;1;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;10;Surface;1;  Blend;2;Two Sided;0;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Vertex Position,InvertActionOnDeselection;1;0;4;True;False;True;False;False;;0
WireConnection;6;0;5;0
WireConnection;12;0;6;0
WireConnection;12;1;9;0
WireConnection;12;2;22;0
WireConnection;16;0;17;0
WireConnection;13;0;12;0
WireConnection;20;0;16;0
WireConnection;18;0;13;3
WireConnection;18;1;20;0
WireConnection;14;0;13;0
WireConnection;14;1;13;1
WireConnection;14;2;13;2
WireConnection;19;0;18;0
WireConnection;1;2;14;0
WireConnection;1;3;19;0
ASEEND*/
// CHKSM = 6564106BE7BFA4D8F642E88D726338DE2CA59F03