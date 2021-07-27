// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/URP/Particles/Custom Effects/Magic Circle"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HDR]_Color("Color", Color) = (1,0.5701252,0.1839623,1)
		_MainTex("MainTex", 2D) = "white" {}
		[HDR]_MagicArrowColor("Color", Color) = (1,1,1,1)
		_MagicArrowMap("Magic Arrow Map", 2D) = "white" {}
		[HDR]_EdgeColor("EdgeColor", Color) = (1,0.1142083,0,1)
		_NoiseMap("NoiseMap", 2D) = "white" {}
		_Angle("Angle", Range( 0 , 360)) = 186.0151
		_CenterSplit("Center Split", Range( 0 , 1)) = 0.5411765
		_Blur("Blur", Float) = 0.05

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Off
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL

		
		Pass
		{
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 70201

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			

			sampler2D _NoiseMap;
			sampler2D _MagicArrowMap;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			half4 _Color;
			half4 _EdgeColor;
			half4 _NoiseMap_ST;
			half _CenterSplit;
			half4 _MagicArrowColor;
			half _Blur;
			half _Angle;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
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

				half3 appendResult132 = (half3(_Color.rgb));
				half3 appendResult143 = (half3(_EdgeColor.rgb));
				half2 currentUV216 = IN.ase_texcoord1.xy;
				half2 panner100 = ( 0.1 * _Time.y * float2( 0,-1 ) + currentUV216);
				half4 tex2DNode99 = tex2D( _NoiseMap, ( ( panner100 * _NoiseMap_ST.xy ) + _NoiseMap_ST.zw ) );
				half smoothstepResult117 = smoothstep( 0.45 , 0.55 , tex2DNode99.r);
				half smoothstepResult118 = smoothstep( 0.55 , 0.65 , tex2DNode99.r);
				half temp_output_120_0 = ( smoothstepResult117 - smoothstepResult118 );
				half temp_output_111_0 = saturate( length( ( ( float2( 0.5,0.5 ) - currentUV216 ) * float2( 2,2 ) ) ) );
				half smoothstepResult113 = smoothstep( ( _CenterSplit - 0.01 ) , ( _CenterSplit + 0.01 ) , temp_output_111_0);
				half3 lerpResult142 = lerp( appendResult132 , appendResult143 , ( temp_output_120_0 * smoothstepResult113 ));
				half3 appendResult134 = (half3(_MagicArrowColor.rgb));
				half temp_output_32_0 = (0.0 + (_Angle - 0.0) * (1.0 - 0.0) / (360.0 - 0.0));
				half minmaxBlur244 = min( _Blur , ( 1.0 - ( abs( ( temp_output_32_0 - 0.5 ) ) * 2.0 ) ) );
				half angle243 = temp_output_32_0;
				float cos54 = cos( ( angle243 * PI ) );
				float sin54 = sin( ( angle243 * PI ) );
				half2 rotator54 = mul( currentUV216 - float2( 0.5,0.5 ) , float2x2( cos54 , -sin54 , sin54 , cos54 )) + float2( 0.5,0.5 );
				half smoothstepResult63 = smoothstep( ( 0.5 - minmaxBlur244 ) , ( 0.5 + minmaxBlur244 ) , rotator54.x);
				float cos59 = cos( ( ( angle243 * PI ) * -1.0 ) );
				float sin59 = sin( ( ( angle243 * PI ) * -1.0 ) );
				half2 rotator59 = mul( currentUV216 - float2( 0.5,0.5 ) , float2x2( cos59 , -sin59 , sin59 , cos59 )) + float2( 0.5,0.5 );
				half smoothstepResult65 = smoothstep( ( 0.5 - minmaxBlur244 ) , ( 0.5 + minmaxBlur244 ) , rotator59.x);
				half smoothstepResult126 = smoothstep( 0.05 , 0.1 , temp_output_111_0);
				half temp_output_130_0 = max( max( ( ( 1.0 - smoothstepResult63 ) * tex2D( _MagicArrowMap, rotator54 ).a ) , ( tex2D( _MagicArrowMap, rotator59 ).a * smoothstepResult65 ) ) , ( 1.0 - smoothstepResult126 ) );
				half3 lerpResult141 = lerp( lerpResult142 , appendResult134 , temp_output_130_0);
				
				half mulTime128 = _TimeParameters.x * 0.1;
				float cos6 = cos( ( mulTime128 * PI ) );
				float sin6 = sin( ( mulTime128 * PI ) );
				half2 rotator6 = mul( currentUV216 - float2( 0.5,0.5 ) , float2x2( cos6 , -sin6 , sin6 , cos6 )) + float2( 0.5,0.5 );
				half4 tex2DNode5 = tex2D( _MainTex, rotator6 );
				float cos239 = cos( ( -0.5 * PI ) );
				float sin239 = sin( ( -0.5 * PI ) );
				half2 rotator239 = mul( currentUV216 - float2( 0.5,0.5 ) , float2x2( cos239 , -sin239 , sin239 , cos239 )) + float2( 0.5,0.5 );
				half2 break222 = ( ( float2( 0.5,0.5 ) - rotator239 ) * float2( 2,2 ) );
				half smoothstepResult240 = smoothstep( ( angle243 - minmaxBlur244 ) , ( angle243 + minmaxBlur244 ) , ( abs( atan2( break222.y , break222.x ) ) / PI ));
				half smoothstepResult105 = smoothstep( 0.0 , 1.0 , tex2DNode99.r);
				half lerpResult123 = lerp( smoothstepResult105 , max( smoothstepResult105 , temp_output_120_0 ) , smoothstepResult113);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult141;
				float Alpha = max( ( tex2DNode5.r * tex2DNode5.a * min( smoothstepResult240 , lerpResult123 ) ) , ( temp_output_130_0 * smoothstepResult240 ) );
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
60;101;1356;741;5287.465;2409.816;6.696346;True;False
Node;AmplifyShaderEditor.RangedFloatNode;31;-2176,1152;Inherit;False;Property;_Angle;Angle;6;0;Create;True;0;0;False;0;186.0151;360;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;32;-1904,1152;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;360;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;39;-1728,1152;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;10;-2816,384;Inherit;True;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;40;-1584,1152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;216;-2608,384;Inherit;False;currentUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1472,1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;42;-1344,1152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;98;-451.762,1287.629;Inherit;True;Property;_NoiseMap;NoiseMap;5;0;Create;True;0;0;False;0;6a1fffff897d00e459ab3c9226cbedc6;6a1fffff897d00e459ab3c9226cbedc6;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-960.9882,1513.131;Inherit;False;216;currentUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1351.7,1322.284;Inherit;False;Property;_Blur;Blur;8;0;Create;True;0;0;False;0;0.05;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;243;-1705,1075;Inherit;False;angle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;237;-2304,640;Inherit;False;216;currentUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;238;-2432,512;Inherit;False;1;0;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;248;-1584,0;Inherit;False;243;angle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;148;-576,1600;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.PannerNode;100;-557,1492;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-1;False;1;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMinOpNode;48;-1184,1152;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;239;-2176,512;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;55;-1401.042,-6.632784;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-379.8627,1504.007;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;220;-1965.952,502.0091;Inherit;True;2;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;241;-1376,-192;Inherit;False;216;currentUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;244;-1072,1152;Inherit;False;minmaxBlur;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;221;-1757.952,502.0091;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;150;-243.8627,1500.007;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;107;-774.4012,1694.356;Inherit;False;2;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1191.657,2.994658;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;247;-560,96;Inherit;False;244;minmaxBlur;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;54;-1040,-320;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;62;-589.8088,-409.0593;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-630.4012,1694.356;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;99;-195.7621,1287.629;Inherit;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;222;-1565.951,502.0091;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;246;-672,400;Inherit;False;244;minmaxBlur;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;84;-380.1046,-199.4015;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;-380.1046,-87.40152;Inherit;False;2;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;59;-1040,-96;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-576.363,1965.177;Inherit;False;Property;_CenterSplit;Center Split;7;0;Create;True;0;0;False;0;0.5411765;360;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;-480,336;Inherit;False;2;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;63;-318.498,-427.2229;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.49;False;2;FLOAT;0.51;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;69;-721.9047,301.6739;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SmoothstepOpNode;118;128,1632;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.55;False;2;FLOAT;0.65;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;117;128,1504;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.45;False;2;FLOAT;0.55;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;82;-480,224;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;49;-1040,-528;Inherit;True;Property;_MagicArrowMap;Magic Arrow Map;3;0;Create;True;0;0;False;0;594858368701aa048886de204e28d1ae;594858368701aa048886de204e28d1ae;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ATan2OpNode;223;-1341.95,502.0091;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;110;-502.4012,1694.356;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;56;-704,-96;Inherit;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;50;-694.1751,-291.6501;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;249;-908.1162,810.2748;Inherit;False;243;angle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;245;-914.6633,951.9224;Inherit;False;244;minmaxBlur;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;65;-271.3047,250.5976;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.49;False;2;FLOAT;0.51;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;120;336,1504;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;79;-88.68159,-397.9706;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;224;-1165.951,726.0092;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;225;-1149.951,502.0091;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;115;-272,1920;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;-272,2032;Inherit;False;2;2;0;FLOAT;0.5;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;128;-944,-1072;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;111;-326.4012,1694.356;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;105;144,1264;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-48,-48;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;125;602.6003,1478.789;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-35.97142,-262.7807;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;127;-752,-1056;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;126;5.421996,237.3086;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.05;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;219;-768,-1152;Inherit;False;216;currentUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;227;-720.6,827;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;113;-160,1696;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;226;-989.9504,502.0091;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;228;-720.6,939;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;144;976.1591,1058.457;Inherit;False;Property;_EdgeColor;EdgeColor;4;1;[HDR];Create;True;0;0;False;0;1,0.1142083,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotatorNode;6;-512,-1152;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;129;256.2066,250.619;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;57;197.144,-151.6312;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;240;-717.4178,506.928;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;131;973.253,842.6736;Inherit;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;1,0.5701252,0.1839623,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;123;640,1168;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;4;-320,-1152;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ColorNode;135;1230.623,-645.4622;Inherit;False;Property;_MagicArrowColor;Color;2;1;[HDR];Create;False;0;0;False;0;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;143;1171.39,1055.37;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;132;1165.253,842.6736;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;130;1434.525,-482.1181;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;96;224,496;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-96,-1152;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;1181.253,1146.674;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;558.8008,-61.24439;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;537.929,-341.6026;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;142;1389.253,954.6736;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;134;1425.854,-648.5489;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;141;1711.675,-497.4364;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;71;1048.261,196.7202;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1975.386,-494.7953;Half;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;Magic Circle;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;0;Forward;7;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;2;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;10;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Vertex Position,InvertActionOnDeselection;1;0;4;True;False;False;False;False;;0
WireConnection;32;0;31;0
WireConnection;39;0;32;0
WireConnection;40;0;39;0
WireConnection;216;0;10;0
WireConnection;41;0;40;0
WireConnection;42;0;41;0
WireConnection;243;0;32;0
WireConnection;148;0;98;0
WireConnection;100;0;218;0
WireConnection;48;0;34;0
WireConnection;48;1;42;0
WireConnection;239;0;237;0
WireConnection;239;2;238;0
WireConnection;55;0;248;0
WireConnection;149;0;100;0
WireConnection;149;1;148;0
WireConnection;220;1;239;0
WireConnection;244;0;48;0
WireConnection;221;0;220;0
WireConnection;150;0;149;0
WireConnection;150;1;148;1
WireConnection;107;1;218;0
WireConnection;60;0;55;0
WireConnection;54;0;241;0
WireConnection;54;2;55;0
WireConnection;62;0;54;0
WireConnection;109;0;107;0
WireConnection;99;0;98;0
WireConnection;99;1;150;0
WireConnection;222;0;221;0
WireConnection;84;1;247;0
WireConnection;85;1;247;0
WireConnection;59;0;241;0
WireConnection;59;2;60;0
WireConnection;83;1;246;0
WireConnection;63;0;62;0
WireConnection;63;1;84;0
WireConnection;63;2;85;0
WireConnection;69;0;59;0
WireConnection;118;0;99;1
WireConnection;117;0;99;1
WireConnection;82;1;246;0
WireConnection;223;0;222;1
WireConnection;223;1;222;0
WireConnection;110;0;109;0
WireConnection;56;0;49;0
WireConnection;56;1;59;0
WireConnection;50;0;49;0
WireConnection;50;1;54;0
WireConnection;65;0;69;0
WireConnection;65;1;82;0
WireConnection;65;2;83;0
WireConnection;120;0;117;0
WireConnection;120;1;118;0
WireConnection;79;0;63;0
WireConnection;225;0;223;0
WireConnection;115;0;114;0
WireConnection;116;0;114;0
WireConnection;111;0;110;0
WireConnection;105;0;99;1
WireConnection;66;0;56;4
WireConnection;66;1;65;0
WireConnection;125;0;105;0
WireConnection;125;1;120;0
WireConnection;61;0;79;0
WireConnection;61;1;50;4
WireConnection;127;0;128;0
WireConnection;126;0;111;0
WireConnection;227;0;249;0
WireConnection;227;1;245;0
WireConnection;113;0;111;0
WireConnection;113;1;115;0
WireConnection;113;2;116;0
WireConnection;226;0;225;0
WireConnection;226;1;224;0
WireConnection;228;0;249;0
WireConnection;228;1;245;0
WireConnection;6;0;219;0
WireConnection;6;2;127;0
WireConnection;129;0;126;0
WireConnection;57;0;61;0
WireConnection;57;1;66;0
WireConnection;240;0;226;0
WireConnection;240;1;227;0
WireConnection;240;2;228;0
WireConnection;123;0;105;0
WireConnection;123;1;125;0
WireConnection;123;2;113;0
WireConnection;143;0;144;0
WireConnection;132;0;131;0
WireConnection;130;0;57;0
WireConnection;130;1;129;0
WireConnection;96;0;240;0
WireConnection;96;1;123;0
WireConnection;5;0;4;0
WireConnection;5;1;6;0
WireConnection;145;0;120;0
WireConnection;145;1;113;0
WireConnection;106;0;130;0
WireConnection;106;1;240;0
WireConnection;44;0;5;1
WireConnection;44;1;5;4
WireConnection;44;2;96;0
WireConnection;142;0;132;0
WireConnection;142;1;143;0
WireConnection;142;2;145;0
WireConnection;134;0;135;0
WireConnection;141;0;142;0
WireConnection;141;1;134;0
WireConnection;141;2;130;0
WireConnection;71;0;44;0
WireConnection;71;1;106;0
WireConnection;0;2;141;0
WireConnection;0;3;71;0
ASEEND*/
//CHKSM=6C403B710CFB14A3148AE32E8BBD04F3F39CEE4E