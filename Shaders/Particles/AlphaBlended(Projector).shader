// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/URP/Particles/Alpha Blended(Projector)"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[ASEBegin][HDR]_TintColor("Tint Color", Color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
		[IntRange]_StencilRef("StencilRef", Range( 0 , 255)) = 10
		[ASEEnd][Enum(UnityEngine.Rendering.CompareFunction)]_StencilCompare("StencilCompare", Float) = 3

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Front
		AlphaToMask Off
		Stencil
		{
			Ref [_StencilRef]
			Comp [_StencilCompare]
			Pass Keep
			Fail Keep
			ZFail Keep
		}
		HLSLINCLUDE
		#pragma target 2.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 
		
		ENDHLSL
		
		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Cull Front
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest GEqual
			Offset 0 , 0
			ColorMask RGBA
			
			
			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 70503

			
			#pragma vertex vert
			#pragma fragment frag
			
			#define REQUIRE_DEPTH_TEXTURE 1

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex: POSITION;
				float3 ase_normal: NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos: SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos: TEXCOORD0;
				#endif

				float4 screenUV: TEXCOORD1;
				float4 viewRayOS: TEXCOORD2;
				float3 cameraPosOS: TEXCOORD3;

				#ifdef ASE_FOG
					float fogFactor: TEXCOORD4;
				#endif
				float3 ps_Parm :TEXCOORD5;
				float4 ase_color : COLOR;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4x4 _w2o;
			float4 _TintColor;
			float _StencilRef;
			float _StencilCompare;
			CBUFFER_END
			sampler2D _MainTex;


			
			float2 rotate2D(float2 uv, half2 pivot, half angle)
			{
				float c = cos(angle);
				float s = sin(angle);
				return mul(uv - pivot, float2x2(c, -s, s, c)) + pivot;
			}

			float2 projectorUV(float4 viewRayOS, float3 cameraPosOS, float4 screenUV, float2 scale, float rotateAngle)
			{
				viewRayOS /= viewRayOS.w;
				screenUV /= screenUV.w;
				#if defined(UNITY_SINGLE_PASS_STEREO)
					screenUV.xy = UnityStereoTransformScreenSpaceTex(screenUV.xy);
				#endif
				float depthQ = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(screenUV.xy), _ZBufferParams);
				
				float depth = depthQ;
				
				
				float3 decalSpaceScenePos = cameraPosOS + viewRayOS.xyz * depth;
				decalSpaceScenePos.xz = rotate2D(decalSpaceScenePos.xz, 0.0.xx, rotateAngle);
				decalSpaceScenePos.xz /= scale;
				float2 decalSpaceUV = decalSpaceScenePos.xz + 0.5;
				
				
				//  Clip decal to volume
				clip(float3(0.5, 0.5, 0.5) - abs(decalSpaceScenePos.xyz));
				
				// sample the decal texture
				return decalSpaceUV.xy;
			}

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 w2oR032 = _w2o[0];
				
				float4 w2oR126 = _w2o[1];
				
				float4 w2oR234 = _w2o[2];
				
				float4 w2oR330 = _w2o[3];
				
				float4 appendResult11 = (float4((v.ase_texcoord).xyz , 1.0));
				float3 ps_center33 = (mul( _w2o, appendResult11 )).xyz;
				
				float2 ps_size29 = (v.ase_texcoord2).xz;
				
				float ps_rotate31 = (v.ase_texcoord1).y;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord6 = v.ase_texcoord;
				
				float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
				float4 positionCS = TransformWorldToHClip(positionWS);

				float4 screenPos = ComputeScreenPos(positionCS);
				o.screenUV = screenPos;

				float3 vr = mul(UNITY_MATRIX_V, float4(positionWS, 1.0)).xyz;
				o.viewRayOS.w = vr.z;

				float4x4 w2o = GetWorldToObjectMatrix();

				float4 w2oC0 = w2oR032;
				float4 w2oC1 = w2oR126;
				float4 w2oC2 = w2oR234;
				float4 w2oC3 = w2oR330;

				w2o._11_12_13_14 = w2oC0;
				w2o._21_22_23_24 = w2oC1;
				w2o._31_32_33_34 = w2oC2;
				w2o._41_42_43_44 = w2oC3;

				float4x4 ViewToObjectMatrix = mul(w2o, UNITY_MATRIX_I_V);
				o.viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, -vr);

				float3 centerDetla = ps_center33;
				o.cameraPosOS = ViewToObjectMatrix._m03_m13_m23 - centerDetla;
				
				float2 scale = ps_size29;
				float rotate = ps_rotate31;
				o.ps_Parm.xy = scale;
				o.ps_Parm.z = -rotate;

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor(positionCS.z);
				#endif
				o.clipPos = positionCS;
				return o;
			}

			half4 frag(VertexOutput IN ): SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif
				
				float2 uv = projectorUV(IN.viewRayOS, IN.cameraPosOS, IN.screenUV, IN.ps_Parm.xy, IN.ps_Parm.z);

				float4 temp_output_16_0 = ( IN.ase_color * _TintColor * tex2D( _MainTex, uv ) );
				float3 appendResult24 = (float3(temp_output_16_0.rgb));
				float3 OutColor27 = appendResult24;
				
				float OutAlpha28 = (temp_output_16_0).a;
				
				
				float3 Color = OutColor27;
				float Alpha = OutAlpha28;

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition(IN.clipPos.xyz, unity_LODFade.x);
				#endif

				#ifdef ASE_FOG
					Color = MixFog(Color, IN.fogFactor);
				#endif

				return half4(Color, Alpha);
			}
			
			ENDHLSL
			
		}

		
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 70503

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			float4x4 _w2o;
			float4 _TintColor;
			float _StencilRef;
			float _StencilCompare;
			CBUFFER_END
			sampler2D _MainTex;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 appendResult11 = (float4((v.ase_texcoord).xyz , 1.0));
				float3 ps_center33 = (mul( _w2o, appendResult11 )).xyz;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord2 = v.ase_texcoord;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ps_center33;
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

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif

				float4 temp_output_16_0 = ( IN.ase_color * _TintColor * tex2D( _MainTex, IN.ase_texcoord2.xy ) );
				float OutAlpha28 = (temp_output_16_0).a;
				
				float Alpha = OutAlpha28;

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 1;
			}
			ENDHLSL
		}

	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
-1816;122;1655;738;1675.044;355.2821;1.61747;True;False
Node;AmplifyShaderEditor.CommentaryNode;3;-48,464;Inherit;False;1078.708;1403.063;ParticleSystem Parameter;21;34;33;32;31;30;29;26;23;22;21;20;19;18;17;15;14;13;12;11;7;4;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;4;0,1024;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;5;-1920,0;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;6;-1920,128;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;None;085e2551690daee499b93a4f09bf8ba0;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SwizzleNode;7;256,1024;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;10;-1664,128;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;8;-1664,-384;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;9;-1664,-128;Inherit;False;Property;_TintColor;Tint Color;0;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0.7686275,1.113726,1.317647,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Matrix4X4Node;12;0,1280;Inherit;False;Property;_w2o;_w2o;2;0;Create;True;0;0;0;False;0;False;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.DynamicAppendNode;11;384,1152;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-1280,0;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;512,1152;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;25;-1152,128;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;17;512,1024;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;768,1024;Inherit;False;ps_center;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-1024,128;Inherit;False;OutAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;640,1280;Inherit;False;w2oR0;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;640,1536;Inherit;False;w2oR2;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-640,128;Inherit;False;34;w2oR2;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-640,-128;Inherit;False;32;w2oR0;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;23;384,1536;Inherit;False;Row;2;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;39;-640,-384;Inherit;False;27;OutColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1920,512;Inherit;False;Property;_StencilRef;StencilRef;3;1;[IntRange];Create;True;0;0;0;True;0;False;10;10;0;255;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-640,640;Inherit;False;31;ps_rotate;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-640,512;Inherit;False;29;ps_size;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1920,640;Inherit;False;Property;_StencilCompare;StencilCompare;4;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-640,256;Inherit;False;30;w2oR3;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-640,-256;Inherit;False;28;OutAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;768,512;Inherit;False;ps_rotate;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-640,0;Inherit;False;26;w2oR1;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;768,768;Inherit;False;ps_size;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-1024,0;Inherit;False;OutColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;640,1408;Inherit;False;w2oR1;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;24;-1152,0;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-640,384;Inherit;False;33;ps_center;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;22;384,1280;Inherit;False;Row;0;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;21;256,512;Inherit;False;FLOAT;1;2;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;20;384,1664;Inherit;False;Row;3;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;19;256,768;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VectorFromMatrixNode;18;384,1408;Inherit;False;Row;1;1;0;FLOAT4x4;1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;14;0,512;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;13;0,768;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;640,1664;Inherit;False;w2oR3;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;d9a07a90db7fc20418f0da16c269dae8;True;SceneSelectionPass;0;1;SceneSelectionPass;1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;1;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;0,0;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;18;ZDShader/URP/Particles/Alpha Blended(Projector);d9a07a90db7fc20418f0da16c269dae8;True;Forward;0;0;Forward;9;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;1;False;-1;False;False;False;False;False;False;False;False;True;True;True;10;True;40;255;False;-1;255;False;-1;7;True;43;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;4;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;5;  Blend;0;0;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;0;2;True;True;False;;False;0
WireConnection;7;0;4;0
WireConnection;10;0;6;0
WireConnection;10;1;5;0
WireConnection;10;7;6;1
WireConnection;11;0;7;0
WireConnection;16;0;8;0
WireConnection;16;1;9;0
WireConnection;16;2;10;0
WireConnection;15;0;12;0
WireConnection;15;1;11;0
WireConnection;25;0;16;0
WireConnection;17;0;15;0
WireConnection;33;0;17;0
WireConnection;28;0;25;0
WireConnection;32;0;22;0
WireConnection;34;0;23;0
WireConnection;23;0;12;0
WireConnection;31;0;21;0
WireConnection;29;0;19;0
WireConnection;27;0;24;0
WireConnection;26;0;18;0
WireConnection;24;0;16;0
WireConnection;22;0;12;0
WireConnection;21;0;14;0
WireConnection;20;0;12;0
WireConnection;19;0;13;0
WireConnection;18;0;12;0
WireConnection;30;0;20;0
WireConnection;1;2;39;0
WireConnection;1;3;38;0
WireConnection;1;10;36;0
WireConnection;1;11;37;0
WireConnection;1;12;35;0
WireConnection;1;13;44;0
WireConnection;1;5;45;0
WireConnection;1;7;42;0
WireConnection;1;8;41;0
ASEEND*/
//CHKSM=8606DDC7AEC27FDCBCB8339F5FE6392B459BD1A1