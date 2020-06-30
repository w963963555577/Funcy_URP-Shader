// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/LWRP/Environment/SpecialTree"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_BaseMap("BaseMap", 2D) = "white" {}
		_ClipThreshod("ClipThreshod", Range( 0 , 1)) = 0.4
		_LambertOffset("LambertOffset", Float) = 0.5
		[HDR]_BlendColor_Light("BlendColor_Light", Color) = (0.227451,0.8784314,0.4121743,0)
		[HDR]_BlendColor_Mid("BlendColor_Mid", Color) = (0.03555536,0.4433962,0.1661608,0)
		[HDR]_BlendColor_Dark("BlendColor_Dark", Color) = (0,0.254717,0.1783019,0)
		[HDR]_BlendColor_SelfShadow("BlendColor_SelfShadow", Color) = (0,0.1776338,0.2,0)
		[HDR]_SpecColor("SpecColor", Color) = (0.227451,1.498039,0,1)
		_SpecularOffset("SpecularOffset", Float) = 0.44
		_Speed("Speed", Float) = 1.5
		_Amount("Amount", Float) = 5
		_Distance("Distance", Range( 0 , 1)) = 0.5
		_ZMotion("ZMotion", Range( 0 , 1)) = 0.5
		_ZMotionSpeed("ZMotionSpeed", Range( 0 , 20)) = 10
		_OriginWeight("OriginWeight", Range( 0 , 1)) = 0.5
		_PositionMask("PositionMask", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Off
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL

		UsePass "Hidden/LWRP/General/SceneSelectionPass"

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
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
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

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT


			sampler2D _PositionMask;
			sampler2D _BaseMap;
			CBUFFER_START( UnityPerMaterial )
			float4 _PositionMask_ST;
			float _Speed;
			float _Amount;
			float _Distance;
			float _OriginWeight;
			float _ZMotionSpeed;
			float _ZMotion;
			float4 _BaseMap_ST;
			float4 _BlendColor_SelfShadow;
			float4 _BlendColor_Dark;
			float4 _BlendColor_Mid;
			float _LambertOffset;
			float4 _BlendColor_Light;
			float _ClipThreshod;
			float _SpecularOffset;
			float4 _SpecColor;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 appendResult182 = (float2(v.vertex.xyz.xy));
				float temp_output_107_0 = ( v.vertex.xyz.y * _Amount );
				float4 transform95 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float lerpResult126 = lerp( ( sin( ( ( 0.0 * _Speed ) + temp_output_107_0 ) ) * _Distance ) , ( sin( ( ( 0.0 * _Speed ) + temp_output_107_0 ) ) * _Distance * ( distance( v.vertex.xyz.y , transform95.y ) / 3.0 ) ) , _OriginWeight);
				float temp_output_125_0 = ( sin( ( ( temp_output_107_0 * ( _ZMotionSpeed / 10.0 ) ) + ( _TimeParameters.x * ( _Speed / 10.0 ) * _ZMotionSpeed ) ) ) * _ZMotion );
				float3 appendResult132 = (float3(0.0 , 0.0 , ( lerpResult126 * temp_output_125_0 )));
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				o.ase_texcoord3.xyz = ase_worldPos;
				float4 ase_shadowCoords = TransformWorldToShadowCoord(ase_worldPos);
				o.ase_texcoord4 = ase_shadowCoords;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( ( tex2Dlod( _PositionMask, float4( ( ( appendResult182 * _PositionMask_ST.xy ) + _PositionMask_ST.zw ), 0, 0.0) ).r * appendResult132 ) / ase_objectScale );
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

				float2 uv_BaseMap = IN.ase_texcoord1.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
				float4 tex2DNode5 = tex2D( _BaseMap, uv_BaseMap );
				float3 ase_worldNormal = IN.ase_texcoord2.xyz;
				float dotResult41 = dot( ase_worldNormal , _MainLightPosition.xyz );
				float temp_output_47_0 = saturate( ( dotResult41 + _LambertOffset ) );
				float smoothstepResult82 = smoothstep( 0.0 , 0.5 , temp_output_47_0);
				float4 lerpResult83 = lerp( _BlendColor_Dark , _BlendColor_Mid , smoothstepResult82);
				float smoothstepResult80 = smoothstep( 0.5 , 1.0 , temp_output_47_0);
				float4 lerpResult57 = lerp( lerpResult83 , _BlendColor_Light , smoothstepResult80);
				float3 ase_worldPos = IN.ase_texcoord3.xyz;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) //la
				float4 ase_shadowCoords = IN.ase_texcoord4;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS) //la
				float4 ase_shadowCoords = TransformWorldToShadowCoord(ase_worldPos);
				#else //la
				float4 ase_shadowCoords = 0;
				#endif //la
				float ase_lightAtten = 0;
				Light ase_lightAtten_mainLight = GetMainLight( ase_shadowCoords );
				ase_lightAtten = ase_lightAtten_mainLight.distanceAttenuation * ase_lightAtten_mainLight.shadowAttenuation;
				float temp_output_147_0 = saturate( ( ase_lightAtten + temp_output_47_0 ) );
				float4 lerpResult145 = lerp( _BlendColor_SelfShadow , lerpResult57 , temp_output_147_0);
				float temp_output_3_0_g5 = ( tex2DNode5.a - _ClipThreshod );
				float temp_output_3_0_g4 = ( tex2DNode5.a - saturate( ( 1.5 * _ClipThreshod ) ) );
				float temp_output_200_0 = saturate( ( dotResult41 + ( _SpecularOffset * -1.0 ) ) );
				
				clip( tex2DNode5.a - _ClipThreshod);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = saturate( ( ( tex2DNode5 * lerpResult145 ) + ( saturate( ( ( saturate( ( temp_output_3_0_g5 / fwidth( temp_output_3_0_g5 ) ) ) - saturate( ( temp_output_3_0_g4 / fwidth( temp_output_3_0_g4 ) ) ) ) * temp_output_200_0 * temp_output_147_0 * tex2DNode5.a ) ) * _SpecColor ) ) ).rgb;
				float Alpha = 1.0;
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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define ASE_SRP_VERSION 70201

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			sampler2D _PositionMask;
			sampler2D _BaseMap;
			CBUFFER_START( UnityPerMaterial )
			float4 _PositionMask_ST;
			float _Speed;
			float _Amount;
			float _Distance;
			float _OriginWeight;
			float _ZMotionSpeed;
			float _ZMotion;
			float4 _BaseMap_ST;
			float4 _BlendColor_SelfShadow;
			float4 _BlendColor_Dark;
			float4 _BlendColor_Mid;
			float _LambertOffset;
			float4 _BlendColor_Light;
			float _ClipThreshod;
			float _SpecularOffset;
			float4 _SpecColor;
			CBUFFER_END


			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			float3 _LightDirection;

			VertexOutput ShadowPassVertex( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float2 appendResult182 = (float2(v.vertex.xyz.xy));
				float temp_output_107_0 = ( v.vertex.xyz.y * _Amount );
				float4 transform95 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float lerpResult126 = lerp( ( sin( ( ( 0.0 * _Speed ) + temp_output_107_0 ) ) * _Distance ) , ( sin( ( ( 0.0 * _Speed ) + temp_output_107_0 ) ) * _Distance * ( distance( v.vertex.xyz.y , transform95.y ) / 3.0 ) ) , _OriginWeight);
				float temp_output_125_0 = ( sin( ( ( temp_output_107_0 * ( _ZMotionSpeed / 10.0 ) ) + ( _TimeParameters.x * ( _Speed / 10.0 ) * _ZMotionSpeed ) ) ) * _ZMotion );
				float3 appendResult132 = (float3(0.0 , 0.0 , ( lerpResult126 * temp_output_125_0 )));
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				
				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( ( tex2Dlod( _PositionMask, float4( ( ( appendResult182 * _PositionMask_ST.xy ) + _PositionMask_ST.zw ), 0, 0.0) ).r * appendResult132 ) / ase_objectScale );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif
				o.clipPos = clipPos;

				return o;
			}

			half4 ShadowPassFragment(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float2 uv_BaseMap = IN.ase_texcoord7.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
				float4 tex2DNode5 = tex2D( _BaseMap, uv_BaseMap );
				clip( tex2DNode5.a - _ClipThreshod);
				
				float Alpha = 1.0;
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

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define ASE_SRP_VERSION 70201

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			sampler2D _PositionMask;
			sampler2D _BaseMap;
			CBUFFER_START( UnityPerMaterial )
			float4 _PositionMask_ST;
			float _Speed;
			float _Amount;
			float _Distance;
			float _OriginWeight;
			float _ZMotionSpeed;
			float _ZMotion;
			float4 _BaseMap_ST;
			float4 _BlendColor_SelfShadow;
			float4 _BlendColor_Dark;
			float4 _BlendColor_Mid;
			float _LambertOffset;
			float4 _BlendColor_Light;
			float _ClipThreshod;
			float _SpecularOffset;
			float4 _SpecColor;
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
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 appendResult182 = (float2(v.vertex.xyz.xy));
				float temp_output_107_0 = ( v.vertex.xyz.y * _Amount );
				float4 transform95 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float lerpResult126 = lerp( ( sin( ( ( 0.0 * _Speed ) + temp_output_107_0 ) ) * _Distance ) , ( sin( ( ( 0.0 * _Speed ) + temp_output_107_0 ) ) * _Distance * ( distance( v.vertex.xyz.y , transform95.y ) / 3.0 ) ) , _OriginWeight);
				float temp_output_125_0 = ( sin( ( ( temp_output_107_0 * ( _ZMotionSpeed / 10.0 ) ) + ( _TimeParameters.x * ( _Speed / 10.0 ) * _ZMotionSpeed ) ) ) * _ZMotion );
				float3 appendResult132 = (float3(0.0 , 0.0 , ( lerpResult126 * temp_output_125_0 )));
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( ( tex2Dlod( _PositionMask, float4( ( ( appendResult182 * _PositionMask_ST.xy ) + _PositionMask_ST.zw ), 0, 0.0) ).r * appendResult132 ) / ase_objectScale );
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

				float2 uv_BaseMap = IN.ase_texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
				float4 tex2DNode5 = tex2D( _BaseMap, uv_BaseMap );
				clip( tex2DNode5.a - _ClipThreshod);
				
				float Alpha = 1.0;
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
0;13;1440;812;2062.591;-1916.861;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;106;-1317.715,2194.475;Inherit;False;Property;_Amount;Amount;10;0;Create;True;0;0;False;0;5;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;94;-1157.715,1506.476;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;115;-1317.715,2530.475;Inherit;False;Property;_ZMotionSpeed;ZMotionSpeed;13;0;Create;True;0;0;False;0;10;0.1;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-1317.715,2098.475;Inherit;False;Property;_Speed;Speed;9;0;Create;True;0;0;False;0;1.5;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;123;-949.7155,2514.475;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;95;-1157.715,1650.476;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-693.7155,1618.476;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-693.7155,1490.476;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;98;-1141.715,1858.476;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;117;-949.7155,2258.475;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-773.7155,1842.476;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-821.7155,2258.475;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-565.7155,1618.476;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;96;-933.7155,1842.476;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;-693.7155,2130.475;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;108;-565.7155,1490.476;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;-565.7155,2130.475;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;90;-225.6687,1104.493;Inherit;True;Property;_PositionMask;PositionMask;15;0;Create;True;0;0;False;0;8b461ce8058c8854db863713d5da9d99;8b461ce8058c8854db863713d5da9d99;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-1317.715,2290.475;Inherit;False;Property;_Distance;Distance;11;0;Create;True;0;0;False;0;0.5;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;102;-437.7155,1618.476;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;97;-437.7155,1490.476;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;110;-565.7155,1842.476;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-1317.715,2450.475;Inherit;False;Property;_ZMotion;ZMotion;12;0;Create;True;0;0;False;0;0.5;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;124;-437.7155,2130.475;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-309.7155,1490.476;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-437.7155,1874.476;Inherit;False;Property;_OriginWeight;OriginWeight;14;0;Create;True;0;0;False;0;0.5;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;182;16,1104;Inherit;False;FLOAT2;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-309.7155,1618.476;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;183;48,1216;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-309.7155,2130.475;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;144,1104;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;126;-53.71535,1490.476;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;185;288,1104;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;202.2847,1490.476;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;133;512,1248;Inherit;True;Property;_TextureSample0;Texture Sample 0;12;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;132;378.2846,1490.476;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;5;-761.6,-224;Inherit;True;Property;_BaseMap;BaseMap;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;947.655,1343.947;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-486.0402,-52.39412;Inherit;False;Property;_ClipThreshod;ClipThreshod;1;0;Create;True;0;0;False;0;0.4;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectScaleNode;186;918.5509,1507.816;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;47;16,272;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;202;-654.3398,85.64249;Inherit;False;Property;_SpecularOffset;SpecularOffset;8;0;Create;True;0;0;False;0;0.44;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;207;979.5007,385.186;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;164;989.7597,-39.07249;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;217;-878.9424,874.3927;Inherit;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClipNode;6;1522.793,769.3523;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;776.5141,-28.98666;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;205;504,299.1;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;41;-400,208;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;1302.1,33.0344;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;49;-32,432;Inherit;False;Property;_BlendColor_Light;BlendColor_Light;3;1;[HDR];Create;True;0;0;False;0;0.227451,0.8784314,0.4121743,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;177;1437.459,342.0244;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;57;614.7794,470.1597;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;82;240,768;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;83;432,608;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;168;347.4595,-16.9725;Inherit;False;Step Antialiasing;-1;;4;2a825e80dfb3290468194f83380797bd;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;237;-125.7947,-55.37096;Inherit;False;2;2;0;FLOAT;1.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-448,320;Inherit;False;Property;_LambertOffset;LambertOffset;2;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;144;506.2001,746.7;Inherit;False;Property;_BlendColor_SelfShadow;BlendColor_SelfShadow;6;1;[HDR];Create;True;0;0;False;0;0,0.1776338,0.2,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;145;854.014,567.1079;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;136;1061.051,71.03796;Inherit;False;Property;_SpecColor;SpecColor;7;1;[HDR];Create;True;0;0;False;0;0.227451,1.498039,0,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;1196.362,376.5298;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-981.7154,1650.476;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;8;-1259.288,504.7752;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;200;29.66016,111.6425;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;820.6855,337.1511;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;167;347.4595,-128.9725;Inherit;False;Step Antialiasing;-1;;5;2a825e80dfb3290468194f83380797bd;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;146;512,944;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;163;623.0623,-30.05553;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;226;-862.9424,970.3926;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LightAttenuation;143;324.9531,951.5895;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;656,320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;101;-821.7155,1618.476;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;80;240,608;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;238;146.9238,-32.16086;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;187;1207.57,1416.256;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;52;-32,784;Inherit;False;Property;_BlendColor_Dark;BlendColor_Dark;5;1;[HDR];Create;True;0;0;False;0;0,0.254717,0.1783019,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;179;1651.879,430.1511;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;201;-222.3398,135.6425;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-245,271;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;147;640,944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;-821.7155,1490.476;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;51;-32,608;Inherit;False;Property;_BlendColor_Mid;BlendColor_Mid;4;1;[HDR];Create;True;0;0;False;0;0.03555536,0.4433962,0.1661608,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;202.2847,1618.476;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;116;-837.7155,2066.475;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;129;-325.7155,2258.475;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;203;-424.4309,95.81796;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;34;-1234.701,46.79994;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;2881.59,620.1353;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;ZDShader/LWRP/Environment/SpecialTree;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;0;Forward;7;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;2;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;1;Above;Hidden/LWRP/General/SceneSelectionPass;Standard;10;Surface;1;  Blend;0;Two Sided;0;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;1;Built-in Fog;1;Meta Pass;0;Vertex Position,InvertActionOnDeselection;1;0;4;True;True;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;123;0;115;0
WireConnection;104;1;105;0
WireConnection;103;1;105;0
WireConnection;117;0;105;0
WireConnection;107;0;94;2
WireConnection;107;1;106;0
WireConnection;118;0;98;0
WireConnection;118;1;117;0
WireConnection;118;2;115;0
WireConnection;109;0;104;0
WireConnection;109;1;107;0
WireConnection;96;0;94;2
WireConnection;96;1;95;2
WireConnection;122;0;107;0
WireConnection;122;1;123;0
WireConnection;108;0;103;0
WireConnection;108;1;107;0
WireConnection;121;0;122;0
WireConnection;121;1;118;0
WireConnection;102;0;109;0
WireConnection;97;0;108;0
WireConnection;110;0;96;0
WireConnection;124;0;121;0
WireConnection;111;0;97;0
WireConnection;111;1;112;0
WireConnection;111;2;110;0
WireConnection;182;0;94;0
WireConnection;113;0;102;0
WireConnection;113;1;112;0
WireConnection;183;0;90;0
WireConnection;125;0;124;0
WireConnection;125;1;114;0
WireConnection;184;0;182;0
WireConnection;184;1;183;0
WireConnection;126;0;113;0
WireConnection;126;1;111;0
WireConnection;126;2;127;0
WireConnection;185;0;184;0
WireConnection;185;1;183;1
WireConnection;130;0;126;0
WireConnection;130;1;125;0
WireConnection;133;0;90;0
WireConnection;133;1;185;0
WireConnection;132;2;130;0
WireConnection;134;0;133;1
WireConnection;134;1;132;0
WireConnection;47;0;46;0
WireConnection;207;0;206;0
WireConnection;164;0;169;0
WireConnection;6;1;5;4
WireConnection;6;2;149;0
WireConnection;169;0;163;0
WireConnection;169;1;200;0
WireConnection;169;2;147;0
WireConnection;169;3;5;4
WireConnection;205;0;200;0
WireConnection;41;0;34;0
WireConnection;41;1;8;0
WireConnection;178;0;164;0
WireConnection;178;1;136;0
WireConnection;177;0;86;0
WireConnection;177;1;178;0
WireConnection;57;0;83;0
WireConnection;57;1;49;0
WireConnection;57;2;80;0
WireConnection;82;0;47;0
WireConnection;83;0;52;0
WireConnection;83;1;51;0
WireConnection;83;2;82;0
WireConnection;168;1;238;0
WireConnection;168;2;5;4
WireConnection;237;1;149;0
WireConnection;145;0;144;0
WireConnection;145;1;57;0
WireConnection;145;2;147;0
WireConnection;86;0;5;0
WireConnection;86;1;145;0
WireConnection;99;0;95;1
WireConnection;99;1;95;3
WireConnection;200;0;201;0
WireConnection;206;1;208;0
WireConnection;167;1;149;0
WireConnection;167;2;5;4
WireConnection;146;0;143;0
WireConnection;146;1;47;0
WireConnection;163;0;167;0
WireConnection;163;1;168;0
WireConnection;208;0;205;0
WireConnection;101;0;94;3
WireConnection;101;1;99;0
WireConnection;101;2;98;0
WireConnection;80;0;47;0
WireConnection;238;0;237;0
WireConnection;187;0;134;0
WireConnection;187;1;186;0
WireConnection;179;0;177;0
WireConnection;201;0;41;0
WireConnection;201;1;203;0
WireConnection;46;0;41;0
WireConnection;46;1;48;0
WireConnection;147;0;146;0
WireConnection;100;0;94;1
WireConnection;100;1;99;0
WireConnection;100;2;98;0
WireConnection;131;0;126;0
WireConnection;131;1;129;0
WireConnection;116;0;98;0
WireConnection;129;0;125;0
WireConnection;203;0;202;0
WireConnection;1;2;179;0
WireConnection;1;3;6;0
WireConnection;1;5;187;0
ASEEND*/
//CHKSM=AB9194F6C5F64197679C58BC1C8718B43A4D5B7F