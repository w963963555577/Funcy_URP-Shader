// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/LWRP/Environment/ToonWater3"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_WaveScale("WaveScale (1=1 meter)", Float) = 2.46
		_Color("BaseColor", Color) = (0.2741634,0.6843107,0.9528302,1)
		_DarkColor("DarkColor", Color) = (0.2336241,0.350327,0.4716981,1)
		[NoScaleOffset][Normal]_BumpMap("BumpMap", 2D) = "bump" {}
		_BumpScale("BumpScale", Float) = 1
		[HDR]_SpecularColor("SpecularColor", Color) = (0.4289338,0.5943396,0.5137573,1)
		_Specular("Specular", Range( 0 , 1)) = 0.033
		_Gloss("Gloss", Range( 2 , 10)) = 2
		_WaveSpeed("Wave1_Speed", Range( 0.01 , 2.5)) = 0.5
		_WaveSpeed1("Wave2_Speed", Range( 0.01 , 2.5)) = 0.5
		_WaterDepth("WaterDepth", Float) = 5
		_WaterDepthHardness("Water Depth Hardness", Range( 0 , 1)) = 0.18

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Back
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL

		
		Pass
		{
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend DstColor Zero , One Zero
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
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

			

			sampler2D _BumpMap;
			uniform float4 _CameraDepthTexture_TexelSize;
			CBUFFER_START( UnityPerMaterial )
			float4 _DarkColor;
			float4 _Color;
			float _WaveSpeed;
			float _WaveScale;
			float _BumpScale;
			float _WaveSpeed1;
			float4 _SpecularColor;
			float _Specular;
			float _Gloss;
			float _WaterDepth;
			float _WaterDepthHardness;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_tangent : TANGENT;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			float3 TransformObjectToWorldDir291( float3 vec )
			{
				return TransformObjectToWorldDir(vec.xyz) ;
			}
			
			float3 TransformObjectToWorldNormal283( float3 Normal )
			{
				return TransformObjectToWorldNormal(Normal.xyz) ;
			}
			
			float3 TransformTangentToWorld286( float4 norm , float3x3 TBN )
			{
				return TransformTangentToWorld(norm.xyz,TBN) ;
			}
			

			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				o.ase_texcoord1.xyz = ase_worldPos;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				o.ase_texcoord1.w = ase_vertexTangentSign;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_tangent = v.ase_tangent;
				o.ase_normal = v.ase_normal;
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

				float3 ase_worldPos = IN.ase_texcoord1.xyz;
				float2 temp_output_44_0 = ( (( ase_worldPos - (mul( GetObjectToWorldMatrix(), float4(0,0,0,1) )).xyz )).xz / _WaveScale );
				float2 panner47 = ( 0.8146841 * _Time.y * ( float2( 0.707,0.707 ) * _WaveSpeed ) + temp_output_44_0);
				float2 panner48 = ( 0.5134327 * _Time.y * ( _WaveSpeed1 * float2( 0.9513,-0.1 ) ) + ( temp_output_44_0 * float2( 1.414,1.414 ) ));
				float3 appendResult365 = (float3(min( (( UnpackNormalScale( tex2D( _BumpMap, panner47 ), _BumpScale ) + ( UnpackNormalScale( tex2D( _BumpMap, panner48 ), _BumpScale ) * float3( 0.8,0.8,0.8 ) ) )).xy , (( UnpackNormalScale( tex2D( _BumpMap, panner47 ), _BumpScale ) - UnpackNormalScale( tex2D( _BumpMap, panner48 ), _BumpScale ) )).xy ) , 0.0));
				float4 norm286 = float4( appendResult365 , 0.0 );
				float3 vec291 = IN.ase_tangent.xyz;
				float3 localTransformObjectToWorldDir291 = TransformObjectToWorldDir291( vec291 );
				float3 Normal283 = IN.ase_normal;
				float3 localTransformObjectToWorldNormal283 = TransformObjectToWorldNormal283( Normal283 );
				float ase_vertexTangentSign = IN.ase_texcoord1.w;
				float3 normalizeResult293 = normalize( ( cross( localTransformObjectToWorldNormal283 , localTransformObjectToWorldDir291 ) * ase_vertexTangentSign ) );
				float3x3 TBN286 = float3x3(localTransformObjectToWorldDir291, normalizeResult293, localTransformObjectToWorldNormal283);
				float3 localTransformTangentToWorld286 = TransformTangentToWorld286( norm286 , TBN286 );
				float3 trueNormal103 = saturate( localTransformTangentToWorld286 );
				float dotResult352 = dot( trueNormal103 , float3(0.3,0,0.5) );
				float temp_output_159_0 = saturate( dotResult352 );
				float4 lerpResult160 = lerp( _DarkColor , _Color , temp_output_159_0);
				float saferPower351 = max( temp_output_159_0 , 0.0001 );
				
				float4 screenPos = IN.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth98 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth98 = saturate( ( screenDepth98 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _WaterDepth ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( lerpResult160 + ( _SpecularColor * _Specular * pow( saferPower351 , _Gloss ) ) ).rgb;
				float Alpha = ( (lerpResult160).a * saturate( ( 1.0 - pow( ( 1.0 - distanceDepth98 ) , (1.0 + (_WaterDepthHardness - 0.0) * (50.0 - 1.0) / (1.0 - 0.0)) ) ) ) );
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

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define ASE_SRP_VERSION 70201
			#define REQUIRE_DEPTH_TEXTURE 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			sampler2D _BumpMap;
			uniform float4 _CameraDepthTexture_TexelSize;
			CBUFFER_START( UnityPerMaterial )
			float4 _DarkColor;
			float4 _Color;
			float _WaveSpeed;
			float _WaveScale;
			float _BumpScale;
			float _WaveSpeed1;
			float4 _SpecularColor;
			float _Specular;
			float _Gloss;
			float _WaterDepth;
			float _WaterDepthHardness;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			float3 TransformObjectToWorldDir291( float3 vec )
			{
				return TransformObjectToWorldDir(vec.xyz) ;
			}
			
			float3 TransformObjectToWorldNormal283( float3 Normal )
			{
				return TransformObjectToWorldNormal(Normal.xyz) ;
			}
			
			float3 TransformTangentToWorld286( float4 norm , float3x3 TBN )
			{
				return TransformTangentToWorld(norm.xyz,TBN) ;
			}
			

			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				o.ase_texcoord.xyz = ase_worldPos;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				o.ase_texcoord.w = ase_vertexTangentSign;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
				o.ase_tangent = v.ase_tangent;
				o.ase_normal = v.ase_normal;
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

				o.clipPos = TransformObjectToHClip(v.vertex.xyz);
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float3 ase_worldPos = IN.ase_texcoord.xyz;
				float2 temp_output_44_0 = ( (( ase_worldPos - (mul( GetObjectToWorldMatrix(), float4(0,0,0,1) )).xyz )).xz / _WaveScale );
				float2 panner47 = ( 0.8146841 * _Time.y * ( float2( 0.707,0.707 ) * _WaveSpeed ) + temp_output_44_0);
				float2 panner48 = ( 0.5134327 * _Time.y * ( _WaveSpeed1 * float2( 0.9513,-0.1 ) ) + ( temp_output_44_0 * float2( 1.414,1.414 ) ));
				float3 appendResult365 = (float3(min( (( UnpackNormalScale( tex2D( _BumpMap, panner47 ), _BumpScale ) + ( UnpackNormalScale( tex2D( _BumpMap, panner48 ), _BumpScale ) * float3( 0.8,0.8,0.8 ) ) )).xy , (( UnpackNormalScale( tex2D( _BumpMap, panner47 ), _BumpScale ) - UnpackNormalScale( tex2D( _BumpMap, panner48 ), _BumpScale ) )).xy ) , 0.0));
				float4 norm286 = float4( appendResult365 , 0.0 );
				float3 vec291 = IN.ase_tangent.xyz;
				float3 localTransformObjectToWorldDir291 = TransformObjectToWorldDir291( vec291 );
				float3 Normal283 = IN.ase_normal;
				float3 localTransformObjectToWorldNormal283 = TransformObjectToWorldNormal283( Normal283 );
				float ase_vertexTangentSign = IN.ase_texcoord.w;
				float3 normalizeResult293 = normalize( ( cross( localTransformObjectToWorldNormal283 , localTransformObjectToWorldDir291 ) * ase_vertexTangentSign ) );
				float3x3 TBN286 = float3x3(localTransformObjectToWorldDir291, normalizeResult293, localTransformObjectToWorldNormal283);
				float3 localTransformTangentToWorld286 = TransformTangentToWorld286( norm286 , TBN286 );
				float3 trueNormal103 = saturate( localTransformTangentToWorld286 );
				float dotResult352 = dot( trueNormal103 , float3(0.3,0,0.5) );
				float temp_output_159_0 = saturate( dotResult352 );
				float4 lerpResult160 = lerp( _DarkColor , _Color , temp_output_159_0);
				float4 screenPos = IN.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth98 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth98 = saturate( ( screenDepth98 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _WaterDepth ) );
				
				float Alpha = ( (lerpResult160).a * saturate( ( 1.0 - pow( ( 1.0 - distanceDepth98 ) , (1.0 + (_WaterDepthHardness - 0.0) * (50.0 - 1.0) / (1.0 - 0.0)) ) ) ) );
				float AlphaClipThreshold = 0.5;

				#if _AlphaClip
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
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
Version=17800
0;12;1440;837;-137.337;2220.418;1;True;False
Node;AmplifyShaderEditor.Vector4Node;34;-4880,-560;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;33;-4912,-624;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-4704,-624;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;36;-4480,-864;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComponentMaskNode;37;-4480,-624;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;-4192,-752;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-4160,-1024;Inherit;False;Property;_WaveScale;WaveScale (1=1 meter);0;0;Create;False;0;0;False;0;2.46;2.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;42;-4016,-752;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;247;-4384,-208;Inherit;False;Property;_WaveSpeed1;Wave2_Speed;9;0;Create;False;0;0;False;0;0.5;2.5;0.01;2.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;44;-3824,-752;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;249;-4288,-80;Inherit;False;Constant;_Wave2_Vector;Wave2_Vector;7;0;Create;True;0;0;False;0;0.9513,-0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;40;-4384,-288;Inherit;False;Property;_WaveSpeed;Wave1_Speed;8;0;Create;False;0;0;False;0;0.5;2.5;0.01;2.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-3776,-608;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;1.414,1.414;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;41;-4240,-512;Inherit;False;Constant;_Wave1_Vector;Wave1_Vector;7;0;Create;True;0;0;False;0;0.707,0.707;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;250;-4064,-240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-4064,-384;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;14;-3616,-960;Inherit;True;Property;_BumpMap;BumpMap;3;2;[NoScaleOffset];[Normal];Create;False;0;0;False;0;fd3127269e9b67f44946c82f0323f8fb;fd3127269e9b67f44946c82f0323f8fb;True;bump;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;48;-3600,-576;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.9513,-0.1;False;1;FLOAT;0.5134327;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;47;-3600,-720;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.707,0.707;False;1;FLOAT;0.8146841;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-3024,-832;Inherit;False;Property;_BumpScale;BumpScale;4;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-3168,-528;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;280;-3055.938,-2160.736;Inherit;False;1410;969;true normal;12;297;295;293;292;291;290;288;287;286;284;283;281;CurrentNormal;1,1,1,1;0;0
Node;AmplifyShaderEditor.TangentVertexDataNode;287;-3007.938,-1856.735;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;284;-3007.938,-1536.735;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnpackScaleNormalNode;57;-2864,-528;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;49;-3168,-720;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;291;-2831.938,-1856.735;Inherit;False;return TransformObjectToWorldDir(vec.xyz) @;3;False;1;True;vec;FLOAT3;0,0,0;In;;Float;False;TransformObjectToWorldDir;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-2624,-480;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.8,0.8,0.8;False;1;FLOAT3;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;28;-2864,-720;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CustomExpressionNode;283;-2831.938,-1536.735;Inherit;False;return TransformObjectToWorldNormal(Normal.xyz) @;3;False;1;True;Normal;FLOAT3;0,0,0;In;;Float;False;TransformObjectToWorldNormal;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;290;-2767.938,-1696.735;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TangentSignVertexDataNode;297;-2815.938,-1776.735;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;299;-2442.718,-410.9321;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-2482,-717;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;288;-2607.938,-1696.735;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;300;-2279,-411;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;366;-2256,-720;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMinOpNode;375;-2042.411,-579.9282;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;293;-2479.938,-1696.735;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;365;-1863.4,-806;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.MatrixFromVectors;281;-2303.938,-1728.735;Inherit;False;FLOAT3x3;True;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.CustomExpressionNode;286;-2000,-1312;Inherit;False;return TransformTangentToWorld(norm.xyz,TBN) @;3;False;2;True;norm;FLOAT4;0,0,0,0;In;;Float;False;True;TBN;FLOAT3x3;1,0,0,1,1,1,1,0,1;In;;Float;False;TransformTangentToWorld;True;False;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3x3;1,0,0,1,1,1,1,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;360;-1792,-704;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;99;512,-768;Inherit;False;Property;_WaterDepth;WaterDepth;12;0;Create;True;0;0;False;0;5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;-1667.559,-710.2992;Inherit;False;trueNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;772.8157,-1995.16;Inherit;False;103;trueNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;58;512,-640;Inherit;False;Property;_WaterDepthHardness;Water Depth Hardness;13;0;Create;True;0;0;False;0;0.18;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;98;656,-768;Inherit;False;True;True;False;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;376;751.337,-1870.418;Inherit;False;Constant;_lightConstDir;lightConstDir;14;0;Create;True;0;0;False;0;0.3,0,0.5;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TFHCRemapNode;93;784,-640;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;50;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;167;896,-768;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;352;1091.209,-1930.795;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;166;1056,-768;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;161;1088,-2256;Inherit;False;Property;_DarkColor;DarkColor;2;0;Create;True;0;0;False;0;0.2336241,0.350327,0.4716981,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;159;1333.803,-2019.702;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;106;1091.94,-2430.756;Inherit;False;Property;_Color;BaseColor;1;0;Create;False;0;0;False;0;0.2741634,0.6843107,0.9528302,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;168;1280,-768;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;160;1562.214,-2196.294;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;100;1700.028,-818.1801;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;350;1773.813,-1766.425;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;239;2192,512;Inherit;False;Property;_ReflectionIntensity;Reflection Intensity;10;0;Create;True;0;0;False;0;1;0.143;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;227;2137.928,423.8045;Inherit;False;False;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;292;-2831.938,-1376.735;Inherit;False;return TransformObjectToWorld(vec.xyz) @;3;False;1;True;vec;FLOAT3;0,0,0;In;;Float;False;TransformObjectToWorld;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldReflectionVector;219;1584,480;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComponentMaskNode;255;-480,-1712;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;1954.358,-1548.675;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;126;1501.955,-1212.171;Inherit;False;Property;_Specular;Specular;6;0;Create;True;0;0;False;0;0.033;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;325;2560,400;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;2432,-1088;Inherit;False;103;trueNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;258;1593.927,679.8046;Inherit;False;256;srcPos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;373;1456,-1552;Inherit;False;Property;_Gloss;Gloss;7;0;Create;True;0;0;False;0;2;0.5;2;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;329;1565.871,779.4569;Inherit;False;Property;_SampleDetensity;SampleDetensity;11;0;Create;True;0;0;False;0;0;0.143;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;222;1242.135,195.6056;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScreenColorNode;182;2153.928,231.8045;Inherit;False;Global;_GrabScreen1;Grab Screen 1;7;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;372;1960.422,-1360.943;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;351;1769.032,-1571.279;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;274;2334.863,429.2161;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;262;-816,-1712;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;238;768,-80;Inherit;False;103;trueNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;223;1249.404,397.5431;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;256;-288,-1712;Inherit;False;srcPos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;224;1561.09,276.4022;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;170;1896.117,333.2126;Inherit;False;return GetSSRUVZ( wldPos, NoV, wldRef, srcPos, sampleDetensity)@;3;False;5;False;wldPos;FLOAT3;0,0,0;In;;Float;False;False;NoV;FLOAT;0;In;;Half;False;False;wldRef;FLOAT3;0,0,0;In;;Half;False;False;srcPos;FLOAT2;0,0;In;;Float;False;True;sampleDetensity;FLOAT;0.1;In;;Half;False;SSRUVZ;True;False;0;5;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT2;0,0;False;4;FLOAT;0.1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;246;1625.927,-104.1955;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;295;-3007.938,-1376.735;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;213;1368.797,-253.6123;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;263;-608,-1712;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;244;960,-64;Inherit;False;True;True;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;370;1277.608,-1796.108;Inherit;False;Half Lambert Term;-1;;17;86299dc21373a954aa5772333626c9c1;0;1;3;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;128;1501.955,-1404.171;Inherit;False;Property;_SpecularColor;SpecularColor;5;1;[HDR];Create;True;0;0;False;0;0.4289338,0.5943396,0.5137573,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;371;2179.13,-1807.34;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;363;2705.192,-1517.611;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;362;2705.192,-1517.611;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;361;2705.192,-1517.611;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;ZDShader/LWRP/Environment/ToonWater3;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;0;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;1;2;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;10;Surface;1;  Blend;3;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;1;Built-in Fog;1;Meta Pass;0;Vertex Position,InvertActionOnDeselection;1;0;4;True;False;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;364;2705.192,-1517.611;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;35;0;33;0
WireConnection;35;1;34;0
WireConnection;37;0;35;0
WireConnection;38;0;36;0
WireConnection;38;1;37;0
WireConnection;42;0;38;0
WireConnection;44;0;42;0
WireConnection;44;1;39;0
WireConnection;80;0;44;0
WireConnection;250;0;247;0
WireConnection;250;1;249;0
WireConnection;43;0;41;0
WireConnection;43;1;40;0
WireConnection;48;0;80;0
WireConnection;48;2;250;0
WireConnection;47;0;44;0
WireConnection;47;2;43;0
WireConnection;50;0;14;0
WireConnection;50;1;48;0
WireConnection;57;0;50;0
WireConnection;57;1;17;0
WireConnection;49;0;14;0
WireConnection;49;1;47;0
WireConnection;291;0;287;0
WireConnection;79;0;57;0
WireConnection;28;0;49;0
WireConnection;28;1;17;0
WireConnection;283;0;284;0
WireConnection;290;0;283;0
WireConnection;290;1;291;0
WireConnection;299;0;28;0
WireConnection;299;1;57;0
WireConnection;77;0;28;0
WireConnection;77;1;79;0
WireConnection;288;0;290;0
WireConnection;288;1;297;0
WireConnection;300;0;299;0
WireConnection;366;0;77;0
WireConnection;375;0;366;0
WireConnection;375;1;300;0
WireConnection;293;0;288;0
WireConnection;365;0;375;0
WireConnection;281;0;291;0
WireConnection;281;1;293;0
WireConnection;281;2;283;0
WireConnection;286;0;365;0
WireConnection;286;1;281;0
WireConnection;360;0;286;0
WireConnection;103;0;360;0
WireConnection;98;0;99;0
WireConnection;93;0;58;0
WireConnection;167;0;98;0
WireConnection;352;0;60;0
WireConnection;352;1;376;0
WireConnection;166;0;167;0
WireConnection;166;1;93;0
WireConnection;159;0;352;0
WireConnection;168;0;166;0
WireConnection;160;0;161;0
WireConnection;160;1;106;0
WireConnection;160;2;159;0
WireConnection;100;0;168;0
WireConnection;350;0;160;0
WireConnection;227;0;170;0
WireConnection;292;0;295;0
WireConnection;255;0;263;0
WireConnection;129;0;128;0
WireConnection;129;1;126;0
WireConnection;129;2;351;0
WireConnection;325;1;274;0
WireConnection;325;2;239;0
WireConnection;182;0;170;0
WireConnection;372;0;350;0
WireConnection;372;1;100;0
WireConnection;351;0;159;0
WireConnection;351;1;373;0
WireConnection;274;0;227;0
WireConnection;256;0;255;0
WireConnection;224;0;222;0
WireConnection;224;1;223;0
WireConnection;170;0;246;0
WireConnection;170;1;224;0
WireConnection;170;2;219;0
WireConnection;170;3;258;0
WireConnection;170;4;329;0
WireConnection;246;0;213;0
WireConnection;246;1;244;0
WireConnection;263;0;262;0
WireConnection;263;1;262;4
WireConnection;244;0;238;0
WireConnection;370;3;60;0
WireConnection;371;0;160;0
WireConnection;371;1;129;0
WireConnection;361;2;371;0
WireConnection;361;3;372;0
ASEEND*/
//CHKSM=CAE22A4D989461E20318B0EA5A46D5723D7B09C5