// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/URP/Particles/Custom Effects/AirDisturbance"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_DisturbanceMap("DisturbanceMap", 2D) = "bump" {}
		_Intensity("Intensity", Range( 0 , 1)) = 0
		[Toggle]_AutoMask("AutoMask", Float) = 1
		[Enum(Square,0,Circle,1)]_MaskType("MaskType", Float) = 0
		_MaskMin("Mask Min", Range( 0 , 1)) = 0.5
		_MaskMax("Mask Max", Range( 0 , 1)) = 1
		[Toggle]_DebugMask("DebugMask", Float) = 0

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent-2" }
		
		Cull Off
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL

		
		Pass
		{
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 70201
			#define REQUIRE_OPAQUE_TEXTURE 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			

			sampler2D _DisturbanceMap;
			CBUFFER_START( UnityPerMaterial )
			half4 _DisturbanceMap_ST;
			half _Intensity;
			half _MaskMin;
			half _MaskMax;
			half _MaskType;
			half _AutoMask;
			half _DebugMask;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord1.xy;
				o.ase_texcoord2.zw = v.ase_texcoord.xy;
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
				v.ase_normal = v.ase_normal;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				o.clipPos = vertexInput.positionCS;
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( vertexInput.positionCS.z );
				#endif
				return o;
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float4 screenPos = IN.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half2 appendResult12 = (half2(ase_screenPosNorm.xy));
				half2 appendResult61 = (half2(ase_screenPosNorm.xy));
				half2 appendResult73 = (half2(( _ScreenParams.x / _ScreenParams.y ) , 1.0));
				half2 panner74 = ( IN.ase_texcoord2.xy.y * float2( -1,-1 ) + ( ( appendResult61 * appendResult73 * _DisturbanceMap_ST.xy ) + _DisturbanceMap_ST.zw ));
				half2 appendResult11 = (half2(( tex2D( _DisturbanceMap, ( panner74 + float2( 0.1,0.1 ) ) ) - tex2D( _DisturbanceMap, ( panner74 - float2( 0.1,0.1 ) ) ) ).rg));
				half2 uv019 = IN.ase_texcoord2.zw * float2( 1,1 ) + float2( 0,0 );
				half2 temp_output_20_0 = ( uv019 - float2( 0.5,0.5 ) );
				float cos24 = cos( ( 0.25 * PI ) );
				float sin24 = sin( ( 0.25 * PI ) );
				half2 rotator24 = mul( ( temp_output_20_0 * float2( 1.41414,1.41414 ) ) - float2( 0,0 ) , float2x2( cos24 , -sin24 , sin24 , cos24 )) + float2( 0,0 );
				half2 break22 = abs( rotator24 );
				half smoothstepResult27 = smoothstep( _MaskMin , _MaskMax , pow( ( break22.x + break22.y ) , 2.0 ));
				half smoothstepResult49 = smoothstep( _MaskMin , _MaskMax , saturate( length( ( temp_output_20_0 * float2( 2,2 ) ) ) ));
				half lerpResult48 = lerp( ( 1.0 - saturate( smoothstepResult27 ) ) , ( 1.0 - smoothstepResult49 ) , _MaskType);
				half lerpResult40 = lerp( 1.0 , lerpResult48 , _AutoMask);
				half4 fetchOpaqueVal5 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( ( ( ( appendResult12 - float2( 0.5,0.5 ) ) + ( appendResult11 * (0.0 + (_Intensity - 0.0) * (0.1 - 0.0) / (1.0 - 0.0)) * lerpResult40 * IN.ase_texcoord2.xy.x ) ) + float2( 0.5,0.5 ) ) ), 1.0 );
				half4 temp_cast_3 = (lerpResult40).xxxx;
				half4 lerpResult54 = lerp( fetchOpaqueVal5 , temp_cast_3 , _DebugMask);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult54.rgb;
				float Alpha = lerpResult40;
				float AlphaClipThreshold = 0.5;

				#if _AlphaClip
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

	
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=17800
0;0;1440;849;2193.043;481.5403;1.942615;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;19;-2816,1152;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-2816,1280;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-2608,1280;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;1.41414,1.41414;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;25;-2596.273,1059.746;Inherit;False;1;0;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenParams;71;-3248.642,342.5722;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotatorNode;24;-2357.169,1042.798;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;72;-3072.642,342.5722;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;69;-3248.642,166.5722;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;7;-3248.642,-169.4278;Inherit;True;Property;_DisturbanceMap;DisturbanceMap;0;0;Create;True;0;0;False;0;None;None;True;bump;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.AbsOpNode;26;-2191.954,1041.822;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;73;-2960.642,342.5722;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureTransformNode;75;-3248.642,22.57222;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.DynamicAppendNode;61;-3072.642,166.5722;Inherit;False;FLOAT2;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;22;-2082.667,1040.298;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-2128,1488;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;-1865.971,1038.997;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-2864.642,166.5722;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;43;-1920,1472;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2368,1408;Inherit;False;Property;_MaskMax;Mask Max;5;0;Create;True;0;0;False;0;1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2368,1328;Inherit;False;Property;_MaskMin;Mask Min;4;0;Create;True;0;0;False;0;0.5;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;-2736.642,166.5722;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;28;-1661.095,1030.365;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;65;-3024,448;Inherit;False;1;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;44;-1760,1472;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;74;-2800.642,310.5722;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-1,-1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;27;-1421.095,1030.365;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;63;-2608.642,310.5722;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;49;-1600,1472;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;32;-1192.066,1048.76;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-2608.642,182.5722;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;45;-1376,1488;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-2448.642,118.5722;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;34;-2448.642,310.5722;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;47;-1082.229,1516.652;Inherit;False;Property;_MaskType;MaskType;3;1;[Enum];Create;True;2;Square;0;Circle;1;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;31;-1152,1152;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;10;-1152,-128;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;-656,832;Inherit;False;Property;_AutoMask;AutoMask;2;1;[Toggle];Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1408,176;Inherit;False;Property;_Intensity;Intensity;1;0;Create;True;0;0;False;0;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;48;-976,1152;Inherit;True;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;36;-2144.642,118.5722;Inherit;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-976,-128;Inherit;True;FLOAT2;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;40;-600.7267,579.758;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;11;-1952.642,118.5722;Inherit;True;FLOAT2;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;42;-1152,176;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;77;-1168,352;Inherit;False;1;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;16;-816,-128;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-816,96;Inherit;True;4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-624,-128;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-432,-128;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-289.1261,792.5329;Inherit;False;Property;_DebugMask;DebugMask;6;1;[Toggle];Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;5;-224,-128;Inherit;False;Global;_GrabScreen0;Grab Screen 0;0;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-803.8025,838.1364;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;54;63.31138,371.8341;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;350.8378,110.4739;Half;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;ZDShader/URP/Particles/AirDisturbance;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;0;Forward;7;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=-2;True;2;0;True;2;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;10;Surface;1;  Blend;0;Two Sided;0;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Vertex Position,InvertActionOnDeselection;1;0;4;True;False;False;False;False;;0
WireConnection;20;0;19;0
WireConnection;21;0;20;0
WireConnection;24;0;21;0
WireConnection;24;2;25;0
WireConnection;72;0;71;1
WireConnection;72;1;71;2
WireConnection;26;0;24;0
WireConnection;73;0;72;0
WireConnection;75;0;7;0
WireConnection;61;0;69;0
WireConnection;22;0;26;0
WireConnection;46;0;20;0
WireConnection;23;0;22;0
WireConnection;23;1;22;1
WireConnection;70;0;61;0
WireConnection;70;1;73;0
WireConnection;70;2;75;0
WireConnection;43;0;46;0
WireConnection;76;0;70;0
WireConnection;76;1;75;1
WireConnection;28;0;23;0
WireConnection;44;0;43;0
WireConnection;74;0;76;0
WireConnection;74;1;65;2
WireConnection;27;0;28;0
WireConnection;27;1;29;0
WireConnection;27;2;30;0
WireConnection;63;0;74;0
WireConnection;49;0;44;0
WireConnection;49;1;29;0
WireConnection;49;2;30;0
WireConnection;32;0;27;0
WireConnection;62;0;74;0
WireConnection;45;0;49;0
WireConnection;8;0;7;0
WireConnection;8;1;62;0
WireConnection;34;0;7;0
WireConnection;34;1;63;0
WireConnection;31;0;32;0
WireConnection;48;0;31;0
WireConnection;48;1;45;0
WireConnection;48;2;47;0
WireConnection;36;0;8;0
WireConnection;36;1;34;0
WireConnection;12;0;10;0
WireConnection;40;1;48;0
WireConnection;40;2;38;0
WireConnection;11;0;36;0
WireConnection;42;0;15;0
WireConnection;16;0;12;0
WireConnection;14;0;11;0
WireConnection;14;1;42;0
WireConnection;14;2;40;0
WireConnection;14;3;77;1
WireConnection;13;0;16;0
WireConnection;13;1;14;0
WireConnection;17;0;13;0
WireConnection;5;0;17;0
WireConnection;54;0;5;0
WireConnection;54;1;40;0
WireConnection;54;2;53;0
WireConnection;1;2;54;0
WireConnection;1;3;40;0
ASEEND*/
//CHKSM=7FE06B540E9C86ECD8046FB44C5C4091DE6CB40E