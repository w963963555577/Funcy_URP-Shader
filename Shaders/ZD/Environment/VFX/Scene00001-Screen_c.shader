// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/URP/Environment/Scene00001-Screen_c"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HDR]_Color("Color", Color) = (1,1,1,0)
		[NoScaleOffset]_Background("Background", 2D) = "white" {}
		_GridMap("GridMap", 2D) = "black" {}
		_NoiseWaveMap("NoiseWaveMap", 2D) = "gray" {}
		_GraphicsScale("Graphics Scale", Vector) = (1,1,0,0)
		_BarChartScale("Bar Chart Scale", Vector) = (1,1,0,0)
		_WaveChartScale("Wave Chart Scale", Vector) = (1,1,0,0)
		_TextScale("Text Scale", Vector) = (1,1,0,0)
		_CircleChartScale("Circle Chart Scale", Vector) = (1,1,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Off
		HLSLINCLUDE
		#pragma target 2.0

		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Color;
			half4 _CircleChartScale;
			half4 _GraphicsScale;
			half4 _WaveChartScale;
			half4 _BarChartScale;
			half4 _GridMap_ST;
			half4 _TextScale;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Background;
			sampler2D _NoiseWaveMap;
			sampler2D _GridMap;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
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

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

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
				half mulTime112 = _TimeParameters.x * 0.1;
				half2 appendResult217 = (half2(_CircleChartScale.x , _CircleChartScale.y));
				half2 appendResult219 = (half2(_CircleChartScale.z , _CircleChartScale.w));
				float cos203 = cos( _TimeParameters.x );
				float sin203 = sin( _TimeParameters.x );
				half2 rotator203 = mul( ( ( float4(IN.ase_texcoord3.xy,0,0).xy * appendResult217 ) + appendResult219 ) - float2( 0.5,0.5 ) , float2x2( cos203 , -sin203 , sin203 , cos203 )) + float2( 0.5,0.5 );
				half2 temp_output_193_0 = ( ( rotator203 - float2( 0.5,0.5 ) ) * float2( 2,2 ) );
				half2 break194 = temp_output_193_0;
				half temp_output_196_0 = ( atan2( break194.y , break194.x ) / ( abs( sin( _TimeParameters.x ) ) * PI ) );
				half smoothstepResult202 = smoothstep( 0.1 , 0.15 , min( ( 1.0 - length( temp_output_193_0 ) ) , abs( temp_output_196_0 ) ));
				half smoothstepResult206 = smoothstep( 0.1 , 0.15 , ( 1.0 - temp_output_196_0 ));
				float2 uv_Background111 = float4(IN.ase_texcoord3.xy,0,0).xy;
				half4 tex2DNode111 = tex2D( _Background, uv_Background111 );
				float cos35 = cos( _TimeParameters.x );
				float sin35 = sin( _TimeParameters.x );
				half2 rotator35 = mul( float4(IN.ase_texcoord3.xy,0,0).xy - float2( 0.5,0.5 ) , float2x2( cos35 , -sin35 , sin35 , cos35 )) + float2( 0.5,0.5 );
				half2 break44 = ( ( float2( 0.5,0.5 ) - rotator35 ) * float2( 2,2 ) );
				half temp_output_73_0 = saturate( abs( ( atan2( break44.y , break44.x ) / PI ) ) );
				half smoothstepResult89 = smoothstep( 0.5 , 1.0 , temp_output_73_0);
				half smoothstepResult80 = smoothstep( 0.5 , 1.0 , ( 1.0 - temp_output_73_0 ));
				half2 appendResult9 = (half2(_GraphicsScale.x , _GraphicsScale.y));
				half2 appendResult10 = (half2(_GraphicsScale.z , _GraphicsScale.w));
				half2 temp_output_12_0 = ( ( ( float4(IN.ase_texcoord3.xy,0,0).xy - float2( 0.5,0.5 ) ) * appendResult9 ) + appendResult10 );
				half2 break15 = ( temp_output_12_0 * float2( 2,2 ) );
				half temp_output_17_0 = atan2( break15.y , break15.x );
				half temp_output_23_0 = ( _TimeParameters.x + ( sin( temp_output_17_0 ) * ( sin( _TimeParameters.x ) * 2.0 ) ) + temp_output_17_0 );
				half4 appendResult26 = (half4(temp_output_23_0 , temp_output_23_0 , temp_output_23_0 , temp_output_23_0));
				half4 s33 = ( cos( ( appendResult26 + ( 1.6 * half4(1,2,3,4) ) ) ) * 0.1 );
				half4 break36 = s33;
				half4 appendResult40 = (half4(break36.y , break36.z , break36.w , break36.x));
				half4 c43 = appendResult40;
				half temp_output_41_0 = ( length( temp_output_12_0 ) - 0.3 );
				half4 appendResult46 = (half4(temp_output_41_0 , temp_output_41_0 , temp_output_41_0 , temp_output_41_0));
				half4 temp_output_57_0 = ( c43 - appendResult46 );
				half4 break151 = saturate( temp_output_57_0 );
				half4 f69 = min( ( appendResult46 - s33 ) , temp_output_57_0 );
				half4 break79 = f69;
				half smoothstepResult113 = smoothstep( 0.0 , 0.03 , saturate( max( max( break79.x , break79.y ) , max( break79.z , break79.w ) ) ));
				half mulTime187 = _TimeParameters.x * 0.1;
				half2 appendResult179 = (half2(_WaveChartScale.x , _WaveChartScale.y));
				half2 appendResult180 = (half2(_WaveChartScale.z , _WaveChartScale.w));
				half2 temp_output_178_0 = ( ( ( float4(IN.ase_texcoord3.xy,0,0).xy - float2( 0,0 ) ) * appendResult179 ) + appendResult180 );
				half2 break182 = temp_output_178_0;
				half2 appendResult170 = (half2(break182.x , 0.0));
				half2 panner186 = ( mulTime187 * float2( 1,3 ) + appendResult170);
				half smoothstepResult173 = smoothstep( 0.4 , 0.42 , ( tex2D( _NoiseWaveMap, panner186 ).r * ( 1.0 - break182.y ) ));
				half2 appendResult10_g46 = (half2(1.0 , 1.0));
				half2 temp_output_11_0_g46 = ( abs( (temp_output_178_0*2.0 + -1.0) ) - appendResult10_g46 );
				half2 break16_g46 = ( 1.0 - ( temp_output_11_0_g46 / fwidth( temp_output_11_0_g46 ) ) );
				half2 appendResult65 = (half2(_BarChartScale.x , _BarChartScale.y));
				half2 appendResult72 = (half2(_BarChartScale.z , _BarChartScale.w));
				half2 temp_output_78_0 = ( ( ( float4(IN.ase_texcoord3.xy,0,0).xy - float2( 0,0 ) ) * appendResult65 ) + appendResult72 );
				half mulTime49 = _TimeParameters.x * 0.1;
				half2 appendResult55 = (half2(mulTime49 , mulTime49));
				half temp_output_76_0 = ( ( tex2D( _NoiseWaveMap, appendResult55 ).r - 0.25 ) * 3.0 );
				half2 appendResult10_g41 = (half2(0.1 , temp_output_76_0));
				half2 temp_output_11_0_g41 = ( abs( (( temp_output_78_0 + float2( 0.445,0.5 ) )*2.0 + -1.0) ) - appendResult10_g41 );
				half2 break16_g41 = ( 1.0 - ( temp_output_11_0_g41 / fwidth( temp_output_11_0_g41 ) ) );
				half2 appendResult52 = (half2(mulTime49 , 0.0));
				half temp_output_77_0 = ( ( tex2D( _NoiseWaveMap, appendResult52 ).r - 0.25 ) * 3.0 );
				half2 appendResult10_g37 = (half2(0.1 , temp_output_77_0));
				half2 temp_output_11_0_g37 = ( abs( (( temp_output_78_0 + float2( 0.32,0.5 ) )*2.0 + -1.0) ) - appendResult10_g37 );
				half2 break16_g37 = ( 1.0 - ( temp_output_11_0_g37 / fwidth( temp_output_11_0_g37 ) ) );
				half2 appendResult53 = (half2(0.0 , mulTime49));
				half temp_output_75_0 = ( ( tex2D( _NoiseWaveMap, appendResult53 ).r - 0.25 ) * 3.0 );
				half2 appendResult10_g44 = (half2(0.1 , temp_output_75_0));
				half2 temp_output_11_0_g44 = ( abs( (( temp_output_78_0 + float2( 0.195,0.5 ) )*2.0 + -1.0) ) - appendResult10_g44 );
				half2 break16_g44 = ( 1.0 - ( temp_output_11_0_g44 / fwidth( temp_output_11_0_g44 ) ) );
				half2 appendResult10_g38 = (half2(0.1 , ( temp_output_77_0 * temp_output_75_0 )));
				half2 temp_output_11_0_g38 = ( abs( (( temp_output_78_0 + float2( 0.07,0.5 ) )*2.0 + -1.0) ) - appendResult10_g38 );
				half2 break16_g38 = ( 1.0 - ( temp_output_11_0_g38 / fwidth( temp_output_11_0_g38 ) ) );
				half2 appendResult10_g42 = (half2(0.1 , ( temp_output_76_0 * temp_output_77_0 )));
				half2 temp_output_11_0_g42 = ( abs( (( temp_output_78_0 + float2( -0.055,0.5 ) )*2.0 + -1.0) ) - appendResult10_g42 );
				half2 break16_g42 = ( 1.0 - ( temp_output_11_0_g42 / fwidth( temp_output_11_0_g42 ) ) );
				half2 appendResult10_g39 = (half2(0.1 , temp_output_77_0));
				half2 temp_output_11_0_g39 = ( abs( (( temp_output_78_0 + float2( -0.18,0.5 ) )*2.0 + -1.0) ) - appendResult10_g39 );
				half2 break16_g39 = ( 1.0 - ( temp_output_11_0_g39 / fwidth( temp_output_11_0_g39 ) ) );
				half2 appendResult10_g40 = (half2(0.1 , temp_output_76_0));
				half2 temp_output_11_0_g40 = ( abs( (( temp_output_78_0 + float2( -0.305,0.5 ) )*2.0 + -1.0) ) - appendResult10_g40 );
				half2 break16_g40 = ( 1.0 - ( temp_output_11_0_g40 / fwidth( temp_output_11_0_g40 ) ) );
				half2 appendResult10_g43 = (half2(0.1 , temp_output_75_0));
				half2 temp_output_11_0_g43 = ( abs( (( temp_output_78_0 + float2( -0.43,0.5 ) )*2.0 + -1.0) ) - appendResult10_g43 );
				half2 break16_g43 = ( 1.0 - ( temp_output_11_0_g43 / fwidth( temp_output_11_0_g43 ) ) );
				half2 appendResult10_g45 = (half2(1.0 , 1.0));
				half2 temp_output_11_0_g45 = ( abs( (temp_output_78_0*2.0 + -1.0) ) - appendResult10_g45 );
				half2 break16_g45 = ( 1.0 - ( temp_output_11_0_g45 / fwidth( temp_output_11_0_g45 ) ) );
				half2 uv0_GridMap = float4(IN.ase_texcoord3.xy,0,0).xy * _GridMap_ST.xy + _GridMap_ST.zw;
				half mulTime142 = _TimeParameters.x * 0.2;
				half2 panner141 = ( mulTime142 * float2( 0,-1 ) + float4(IN.ase_texcoord3.xy,0,0).xy);
				half2 appendResult133 = (half2(_TextScale.x , _TextScale.y));
				half2 appendResult135 = (half2(_TextScale.z , _TextScale.w));
				half2 break148 = ( ( panner141 * appendResult133 ) + appendResult135 );
				half2 appendResult149 = (half2(saturate( break148.x ) , break148.y));
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = _Color.rgb;
				float Alpha = ( abs( sin( ( ( float4(IN.ase_texcoord3.xy,0,0).xy.y - mulTime112 ) * 120.0 ) ) ) * max( max( max( max( ( smoothstepResult202 * 0.5 ) , min( smoothstepResult202 , smoothstepResult206 ) ) , max( ( tex2DNode111.r * max( max( smoothstepResult89 , smoothstepResult80 ) , 0.1 ) ) , max( ( ( break151.x + break151.y + break151.z + break151.w ) * 0.4 ) , smoothstepResult113 ) ) ) , max( ( smoothstepResult173 * saturate( min( break16_g46.x , break16_g46.y ) ) ) , ( ( ( saturate( min( break16_g41.x , break16_g41.y ) ) + saturate( min( break16_g37.x , break16_g37.y ) ) + saturate( min( break16_g44.x , break16_g44.y ) ) + saturate( min( break16_g38.x , break16_g38.y ) ) ) + ( saturate( min( break16_g42.x , break16_g42.y ) ) + saturate( min( break16_g39.x , break16_g39.y ) ) + saturate( min( break16_g40.x , break16_g40.y ) ) + saturate( min( break16_g43.x , break16_g43.y ) ) ) ) * saturate( min( break16_g45.x , break16_g45.y ) ) ) ) ) , ( tex2DNode111.g * max( tex2D( _GridMap, uv0_GridMap ).r , saturate( tex2D( _Background, appendResult149 ).b ) ) ) ) );
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

	
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	
	
}
/*ASEBEGIN
Version=18104
0;99;1433;638;-996.6623;2616.471;1.63256;True;False
Node;AmplifyShaderEditor.CommentaryNode;5;-2722.397,-642.0864;Inherit;False;3584;1350;Graphics;54;113;108;102;88;83;79;69;62;57;51;48;47;46;43;41;40;38;36;34;33;30;29;28;27;26;25;24;23;22;21;20;19;18;17;16;15;14;13;12;11;10;9;8;7;6;4;3;2;0;157;161;151;159;160;Graphics;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;7;-2674.397,-226.0864;Inherit;False;Property;_GraphicsScale;Graphics Scale;4;0;Create;True;0;0;False;0;False;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;6;-2674.397,-386.0864;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;9;-2498.397,-226.0864;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;8;-2466.397,-386.0864;Inherit;False;2;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;-2498.397,-130.0864;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-2322.397,-386.0864;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-2194.397,-386.0864;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-2050.397,-386.0864;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;15;-1922.397,-386.0864;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleTimeNode;14;-1682.397,-594.0864;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;17;-1666.397,-386.0864;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;16;-1522.397,-594.0864;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;18;-1298.397,-498.0864;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-1378.397,-594.0864;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;20;-1874.397,77.91357;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1090.397,-562.0864;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1602.397,397.9136;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;False;0;False;1.6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;24;-1602.397,493.9136;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;False;1,2,3,4;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;23;-1666.397,29.91357;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1442.397,397.9136;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-1410.397,109.9136;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-1298.397,253.9136;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CosOpNode;29;-1090.397,253.9136;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1090.397,365.9136;Inherit;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-914.3967,253.9136;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0.1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-786.3967,253.9136;Inherit;False;s;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;32;-384,-1536;Inherit;True;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;215;-1132.446,-2396.117;Inherit;False;Property;_CircleChartScale;Circle Chart Scale;8;0;Create;True;0;0;False;0;False;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;34;-1282.397,29.91357;Inherit;False;33;s;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;31;-385.7962,-1328;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;214;-1148.446,-2540.117;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotatorNode;35;-129.7962,-1536;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;36;-1106.397,29.91357;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;217;-924.4459,-2396.117;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;219;-924.4459,-2300.117;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;38;-2050.397,-226.0864;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;40;-898.3967,29.91357;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;37;64,-1536;Inherit;False;2;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;-768,-2544;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;204;-720,-2112;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;188;-1504,784;Inherit;False;2368;1606.144;Charts;60;181;175;49;179;176;53;180;177;59;55;52;56;54;65;63;64;66;61;178;70;72;68;71;182;67;75;77;76;78;170;187;86;90;92;93;82;186;85;81;91;84;87;100;101;94;97;103;95;174;162;104;96;107;106;171;184;116;173;117;120;Charts;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;220;-624,-2544;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-770.3967,29.91357;Inherit;False;c;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;41;-1874.397,-146.0864;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;192,-1536;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;44;320,-1536;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TexCoordVertexDataNode;175;-992,928;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;181;-992,1056;Inherit;False;Property;_WaveChartScale;Wave Chart Scale;6;0;Create;True;0;0;False;0;False;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;46;-1410.397,-226.0864;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-1097.519,-409.4131;Inherit;False;43;c;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-1410.397,-82.08643;Inherit;False;33;s;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RotatorNode;203;-304,-2304;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ATan2OpNode;50;640,-1536;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;49;-1456,1584;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;189;990,-517.4517;Inherit;False;1704;700.4517;Text;13;142;130;131;133;141;135;134;136;148;150;149;137;140;Text;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;192;-128,-2304;Inherit;False;2;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;176;-784,928;Inherit;False;2;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;-1154.397,-226.0864;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PiNode;45;656,-1312;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;179;-784,1056;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;57;-889.7233,-291.6383;Inherit;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;131;1056,-48;Inherit;False;Property;_TextScale;Text Scale;7;0;Create;True;0;0;False;0;False;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;58;880,-1536;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;55;-1248,1552;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;56;-1088,2032;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;54;-1088,2160;Inherit;False;Property;_BarChartScale;Bar Chart Scale;5;0;Create;True;0;0;False;0;False;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;180;-784,1152;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;53;-1248,1824;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-640,928;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;130;1040,-192;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;0,-2304;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMinOpNode;62;-642.3967,-354.0864;Inherit;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SinOpNode;210;-48.67151,-1903.714;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-1248,1664;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;59;-1456,1344;Inherit;True;Property;_NoiseWaveMap;NoiseWaveMap;3;0;Create;True;0;0;False;0;False;6a1fffff897d00e459ab3c9226cbedc6;6a1fffff897d00e459ab3c9226cbedc6;False;gray;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleTimeNode;142;1040,-320;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;66;-1088,1584;Inherit;True;Property;_TextureSample2;Texture Sample 2;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;64;-1088,1376;Inherit;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;61;-880,2032;Inherit;False;2;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-450.3967,-354.0864;Inherit;False;f;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;141;1232,-192;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;60;1072,-1536;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;63;-1088,1792;Inherit;True;Property;_TextureSample3;Texture Sample 3;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;211;216.0241,-1922.621;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;194;128,-2304;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;65;-880,2160;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;178;-512,928;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;133;1264,-48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;67;-768,1792;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;1264,48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;71;-768,1584;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;1520,-192;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;182;-384,928;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;79;-258.3967,-354.0864;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleSubtractOpNode;68;-768,1376;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;195;400,-2080;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-736,2032;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ATan2OpNode;198;384,-2304;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;73;1280,-1664;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;72;-880,2256;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;83;-2.396729,-146.0864;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;187;-224,832;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;196;624,-2304;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-608,1792;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;74;1280,-1456;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-608,1376;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-608,2032;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;157;-739.6743,-524.2423;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;136;1648,-192;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;199;128,-2208;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;88;-2.396729,-354.0864;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-608,1584;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;170;-176,928;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-112,2224;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-0.43,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;186;-64,928;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,3;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;80;1472,-1456;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-112,1328;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.445,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-112,1840;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-0.055,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;82;-112,1968;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-0.18,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;89;1472,-1664;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-112,1584;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.195,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;86;-112,1456;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.32,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;-112,2096;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-0.305,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;151;-432,-544;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMaxOpNode;102;205.6033,-354.0864;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;197;816,-2304;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-400,1856;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-112,1712;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.07,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-400,1968;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;148;1760,-192;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.OneMinusNode;200;816,-2512;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;108;413.6033,-354.0864;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;159;-128,-560;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;174;32,1120;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;201;1008,-2512;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;150;1994.05,-288.9951;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;98;1280,-2048;Inherit;True;Property;_Background;Background;1;1;[NoScaleOffset];Create;True;0;0;False;0;False;6257a714f93541d4abbadd6deb26f6ff;6257a714f93541d4abbadd6deb26f6ff;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;100;64,1712;Inherit;False;Rectangle;-1;;38;6b23e0c975270fb4084c354b2c83366a;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.1;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;205;512,-1968;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;95;64,1456;Inherit;False;Rectangle;-1;;37;6b23e0c975270fb4084c354b2c83366a;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.1;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;96;64,2096;Inherit;False;Rectangle;-1;;40;6b23e0c975270fb4084c354b2c83366a;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.1;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;162;96,912;Inherit;True;Property;_TextureSample6;Texture Sample 6;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;97;64,1328;Inherit;False;Rectangle;-1;;41;6b23e0c975270fb4084c354b2c83366a;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.1;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;101;64,1840;Inherit;False;Rectangle;-1;;42;6b23e0c975270fb4084c354b2c83366a;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.1;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;94;64,1584;Inherit;False;Rectangle;-1;;44;6b23e0c975270fb4084c354b2c83366a;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.1;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;103;64,2224;Inherit;False;Rectangle;-1;;43;6b23e0c975270fb4084c354b2c83366a;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.1;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;104;64,1968;Inherit;False;Rectangle;-1;;39;6b23e0c975270fb4084c354b2c83366a;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.1;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;99;1696,-1664;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;190;1152,-3072;Inherit;False;904;304;TV Wave;6;109;112;114;122;125;127;TV Wave;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;149;2085.05,-223.9951;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;107;320,1456;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;113;605.6033,-354.0864;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.03;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;368,944;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;106;320,1840;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;192,-560;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;202;1216,-2512;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;206;704,-1968;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;111;1520,-2048;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;110;1968,-1696;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;105;1893.245,-1006.783;Inherit;True;Property;_GridMap;GridMap;2;0;Create;True;0;0;False;0;False;bb63df7bf5282ab4692ca42f0d9f26bc;bb63df7bf5282ab4692ca42f0d9f26bc;False;black;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;117;304,2032;Inherit;True;Rectangle;-1;;45;6b23e0c975270fb4084c354b2c83366a;0;3;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;109;1200,-3024;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;184;-320,1056;Inherit;True;Rectangle;-1;;46;6b23e0c975270fb4084c354b2c83366a;0;3;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;112;1200,-2912;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;137;2174.528,-467.4517;Inherit;True;Property;_TextureSample5;Texture Sample 5;7;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;116;448,1520;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;1824,-2048;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;115;2021.245,-782.7828;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;161;656,-592;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;209;1536,-2288;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;173;608,944;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.4;False;2;FLOAT;0.42;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;1512.533,-2486.431;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;119;2149.245,-1006.783;Inherit;True;Property;_TextureSample4;Texture Sample 4;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;121;2048,-2048;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;672,1552;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;225;1743.921,-2469.987;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;140;2496,-464;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;912,944;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;114;1392,-3024;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;1552,-3024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;120;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;212;2304,-2048;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;139;2480,-1072;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;183;1130.273,1098.743;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;2448,-1424;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;124;2416,-1664;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;125;1696,-3024;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;126;2624,-1664;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;127;1856,-3024;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;128;2432,-2944;Inherit;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;191;-768,-2304;Inherit;True;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;2560,-2560;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;2816,-2816;Half;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;ZDShader/URP/Environment/Scene00001-Screen_c;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;;0;0;Standard;21;Surface;1;  Blend;0;Two Sided;0;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;DOTS Instancing;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;False;False;False;;0
WireConnection;9;0;7;1
WireConnection;9;1;7;2
WireConnection;8;0;6;0
WireConnection;10;0;7;3
WireConnection;10;1;7;4
WireConnection;11;0;8;0
WireConnection;11;1;9;0
WireConnection;12;0;11;0
WireConnection;12;1;10;0
WireConnection;13;0;12;0
WireConnection;15;0;13;0
WireConnection;17;0;15;1
WireConnection;17;1;15;0
WireConnection;16;0;14;0
WireConnection;18;0;17;0
WireConnection;19;0;16;0
WireConnection;21;0;18;0
WireConnection;21;1;19;0
WireConnection;23;0;20;0
WireConnection;23;1;21;0
WireConnection;23;2;17;0
WireConnection;25;0;22;0
WireConnection;25;1;24;0
WireConnection;26;0;23;0
WireConnection;26;1;23;0
WireConnection;26;2;23;0
WireConnection;26;3;23;0
WireConnection;27;0;26;0
WireConnection;27;1;25;0
WireConnection;29;0;27;0
WireConnection;30;0;29;0
WireConnection;30;1;28;0
WireConnection;33;0;30;0
WireConnection;35;0;32;0
WireConnection;35;2;31;0
WireConnection;36;0;34;0
WireConnection;217;0;215;1
WireConnection;217;1;215;2
WireConnection;219;0;215;3
WireConnection;219;1;215;4
WireConnection;38;0;12;0
WireConnection;40;0;36;1
WireConnection;40;1;36;2
WireConnection;40;2;36;3
WireConnection;40;3;36;0
WireConnection;37;1;35;0
WireConnection;218;0;214;0
WireConnection;218;1;217;0
WireConnection;220;0;218;0
WireConnection;220;1;219;0
WireConnection;43;0;40;0
WireConnection;41;0;38;0
WireConnection;39;0;37;0
WireConnection;44;0;39;0
WireConnection;46;0;41;0
WireConnection;46;1;41;0
WireConnection;46;2;41;0
WireConnection;46;3;41;0
WireConnection;203;0;220;0
WireConnection;203;2;204;0
WireConnection;50;0;44;1
WireConnection;50;1;44;0
WireConnection;192;0;203;0
WireConnection;176;0;175;0
WireConnection;51;0;46;0
WireConnection;51;1;47;0
WireConnection;179;0;181;1
WireConnection;179;1;181;2
WireConnection;57;0;48;0
WireConnection;57;1;46;0
WireConnection;58;0;50;0
WireConnection;58;1;45;0
WireConnection;55;0;49;0
WireConnection;55;1;49;0
WireConnection;180;0;181;3
WireConnection;180;1;181;4
WireConnection;53;1;49;0
WireConnection;177;0;176;0
WireConnection;177;1;179;0
WireConnection;193;0;192;0
WireConnection;62;0;51;0
WireConnection;62;1;57;0
WireConnection;210;0;204;0
WireConnection;52;0;49;0
WireConnection;66;0;59;0
WireConnection;66;1;52;0
WireConnection;64;0;59;0
WireConnection;64;1;55;0
WireConnection;61;0;56;0
WireConnection;69;0;62;0
WireConnection;141;0;130;0
WireConnection;141;1;142;0
WireConnection;60;0;58;0
WireConnection;63;0;59;0
WireConnection;63;1;53;0
WireConnection;211;0;210;0
WireConnection;194;0;193;0
WireConnection;65;0;54;1
WireConnection;65;1;54;2
WireConnection;178;0;177;0
WireConnection;178;1;180;0
WireConnection;133;0;131;1
WireConnection;133;1;131;2
WireConnection;67;0;63;1
WireConnection;135;0;131;3
WireConnection;135;1;131;4
WireConnection;71;0;66;1
WireConnection;134;0;141;0
WireConnection;134;1;133;0
WireConnection;182;0;178;0
WireConnection;79;0;69;0
WireConnection;68;0;64;1
WireConnection;195;0;211;0
WireConnection;70;0;61;0
WireConnection;70;1;65;0
WireConnection;198;0;194;1
WireConnection;198;1;194;0
WireConnection;73;0;60;0
WireConnection;72;0;54;3
WireConnection;72;1;54;4
WireConnection;83;0;79;2
WireConnection;83;1;79;3
WireConnection;196;0;198;0
WireConnection;196;1;195;0
WireConnection;75;0;67;0
WireConnection;74;0;73;0
WireConnection;76;0;68;0
WireConnection;78;0;70;0
WireConnection;78;1;72;0
WireConnection;157;0;57;0
WireConnection;136;0;134;0
WireConnection;136;1;135;0
WireConnection;199;0;193;0
WireConnection;88;0;79;0
WireConnection;88;1;79;1
WireConnection;77;0;71;0
WireConnection;170;0;182;0
WireConnection;90;0;78;0
WireConnection;186;0;170;0
WireConnection;186;1;187;0
WireConnection;80;0;74;0
WireConnection;93;0;78;0
WireConnection;81;0;78;0
WireConnection;82;0;78;0
WireConnection;89;0;73;0
WireConnection;91;0;78;0
WireConnection;86;0;78;0
WireConnection;85;0;78;0
WireConnection;151;0;157;0
WireConnection;102;0;88;0
WireConnection;102;1;83;0
WireConnection;197;0;196;0
WireConnection;84;0;77;0
WireConnection;84;1;75;0
WireConnection;87;0;78;0
WireConnection;92;0;76;0
WireConnection;92;1;77;0
WireConnection;148;0;136;0
WireConnection;200;0;199;0
WireConnection;108;0;102;0
WireConnection;159;0;151;0
WireConnection;159;1;151;1
WireConnection;159;2;151;2
WireConnection;159;3;151;3
WireConnection;174;0;182;1
WireConnection;201;0;200;0
WireConnection;201;1;197;0
WireConnection;150;0;148;0
WireConnection;100;1;87;0
WireConnection;100;3;84;0
WireConnection;205;0;196;0
WireConnection;95;1;86;0
WireConnection;95;3;77;0
WireConnection;96;1;85;0
WireConnection;96;3;76;0
WireConnection;162;0;59;0
WireConnection;162;1;186;0
WireConnection;97;1;93;0
WireConnection;97;3;76;0
WireConnection;101;1;81;0
WireConnection;101;3;92;0
WireConnection;94;1;91;0
WireConnection;94;3;75;0
WireConnection;103;1;90;0
WireConnection;103;3;75;0
WireConnection;104;1;82;0
WireConnection;104;3;77;0
WireConnection;99;0;89;0
WireConnection;99;1;80;0
WireConnection;149;0;150;0
WireConnection;149;1;148;1
WireConnection;107;0;97;0
WireConnection;107;1;95;0
WireConnection;107;2;94;0
WireConnection;107;3;100;0
WireConnection;113;0;108;0
WireConnection;171;0;162;1
WireConnection;171;1;174;0
WireConnection;106;0;101;0
WireConnection;106;1;104;0
WireConnection;106;2;96;0
WireConnection;106;3;103;0
WireConnection;160;0;159;0
WireConnection;202;0;201;0
WireConnection;206;0;205;0
WireConnection;111;0;98;0
WireConnection;110;0;99;0
WireConnection;117;1;78;0
WireConnection;184;1;178;0
WireConnection;137;0;98;0
WireConnection;137;1;149;0
WireConnection;116;0;107;0
WireConnection;116;1;106;0
WireConnection;118;0;111;1
WireConnection;118;1;110;0
WireConnection;115;2;105;0
WireConnection;161;0;160;0
WireConnection;161;1;113;0
WireConnection;209;0;202;0
WireConnection;209;1;206;0
WireConnection;173;0;171;0
WireConnection;224;0;202;0
WireConnection;119;0;105;0
WireConnection;119;1;115;0
WireConnection;121;0;118;0
WireConnection;121;1;161;0
WireConnection;120;0;116;0
WireConnection;120;1;117;0
WireConnection;225;0;224;0
WireConnection;225;1;209;0
WireConnection;140;0;137;3
WireConnection;185;0;173;0
WireConnection;185;1;184;0
WireConnection;114;0;109;2
WireConnection;114;1;112;0
WireConnection;122;0;114;0
WireConnection;212;0;225;0
WireConnection;212;1;121;0
WireConnection;139;0;119;1
WireConnection;139;1;140;0
WireConnection;183;0;185;0
WireConnection;183;1;120;0
WireConnection;123;0;111;2
WireConnection;123;1;139;0
WireConnection;124;0;212;0
WireConnection;124;1;183;0
WireConnection;125;0;122;0
WireConnection;126;0;124;0
WireConnection;126;1;123;0
WireConnection;127;0;125;0
WireConnection;129;0;127;0
WireConnection;129;1;126;0
WireConnection;1;2;128;0
WireConnection;1;3;129;0
ASEEND*/
//CHKSM=CC2C92E045E33DE53C6CE246674F886D024151DD