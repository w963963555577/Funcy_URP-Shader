// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/LWRP/Environment/Real Water"
{
    Properties
    {
		[HideInInspector]_ReflectionTex("ReflectionTex", 2D) = "white" {}
		[NoScaleOffset]_NormalMap("NormalMap", 2D) = "white" {}
		[NoScaleOffset]_FoamMap("FoamMap", 2D) = "white" {}
		_WaveScale("WaveScale (1=1 meter)", Float) = 1
		_RefractionIntensity("Refraction Intensity", Range( 0 , 1)) = 1
		_FoamIntensity("Foam Intensity", Range( 0 , 1)) = 0
		_WaveSpeed("WaveSpeed", Range( 0.01 , 2.5)) = 0.5
		_WaterDepth("WaterDepth", Range( 0 , 10)) = 1

    }

    SubShader
    {
		LOD 0

		

        Tags { "RenderPipeline"="LightweightPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        Cull Back
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL

		
        Pass
        {
            Tags { "LightMode"="LightweightForward" }
            Name "Base"

            Blend One Zero , One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

            HLSLPROGRAM
            #define _RECEIVE_SHADOWS_OFF 1
            #define ASE_SRP_VERSION 60902
            #define REQUIRE_DEPTH_TEXTURE 1
            #define REQUIRE_OPAQUE_TEXTURE 1

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            // -------------------------------------
            // Lightweight Pipeline keywords
            #pragma shader_feature _SAMPLE_GI

            // -------------------------------------
            // Unity defined keywords
			#ifdef ASE_FOG
            #pragma multi_compile_fog
			#endif
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma vertex vert
            #pragma fragment frag


            // Lighting include is needed because of GI
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/Shaders/UnlitInput.hlsl"

            

			sampler2D _ReflectionTex;
			sampler2D _NormalMap;
			sampler2D _FoamMap;
			uniform float4 _CameraDepthTexture_TexelSize;
			CBUFFER_START( UnityPerMaterial )
			float _WaveSpeed;
			float _WaveScale;
			float _RefractionIntensity;
			float _FoamIntensity;
			float _WaterDepth;
			CBUFFER_END


            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct GraphVertexOutput
            {
                float4 position : POSITION;
				#ifdef ASE_FOG
				float fogCoord : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			

            GraphVertexOutput vert (GraphVertexInput v)
            {
                GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				o.ase_texcoord2.xyz = ase_worldPos;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = v.vertex.xyz;
				#else
				float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue =  defaultVertexValue ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue; 
				#else
				v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal =  v.ase_normal ;
                o.position = TransformObjectToHClip(v.vertex.xyz);
				#ifdef ASE_FOG
				o.fogCoord = ComputeFogFactor( o.position.z );
				#endif
                return o;
            }

            half4 frag (GraphVertexOutput IN ) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
				float4 screenPos = IN.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult31 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 temp_output_70_0 = ( float2( 0.707,0.707 ) * _WaveSpeed );
				float3 ase_worldPos = IN.ase_texcoord2.xyz;
				float2 temp_output_29_0 = ( (( ase_worldPos - (mul( GetObjectToWorldMatrix(), float4(0,0,0,1) )).xyz )).xz / _WaveScale );
				float2 panner11 = ( 0.8146843 * _Time.y * temp_output_70_0 + temp_output_29_0);
				float2 panner23 = ( 0.513432 * _Time.y * float2( 1,0 ) + temp_output_29_0);
				float screenDepth52 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth52 = abs( ( screenDepth52 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _WaterDepth ) );
				float temp_output_55_0 = pow( saturate( ( 1.0 - distanceDepth52 ) ) , 2.0 );
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float4 fetchOpaqueVal59 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( ase_grabScreenPosNorm ), 1.0 );
				
		        float3 Color = ( ( saturate( ( tex2D( _ReflectionTex, ( appendResult31 + ( ( (tex2D( _NormalMap, panner11 )).rg - (tex2D( _NormalMap, panner23 )).rg ) * _RefractionIntensity ) ) ) + float4( ( ( ( (tex2D( _FoamMap, panner11 )).rgb - (tex2D( _FoamMap, panner23 )).rgb ) + float3( 0.2,0.2,0.2 ) ) * _FoamIntensity ) , 0.0 ) ) ) * ( 1.0 - temp_output_55_0 ) ) + ( temp_output_55_0 * fetchOpaqueVal59 ) ).rgb;
		        float Alpha = 1;
		        float AlphaClipThreshold = 0;
			
			#if _AlphaClip
				clip(Alpha - AlphaClipThreshold);
			#endif

			#ifdef ASE_FOG
				Color = MixFog( Color, IN.fogCoord );
			#endif

			#ifdef LOD_FADE_CROSSFADE
				LODDitheringTransition (IN.clipPos.xyz, unity_LODFade.x);
			#endif

                return half4(Color, Alpha);
            }
            ENDHLSL
        }

		
        Pass
        {
			
            Name "DepthOnly"
            Tags { "LightMode"="DepthOnly" }

            ZWrite On
			ZTest LEqual
			ColorMask 0

            HLSLPROGRAM
            #define _RECEIVE_SHADOWS_OFF 1
            #define ASE_SRP_VERSION 60902

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag


            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            

			CBUFFER_START( UnityPerMaterial )
			float _WaveSpeed;
			float _WaveScale;
			float _RefractionIntensity;
			float _FoamIntensity;
			float _WaterDepth;
			CBUFFER_END


			struct GraphVertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

            struct VertexOutput
            {
                float4 clipPos : SV_POSITION;
				
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

			
			VertexOutput vert( GraphVertexInput v  )
			{
					VertexOutput o = (VertexOutput)0;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					
					#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
					#else
					float3 defaultVertexValue = float3(0, 0, 0);
					#endif
					float3 vertexValue =  defaultVertexValue ;	
					#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
					#else
					v.vertex.xyz += vertexValue;
					#endif
					v.ase_normal =  v.ase_normal ;
					o.clipPos = TransformObjectToHClip(v.vertex.xyz);
					return o;
			}

            half4 frag( VertexOutput IN  ) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
				

				float Alpha = 1;
				float AlphaClipThreshold = AlphaClipThreshold;

			#if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
			#endif
                return 0;
			#ifdef LOD_FADE_CROSSFADE
				LODDitheringTransition (IN.clipPos.xyz, unity_LODFade.x);
			#endif
            }
            ENDHLSL
        }
		
    }
    Fallback "Hidden/InternalErrorShader"
	CustomEditor "ASEMaterialInspector"
	
}
/*ASEBEGIN
Version=17500
10;2;1426;844;770.2333;379.6468;1.667779;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;13;-2081.218,8.677368;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComponentMaskNode;39;-576,656;Inherit;True;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;21;-864,240;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;64;944,368;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;38;-864,848;Inherit;True;Property;_TextureSample3;Texture Sample 3;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-2256,144;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;32;-592,-240;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;9;-576,48;Inherit;True;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;0,-304;Inherit;True;Property;_ReflectionTex;ReflectionTex;0;1;[HideInInspector];Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1776,96;Inherit;False;Property;_WaveScale;WaveScale (1=1 meter);3;0;Create;False;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;669.8774,212.4076;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;10;-1296,-160;Inherit;True;Property;_NormalMap;NormalMap;1;1;[NoScaleOffset];Create;True;0;0;False;0;1b785ba7e757439478e6db434e0d3dd2;1b785ba7e757439478e6db434e0d3dd2;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SaturateNode;45;816,224;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;293.3,32.40001;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;1120,528;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;41;-1296,464;Inherit;True;Property;_FoamMap;FoamMap;2;1;[NoScaleOffset];Create;True;0;0;False;0;199d83fd2aca7214481411272c61f368;199d83fd2aca7214481411272c61f368;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;25.35661,652.8711;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;22;-576,240;Inherit;True;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;54;656,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;37;-864,656;Inherit;True;Property;_Sample;Sample;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;71;-2050.351,492.3657;Inherit;False;Property;_WaveSpeed;WaveSpeed;6;0;Create;False;0;0;False;0;0.5;0;0.01;2.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-176,48;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;29;-1488,16;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;42;-320,656;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-368,-240;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;1243.261,261.8271;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-592,-32;Inherit;False;Property;_RefractionIntensity;Refraction Intensity;4;0;Create;False;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-1904,16;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-179.8199,663.3676;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.2,0.2,0.2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;19;-2112,144;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-320,48;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;56;816,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;1050.261,223.8271;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;20;-1728,16;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;40;-576,848;Inherit;True;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DepthFade;52;400,512;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;55;951,516;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;16;-2464,144;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-320,800;Inherit;False;Property;_FoamIntensity;Foam Intensity;5;0;Create;False;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;18;-2432,208;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-864,48;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;66;-38.16115,485.2551;Inherit;False;Property;_WaterDepth;WaterDepth;7;0;Create;False;0;0;False;0;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;11;-1296,48;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.707,0.707;False;1;FLOAT;0.8146843;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;23;-1296,192;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;0.513432;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;59;947,644;Inherit;False;Global;_GrabScreen0;Grab Screen 0;6;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;68;-1958,253;Inherit;False;Constant;_Vector1;Vector 1;7;0;Create;True;0;0;False;0;0.707,0.707;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;25;112,48;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.3,0.3;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;69;-1600,272;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1775.351,379.3657;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;96,-48;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;e2514bdcf5e5399499a9eb24d175b9db;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;96,-48;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;e2514bdcf5e5399499a9eb24d175b9db;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthOnly;True;0;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;1443.224,253.8147;Float;False;True;-1;2;ASEMaterialInspector;0;3;ZDShader/LWRP/Environment/Real Water;e2514bdcf5e5399499a9eb24d175b9db;True;Base;0;0;Base;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;Hidden/InternalErrorShader;0;0;Standard;8;Surface;0;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;Built-in Fog;0;LOD CrossFade;0;Vertex Position,InvertActionOnDeselection;1;0;3;True;False;True;False;;0
WireConnection;39;0;37;0
WireConnection;21;0;10;0
WireConnection;21;1;23;0
WireConnection;64;0;55;0
WireConnection;38;0;41;0
WireConnection;38;1;23;0
WireConnection;17;0;16;0
WireConnection;17;1;18;0
WireConnection;9;0;2;0
WireConnection;43;0;4;0
WireConnection;43;1;48;0
WireConnection;45;0;43;0
WireConnection;4;0;3;0
WireConnection;4;1;25;0
WireConnection;60;0;55;0
WireConnection;60;1;59;0
WireConnection;48;0;49;0
WireConnection;48;1;46;0
WireConnection;22;0;21;0
WireConnection;54;0;52;0
WireConnection;37;0;41;0
WireConnection;37;1;11;0
WireConnection;36;0;35;0
WireConnection;36;1;34;0
WireConnection;29;0;20;0
WireConnection;29;1;27;0
WireConnection;42;0;39;0
WireConnection;42;1;40;0
WireConnection;31;0;32;1
WireConnection;31;1;32;2
WireConnection;65;0;63;0
WireConnection;65;1;60;0
WireConnection;15;0;13;0
WireConnection;15;1;19;0
WireConnection;49;0;42;0
WireConnection;19;0;17;0
WireConnection;35;0;9;0
WireConnection;35;1;22;0
WireConnection;56;0;54;0
WireConnection;63;0;45;0
WireConnection;63;1;64;0
WireConnection;20;0;15;0
WireConnection;40;0;38;0
WireConnection;52;0;66;0
WireConnection;55;0;56;0
WireConnection;2;0;10;0
WireConnection;2;1;11;0
WireConnection;11;0;29;0
WireConnection;11;2;70;0
WireConnection;23;0;29;0
WireConnection;25;0;31;0
WireConnection;25;1;36;0
WireConnection;69;0;70;0
WireConnection;70;0;68;0
WireConnection;70;1;71;0
WireConnection;5;0;65;0
ASEEND*/
//CHKSM=6FAD31CAEADDB9EE3A4027E1EA2CE70D0B51BF4D