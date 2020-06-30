// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/LWRP/Particles/Ghost Fire"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HDR]_ColorUp("ColorUp", Color) = (0.8156863,0,8,1)
		[HDR]_ColorDown("ColorDown", Color) = (0,0.5337852,1.071773,1)
		[HDR]_ColorCenter("ColorCenter", Color) = (0,0.1782091,0.5188679,1)
		_MaxBrightness("Max Brightness", Float) = 1
		_MainTex("MainTex", 2D) = "white" {}
		_Speed("Speed", Float) = 1
		_RefractionIntensity("Refraction Intensity", Range( 0 , 0.5)) = 0.438
		_Clip("Clip", Range( 0 , 1)) = 0.15
		_EdgeBlur("EdgeBlur", Range( 0 , 0.2)) = 0.05
		_VertexIntensity("Vertex Intensity", Range( 0 , 1)) = 0
		_RefractionRange("Refraction Range", Vector) = (0.17,0.79,0,0)
		_CullOfBottom("Cull Of Bottom", Range( 0 , 1)) = 0.263
		_Soft("Soft", Range( 0 , 5)) = 0.5

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
			
			Blend SrcAlpha One
			ZWrite Off
			ZTest Less
			Offset 0 , 0
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

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION


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
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex;
			uniform float4 _CameraDepthTexture_TexelSize;
			CBUFFER_START( UnityPerMaterial )
			float _VertexIntensity;
			float _RefractionIntensity;
			float4 _RefractionRange;
			float _Speed;
			float4 _ColorCenter;
			float4 _ColorDown;
			float4 _ColorUp;
			float _Clip;
			float _EdgeBlur;
			float4 _MainTex_ST;
			float _CullOfBottom;
			float _MaxBrightness;
			float _Soft;
			CBUFFER_END


			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float cos317 = cos( ( -0.5 * PI ) );
				float sin317 = sin( ( -0.5 * PI ) );
				float2 rotator317 = mul( v.ase_texcoord.xy - float2( 0.5,0.5 ) , float2x2( cos317 , -sin317 , sin317 , cos317 )) + float2( 0.5,0.5 );
				float2 baseUV319 = rotator317;
				float2 break323 = baseUV319;
				float mulTime239 = _TimeParameters.x * _Speed;
				float2 panner236 = ( mulTime239 * float2( 0,-0.9913 ) + baseUV319);
				float2 panner237 = ( mulTime239 * float2( 0.217,-0.799641 ) + baseUV319);
				float smoothstepResult243 = smoothstep( _RefractionRange.x , _RefractionRange.y , max( tex2Dlod( _MainTex, float4( frac( panner236 ), 0, 0.0) ).b , tex2Dlod( _MainTex, float4( frac( panner237 ), 0, 0.0) ).b ));
				float temp_output_253_0 = ( smoothstepResult243 * _RefractionIntensity );
				float temp_output_256_0 = saturate( ( ( break323.y - min( 0.4 , _RefractionIntensity ) ) + temp_output_253_0 ) );
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( v.ase_normal * _VertexIntensity * temp_output_256_0 );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float cos317 = cos( ( -0.5 * PI ) );
				float sin317 = sin( ( -0.5 * PI ) );
				float2 rotator317 = mul( IN.ase_texcoord3.xy - float2( 0.5,0.5 ) , float2x2( cos317 , -sin317 , sin317 , cos317 )) + float2( 0.5,0.5 );
				float2 baseUV319 = rotator317;
				float4 lerpResult292 = lerp( _ColorDown , _ColorUp , baseUV319.y);
				float2 break323 = baseUV319;
				float mulTime239 = _TimeParameters.x * _Speed;
				float2 panner236 = ( mulTime239 * float2( 0,-0.9913 ) + baseUV319);
				float2 panner237 = ( mulTime239 * float2( 0.217,-0.799641 ) + baseUV319);
				float smoothstepResult243 = smoothstep( _RefractionRange.x , _RefractionRange.y , max( tex2D( _MainTex, frac( panner236 ) ).b , tex2D( _MainTex, frac( panner237 ) ).b ));
				float temp_output_253_0 = ( smoothstepResult243 * _RefractionIntensity );
				float temp_output_256_0 = saturate( ( ( break323.y - min( 0.4 , _RefractionIntensity ) ) + temp_output_253_0 ) );
				float2 appendResult246 = (float2(break323.x , ( temp_output_256_0 + _RefractionRange.z )));
				float2 fireUV248 = appendResult246;
				float4 tex2DNode247 = tex2D( _MainTex, ( ( fireUV248 * _MainTex_ST.xy ) + _MainTex_ST.zw ) );
				float smoothstepResult305 = smoothstep( 0.0 , _CullOfBottom , break323.y);
				float smoothstepResult340 = smoothstep( 0.7 , 1.0 , ( 1.0 - baseUV319.y ));
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float fresnelNdotV326 = dot( ( ase_worldNormal * float3( -1,-1,-1 ) ), ase_worldViewDir );
				float fresnelNode326 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV326, 1.0 ) );
				float smoothstepResult331 = smoothstep( 0.0 , 1.0 , ( 1.0 - saturate( fresnelNode326 ) ));
				float temp_output_311_0 = ( (tex2DNode247).g * saturate( ( ( smoothstepResult305 - min( _CullOfBottom , 0.4 ) ) + temp_output_253_0 ) ) * max( ( ( fireUV248.y + smoothstepResult340 ) * smoothstepResult340 ) , smoothstepResult331 ) );
				float smoothstepResult270 = smoothstep( ( _Clip - _EdgeBlur ) , ( _Clip + _EdgeBlur ) , temp_output_311_0);
				float4 lerpResult290 = lerp( _ColorCenter , lerpResult292 , saturate( ( smoothstepResult270 - (tex2DNode247).r ) ));
				float3 appendResult356 = (float3(lerpResult290.rgb));
				float3 temp_cast_1 = (_MaxBrightness).xxx;
				float3 clampResult357 = clamp( appendResult356 , float3( 0,0,0 ) , temp_cast_1 );
				
				clip( temp_output_311_0 - _Clip);
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth350 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth350 = abs( ( screenDepth350 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Soft ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = clampResult357;
				float Alpha = ( temp_output_311_0 * smoothstepResult270 * saturate( distanceDepth350 ) );
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
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
0;37;1421;717;-1854.983;917.8199;1.763909;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;235;1152,-640;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;318;1152,-512;Inherit;False;1;0;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;317;1408,-640;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;319;1664,-640;Inherit;False;baseUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;238;1536,-256;Inherit;False;Property;_Speed;Speed;5;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;321;1664,-384;Inherit;False;319;baseUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;239;1664,-256;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;236;1840,-384;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.9913;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;237;1840,-256;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.217,-0.799641;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;231;2048,-1024;Inherit;True;Property;_MainTex;MainTex;4;0;Create;True;0;0;False;0;65a8c5e7454b8fe45a5edf74bf690048;65a8c5e7454b8fe45a5edf74bf690048;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FractNode;255;2048,-256;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;254;2048,-384;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;233;2304,-384;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;234;2304,-176;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;252;2779.03,61.3887;Inherit;False;Property;_RefractionIntensity;Refraction Intensity;6;0;Create;True;0;0;False;0;0.438;1;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;263;2416,16;Inherit;False;Property;_RefractionRange;Refraction Range;10;0;Create;True;0;0;False;0;0.17,0.79,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;242;2608,-256;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;322;2176,-768;Inherit;False;319;baseUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;285;2697.556,-391.0848;Inherit;False;Constant;_subVal;subVal;7;0;Create;True;0;0;False;0;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;243;2816,-256;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.79;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;323;2336,-768;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMinOpNode;286;2880,-416;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;253;3072,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;284;2992,-416;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;245;3184,-480;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;256;3392,-480;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;359;3558.919,-436.2728;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;329;1840,-1792;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;338;2285.585,-2084.95;Inherit;False;319;baseUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;246;3747.295,-473.2753;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;248;3824,-544;Inherit;False;fireUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;330;2048,-1792;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,-1,-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;337;2440,-2085;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;344;2288,-2240;Inherit;False;248;fireUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;326;2224,-1792;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;339;2656,-2080;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;299;1842.7,-1293.1;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RangedFloatNode;306;2304,-496;Inherit;False;Property;_CullOfBottom;Cull Of Bottom;11;0;Create;True;0;0;False;0;0.263;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;249;1874.7,-1405.1;Inherit;False;248;fireUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;340;2848,-2080;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.7;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;300;2034.7,-1405.1;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;345;2448,-2240;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMinOpNode;308;2880,-560;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;328;2480,-1792;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;305;2534.924,-662.6226;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;347;2848,-2320;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;301;2178.7,-1405.1;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;327;2656,-1792;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;309;3008,-560;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;349;3119.619,-2111.732;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;247;2688,-1408;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;331;2816,-1792;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;304;3184,-704;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;310;3392,-704;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;341;3100.136,-1716.331;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;251;3008,-1200;Inherit;True;False;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;267;2821.616,-849.0342;Inherit;False;Property;_Clip;Clip;7;0;Create;True;0;0;False;0;0.15;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;273;2822.262,-765.5972;Inherit;False;Property;_EdgeBlur;EdgeBlur;8;0;Create;True;0;0;False;0;0.05;1;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;311;3362.134,-1180.382;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;272;3110.262,-893.5972;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;271;3110.262,-989.597;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;250;3008,-1408;Inherit;True;True;False;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;270;3572.15,-985.7557;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;324;3348.947,-2166.478;Inherit;False;319;baseUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;294;3552,-1728;Inherit;False;Property;_ColorDown;ColorDown;1;1;[HDR];Create;True;0;0;False;0;0,0.5337852,1.071773,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;288;3718.965,-1293.854;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;325;3508.947,-2166.478;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ColorNode;269;3544.7,-1906.9;Inherit;False;Property;_ColorUp;ColorUp;0;1;[HDR];Create;True;0;0;False;0;0.8156863,0,8,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;355;3957.314,-1322.432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;289;3712,-1520;Inherit;False;Property;_ColorCenter;ColorCenter;2;1;[HDR];Create;True;0;0;False;0;0,0.1782091,0.5188679,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;292;3808.795,-1822.17;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;352;3933.037,-427.6794;Inherit;False;Property;_Soft;Soft;12;0;Create;True;0;0;False;0;0.5;0.2;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;350;4161.394,-594.2855;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;290;4136.64,-1557.895;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode;297;4001.691,-954.5571;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;358;4401.457,-1269.446;Inherit;False;Property;_MaxBrightness;Max Brightness;3;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;356;4413.457,-1434.446;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;296;3909.119,-812.7612;Inherit;False;Property;_VertexIntensity;Vertex Intensity;9;0;Create;True;0;0;False;0;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;351;4395.862,-585.0604;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;312;4007.322,-1184.256;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;357;4568.457,-1391.446;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;4301.873,-929.1918;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;313;4294.179,-1163.755;Inherit;False;3;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;335;2672.121,-1145.592;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;4726.9,-1241.635;Half;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;ZDShader/LWRP/Particles/Ghost Fire;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;8;5;False;-1;1;False;-1;0;5;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;1;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;0;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;False;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;353;4726.9,-1241.635;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;317;0;235;0
WireConnection;317;2;318;0
WireConnection;319;0;317;0
WireConnection;239;0;238;0
WireConnection;236;0;321;0
WireConnection;236;1;239;0
WireConnection;237;0;321;0
WireConnection;237;1;239;0
WireConnection;255;0;237;0
WireConnection;254;0;236;0
WireConnection;233;0;231;0
WireConnection;233;1;254;0
WireConnection;234;0;231;0
WireConnection;234;1;255;0
WireConnection;242;0;233;3
WireConnection;242;1;234;3
WireConnection;243;0;242;0
WireConnection;243;1;263;1
WireConnection;243;2;263;2
WireConnection;323;0;322;0
WireConnection;286;0;285;0
WireConnection;286;1;252;0
WireConnection;253;0;243;0
WireConnection;253;1;252;0
WireConnection;284;0;323;1
WireConnection;284;1;286;0
WireConnection;245;0;284;0
WireConnection;245;1;253;0
WireConnection;256;0;245;0
WireConnection;359;0;256;0
WireConnection;359;1;263;3
WireConnection;246;0;323;0
WireConnection;246;1;359;0
WireConnection;248;0;246;0
WireConnection;330;0;329;0
WireConnection;337;0;338;0
WireConnection;326;0;330;0
WireConnection;339;0;337;1
WireConnection;299;0;231;0
WireConnection;340;0;339;0
WireConnection;300;0;249;0
WireConnection;300;1;299;0
WireConnection;345;0;344;0
WireConnection;308;0;306;0
WireConnection;308;1;285;0
WireConnection;328;0;326;0
WireConnection;305;0;323;1
WireConnection;305;2;306;0
WireConnection;347;0;345;1
WireConnection;347;1;340;0
WireConnection;301;0;300;0
WireConnection;301;1;299;1
WireConnection;327;0;328;0
WireConnection;309;0;305;0
WireConnection;309;1;308;0
WireConnection;349;0;347;0
WireConnection;349;1;340;0
WireConnection;247;0;231;0
WireConnection;247;1;301;0
WireConnection;331;0;327;0
WireConnection;304;0;309;0
WireConnection;304;1;253;0
WireConnection;310;0;304;0
WireConnection;341;0;349;0
WireConnection;341;1;331;0
WireConnection;251;0;247;0
WireConnection;311;0;251;0
WireConnection;311;1;310;0
WireConnection;311;2;341;0
WireConnection;272;0;267;0
WireConnection;272;1;273;0
WireConnection;271;0;267;0
WireConnection;271;1;273;0
WireConnection;250;0;247;0
WireConnection;270;0;311;0
WireConnection;270;1;271;0
WireConnection;270;2;272;0
WireConnection;288;0;270;0
WireConnection;288;1;250;0
WireConnection;325;0;324;0
WireConnection;355;0;288;0
WireConnection;292;0;294;0
WireConnection;292;1;269;0
WireConnection;292;2;325;1
WireConnection;350;0;352;0
WireConnection;290;0;289;0
WireConnection;290;1;292;0
WireConnection;290;2;355;0
WireConnection;356;0;290;0
WireConnection;351;0;350;0
WireConnection;312;0;311;0
WireConnection;312;1;311;0
WireConnection;312;2;267;0
WireConnection;357;0;356;0
WireConnection;357;2;358;0
WireConnection;298;0;297;0
WireConnection;298;1;296;0
WireConnection;298;2;256;0
WireConnection;313;0;312;0
WireConnection;313;1;270;0
WireConnection;313;2;351;0
WireConnection;335;0;305;0
WireConnection;0;2;357;0
WireConnection;0;3;313;0
WireConnection;0;5;298;0
ASEEND*/
//CHKSM=B90B36A889997BF22B55370BC0CC4AD1AF0F7B5D