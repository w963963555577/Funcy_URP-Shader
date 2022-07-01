// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/URP/Terrain/4 Textures"
{
	Properties
	{
		[Toggle(_USEOPACITYMASK_ON)] _useOpacityMask("useOpacityMask", Float) = 0

		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_Splat0("Layer 1", 2D) = "white" {}
		_Splat1("Layer 2", 2D) = "white" {}
		_Splat2("Layer 3", 2D) = "white" {}
		_Splat3("Layer 4", 2D) = "white" {}
		_Normal0("Normalmap 1", 2D) = "bump" {}
		_Normal1("Normalmap 2", 2D) = "bump" {}
		_Normal2("Normalmap 3", 2D) = "bump" {}
		_Normal3("Normalmap 4", 2D) = "bump" {}
		[Gamma]_Metallic0("Metallic 1", Range( 0 , 1)) = 0
		[Gamma]_Metallic1("Metallic 2", Range( 0 , 1)) = 0
		[Gamma]_Metallic2("Metallic 3", Range( 0 , 1)) = 0
		[Gamma]_Metallic3("Metallic 4", Range( 0 , 1)) = 0
		_Smoothness0("Smoothness 1", Range( 0 , 1)) = 0.5
		_Smoothness1("Smoothness 2", Range( 0 , 1)) = 0.5
		_Smoothness2("Smoothness 3", Range( 0 , 1)) = 0.5
		_Smoothness3("Smoothness 4", Range( 0 , 1)) = 0.5
		_Control("Control", 2D) = "white" {}
		_NormalIntensity0("Normal Intensity 1", Range( 0.01 , 10)) = 1
		_NormalIntensity1("Normal Intensity 2", Range( 0.01 , 10)) = 1
		_NormalIntensity2("Normal Intensity 3", Range( 0.01 , 10)) = 1
		_NormalIntensity3("Normal Intensity 4", Range( 0.01 , 10)) = 1

		[Space(20)][Toggle(_CLOSEFADE_ON)] _CloseFade("Enable CloseFade", Float) = 0
	}

	SubShader
	{
		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
	LOD 0
		Cull Back
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL
		// ExtraPrePass
		UsePass "Hidden/Nature/Terrain/Utilities/PICKING"
	UsePass "Hidden/Nature/Terrain/Utilities/SELECTION"

		Pass
		{
			
			Name "Forward"
			
			Tags { "LightMode"="Terrain" }
			
			Blend One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			Stencil
			{
				Ref 10
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}

			HLSLPROGRAM
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70503
			#define ASE_USING_SAMPLING_MACROS 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x 
			#pragma multi_compile_fog

			 //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#define _MAIN_LIGHT_SHADOWS 1
			//#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#define _MAIN_LIGHT_SHADOWS_CASCADE 1
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			//#pragma multi_compile _ _SHADOWS_SOFT
			#define _SHADOWS_SOFT 1
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE


			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif
			#pragma shader_feature_local _USEOPACITYMASK_ON
			#pragma multi_compile_fragment _ _DISABLE_PRE_Z
			#pragma shader_feature_local _CLOSEFADE_ON
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_FOG 1
			#define _BlendOutput
			#pragma multi_compile_instancing
			#pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap forwardadd


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactor : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION) || defined(ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED) || defined(_CLOSEFADE_ON)
				float4 screenPos : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Control_ST;
			half4 _Splat0_ST;
			half4 _Splat1_ST;
			half4 _Splat2_ST;
			half4 _Splat3_ST;
			float _Metallic1;
			float _Metallic0;
			half _NormalIntensity3;
			half _NormalIntensity2;
			half _NormalIntensity1;
			float _Smoothness3;
			float _Metallic2;
			float _Smoothness2;
			float _Smoothness1;
			float _Smoothness0;
			half _NormalIntensity0;
			float _Metallic3;
			TEXTURE2D(_Control);
			SAMPLER(sampler_Control);
			TEXTURE2D(_Splat0);
			SAMPLER(sampler_Splat0);
			TEXTURE2D(_Splat1);
			SAMPLER(sampler_Splat1);
			TEXTURE2D(_Splat2);
			SAMPLER(sampler_Splat2);
			TEXTURE2D(_Splat3);
			SAMPLER(sampler_Splat3);
			TEXTURE2D(_Normal0);
			SAMPLER(sampler_Normal0);
			TEXTURE2D(_Normal1);
			SAMPLER(sampler_Normal1);
			TEXTURE2D(_Normal2);
			SAMPLER(sampler_Normal2);
			TEXTURE2D(_Normal3);
			SAMPLER(sampler_Normal3);
			TEXTURE2D(UniversalOpaqueGBuffer1);
			SAMPLER(samplerUniversalOpaqueGBuffer1);
			#ifdef UNITY_INSTANCING_ENABLED//ASE Terrain Instancing
				TEXTURE2D(_TerrainHeightmapTexture);//ASE Terrain Instancing
				TEXTURE2D( _TerrainNormalmapTexture);//ASE Terrain Instancing
				SAMPLER(sampler_TerrainNormalmapTexture);//ASE Terrain Instancing
			#endif//ASE Terrain Instancing
			UNITY_INSTANCING_BUFFER_START( Terrain )//ASE Terrain Instancing
				UNITY_DEFINE_INSTANCED_PROP( float4, _TerrainPatchInstanceData )//ASE Terrain Instancing
			UNITY_INSTANCING_BUFFER_END( Terrain)//ASE Terrain Instancing
			CBUFFER_START( UnityTerrain)//ASE Terrain Instancing
				#ifdef UNITY_INSTANCING_ENABLED//ASE Terrain Instancing
					float4 _TerrainHeightmapRecipSize;//ASE Terrain Instancing
					float4 _TerrainHeightmapScale;//ASE Terrain Instancing
				#endif//ASE Terrain Instancing
			CBUFFER_END//ASE Terrain Instancing

			CBUFFER_END

			float4 WeightedBlend4143( half4 Weight, float4 Layer1, float4 Layer2, float4 Layer3, float4 Layer4 )
			{
				return Layer1 * Weight.r + Layer2 * Weight.g + Layer3 * Weight.b + Layer4 * Weight.a;
			}
			
			inline half3 MTE_NormalIntensity_fixed154( half3 Normal, half Strength )
			{
				return  lerp(Normal, float3(0,0,1), - Strength + 1.0);
			}
			
			inline half3 MTE_NormalIntensity_fixed151( half3 Normal, half Strength )
			{
				return  lerp(Normal, float3(0,0,1), - Strength + 1.0);
			}
			
			inline half3 MTE_NormalIntensity_fixed148( half3 Normal, half Strength )
			{
				return  lerp(Normal, float3(0,0,1), - Strength + 1.0);
			}
			
			inline half3 MTE_NormalIntensity_fixed145( half3 Normal, half Strength )
			{
				return  lerp(Normal, float3(0,0,1), - Strength + 1.0);
			}
			
			float4 WeightedBlend489( half4 Weight, float4 Layer1, float4 Layer2, float4 Layer3, float4 Layer4 )
			{
				return Layer1 * Weight.r + Layer2 * Weight.g + Layer3 * Weight.b + Layer4 * Weight.a;
			}
			
			VertexInput ApplyMeshModification( VertexInput v )
			{
			#ifdef UNITY_INSTANCING_ENABLED
				float2 patchVertex = v.vertex.xy;
				float4 instanceData = UNITY_ACCESS_INSTANCED_PROP( Terrain, _TerrainPatchInstanceData );
				float2 sampleCoords = ( patchVertex.xy + instanceData.xy ) * instanceData.z;
				float height = UnpackHeightmap( _TerrainHeightmapTexture.Load( int3( sampleCoords, 0 ) ) );
				v.vertex.xz = sampleCoords* _TerrainHeightmapScale.xz;
				v.vertex.y = height* _TerrainHeightmapScale.y;
				#ifdef ENABLE_TERRAIN_PERPIXEL_NORMAL
					v.ase_normal = float3(0, 1, 0);
				#else
					v.ase_normal = _TerrainNormalmapTexture.Load(int3(sampleCoords, 0)).rgb* 2 - 1;
				#endif
				v.ase_texcoord.xy = sampleCoords* _TerrainHeightmapRecipSize.zw;
			#endif
				return v;
			}
			

			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				v = ApplyMeshModification(v);
				o.ase_texcoord7.xy = v.ase_texcoord.xy;
				o.ase_texcoord8 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
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
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				#ifdef ASE_FOG
					half4 fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half4 fogFactor = 0;
				#endif
				o.fogFactor = fogFactor;
				
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				o.clipPos = positionCS;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION) || defined(ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED) || defined(_CLOSEFADE_ON)
				o.screenPos = ComputeScreenPos(positionCS);
				#endif
				return o;
			}
			
			half4 frag ( VertexOutput IN
			#ifdef _MRT_GBUFFER0
			,out half4 gbuffer:SV_Target1
			#endif
			 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 WorldNormal = normalize( IN.tSpace0.xyz );
				float3 WorldTangent = IN.tSpace1.xyz;
				float3 WorldBiTangent = IN.tSpace2.xyz;
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float camDist = distance(float3(0, 0, 0), WorldViewDirection);
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION) || defined(ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED) || defined(_CLOSEFADE_ON)
				float4 ScreenPos = IN.screenPos;
				float4 screenPosNrm = ScreenPos / ScreenPos.w;
				screenPosNrm.z = (UNITY_NEAR_CLIP_VALUE >= 0) ? screenPosNrm.z : screenPosNrm.z * 0.5 + 0.5;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif
	
				#if SHADER_HINT_NICE_QUALITY
					WorldViewDirection = SafeNormalize( WorldViewDirection );
				#endif

				half4 localBreakRGBA115 = ( float4( 0,0,0,0 ) );
				half2 uv_Control = IN.ase_texcoord7.xy * _Control_ST.xy + _Control_ST.zw;
				half4 tex2DNode6 = SAMPLE_TEXTURE2D( _Control, sampler_Control, uv_Control );
				float4 Weight143 = tex2DNode6;
				half2 uv_Splat0 = IN.ase_texcoord7.xy * _Splat0_ST.xy + _Splat0_ST.zw;
				half4 appendResult123 = (half4(1.0 , 1.0 , 1.0 , _Smoothness0));
				float4 Layer1143 = ( SAMPLE_TEXTURE2D( _Splat0, sampler_Splat0, uv_Splat0 ) * appendResult123 );
				half2 uv_Splat1 = IN.ase_texcoord7.xy * _Splat1_ST.xy + _Splat1_ST.zw;
				half4 appendResult126 = (half4(1.0 , 1.0 , 1.0 , _Smoothness1));
				float4 Layer2143 = ( SAMPLE_TEXTURE2D( _Splat1, sampler_Splat1, uv_Splat1 ) * appendResult126 );
				half2 uv_Splat2 = IN.ase_texcoord7.xy * _Splat2_ST.xy + _Splat2_ST.zw;
				half4 appendResult129 = (half4(1.0 , 1.0 , 1.0 , _Smoothness2));
				float4 Layer3143 = ( SAMPLE_TEXTURE2D( _Splat2, sampler_Splat2, uv_Splat2 ) * appendResult129 );
				half2 uv_Splat3 = IN.ase_texcoord7.xy * _Splat3_ST.xy + _Splat3_ST.zw;
				half4 appendResult131 = (half4(1.0 , 1.0 , 1.0 , _Smoothness3));
				float4 Layer4143 = ( SAMPLE_TEXTURE2D( _Splat3, sampler_Splat3, uv_Splat3 ) * appendResult131 );
				float4 localWeightedBlend4143 = WeightedBlend4143( Weight143 , Layer1143 , Layer2143 , Layer3143 , Layer4143 );
				half4 RGBA115 = localWeightedBlend4143;
				half3 RGB115 = float3( 0,0,0 );
				half A115 = 0;
				{
				RGB115 = RGBA115.rgb;
				A115 = RGBA115.a;
				}
				
				float4 Weight89 = tex2DNode6;
				half3 Normal154 = UnpackNormalScale( SAMPLE_TEXTURE2D( _Normal0, sampler_Normal0, uv_Splat0 ), 1.0f );
				half Strength154 = _NormalIntensity0;
				half3 localMTE_NormalIntensity_fixed154 = MTE_NormalIntensity_fixed154( Normal154 , Strength154 );
				float4 Layer189 = float4( localMTE_NormalIntensity_fixed154 , 0.0 );
				half3 Normal151 = UnpackNormalScale( SAMPLE_TEXTURE2D( _Normal1, sampler_Normal1, uv_Splat1 ), 1.0f );
				half Strength151 = _NormalIntensity1;
				half3 localMTE_NormalIntensity_fixed151 = MTE_NormalIntensity_fixed151( Normal151 , Strength151 );
				float4 Layer289 = float4( localMTE_NormalIntensity_fixed151 , 0.0 );
				half3 Normal148 = UnpackNormalScale( SAMPLE_TEXTURE2D( _Normal2, sampler_Normal2, uv_Splat2 ), 1.0f );
				half Strength148 = _NormalIntensity2;
				half3 localMTE_NormalIntensity_fixed148 = MTE_NormalIntensity_fixed148( Normal148 , Strength148 );
				float4 Layer389 = float4( localMTE_NormalIntensity_fixed148 , 0.0 );
				half3 Normal145 = UnpackNormalScale( SAMPLE_TEXTURE2D( _Normal3, sampler_Normal3, uv_Splat3 ), 1.0f );
				half Strength145 = _NormalIntensity3;
				half3 localMTE_NormalIntensity_fixed145 = MTE_NormalIntensity_fixed145( Normal145 , Strength145 );
				float4 Layer489 = float4( localMTE_NormalIntensity_fixed145 , 0.0 );
				float4 localWeightedBlend489 = WeightedBlend489( Weight89 , Layer189 , Layer289 , Layer389 , Layer489 );
				
				half4 appendResult137 = (half4(_Metallic0 , _Metallic1 , _Metallic2 , _Metallic3));
				half dotResult136 = dot( tex2DNode6 , appendResult137 );
				
				half2 appendResult201 = (half2(screenPosNrm.x , screenPosNrm.y));
				half4 tex2DNode196 = SAMPLE_TEXTURE2D( UniversalOpaqueGBuffer1, samplerUniversalOpaqueGBuffer1, appendResult201 );
				half screenDepth206 = tex2DNode196.a;
				half3 objToWorld2_g1 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord8.xyz, 1 ) ).xyz;
				half3 worldToView13_g1 = mul( UNITY_MATRIX_V, float4( objToWorld2_g1, 1 ) ).xyz;
				half smoothstepResult212 = smoothstep( 0.5 , 0.0 , ( ( ( screenDepth206 / -worldToView13_g1.z ) - 1.0 ) * ( ( _WorldSpaceCameraPos.y - objToWorld2_g1.y ) + 10.0 ) ));
				half clearArea218 = ( 1.0 - step( ( tex2DNode196.r + tex2DNode196.g + tex2DNode196.b ) , 0.0 ) );
				half4 appendResult198 = (half4(tex2DNode196.rgb , ( smoothstepResult212 * clearArea218 )));
				
				float3 Albedo = RGB115;
				float3 Normal = localWeightedBlend489.xyz;
				float3 Emission = 0;
				float Metallic = dotResult136;
				float Smoothness = ( A115 * 0.0 );
				float Specular = 0.5;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;


				#ifdef _USEOPACITYMASK_ON
				#ifdef _CLOSEFADE_ON
					float disAlpha = saturate((camDist - DistFadeNear) / (DistFadeFar - DistFadeNear) );
					float2 clipSC = screenPosNrm.xy * _ScreenParams.xy;
					float dither = DitherBayer(clipSC);
					Alpha *= step( dither, disAlpha * disAlpha);
				#endif
				
				#if defined(_ALPHATEST_ON) || defined(_CLOSEFADE_ON)
				#ifdef _DISABLE_PRE_Z
					clip(Alpha - AlphaClipThreshold);
				#endif
				#endif
				#endif
				

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					inputData.normalWS = normalize(TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal )));
				#else
					#if !SHADER_HINT_NICE_QUALITY
						inputData.normalWS = WorldNormal;
					#else
						inputData.normalWS = normalize( WorldNormal );
					#endif
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactor.x;
				#endif

				inputData.vertexLighting = 1.0;//IN.fogFactor.yzw;
				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
				#if ASE_SRP_VERSION >= 100000
				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);
				#endif
				half4 color = UniversalFragmentPBR(
					inputData, 
					Albedo, 
					Metallic, 
					Specular, 
					Smoothness, 
					Occlusion, 
					Emission, 
					Alpha);
				#ifdef _BlendOutput
					half4 blendOutput =  appendResult198;
					color.rgb = lerp(color.rgb, blendOutput.rgb, blendOutput.a);
				#endif
				#ifdef ASE_FOG
					color.rgb = MixFog( color.rgb, inputData.fogCoord );
				#endif
				#ifdef _MRT_GBUFFER0
				gbuffer = float4(0.0, 0.0, 0.0, 0.0);
				#endif
				return color;
			}

			ENDHLSL
		}

		// Pass ShadowCaster
		UsePass "Hidden/Nature/Terrain/Utilities/PICKING"
	UsePass "Hidden/Nature/Terrain/Utilities/SELECTION"

		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70503
			#define ASE_USING_SAMPLING_MACROS 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x 
			#pragma shader_feature_local _USEOPACITYMASK_ON 

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION
			#pragma multi_compile_instancing
			#pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap forwardadd


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
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Control_ST;
			half4 _Splat0_ST;
			half4 _Splat1_ST;
			half4 _Splat2_ST;
			half4 _Splat3_ST;
			float _Metallic1;
			float _Metallic0;
			half _NormalIntensity3;
			half _NormalIntensity2;
			half _NormalIntensity1;
			float _Smoothness3;
			float _Metallic2;
			float _Smoothness2;
			float _Smoothness1;
			float _Smoothness0;
			half _NormalIntensity0;
			float _Metallic3;
			#ifdef UNITY_INSTANCING_ENABLED//ASE Terrain Instancing
				TEXTURE2D(_TerrainHeightmapTexture);//ASE Terrain Instancing
				TEXTURE2D( _TerrainNormalmapTexture);//ASE Terrain Instancing
				SAMPLER(sampler_TerrainNormalmapTexture);//ASE Terrain Instancing
			#endif//ASE Terrain Instancing
			UNITY_INSTANCING_BUFFER_START( Terrain )//ASE Terrain Instancing
				UNITY_DEFINE_INSTANCED_PROP( float4, _TerrainPatchInstanceData )//ASE Terrain Instancing
			UNITY_INSTANCING_BUFFER_END( Terrain)//ASE Terrain Instancing
			CBUFFER_START( UnityTerrain)//ASE Terrain Instancing
				#ifdef UNITY_INSTANCING_ENABLED//ASE Terrain Instancing
					float4 _TerrainHeightmapRecipSize;//ASE Terrain Instancing
					float4 _TerrainHeightmapScale;//ASE Terrain Instancing
				#endif//ASE Terrain Instancing
			CBUFFER_END//ASE Terrain Instancing

			CBUFFER_END

			VertexInput ApplyMeshModification( VertexInput v )
			{
			#ifdef UNITY_INSTANCING_ENABLED
				float2 patchVertex = v.vertex.xy;
				float4 instanceData = UNITY_ACCESS_INSTANCED_PROP( Terrain, _TerrainPatchInstanceData );
				float2 sampleCoords = ( patchVertex.xy + instanceData.xy ) * instanceData.z;
				float height = UnpackHeightmap( _TerrainHeightmapTexture.Load( int3( sampleCoords, 0 ) ) );
				v.vertex.xz = sampleCoords* _TerrainHeightmapScale.xz;
				v.vertex.y = height* _TerrainHeightmapScale.y;
				#ifdef ENABLE_TERRAIN_PERPIXEL_NORMAL
					v.ase_normal = float3(0, 1, 0);
				#else
					v.ase_normal = _TerrainNormalmapTexture.Load(int3(sampleCoords, 0)).rgb* 2 - 1;
				#endif
				v.ase_texcoord.xy = sampleCoords* _TerrainHeightmapRecipSize.zw;
			#endif
				return v;
			}
			
			
			float3 _LightDirection;

			VertexOutput vert( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				v = ApplyMeshModification(v);
				o.ase_texcoord2 = v.ase_texcoord;
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
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
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

				
				#ifdef _USEOPACITYMASK_ON
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif
				#endif
				
				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}

			ENDHLSL
		}

		// Pass DepthOnly
		UsePass "Hidden/Nature/Terrain/Utilities/PICKING"
	UsePass "Hidden/Nature/Terrain/Utilities/SELECTION"

		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70503
			#define ASE_USING_SAMPLING_MACROS 1

			#pragma shader_feature_local _USEOPACITYMASK_ON 

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION
			#pragma multi_compile_instancing
			#pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap forwardadd

			

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
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Control_ST;
			half4 _Splat0_ST;
			half4 _Splat1_ST;
			half4 _Splat2_ST;
			half4 _Splat3_ST;
			float _Metallic1;
			float _Metallic0;
			half _NormalIntensity3;
			half _NormalIntensity2;
			half _NormalIntensity1;
			float _Smoothness3;
			float _Metallic2;
			float _Smoothness2;
			float _Smoothness1;
			float _Smoothness0;
			half _NormalIntensity0;
			float _Metallic3;
			#ifdef UNITY_INSTANCING_ENABLED//ASE Terrain Instancing
				TEXTURE2D(_TerrainHeightmapTexture);//ASE Terrain Instancing
				TEXTURE2D( _TerrainNormalmapTexture);//ASE Terrain Instancing
				SAMPLER(sampler_TerrainNormalmapTexture);//ASE Terrain Instancing
			#endif//ASE Terrain Instancing
			UNITY_INSTANCING_BUFFER_START( Terrain )//ASE Terrain Instancing
				UNITY_DEFINE_INSTANCED_PROP( float4, _TerrainPatchInstanceData )//ASE Terrain Instancing
			UNITY_INSTANCING_BUFFER_END( Terrain)//ASE Terrain Instancing
			CBUFFER_START( UnityTerrain)//ASE Terrain Instancing
				#ifdef UNITY_INSTANCING_ENABLED//ASE Terrain Instancing
					float4 _TerrainHeightmapRecipSize;//ASE Terrain Instancing
					float4 _TerrainHeightmapScale;//ASE Terrain Instancing
				#endif//ASE Terrain Instancing
			CBUFFER_END//ASE Terrain Instancing

			CBUFFER_END

			VertexInput ApplyMeshModification( VertexInput v )
			{
			#ifdef UNITY_INSTANCING_ENABLED
				float2 patchVertex = v.vertex.xy;
				float4 instanceData = UNITY_ACCESS_INSTANCED_PROP( Terrain, _TerrainPatchInstanceData );
				float2 sampleCoords = ( patchVertex.xy + instanceData.xy ) * instanceData.z;
				float height = UnpackHeightmap( _TerrainHeightmapTexture.Load( int3( sampleCoords, 0 ) ) );
				v.vertex.xz = sampleCoords* _TerrainHeightmapScale.xz;
				v.vertex.y = height* _TerrainHeightmapScale.y;
				#ifdef ENABLE_TERRAIN_PERPIXEL_NORMAL
					v.ase_normal = float3(0, 1, 0);
				#else
					v.ase_normal = _TerrainNormalmapTexture.Load(int3(sampleCoords, 0)).rgb* 2 - 1;
				#endif
				v.ase_texcoord.xy = sampleCoords* _TerrainHeightmapRecipSize.zw;
			#endif
				return v;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				v = ApplyMeshModification(v);
				o.ase_texcoord2 = v.ase_texcoord;
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

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#ifdef _USEOPACITYMASK_ON
				#ifdef _ALPHATEST_ON
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

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				clip(Alpha - AlphaClipThreshold);
				
				#endif
				#endif
				
				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				
				return 0;
			}
			ENDHLSL
		}

		// Pass SceneSelectionPass
		UsePass "Hidden/Nature/Terrain/Utilities/PICKING"
	UsePass "Hidden/Nature/Terrain/Utilities/SELECTION"

		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 70503
			#define ASE_USING_SAMPLING_MACROS 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x 

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_POSITION
			#pragma multi_compile_instancing
			#pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap forwardadd


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
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
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			half4 _Control_ST;
			half4 _Splat0_ST;
			half4 _Splat1_ST;
			half4 _Splat2_ST;
			half4 _Splat3_ST;
			float _Metallic1;
			float _Metallic0;
			half _NormalIntensity3;
			half _NormalIntensity2;
			half _NormalIntensity1;
			float _Smoothness3;
			float _Metallic2;
			float _Smoothness2;
			float _Smoothness1;
			float _Smoothness0;
			half _NormalIntensity0;
			float _Metallic3;
			TEXTURE2D(_Control);
			SAMPLER(sampler_Control);
			TEXTURE2D(_Splat0);
			SAMPLER(sampler_Splat0);
			TEXTURE2D(_Splat1);
			SAMPLER(sampler_Splat1);
			TEXTURE2D(_Splat2);
			SAMPLER(sampler_Splat2);
			TEXTURE2D(_Splat3);
			SAMPLER(sampler_Splat3);
			#ifdef UNITY_INSTANCING_ENABLED//ASE Terrain Instancing
				TEXTURE2D(_TerrainHeightmapTexture);//ASE Terrain Instancing
				TEXTURE2D( _TerrainNormalmapTexture);//ASE Terrain Instancing
				SAMPLER(sampler_TerrainNormalmapTexture);//ASE Terrain Instancing
			#endif//ASE Terrain Instancing
			UNITY_INSTANCING_BUFFER_START( Terrain )//ASE Terrain Instancing
				UNITY_DEFINE_INSTANCED_PROP( float4, _TerrainPatchInstanceData )//ASE Terrain Instancing
			UNITY_INSTANCING_BUFFER_END( Terrain)//ASE Terrain Instancing
			CBUFFER_START( UnityTerrain)//ASE Terrain Instancing
				#ifdef UNITY_INSTANCING_ENABLED//ASE Terrain Instancing
					float4 _TerrainHeightmapRecipSize;//ASE Terrain Instancing
					float4 _TerrainHeightmapScale;//ASE Terrain Instancing
				#endif//ASE Terrain Instancing
			CBUFFER_END//ASE Terrain Instancing

			CBUFFER_END

			float4 WeightedBlend4143( half4 Weight, float4 Layer1, float4 Layer2, float4 Layer3, float4 Layer4 )
			{
				return Layer1 * Weight.r + Layer2 * Weight.g + Layer3 * Weight.b + Layer4 * Weight.a;
			}
			
			VertexInput ApplyMeshModification( VertexInput v )
			{
			#ifdef UNITY_INSTANCING_ENABLED
				float2 patchVertex = v.vertex.xy;
				float4 instanceData = UNITY_ACCESS_INSTANCED_PROP( Terrain, _TerrainPatchInstanceData );
				float2 sampleCoords = ( patchVertex.xy + instanceData.xy ) * instanceData.z;
				float height = UnpackHeightmap( _TerrainHeightmapTexture.Load( int3( sampleCoords, 0 ) ) );
				v.vertex.xz = sampleCoords* _TerrainHeightmapScale.xz;
				v.vertex.y = height* _TerrainHeightmapScale.y;
				#ifdef ENABLE_TERRAIN_PERPIXEL_NORMAL
					v.ase_normal = float3(0, 1, 0);
				#else
					v.ase_normal = _TerrainNormalmapTexture.Load(int3(sampleCoords, 0)).rgb* 2 - 1;
				#endif
				v.ase_texcoord.xy = sampleCoords* _TerrainHeightmapRecipSize.zw;
			#endif
				return v;
			}
			

			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				v = ApplyMeshModification(v);
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				
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
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
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

				half4 localBreakRGBA115 = ( float4( 0,0,0,0 ) );
				half2 uv_Control = IN.ase_texcoord2.xy * _Control_ST.xy + _Control_ST.zw;
				half4 tex2DNode6 = SAMPLE_TEXTURE2D( _Control, sampler_Control, uv_Control );
				float4 Weight143 = tex2DNode6;
				half2 uv_Splat0 = IN.ase_texcoord2.xy * _Splat0_ST.xy + _Splat0_ST.zw;
				half4 appendResult123 = (half4(1.0 , 1.0 , 1.0 , _Smoothness0));
				float4 Layer1143 = ( SAMPLE_TEXTURE2D( _Splat0, sampler_Splat0, uv_Splat0 ) * appendResult123 );
				half2 uv_Splat1 = IN.ase_texcoord2.xy * _Splat1_ST.xy + _Splat1_ST.zw;
				half4 appendResult126 = (half4(1.0 , 1.0 , 1.0 , _Smoothness1));
				float4 Layer2143 = ( SAMPLE_TEXTURE2D( _Splat1, sampler_Splat1, uv_Splat1 ) * appendResult126 );
				half2 uv_Splat2 = IN.ase_texcoord2.xy * _Splat2_ST.xy + _Splat2_ST.zw;
				half4 appendResult129 = (half4(1.0 , 1.0 , 1.0 , _Smoothness2));
				float4 Layer3143 = ( SAMPLE_TEXTURE2D( _Splat2, sampler_Splat2, uv_Splat2 ) * appendResult129 );
				half2 uv_Splat3 = IN.ase_texcoord2.xy * _Splat3_ST.xy + _Splat3_ST.zw;
				half4 appendResult131 = (half4(1.0 , 1.0 , 1.0 , _Smoothness3));
				float4 Layer4143 = ( SAMPLE_TEXTURE2D( _Splat3, sampler_Splat3, uv_Splat3 ) * appendResult131 );
				float4 localWeightedBlend4143 = WeightedBlend4143( Weight143 , Layer1143 , Layer2143 , Layer3143 , Layer4143 );
				half4 RGBA115 = localWeightedBlend4143;
				half3 RGB115 = float3( 0,0,0 );
				half A115 = 0;
				{
				RGB115 = RGBA115.rgb;
				A115 = RGBA115.a;
				}
				
				
				float3 Albedo = RGB115;
				float3 Emission = 0;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = Albedo;
				metaInput.Emission = Emission;
				
				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
	}
	
	
	CustomEditor "ASEMaterialInspector"
	Fallback "Hidden/InternalErrorShader"
	
}/*ASEBEGIN
Version=18935
-1969;123;1655;958;663.9625;971.01;1.3;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;19;-1654.834,-945.6718;Float;True;Property;_Splat0;Layer 1;0;0;Create;False;0;0;0;False;0;False;None;4b47b0a6c0fb56042a6e27b906c6b094;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;37;-1644.116,-562.9706;Float;True;Property;_Splat1;Layer 2;1;0;Create;False;0;0;0;False;0;False;None;6af61a2daa217d14bbf5cf8041ed4a01;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;45;-1629.877,346.9561;Float;True;Property;_Splat3;Layer 4;3;0;Create;False;0;0;0;False;0;False;None;455c87dd3c6f56a4998dba3853d6d06a;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;41;-1642.848,-129.2168;Float;True;Property;_Splat2;Layer 3;2;0;Create;False;0;0;0;False;0;False;None;d48257dc68085d747ab2a99002e5f91d;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;60;-1082.58,536.8337;Float;False;Property;_Smoothness3;Smoothness 4;15;0;Create;False;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-1116.138,-464.2166;Float;False;Property;_Smoothness1;Smoothness 2;13;0;Create;False;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1121.69,-946.0693;Float;False;Property;_Smoothness0;Smoothness 1;12;0;Create;False;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-1366.124,-928.462;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;-1370.47,-39.30476;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;40;-1390.519,-501.1515;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-1360.079,420.9971;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;59;-1096.556,44.96426;Float;False;Property;_Smoothness2;Smoothness 3;14;0;Create;False;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;103;-1635.359,-1358.877;Float;True;Property;_Control;Control;16;0;Create;True;0;0;0;False;0;False;None;3c72930315517eb46b6440ee0d4463f8;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;38;-1116.809,-655.905;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;104;-1381.158,-1291.34;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;123;-832.7972,-1031.363;Inherit;False;FLOAT4;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;126;-824.8046,-534.9642;Inherit;False;FLOAT4;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;5;-1134.41,-1133.135;Inherit;True;Property;_Splat0;Splat0;0;0;Create;True;0;0;0;False;0;False;-1;None;4b47b0a6c0fb56042a6e27b906c6b094;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;129;-808.5327,-33.82042;Inherit;False;FLOAT4;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;43;-1108.139,-160.4059;Inherit;True;Property;_TextureSample3;Texture Sample 3;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;91;-1089.493,340.7771;Inherit;True;Property;_TextureSample6;Texture Sample 6;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;131;-767.1368,532.3789;Inherit;False;FLOAT4;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;6;-1133.791,-1356.361;Inherit;True;Property;_CC;CC;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-654.09,377.8167;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-706.6159,-1080.008;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;-694.8233,-589.3093;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-659.7041,-78.93899;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;141;63.05293,338.143;Inherit;False;807.571;421.6749;Comment;6;56;137;53;136;58;61;Metaillic (not used);0.5882353,0.5882353,0.5921569,1;0;0
Node;AmplifyShaderEditor.CustomExpressionNode;143;77.52283,-600.254;Float;False;return Layer1 * Weight.r + Layer2 * Weight.g + Layer3 * Weight.b + Layer4 * Weight.a@;4;Create;5;True;Weight;FLOAT4;0,0,0,0;In;float[5];Half;False;True;Layer1;FLOAT4;0,0,0,0;In;;Float;False;True;Layer2;FLOAT4;0,0,0,0;In;;Float;False;True;Layer3;FLOAT4;0,0,0,0;In;;Float;False;True;Layer4;FLOAT4;0,0,0,0;In;;Float;False;Weighted Blend 4;True;False;0;;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;58;119.1456,558.5928;Float;False;Property;_Metallic2;Metallic 3;10;1;[Gamma];Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;148;-528.2087,234.9157;Inherit;False; lerp(Normal, float3(0,0,1), - Strength + 1.0);3;Create;2;True;Normal;FLOAT3;0,0,0;In;;Inherit;False;True;Strength;FLOAT;1;In;;Inherit;False;MTE_NormalIntensity_fixed;True;False;0;;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;53;112,400;Float;False;Property;_Metallic0;Metallic 1;8;1;[Gamma];Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;217;-134,885;Inherit;True;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;89;78.64703,-406.7304;Float;False;return Layer1 * Weight.r + Layer2 * Weight.g + Layer3 * Weight.b + Layer4 * Weight.a@;4;Create;5;True;Weight;FLOAT4;0,0,0,0;In;float[5];Half;False;True;Layer1;FLOAT4;0,0,0,0;In;;Float;False;True;Layer2;FLOAT4;0,0,0,0;In;;Float;False;True;Layer3;FLOAT4;0,0,0,0;In;;Float;False;True;Layer4;FLOAT4;0,0,0,0;In;;Float;False;Weighted Blend 4;True;False;0;;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;237;-128,1536;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;136;589.9938,458.1799;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-774.8143,757.0594;Inherit;False;Property;_NormalIntensity3;Normal Intensity 4;20;0;Create;False;0;0;0;False;0;False;1;1;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;122.3741,649.6501;Float;False;Property;_Metallic3;Metallic 4;11;1;[Gamma];Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;228;128,896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;39;-1119.519,-373.9468;Inherit;True;Property;_Normal1;Normalmap 2;5;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;44;-1097.987,131.5944;Inherit;True;Property;_Normal2;Normalmap 3;6;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;56;113.0531,479.3678;Float;False;Property;_Metallic1;Metallic 2;9;1;[Gamma];Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;-896,1536;Inherit;False;206;screenDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;219;-512,1664;Inherit;False;218;clearArea;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;115;291.5545,-625.0408;Inherit;False;RGB = RGBA.rgb@$A = RGBA.a@;7;Create;3;True;RGBA;FLOAT4;0,0,0,0;In;;Inherit;False;True;RGB;FLOAT3;0,0,0;Out;;Inherit;False;True;A;FLOAT;0;Out;;Inherit;False;BreakRGBA;False;False;0;;False;4;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;3;FLOAT4;0;FLOAT3;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;218;256,896;Inherit;False;clearArea;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-845.6536,-757.6703;Inherit;False;Property;_NormalIntensity0;Normal Intensity 1;17;0;Create;False;0;0;0;False;0;False;1;1;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;196;-512,1024;Inherit;True;Property;_TextureSample0;Texture Sample 0;22;0;Create;True;0;0;0;False;0;False;195;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;206;-155.3,1106.5;Inherit;False;screenDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;161;616.5988,-286.2784;Inherit;False;Constant;_Float0;Float 0;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;199;614.0848,-315.2182;Inherit;False;Constant;_Color0;Color 0;23;0;Create;True;0;0;0;False;0;False;0.6698113,0.3134717,0.3134717,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;48;-1084.439,630.5511;Inherit;True;Property;_Normal3;Normalmap 4;7;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;200;-896,1280;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;145;-501.0876,738.4252;Inherit;False; lerp(Normal, float3(0,0,1), - Strength + 1.0);3;Create;2;True;Normal;FLOAT3;0,0,0;In;;Inherit;False;True;Strength;FLOAT;1;In;;Inherit;False;MTE_NormalIntensity_fixed;True;False;0;;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-829.4495,-263.3238;Inherit;False;Property;_NormalIntensity1;Normal Intensity 2;18;0;Create;False;0;0;0;False;0;False;1;1;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;214;-256,896;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-801.9351,253.55;Inherit;False;Property;_NormalIntensity2;Normal Intensity 3;19;0;Create;False;0;0;0;False;0;False;1;1;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;16;-1129.263,-866.5981;Inherit;True;Property;_Normal0;Normalmap 1;4;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;201;-640,1280;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;212;-384,1536;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;137;441.5179,480.4901;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;195;-896,1024;Inherit;True;Global;UniversalOpaqueGBuffer1;UniversalOpaqueGBuffer1;21;0;Create;True;0;0;0;False;0;False;None;;False;black;LockedToTexture2D;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;238;-640,1536;Inherit;False;HeightDepth;-1;;1;b9577529e1aad6b41b40db01c6b47b7c;0;2;14;FLOAT;0;False;16;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;198;512,1024;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;240;989.6375,-270.3101;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;151;-555.7234,-281.9581;Inherit;False; lerp(Normal, float3(0,0,1), - Strength + 1.0);3;Create;2;True;Normal;FLOAT3;0,0,0;In;;Inherit;False;True;Strength;FLOAT;1;In;;Inherit;False;MTE_NormalIntensity_fixed;True;False;0;;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;154;-584.8986,-784.5592;Inherit;False; lerp(Normal, float3(0,0,1), - Strength + 1.0);3;Create;2;True;Normal;FLOAT3;0,0,0;In;;Inherit;False;True;Strength;FLOAT;1;In;;Inherit;False;MTE_NormalIntensity_fixed;True;False;0;;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;183;896,-640;Float;False;False;-1;2;ASEMaterialInspector;200;18;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;182;896,-640;Float;False;False;-1;2;ASEMaterialInspector;200;18;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;180;896,-512;Float;False;False;-1;2;ASEMaterialInspector;200;18;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;ExtraPrePass;0;0;ExtraPrePass;10;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;False;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Hidden/InternalErrorShader;0;0;Standard;3;Built-in Fog;1;0;Blend Output;0;0;MRT Output;0;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;239;1408,-512;Float;False;False;-1;2;ASEMaterialInspector;200;1;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;SceneSelectionPass;0;4;SceneSelectionPass;5;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;False;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;181;1408,-512;Half;False;True;-1;2;ASEMaterialInspector;0;18;ZDShader/URP/Terrain/4 Textures;9f53fdc6bec2ee94397ba2956dd3cfbc;True;Forward;0;1;Forward;13;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;False;0;True;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;True;10;False;-1;255;False;-1;255;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Terrain;False;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Hidden/InternalErrorShader;0;0;Standard;10;Alpha Test;0;0;Cast Shadows;1;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;1;0;DOTS Instancing;0;0;Vertex Position,InvertActionOnDeselection;1;0;Extra Pre Pass;0;637915729906819298;Scene Selectioin Pass;0;0;Vertex Position ExtraPass,InvertActionOnDeselection;1;0;3;Built-in Fog;1;0;Blend Output;1;637915766595369150;MRT Output;0;0;6;False;True;True;True;False;True;True;;True;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;184;896,-512;Float;False;False;-1;2;ASEMaterialInspector;200;18;New Amplify Shader;9f53fdc6bec2ee94397ba2956dd3cfbc;True;Meta;0;5;Meta;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;28;2;19;0
WireConnection;42;2;41;0
WireConnection;40;2;37;0
WireConnection;46;2;45;0
WireConnection;38;0;37;0
WireConnection;38;1;40;0
WireConnection;38;7;37;1
WireConnection;104;2;103;0
WireConnection;123;3;54;0
WireConnection;126;3;57;0
WireConnection;5;0;19;0
WireConnection;5;1;28;0
WireConnection;5;7;19;1
WireConnection;129;3;59;0
WireConnection;43;0;41;0
WireConnection;43;1;42;0
WireConnection;43;7;41;1
WireConnection;91;0;45;0
WireConnection;91;1;46;0
WireConnection;91;7;45;1
WireConnection;131;3;60;0
WireConnection;6;0;103;0
WireConnection;6;1;104;0
WireConnection;6;7;103;1
WireConnection;130;0;91;0
WireConnection;130;1;131;0
WireConnection;125;0;5;0
WireConnection;125;1;123;0
WireConnection;127;0;38;0
WireConnection;127;1;126;0
WireConnection;128;0;43;0
WireConnection;128;1;129;0
WireConnection;143;0;6;0
WireConnection;143;1;125;0
WireConnection;143;2;127;0
WireConnection;143;3;128;0
WireConnection;143;4;130;0
WireConnection;148;0;44;0
WireConnection;148;1;147;0
WireConnection;217;0;214;0
WireConnection;89;0;6;0
WireConnection;89;1;154;0
WireConnection;89;2;151;0
WireConnection;89;3;148;0
WireConnection;89;4;145;0
WireConnection;237;0;212;0
WireConnection;237;1;219;0
WireConnection;136;0;6;0
WireConnection;136;1;137;0
WireConnection;228;0;217;0
WireConnection;39;1;40;0
WireConnection;44;1;42;0
WireConnection;115;1;143;0
WireConnection;218;0;228;0
WireConnection;196;0;195;0
WireConnection;196;1;201;0
WireConnection;206;0;196;4
WireConnection;48;1;46;0
WireConnection;145;0;48;0
WireConnection;145;1;144;0
WireConnection;214;0;196;1
WireConnection;214;1;196;2
WireConnection;214;2;196;3
WireConnection;16;1;28;0
WireConnection;201;0;200;1
WireConnection;201;1;200;2
WireConnection;212;0;238;0
WireConnection;137;0;53;0
WireConnection;137;1;56;0
WireConnection;137;2;58;0
WireConnection;137;3;61;0
WireConnection;238;14;207;0
WireConnection;198;0;196;0
WireConnection;198;3;237;0
WireConnection;240;0;115;4
WireConnection;151;0;39;0
WireConnection;151;1;150;0
WireConnection;154;0;16;0
WireConnection;154;1;153;0
WireConnection;181;0;115;3
WireConnection;181;1;89;0
WireConnection;181;3;136;0
WireConnection;181;4;240;0
WireConnection;181;181;198;0
ASEEND*/
//CHKSM=46B66D8C14411B86B63245250D927CA9634B08A7