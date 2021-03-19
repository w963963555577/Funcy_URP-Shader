// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/URP/Environment/ToonWater2"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_WaveScale("WaveScale (1=1 meter)", Float) = 2.46
		_Shininess("Shininess", Range( 0.01 , 1)) = 0.1
		[HDR]_Color("BaseColor", Color) = (0.2741634,0.6843107,0.9528302,1)
		[HDR]_DarkColor("DarkColor", Color) = (0.2336241,0.350327,0.4716981,1)
		[NoScaleOffset][Normal]_BumpMap("BumpMap", 2D) = "bump" {}
		[NoScaleOffset]_RampMap("RampMap", 2D) = "white" {}
		_BumpScale("BumpScale", Float) = 1
		[HDR]_SpecularColor("SpecularColor", Color) = (0.4289338,0.5943396,0.5137573,1)
		_Specular("Specular", Range( 0 , 1)) = 0.033
		_WaveSpeed("Wave1_Speed", Range( 0.01 , 2.5)) = 0.5
		_WaveSpeed1("Wave2_Speed", Range( 0.01 , 2.5)) = 0.5
		_RefractionIntensity1("Refraction Intensity", Range( 0 , 1)) = 0.133
		_ReflectionIntensity("Reflection Intensity", Range( 0 , 2)) = 1
		_SampleDetensity("SampleDetensity", Range( 0 , 1)) = 0
		_WaterDepth("WaterDepth", Float) = 5
		_WaterDepthHardness("Water Depth Hardness", Range( 0 , 1)) = 0.18

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent-1" }
		
		Cull Back
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

			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#include "Packages/com.zd.lwrp.funcy/ShaderLibrary/SSR.hlsl"


			sampler2D _BumpMap;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _RampMap;
			CBUFFER_START( UnityPerMaterial )
			float _RefractionIntensity1;
			float _WaveSpeed;
			float _WaveScale;
			float _BumpScale;
			float _WaveSpeed1;
			float _WaterDepth;
			float _WaterDepthHardness;
			float4 _SpecularColor;
			float _Specular;
			float _Shininess;
			float4 _Color;
			float4 _DarkColor;
			float _SampleDetensity;
			float _ReflectionIntensity;
			CBUFFER_END


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
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
				float4 ase_tangent : TANGENT;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 lightmapUVOrVertexSH : TEXCOORD7;
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
			
			float3 ASEIndirectDiffuse( float2 uvStaticLightmap, float3 normalWS )
			{
			#ifdef LIGHTMAP_ON
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			
			float3 SSRUVZ170( float3 wldPos , half NoV , half3 wldRef , float2 srcPos , half sampleDetensity , sampler2D rampMap )
			{
				return GetSSRUVZ( wldPos, NoV, wldRef, srcPos, sampleDetensity,rampMap);
			}
			

			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				o.ase_texcoord2.xyz = ase_worldPos;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				o.ase_texcoord2.w = ase_vertexTangentSign;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				float4 ase_shadowCoords = TransformWorldToShadowCoord(ase_worldPos);
				o.ase_texcoord6 = ase_shadowCoords;
				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( ase_worldNormal, o.lightmapUVOrVertexSH.xyz );
				
				o.ase_tangent = v.ase_tangent;
				o.ase_normal = v.ase_normal;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
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
				float2 srcPos256 = (( screenPos / screenPos.w )).xy;
				float3 ase_worldPos = IN.ase_texcoord2.xyz;
				float2 temp_output_44_0 = ( (( ase_worldPos - (mul( GetObjectToWorldMatrix(), float4(0,0,0,1) )).xyz )).xz / _WaveScale );
				float2 panner47 = ( 0.8146841 * _Time.y * ( float2( 0.707,0.707 ) * _WaveSpeed ) + temp_output_44_0);
				float2 panner48 = ( 0.5134327 * _Time.y * ( _WaveSpeed1 * float2( 0.9513,-0.1 ) ) + ( temp_output_44_0 * float2( 1.41414,1.414141 ) ));
				float3 temp_output_350_0 = ( UnpackNormalScale( tex2D( _BumpMap, panner47 ), _BumpScale ) - UnpackNormalScale( tex2D( _BumpMap, panner48 ), _BumpScale ) );
				float2 trueRefraction298 = (temp_output_350_0).xy;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth98 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth98 = saturate( ( screenDepth98 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _WaterDepth ) );
				float temp_output_100_0 = saturate( ( 1.0 - pow( ( 1.0 - distanceDepth98 ) , (1.0 + (_WaterDepthHardness - 0.0) * (50.0 - 1.0) / (1.0 - 0.0)) ) ) );
				float4 fetchOpaqueVal94 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( ( srcPos256 + ( (0.0 + (_RefractionIntensity1 - 0.0) * (0.1 - 0.0) / (1.0 - 0.0)) * trueRefraction298 * temp_output_100_0 ) ) ), 1.0 );
				float3 appendResult95 = (float3(fetchOpaqueVal94.rgb));
				float4 temp_output_43_0_g15 = ( _SpecularColor * _Specular );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 normalizeResult4_g16 = normalize( ( ase_worldViewDir + _MainLightPosition.xyz ) );
				float3 appendResult355 = (float3(min( (( UnpackNormalScale( tex2D( _BumpMap, panner47 ), _BumpScale ) + ( UnpackNormalScale( tex2D( _BumpMap, panner48 ), _BumpScale ) * float3( 0.8,0.8,0.8 ) ) )).xy , (temp_output_350_0).xy ) , 0.5));
				float4 norm286 = float4( appendResult355 , 0.0 );
				float3 vec291 = IN.ase_tangent.xyz;
				float3 localTransformObjectToWorldDir291 = TransformObjectToWorldDir291( vec291 );
				float3 Normal283 = IN.ase_normal;
				float3 localTransformObjectToWorldNormal283 = TransformObjectToWorldNormal283( Normal283 );
				float ase_vertexTangentSign = IN.ase_texcoord2.w;
				float3 normalizeResult293 = normalize( ( cross( localTransformObjectToWorldNormal283 , localTransformObjectToWorldDir291 ) * ase_vertexTangentSign ) );
				float3x3 TBN286 = float3x3(localTransformObjectToWorldDir291, normalizeResult293, localTransformObjectToWorldNormal283);
				float3 localTransformTangentToWorld286 = TransformTangentToWorld286( norm286 , TBN286 );
				float3 trueNormal103 = localTransformTangentToWorld286;
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal12_g15 = trueNormal103;
				float3 worldNormal12_g15 = float3(dot(tanToWorld0,tanNormal12_g15), dot(tanToWorld1,tanNormal12_g15), dot(tanToWorld2,tanNormal12_g15));
				float3 normalizeResult64_g15 = normalize( worldNormal12_g15 );
				float dotResult19_g15 = dot( normalizeResult4_g16 , normalizeResult64_g15 );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) //la
				float4 ase_shadowCoords = IN.ase_texcoord6;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS) //la
				float4 ase_shadowCoords = TransformWorldToShadowCoord(ase_worldPos);
				#else //la
				float4 ase_shadowCoords = 0;
				#endif //la
				float ase_lightAtten = 0;
				Light ase_lightAtten_mainLight = GetMainLight( ase_shadowCoords );
				ase_lightAtten = ase_lightAtten_mainLight.distanceAttenuation * ase_lightAtten_mainLight.shadowAttenuation;
				float4 temp_output_40_0_g15 = ( _MainLightColor * ase_lightAtten );
				float dotResult14_g15 = dot( normalizeResult64_g15 , _MainLightPosition.xyz );
				float3 bakedGI34_g15 = ASEIndirectDiffuse( IN.lightmapUVOrVertexSH.xy, normalizeResult64_g15);
				float dotResult347 = dot( trueNormal103 , _MainLightPosition.xyz );
				float4 lerpResult160 = lerp( _Color , _DarkColor , saturate( dotResult347 ));
				half3 reflectVector331 = reflect( -ase_worldViewDir, trueNormal103 );
				float3 indirectSpecular331 = GlossyEnvironmentReflection( reflectVector331, 1.0 - 1.0, 1.0 );
				float4 temp_output_42_0_g15 = ( 1.0 - ( ( 1.0 - lerpResult160 ) * float4( ( 1.0 - indirectSpecular331 ) , 0.0 ) ) );
				float4 lerpResult163 = lerp( float4( ( appendResult95 + float3( 0,0,0 ) ) , 0.0 ) , ( ( float4( (temp_output_43_0_g15).rgb , 0.0 ) * (temp_output_43_0_g15).a * pow( max( dotResult19_g15 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g15 ) + ( ( ( temp_output_40_0_g15 * max( dotResult14_g15 , 0.0 ) ) + float4( bakedGI34_g15 , 0.0 ) ) * float4( (temp_output_42_0_g15).rgb , 0.0 ) ) ) , temp_output_100_0);
				float3 wldPos170 = ( ase_worldPos + (trueNormal103).xyz );
				float dotResult224 = dot( ase_worldNormal , ase_worldViewDir );
				float NoV170 = dotResult224;
				float3 ase_worldReflection = reflect(-ase_worldViewDir, ase_worldNormal);
				float3 wldRef170 = ase_worldReflection;
				float2 srcPos170 = srcPos256;
				float sampleDetensity170 = _SampleDetensity;
				sampler2D rampMap170 = _RampMap;
				float3 localSSRUVZ170 = SSRUVZ170( wldPos170 , NoV170 , wldRef170 , srcPos170 , sampleDetensity170 , rampMap170 );
				float4 fetchOpaqueVal182 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( localSSRUVZ170.xy ), 1.0 );
				float lerpResult325 = lerp( 0.0 , saturate( (localSSRUVZ170).z ) , _ReflectionIntensity);
				float4 lerpResult323 = lerp( lerpResult163 , fetchOpaqueVal182 , lerpResult325);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult323.rgb;
				float Alpha = 1;
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
114;27;1206;737;-2791.445;1396.128;1;True;False
Node;AmplifyShaderEditor.Vector4Node;34;-4880,-560;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;33;-4912,-624;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-4704,-624;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;37;-4480,-624;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;36;-4480,-864;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;-4192,-752;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;42;-4016,-752;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-4160,-1024;Inherit;False;Property;_WaveScale;WaveScale (1=1 meter);0;0;Create;False;0;0;False;0;2.46;2.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;247;-4384,-208;Inherit;False;Property;_WaveSpeed1;Wave2_Speed;14;0;Create;False;0;0;False;0;0.5;2.5;0.01;2.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;249;-4288,-80;Inherit;False;Constant;_Wave2_Vector;Wave2_Vector;7;0;Create;True;0;0;False;0;0.9513,-0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;44;-3824,-752;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;250;-4064,-240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;41;-4240,-512;Inherit;False;Constant;_Wave1_Vector;Wave1_Vector;7;0;Create;True;0;0;False;0;0.707,0.707;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;40;-4384,-288;Inherit;False;Property;_WaveSpeed;Wave1_Speed;13;0;Create;False;0;0;False;0;0.5;2.5;0.01;2.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-3747,-583;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;1.41414,1.414141;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;48;-3600,-576;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.9513,-0.1;False;1;FLOAT;0.5134327;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-4064,-384;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;14;-3568,-1136;Inherit;True;Property;_BumpMap;BumpMap;7;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;fd3127269e9b67f44946c82f0323f8fb;fd3127269e9b67f44946c82f0323f8fb;True;bump;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;50;-3168,-528;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-3024,-832;Inherit;False;Property;_BumpScale;BumpScale;9;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;47;-3600,-720;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.707,0.707;False;1;FLOAT;0.8146841;False;1;FLOAT2;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;57;-2864,-528;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TangentVertexDataNode;287;-3007.938,-1856.735;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;284;-3007.938,-1536.735;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;49;-3168,-720;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;283;-2831.938,-1536.735;Inherit;False;return TransformObjectToWorldNormal(Normal.xyz) @;3;False;1;True;Normal;FLOAT3;0,0,0;In;;Float;False;TransformObjectToWorldNormal;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;291;-2831.938,-1856.735;Inherit;False;return TransformObjectToWorldDir(vec.xyz) @;3;False;1;True;vec;FLOAT3;0,0,0;In;;Float;False;TransformObjectToWorldDir;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;349;-2633.096,-684.9884;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.8,0.8,0.8;False;1;FLOAT3;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;28;-2864,-720;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;351;-2483.296,-927.1884;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;290;-2767.938,-1696.735;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;350;-2444.014,-621.1204;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TangentSignVertexDataNode;297;-2815.938,-1776.735;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;352;-2280.296,-621.1884;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;288;-2607.938,-1696.735;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;353;-2257.296,-930.1884;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;293;-2479.938,-1696.735;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMinOpNode;354;-2043.706,-790.1166;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;99;512,-768;Inherit;False;Property;_WaterDepth;WaterDepth;18;0;Create;True;0;0;False;0;5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.MatrixFromVectors;281;-2303.938,-1728.735;Inherit;False;FLOAT3x3;True;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.DynamicAppendNode;355;-1947.32,-983.8416;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DepthFade;98;656,-768;Inherit;False;True;True;False;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;512,-640;Inherit;False;Property;_WaterDepthHardness;Water Depth Hardness;19;0;Create;True;0;0;False;0;0.18;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;286;-2000,-1312;Inherit;False;return TransformTangentToWorld(norm.xyz,TBN) @;3;False;2;True;norm;FLOAT4;0,0,0,0;In;;Float;False;True;TBN;FLOAT3x3;1,0,0,1,1,1,1,0,1;In;;Float;False;TransformTangentToWorld;True;False;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3x3;1,0,0,1,1,1,1,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;167;896,-768;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;-1667.559,-710.2992;Inherit;False;trueNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;262;-816,-1712;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;93;784,-640;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;50;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;166;1056,-768;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;682.6595,-1904.928;Inherit;False;103;trueNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;263;-608,-1712;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;348;681.1276,-1776.115;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComponentMaskNode;300;-2455.052,-489.4095;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;298;-2247.051,-489.4095;Inherit;False;trueRefraction;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;168;1280,-768;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-1376.215,-1328.653;Inherit;False;Property;_RefractionIntensity1;Refraction Intensity;15;0;Create;False;0;0;False;0;0.133;0.143;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;347;1160.412,-1991.056;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;255;-480,-1712;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;238;768,-80;Inherit;False;103;trueNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;161;1104,-2256;Inherit;False;Property;_DarkColor;DarkColor;6;1;[HDR];Create;True;0;0;False;0;0.2336241,0.350327,0.4716981,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;159;1423.792,-2037.981;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;106;1091.94,-2430.756;Inherit;False;Property;_Color;BaseColor;5;1;[HDR];Create;False;0;0;False;0;0.2741634,0.6843107,0.9528302,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;301;112,-1168;Inherit;False;298;trueRefraction;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;256;-288,-1712;Inherit;False;srcPos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;100;1700.028,-818.1801;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;140;128,-1360;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;222;1242.135,195.6056;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;160;1562.214,-2196.294;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.IndirectSpecularLight;331;1195.79,-1780.69;Inherit;False;World;3;0;FLOAT3;0,0,1;False;1;FLOAT;1;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;223;1249.404,397.5431;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;257;496,-1456;Inherit;False;256;srcPos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;464,-1312;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;213;1296,-208;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComponentMaskNode;244;960,-64;Inherit;False;True;True;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldReflectionVector;219;1584,480;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;246;1625.927,-104.1955;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;329;1504,768;Inherit;False;Property;_SampleDetensity;SampleDetensity;17;0;Create;True;0;0;False;0;0;0.143;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;341;1839.032,-2142.533;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;138;672.2671,-1453.347;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;258;1593.927,679.8046;Inherit;False;256;srcPos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;358;1820.082,753.7837;Inherit;True;Property;_RampMap;RampMap;8;1;[NoScaleOffset];Create;True;0;0;False;0;3361f6c526a5a3444b2ec765acadf995;fd3127269e9b67f44946c82f0323f8fb;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.OneMinusNode;342;1635.871,-1845.136;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;224;1561.09,276.4022;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;94;1008,-1297.55;Inherit;False;Global;_GrabScreen0;Grab Screen 0;7;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;128;1664,-640;Inherit;False;Property;_SpecularColor;SpecularColor;10;1;[HDR];Create;True;0;0;False;0;0.4289338,0.5943396,0.5137573,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;343;2038.521,-1945.492;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;170;1896.117,333.2126;Inherit;False;return GetSSRUVZ( wldPos, NoV, wldRef, srcPos, sampleDetensity,rampMap)@;3;False;6;False;wldPos;FLOAT3;0,0,0;In;;Float;False;False;NoV;FLOAT;0;In;;Half;False;False;wldRef;FLOAT3;0,0,0;In;;Half;False;False;srcPos;FLOAT2;0,0;In;;Float;False;True;sampleDetensity;FLOAT;0.1;In;;Half;False;True;rampMap;SAMPLER2D;;In;;Float;False;SSRUVZ;True;False;0;6;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT2;0,0;False;4;FLOAT;0.1;False;5;SAMPLER2D;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;126;1664,-448;Inherit;False;Property;_Specular;Specular;11;0;Create;True;0;0;False;0;0.033;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;227;2176,416;Inherit;False;False;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;2401.404,-958.5956;Inherit;False;103;trueNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;95;1238.147,-1254.291;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;1920,-640;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;344;2297.979,-1925.91;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;319;2654.265,-897.5372;Inherit;False;Blinn-Phong Light;1;;15;cf814dba44d007a4e958d2ddd5813da6;0;3;42;COLOR;0,0,0,0;False;52;FLOAT3;0,0,0;False;43;COLOR;0,0,0,0;False;2;COLOR;0;FLOAT;57
Node;AmplifyShaderEditor.SimpleAddOpNode;236;1496.632,-1162.539;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;274;2368,416;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;239;2192,512;Inherit;False;Property;_ReflectionIntensity;Reflection Intensity;16;0;Create;True;0;0;False;0;1;0.143;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;325;2512,416;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;182;2192.471,219.3713;Inherit;False;Global;_GrabScreen1;Grab Screen 1;7;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;163;2946,-1129;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;275;2176,-640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;323;3216,-983;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;295;-3007.938,-1376.735;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;292;-2831.938,-1376.735;Inherit;False;return TransformObjectToWorld(vec.xyz) @;3;False;1;True;vec;FLOAT3;0,0,0;In;;Float;False;TransformObjectToWorld;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;127;1664,-352;Inherit;False;Property;_Smoothness;Smoothness;12;0;Create;True;0;0;False;0;0.678;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;359;3404.445,-1162.128;Inherit;False;World;3;0;FLOAT3;0,0,1;False;1;FLOAT;1;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;308;3754.969,-962.66;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;ZDShader/LWRP/Environment/ToonWater2;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;0;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=-1;True;2;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;2;Include;;False;;Native;Include;;True;7751b70ff9f6a2643bedd1abfa1f0475;Custom;Hidden/InternalErrorShader;0;0;Standard;10;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Vertex Position,InvertActionOnDeselection;1;0;4;True;False;False;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;309;2720,-1232;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;310;2720,-1232;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;311;2720,-1232;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.CommentaryNode;280;-3055.938,-2160.736;Inherit;False;1410;969;true normal;0;CurrentNormal;1,1,1,1;0;0
WireConnection;35;0;33;0
WireConnection;35;1;34;0
WireConnection;37;0;35;0
WireConnection;38;0;36;0
WireConnection;38;1;37;0
WireConnection;42;0;38;0
WireConnection;44;0;42;0
WireConnection;44;1;39;0
WireConnection;250;0;247;0
WireConnection;250;1;249;0
WireConnection;80;0;44;0
WireConnection;48;0;80;0
WireConnection;48;2;250;0
WireConnection;43;0;41;0
WireConnection;43;1;40;0
WireConnection;50;0;14;0
WireConnection;50;1;48;0
WireConnection;47;0;44;0
WireConnection;47;2;43;0
WireConnection;57;0;50;0
WireConnection;57;1;17;0
WireConnection;49;0;14;0
WireConnection;49;1;47;0
WireConnection;283;0;284;0
WireConnection;291;0;287;0
WireConnection;349;0;57;0
WireConnection;28;0;49;0
WireConnection;28;1;17;0
WireConnection;351;0;28;0
WireConnection;351;1;349;0
WireConnection;290;0;283;0
WireConnection;290;1;291;0
WireConnection;350;0;28;0
WireConnection;350;1;57;0
WireConnection;352;0;350;0
WireConnection;288;0;290;0
WireConnection;288;1;297;0
WireConnection;353;0;351;0
WireConnection;293;0;288;0
WireConnection;354;0;353;0
WireConnection;354;1;352;0
WireConnection;281;0;291;0
WireConnection;281;1;293;0
WireConnection;281;2;283;0
WireConnection;355;0;354;0
WireConnection;98;0;99;0
WireConnection;286;0;355;0
WireConnection;286;1;281;0
WireConnection;167;0;98;0
WireConnection;103;0;286;0
WireConnection;93;0;58;0
WireConnection;166;0;167;0
WireConnection;166;1;93;0
WireConnection;263;0;262;0
WireConnection;263;1;262;4
WireConnection;300;0;350;0
WireConnection;298;0;300;0
WireConnection;168;0;166;0
WireConnection;347;0;60;0
WireConnection;347;1;348;0
WireConnection;255;0;263;0
WireConnection;159;0;347;0
WireConnection;256;0;255;0
WireConnection;100;0;168;0
WireConnection;140;0;53;0
WireConnection;160;0;106;0
WireConnection;160;1;161;0
WireConnection;160;2;159;0
WireConnection;331;0;60;0
WireConnection;139;0;140;0
WireConnection;139;1;301;0
WireConnection;139;2;100;0
WireConnection;244;0;238;0
WireConnection;246;0;213;0
WireConnection;246;1;244;0
WireConnection;341;0;160;0
WireConnection;138;0;257;0
WireConnection;138;1;139;0
WireConnection;342;0;331;0
WireConnection;224;0;222;0
WireConnection;224;1;223;0
WireConnection;94;0;138;0
WireConnection;343;0;341;0
WireConnection;343;1;342;0
WireConnection;170;0;246;0
WireConnection;170;1;224;0
WireConnection;170;2;219;0
WireConnection;170;3;258;0
WireConnection;170;4;329;0
WireConnection;170;5;358;0
WireConnection;227;0;170;0
WireConnection;95;0;94;0
WireConnection;129;0;128;0
WireConnection;129;1;126;0
WireConnection;344;0;343;0
WireConnection;319;42;344;0
WireConnection;319;52;119;0
WireConnection;319;43;129;0
WireConnection;236;0;95;0
WireConnection;274;0;227;0
WireConnection;325;1;274;0
WireConnection;325;2;239;0
WireConnection;182;0;170;0
WireConnection;163;0;236;0
WireConnection;163;1;319;0
WireConnection;163;2;100;0
WireConnection;275;0;127;0
WireConnection;275;1;100;0
WireConnection;323;0;163;0
WireConnection;323;1;182;0
WireConnection;323;2;325;0
WireConnection;292;0;295;0
WireConnection;308;2;323;0
ASEEND*/
//CHKSM=B3D1617295706A3BC668A87D309644A52AE515DA