// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/URP/Particles/Custom Effects/Magic Circle_Practice"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HDR]_Color("Color", Color) = (1,0.5701252,0.1839623,1)
		_MainTex("MainTex", 2D) = "white" {}
		[HDR]_MagicArrowColor1("Color", Color) = (1,1,1,1)
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
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
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
			half4 _MagicArrowColor1;
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

				half3 appendResult442 = (half3(_Color.rgb));
				half3 appendResult440 = (half3(_EdgeColor.rgb));
				half2 currentUV358 = IN.ase_texcoord1.xy;
				half2 panner369 = ( 0.1 * _Time.y * float2( 0.137,-0.9951 ) + currentUV358);
				half2 panner447 = ( 0.1 * _Time.y * float2( -0.1231,-0.9113 ) + currentUV358);
				half temp_output_452_0 = min( tex2D( _NoiseMap, ( ( panner369 * _NoiseMap_ST.xy ) + _NoiseMap_ST.zw ) ).r , tex2D( _NoiseMap, ( ( panner447 * _NoiseMap_ST.xy ) + _NoiseMap_ST.zw ) ).r );
				half smoothstepResult396 = smoothstep( 0.45 , 0.55 , temp_output_452_0);
				half smoothstepResult393 = smoothstep( 0.55 , 0.65 , temp_output_452_0);
				half temp_output_406_0 = ( smoothstepResult396 - smoothstepResult393 );
				half temp_output_410_0 = saturate( length( ( ( float2( 0.5,0.5 ) - currentUV358 ) * float2( 2,2 ) ) ) );
				half smoothstepResult434 = smoothstep( ( _CenterSplit - 0.01 ) , ( _CenterSplit + 0.01 ) , temp_output_410_0);
				half3 lerpResult444 = lerp( appendResult442 , appendResult440 , ( temp_output_406_0 * smoothstepResult434 ));
				half3 appendResult436 = (half3(_MagicArrowColor1.rgb));
				half temp_output_354_0 = (0.0 + (_Angle - 0.0) * (1.0 - 0.0) / (360.0 - 0.0));
				half minmaxBlur372 = min( _Blur , ( 1.0 - ( abs( ( temp_output_354_0 - 0.5 ) ) * 2.0 ) ) );
				half angle366 = temp_output_354_0;
				float cos380 = cos( ( angle366 * PI ) );
				float sin380 = sin( ( angle366 * PI ) );
				half2 rotator380 = mul( currentUV358 - float2( 0.5,0.5 ) , float2x2( cos380 , -sin380 , sin380 , cos380 )) + float2( 0.5,0.5 );
				half smoothstepResult391 = smoothstep( ( 0.5 - minmaxBlur372 ) , ( 0.5 + minmaxBlur372 ) , rotator380.x);
				float cos390 = cos( ( ( angle366 * PI ) * -1.0 ) );
				float sin390 = sin( ( ( angle366 * PI ) * -1.0 ) );
				half2 rotator390 = mul( currentUV358 - float2( 0.5,0.5 ) , float2x2( cos390 , -sin390 , sin390 , cos390 )) + float2( 0.5,0.5 );
				half smoothstepResult403 = smoothstep( ( 0.5 - minmaxBlur372 ) , ( 0.5 + minmaxBlur372 ) , rotator390.x);
				half smoothstepResult418 = smoothstep( 0.05 , 0.1 , temp_output_410_0);
				half temp_output_437_0 = max( max( ( ( 1.0 - smoothstepResult391 ) * tex2D( _MagicArrowMap, rotator380 ).a ) , ( tex2D( _MagicArrowMap, rotator390 ).a * smoothstepResult403 ) ) , ( 1.0 - smoothstepResult418 ) );
				half3 lerpResult445 = lerp( lerpResult444 , appendResult436 , temp_output_437_0);
				
				half mulTime407 = _TimeParameters.x * 0.1;
				float cos421 = cos( ( mulTime407 * PI ) );
				float sin421 = sin( ( mulTime407 * PI ) );
				half2 rotator421 = mul( currentUV358 - float2( 0.5,0.5 ) , float2x2( cos421 , -sin421 , sin421 , cos421 )) + float2( 0.5,0.5 );
				half4 tex2DNode427 = tex2D( _MainTex, rotator421 );
				float cos371 = cos( ( -0.5 * PI ) );
				float sin371 = sin( ( -0.5 * PI ) );
				half2 rotator371 = mul( currentUV358 - float2( 0.5,0.5 ) , float2x2( cos371 , -sin371 , sin371 , cos371 )) + float2( 0.5,0.5 );
				half2 break386 = ( ( float2( 0.5,0.5 ) - rotator371 ) * float2( 2,2 ) );
				half smoothstepResult425 = smoothstep( ( angle366 - minmaxBlur372 ) , ( angle366 + minmaxBlur372 ) , ( abs( atan2( break386.y , break386.x ) ) / PI ));
				half smoothstepResult411 = smoothstep( 0.0 , 1.0 , temp_output_452_0);
				half lerpResult426 = lerp( smoothstepResult411 , max( smoothstepResult411 , temp_output_406_0 ) , smoothstepResult434);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult445;
				float Alpha = max( ( tex2DNode427.r * tex2DNode427.a * min( smoothstepResult425 , lerpResult426 ) ) , ( temp_output_437_0 * smoothstepResult425 ) );
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
20;25;1420;789;1229.525;360.1517;2.086804;True;False
Node;AmplifyShaderEditor.RangedFloatNode;353;-1037.324,84.5531;Inherit;False;Property;_Angle;Angle;6;0;Create;True;0;0;False;0;186.0151;360;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;354;-765.3236,84.5531;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;360;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;355;-589.3236,84.5531;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;356;-1677.324,-683.4469;Inherit;True;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;357;-445.3236,84.5531;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;358;-1469.324,-683.4469;Inherit;False;currentUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;359;-333.3236,84.5531;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;362;112,240;Inherit;True;Property;_NoiseMap;NoiseMap;5;0;Create;True;0;0;False;0;6a1fffff897d00e459ab3c9226cbedc6;6a1fffff897d00e459ab3c9226cbedc6;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;363;40.79262,765.5876;Inherit;False;358;currentUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;366;-566.3236,7.553101;Inherit;False;angle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;447;286.7399,655.1526;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.1231,-0.9113;False;1;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;369;100.3802,443.2863;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.137,-0.9951;False;1;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureTransformNode;368;176,560;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.PiNode;364;-1293.324,-555.4469;Inherit;False;1;0;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;361;-213.0236,254.8372;Inherit;False;Property;_Blur;Blur;8;0;Create;True;0;0;False;0;0.05;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;365;-1165.324,-427.4469;Inherit;False;358;currentUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;360;-205.3236,84.5531;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;371;-1037.324,-555.4469;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;367;-445.3236,-1067.447;Inherit;False;366;angle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;448;512,656;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;375;352,448;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMinOpNode;370;-45.32361,84.5531;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;372;66.67639,84.5531;Inherit;False;minmaxBlur;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;374;-827.2756,-565.4378;Inherit;True;2;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;378;480,448;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;376;-262.3656,-1074.08;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;450;640,656;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;-237.3236,-1259.447;Inherit;False;358;currentUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;385;752,245;Inherit;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;379;316.722,889.1721;Inherit;False;2;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;377;-619.2756,-565.4378;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;380;98.67639,-1387.447;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;381;578.6764,-971.4469;Inherit;False;372;minmaxBlur;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;382;-52.98059,-1064.452;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;446;752,437;Inherit;True;Property;_TextureSample4;Texture Sample 4;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMinOpNode;452;1045.405,261.725;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;384;460.722,889.1721;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;388;758.5718,-1266.848;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;390;98.67639,-1163.447;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;386;-427.2747,-565.4378;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;383;548.8676,-1476.506;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;389;758.5718,-1154.848;Inherit;False;2;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;387;466.6764,-667.4469;Inherit;False;372;minmaxBlur;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;395;658.6764,-843.4469;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;394;658.6764,-731.4469;Inherit;False;2;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;433;514.7602,1159.993;Inherit;False;Property;_CenterSplit;Center Split;7;0;Create;True;0;0;False;0;0.5411765;360;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;397;588.722,889.1721;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;396;1266.676,436.5531;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.45;False;2;FLOAT;0.55;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;399;98.67639,-1595.447;Inherit;True;Property;_MagicArrowMap;Magic Arrow Map;3;0;Create;True;0;0;False;0;594858368701aa048886de204e28d1ae;594858368701aa048886de204e28d1ae;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SmoothstepOpNode;391;820.1784,-1494.67;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.49;False;2;FLOAT;0.51;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;393;1266.676,564.5531;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.55;False;2;FLOAT;0.65;False;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;398;-203.2736,-565.4378;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;392;416.7717,-765.773;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleSubtractOpNode;406;1474.676,436.5531;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;400;1049.995,-1465.417;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;401;434.6764,-1163.447;Inherit;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;402;444.5013,-1359.097;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;403;867.3717,-816.8493;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.49;False;2;FLOAT;0.51;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;405;230.5602,-257.1721;Inherit;False;366;angle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;410;764.7221,889.1721;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;408;-27.27466,-341.4377;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;407;194.6764,-2139.447;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;432;819.1234,1114.816;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;431;819.1234,1226.816;Inherit;False;2;2;0;FLOAT;0.5;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;409;-11.27466,-565.4378;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;411;1282.676,196.5531;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;404;224.0131,-115.5245;Inherit;False;372;minmaxBlur;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;417;386.6764,-2123.447;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;418;1144.098,-830.1383;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.05;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;419;370.6764,-2219.447;Inherit;False;358;currentUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;420;418.0764,-240.4469;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;434;931.1234,890.8161;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;415;418.0764,-128.4469;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;414;1102.705,-1330.228;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;412;1090.676,-1115.447;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;416;148.726,-565.4378;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;413;1741.277,411.342;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;441;2111.929,-224.7733;Inherit;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;1,0.5701252,0.1839623,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;439;2114.835,-8.989868;Inherit;False;Property;_EdgeColor;EdgeColor;4;1;[HDR];Create;True;0;0;False;0;1,0.1142083,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;422;1335.82,-1219.078;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;421;626.6764,-2219.447;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;423;818.6764,-2219.447;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SmoothstepOpNode;425;421.2586,-560.5189;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;426;1778.676,100.5531;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;424;1394.883,-816.8279;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;443;2319.929,79.22705;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;428;1362.676,-571.4469;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;427;1042.676,-2219.447;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;437;2573.201,-1549.565;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;442;2303.929,-224.7733;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;440;2310.066,-12.0769;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;435;2369.299,-1712.909;Inherit;False;Property;_MagicArrowColor1;Color;2;1;[HDR];Create;False;0;0;False;0;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;430;1676.605,-1409.05;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;436;2564.53,-1715.996;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;429;1697.477,-1128.691;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;444;2527.929,-112.7733;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;445;2850.352,-1564.883;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;438;2186.938,-870.7267;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;3301.959,-1557.917;Half;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;Magic Circle_Practice;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;0;Forward;7;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;2;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;10;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Vertex Position,InvertActionOnDeselection;1;0;4;True;False;False;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;354;0;353;0
WireConnection;355;0;354;0
WireConnection;357;0;355;0
WireConnection;358;0;356;0
WireConnection;359;0;357;0
WireConnection;366;0;354;0
WireConnection;447;0;363;0
WireConnection;369;0;363;0
WireConnection;368;0;362;0
WireConnection;360;0;359;0
WireConnection;371;0;365;0
WireConnection;371;2;364;0
WireConnection;448;0;447;0
WireConnection;448;1;368;0
WireConnection;375;0;369;0
WireConnection;375;1;368;0
WireConnection;370;0;361;0
WireConnection;370;1;360;0
WireConnection;372;0;370;0
WireConnection;374;1;371;0
WireConnection;378;0;375;0
WireConnection;378;1;368;1
WireConnection;376;0;367;0
WireConnection;450;0;448;0
WireConnection;450;1;368;1
WireConnection;385;0;362;0
WireConnection;385;1;378;0
WireConnection;379;1;363;0
WireConnection;377;0;374;0
WireConnection;380;0;373;0
WireConnection;380;2;376;0
WireConnection;382;0;376;0
WireConnection;446;0;362;0
WireConnection;446;1;450;0
WireConnection;452;0;385;1
WireConnection;452;1;446;1
WireConnection;384;0;379;0
WireConnection;388;1;381;0
WireConnection;390;0;373;0
WireConnection;390;2;382;0
WireConnection;386;0;377;0
WireConnection;383;0;380;0
WireConnection;389;1;381;0
WireConnection;395;1;387;0
WireConnection;394;1;387;0
WireConnection;397;0;384;0
WireConnection;396;0;452;0
WireConnection;391;0;383;0
WireConnection;391;1;388;0
WireConnection;391;2;389;0
WireConnection;393;0;452;0
WireConnection;398;0;386;1
WireConnection;398;1;386;0
WireConnection;392;0;390;0
WireConnection;406;0;396;0
WireConnection;406;1;393;0
WireConnection;400;0;391;0
WireConnection;401;0;399;0
WireConnection;401;1;390;0
WireConnection;402;0;399;0
WireConnection;402;1;380;0
WireConnection;403;0;392;0
WireConnection;403;1;395;0
WireConnection;403;2;394;0
WireConnection;410;0;397;0
WireConnection;432;0;433;0
WireConnection;431;0;433;0
WireConnection;409;0;398;0
WireConnection;411;0;452;0
WireConnection;417;0;407;0
WireConnection;418;0;410;0
WireConnection;420;0;405;0
WireConnection;420;1;404;0
WireConnection;434;0;410;0
WireConnection;434;1;432;0
WireConnection;434;2;431;0
WireConnection;415;0;405;0
WireConnection;415;1;404;0
WireConnection;414;0;400;0
WireConnection;414;1;402;4
WireConnection;412;0;401;4
WireConnection;412;1;403;0
WireConnection;416;0;409;0
WireConnection;416;1;408;0
WireConnection;413;0;411;0
WireConnection;413;1;406;0
WireConnection;422;0;414;0
WireConnection;422;1;412;0
WireConnection;421;0;419;0
WireConnection;421;2;417;0
WireConnection;425;0;416;0
WireConnection;425;1;420;0
WireConnection;425;2;415;0
WireConnection;426;0;411;0
WireConnection;426;1;413;0
WireConnection;426;2;434;0
WireConnection;424;0;418;0
WireConnection;443;0;406;0
WireConnection;443;1;434;0
WireConnection;428;0;425;0
WireConnection;428;1;426;0
WireConnection;427;0;423;0
WireConnection;427;1;421;0
WireConnection;437;0;422;0
WireConnection;437;1;424;0
WireConnection;442;0;441;0
WireConnection;440;0;439;0
WireConnection;430;0;427;1
WireConnection;430;1;427;4
WireConnection;430;2;428;0
WireConnection;436;0;435;0
WireConnection;429;0;437;0
WireConnection;429;1;425;0
WireConnection;444;0;442;0
WireConnection;444;1;440;0
WireConnection;444;2;443;0
WireConnection;445;0;444;0
WireConnection;445;1;436;0
WireConnection;445;2;437;0
WireConnection;438;0;430;0
WireConnection;438;1;429;0
WireConnection;0;2;445;0
WireConnection;0;3;438;0
ASEEND*/
//CHKSM=8171677E0D59511979909D8298B0FBDA575CCB12