// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/LWRP/Environment/ToonWater"
{
    Properties
    {
		_Color("Color", Color) = (0,0,0,0)
		_ColorFar("ColorFar", Color) = (0,0,0,0)
		[NoScaleOffset]_NormalMap("NormalMap", 2D) = "white" {}
		_RefractionScale("Refraction Scale (1=1 meter)", Float) = 1
		_RefractionIntensity("Refraction Intensity", Range( 0 , 1)) = 1
		_WaveSpeed("WaveSpeed", Range( 0.01 , 2.5)) = 0.5
		_WaveDirection("Wave Angle (World Y axis)", Range( 0 , 360)) = 0.5
		[HDR]_FoamColor("FoamColor", Color) = (0,0,0,0)
		[NoScaleOffset]_FoamMap("FoamMap", 2D) = "white" {}
		_FoamScale("Foam Scale (1=1 meter)", Float) = 1
		_Reflection("Reflaction", Range( 0 , 1)) = 0
		_Specular("Specular", Range( 0 , 1)) = 0.882
		_Depth("Depth", Float) = 1
		[HideInInspector]_ReflectionMap("_ReflectionMap", 2D) = "black" {}
		_DepthArea("DepthArea", Float) = 0
		_DepthHard("DepthHard", Float) = 0

    }


    SubShader
    {
		LOD 0

		
        Tags { "RenderPipeline"="LightweightPipeline" "RenderType"="Transparent" "Queue"="Transparent" }

		Cull Off
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL
		
        Pass
        {
        	Tags { "LightMode"="LightweightForward" }

        	Name "Base"
			Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
            
        	HLSLPROGRAM
            #define _RECEIVE_SHADOWS_OFF 1
            #pragma multi_compile_fog
            #define ASE_FOG 1
            #define ASE_SRP_VERSION 60902
            #define REQUIRE_DEPTH_TEXTURE 1
            #define REQUIRE_OPAQUE_TEXTURE 1
            #define _NORMALMAP 1

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

        	// -------------------------------------
            // Lightweight Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            
        	// -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
        	#pragma fragment frag

        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
		
			

			sampler2D _ReflectionMap;
			sampler2D _NormalMap;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _FoamMap;
			CBUFFER_START( UnityPerMaterial )
			float _WaveDirection;
			float _WaveSpeed;
			float _RefractionScale;
			float _RefractionIntensity;
			float _Reflection;
			float4 _Color;
			float4 _ColorFar;
			float _Depth;
			float4 _FoamColor;
			float _FoamScale;
			float _DepthArea;
			float _DepthHard;
			float _Specular;
			CBUFFER_END


            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
                float4 ase_tangent : TANGENT;
                float4 texcoord1 : TEXCOORD1;
				
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct GraphVertexOutput
            {
                float4 clipPos                : SV_POSITION;
                float4 lightmapUVOrVertexSH	  : TEXCOORD0;
        		half4 fogFactorAndVertexLight : TEXCOORD1; // x: fogFactor, yzw: vertex light
            	float4 shadowCoord            : TEXCOORD2;
				float4 tSpace0					: TEXCOORD3;
				float4 tSpace1					: TEXCOORD4;
				float4 tSpace2					: TEXCOORD5;
				float4 ase_texcoord7 : TEXCOORD7;
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
			

            GraphVertexOutput vert (GraphVertexInput v  )
        	{
        		GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
            	UNITY_TRANSFER_INSTANCE_ID(v, o);
        		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord7 = screenPos;
				
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

        		// Vertex shader outputs defined by graph
                float3 lwWNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 lwWorldPos = TransformObjectToWorld(v.vertex.xyz);
				float3 lwWTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 lwWBinormal = normalize(cross(lwWNormal, lwWTangent) * v.ase_tangent.w);
				o.tSpace0 = float4(lwWTangent.x, lwWBinormal.x, lwWNormal.x, lwWorldPos.x);
				o.tSpace1 = float4(lwWTangent.y, lwWBinormal.y, lwWNormal.y, lwWorldPos.y);
				o.tSpace2 = float4(lwWTangent.z, lwWBinormal.z, lwWNormal.z, lwWorldPos.z);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                
         		// We either sample GI from lightmap or SH.
        	    // Lightmap UV and vertex SH coefficients use the same interpolator ("float2 lightmapUV" for lightmap or "half3 vertexSH" for SH)
                // see DECLARE_LIGHTMAP_OR_SH macro.
        	    // The following funcions initialize the correct variable with correct data
        	    OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
        	    OUTPUT_SH(lwWNormal, o.lightmapUVOrVertexSH.xyz);

        	    half3 vertexLight = VertexLighting(vertexInput.positionWS, lwWNormal);
			#ifdef ASE_FOG
        	    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
			#else
				half fogFactor = 0;
			#endif
        	    o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
        	    o.clipPos = vertexInput.positionCS;

        	#ifdef _MAIN_LIGHT_SHADOWS
        		o.shadowCoord = GetShadowCoord(vertexInput);
        	#endif
        		return o;
        	}

        	half4 frag (GraphVertexOutput IN  ) : SV_Target
            {
            	UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

        		float3 WorldSpaceNormal = normalize(float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z));
				float3 WorldSpaceTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldSpaceBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldSpacePosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldSpaceViewDirection = SafeNormalize( _WorldSpaceCameraPos.xyz  - WorldSpacePosition );
    
				float4 screenPos = IN.ase_texcoord7;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult31 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float temp_output_218_0 = ( ( _WaveDirection * PI ) / 180.0 );
				float2 appendResult214 = (float2(cos( temp_output_218_0 ) , sin( temp_output_218_0 )));
				float2 temp_output_70_0 = ( appendResult214 * _WaveSpeed );
				float2 temp_output_20_0 = (( WorldSpacePosition - (mul( GetObjectToWorldMatrix(), float4(0,0,0,1) )).xyz )).xz;
				float2 panner11 = ( 0.8146843 * _Time.y * temp_output_70_0 + temp_output_20_0);
				float2 uv_Ref085 = ( panner11 / _RefractionScale );
				float4 tex2DNode2 = tex2D( _NormalMap, uv_Ref085 );
				float2 appendResult75 = (float2(( length( temp_output_70_0 ) * -1.0 ) , 0.0));
				float2 panner23 = ( 0.513432 * _Time.y * appendResult75 + temp_output_20_0);
				float2 uv_Ref186 = ( panner23 / _RefractionScale );
				float4 tex2DNode21 = tex2D( _NormalMap, uv_Ref186 );
				float screenDepth112 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth112 = abs( ( screenDepth112 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depth ) );
				float temp_output_115_0 = saturate( distanceDepth112 );
				float4 lerpResult207 = lerp( _Color , _ColorFar , pow( temp_output_115_0 , 1.5 ));
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float4 fetchOpaqueVal111 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( ase_grabScreenPosNorm ), 1.0 );
				float4 lerpResult109 = lerp( ( ( tex2D( _ReflectionMap, ( appendResult31 + ( ( (tex2DNode2).rg - (tex2DNode21).rg ) * _RefractionIntensity ) ) ) * _Reflection ) + lerpResult207 ) , fetchOpaqueVal111 , ( 1.0 - temp_output_115_0 ));
				float2 uv_Foam0134 = ( panner11 / _FoamScale );
				float2 uv_Foam1135 = ( panner23 / _FoamScale );
				float screenDepth52 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth52 = abs( ( screenDepth52 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthArea ) );
				float depthArea90 = ( pow( saturate( ( 1.0 - distanceDepth52 ) ) , _DepthHard ) * 5.0 );
				float fresnelNdotV129 = dot( WorldSpaceNormal, WorldSpaceViewDirection );
				float fresnelNode129 = ( 0.0 + 0.65 * pow( 1.0 - fresnelNdotV129, 1.0 ) );
				float temp_output_102_0 = saturate( ( (( (tex2D( _FoamMap, uv_Foam0134 )).rgb + ( (tex2D( _FoamMap, uv_Foam1135 )).rgb * float3( 0.5,0.5,0.5 ) ) )).x * depthArea90 * fresnelNode129 ) );
				float4 lerpResult118 = lerp( lerpResult109 , ( _FoamColor * temp_output_102_0 ) , temp_output_102_0);
				
				
		        float3 Albedo = lerpResult118.rgb;
				float3 Normal = UnpackNormalScale( ( tex2DNode2 * tex2DNode21 ), 1.0 );
				float3 Emission = 0;
				float3 Specular = float3(0.5, 0.5, 0.5);
				float Metallic = 0;
				float Smoothness = _Specular;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0;

        		InputData inputData;
        		inputData.positionWS = WorldSpacePosition;

        #ifdef _NORMALMAP
        	    inputData.normalWS = normalize(TransformTangentToWorld(Normal, half3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal)));
        #else
            #if !SHADER_HINT_NICE_QUALITY
                inputData.normalWS = WorldSpaceNormal;
            #else
        	    inputData.normalWS = normalize(WorldSpaceNormal);
            #endif
        #endif

			#if !SHADER_HINT_NICE_QUALITY
        	    // viewDirection should be normalized here, but we avoid doing it as it's close enough and we save some ALU.
        	    inputData.viewDirectionWS = WorldSpaceViewDirection;
			#else
        	    inputData.viewDirectionWS = normalize(WorldSpaceViewDirection);
			#endif

        	    inputData.shadowCoord = IN.shadowCoord;
			#ifdef ASE_FOG
        	    inputData.fogCoord = IN.fogFactorAndVertexLight.x;
			#endif
        	    inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
        	    inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS);

        		half4 color = LightweightFragmentPBR(
        			inputData, 
        			Albedo, 
        			Metallic, 
        			Specular, 
        			Smoothness, 
        			Occlusion, 
        			Emission, 
        			Alpha);

		#ifdef ASE_FOG
			#ifdef TERRAIN_SPLAT_ADDPASS
				color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
			#else
				color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
			#endif
		#endif

        #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
		
		#ifdef LOD_FADE_CROSSFADE
				LODDitheringTransition (IN.clipPos.xyz, unity_LODFade.x);
		#endif
        		return color;
            }

        	ENDHLSL
        }

	
    }
    Fallback "Hidden/InternalErrorShader"
	CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.ToonWater"
	
}
/*ASEBEGIN
Version=17500
9;11;1426;838;567.5428;-1355.476;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;83;-5437.193,489.9264;Inherit;False;1623.743;646.2594;Wave Animation;12;71;75;81;69;70;211;212;213;214;215;217;218;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-5424,592;Inherit;False;Property;_WaveDirection;Wave Angle (World Y axis);6;0;Create;False;0;0;False;0;0.5;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;215;-5405.72,718.86;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;217;-5226.059,695.7402;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;218;-5130.031,588.8594;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;213;-4992,672;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;84;-3517.929,-849.2041;Inherit;False;2102.859;1578.865;Wave UV;19;86;85;130;29;27;23;11;20;15;19;13;17;18;16;131;132;133;134;135;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CosOpNode;212;-4992,592;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-4882.45,825.9262;Inherit;False;Property;_WaveSpeed;WaveSpeed;5;0;Create;False;0;0;False;0;0.5;1.28;0.01;2.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;214;-4800,608;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;18;-3453.929,-513.204;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;16;-3469.929,-593.204;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-3245.929,-593.204;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-4658.451,601.9264;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;19;-3037.929,-593.204;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;13;-3021.929,-801.2041;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LengthOpNode;69;-4450.451,841.9262;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-2765.929,-705.2041;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-4258.452,841.9262;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;75;-4034.452,841.9262;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;20;-2557.929,-705.2041;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;11;-2317.929,-705.2041;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.707,0.707;False;1;FLOAT;0.8146843;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;23;-2317.929,-481.204;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;0.513432;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2336,-240;Inherit;False;Property;_RefractionScale;Refraction Scale (1=1 meter);3;0;Create;False;0;0;False;0;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-2336,448;Inherit;False;Property;_FoamScale;Foam Scale (1=1 meter);9;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;130;-1952,-480;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;29;-1949.929,-705.2041;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;209;-1328,1920;Inherit;False;Property;_DepthArea;DepthArea;14;0;Create;True;0;0;False;0;0;5.86;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;-1728,-480;Inherit;False;uv_Ref1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;133;-1952,208;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;89;-1165,1856;Inherit;False;1335.996;513.6545;Depth Area;7;90;74;56;79;54;52;210;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-1728,-704;Inherit;False;uv_Ref0;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;82;-1275.39,839.4171;Inherit;False;2127.772;833.7234;Foam;16;94;102;106;97;91;49;39;80;37;40;38;92;93;41;110;129;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;132;-1952,-16;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;135;-1728,208;Inherit;False;uv_Foam1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;87;-1088,48;Inherit;False;85;uv_Ref0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DepthFade;52;-1120,1904;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;10;-1075.2,-164.8;Inherit;True;Property;_NormalMap;NormalMap;2;1;[NoScaleOffset];Create;True;0;0;False;0;1b785ba7e757439478e6db434e0d3dd2;1b785ba7e757439478e6db434e0d3dd2;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-1088,240;Inherit;False;86;uv_Ref1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;2;-864,48;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;134;-1728,-16;Inherit;False;uv_Foam0;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;54;-880,1904;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;21;-864,240;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;93;-1210.403,1331.334;Inherit;False;135;uv_Foam1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;41;-1206.682,938.7628;Inherit;True;Property;_FoamMap;FoamMap;8;1;[NoScaleOffset];Create;True;0;0;False;0;199d83fd2aca7214481411272c61f368;94b2470d29df55e4fad7f0aee4b2243f;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-736,2000;Inherit;False;Property;_DepthHard;DepthHard;15;0;Create;True;0;0;False;0;0;20.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-1210.403,1139.334;Inherit;False;134;uv_Foam0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;38;-966.6823,1338.763;Inherit;True;Property;_TextureSample3;Texture Sample 3;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;56;-720,1904;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;9;-576,48;Inherit;True;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;22;-576,240;Inherit;True;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;32;-592,-240;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;37;-966.6823,1146.763;Inherit;True;Property;_Sample;Sample;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-320,48;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;205;-639.9858,2732.357;Inherit;False;Property;_Depth;Depth;12;0;Create;True;0;0;False;0;1;12.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;79;-560,1904;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-848,464;Inherit;False;Property;_RefractionIntensity;Refraction Intensity;4;0;Create;False;0;0;False;0;1;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;40;-662.6819,1338.763;Inherit;True;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;39;-662.6819,1146.763;Inherit;True;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-422.6818,1338.763;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.5,0.5,0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-112,48;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-304,1904;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-368,-240;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DepthFade;112;-493.0876,2613.38;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;115;-34.42147,2598.469;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-406.6818,1034.763;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.2,0.2,0.2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;193.5145,1684.293;Inherit;True;Property;_ReflectionMap;_ReflectionMap;13;1;[HideInInspector];Create;True;0;0;False;0;None;None;False;black;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;138.7,-138.8;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.3,0.3;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-96,1904;Inherit;False;depthArea;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;203;512,1888;Inherit;False;Property;_Reflection;Reflaction;10;0;Create;False;0;0;False;0;0;0.65;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-192,1360;Inherit;False;90;depthArea;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;96;576,1984;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;0,0,0,0;0.2743414,0.4245283,0.4236125,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;479,1696;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;97;-198.6819,1066.763;Inherit;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;208;217.103,2437.588;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;206;576,2160;Inherit;False;Property;_ColorFar;ColorFar;1;0;Create;True;0;0;False;0;0,0,0,0;0.2803489,0.7924528,0.5530276,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;129;21.20695,1379.604;Inherit;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.65;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;805.4005,1723.904;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;48,1072;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;207;806.1319,2052.515;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;111;836.0999,2343.6;Inherit;False;Global;_GrabScreen0;Grab Screen 0;8;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;120;985.1805,1722.876;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;94;208,880;Inherit;False;Property;_FoamColor;FoamColor;7;1;[HDR];Create;True;0;0;False;0;0,0,0,0;12.42353,23.96863,14.43137,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;116;125.5785,2598.469;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;102;265.3181,1066.763;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;187;819.5617,2894;Inherit;False;847.4383;360.4009;Vertex Offset;6;181;182;183;185;186;191;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-320,272;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;496,880;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;109;1039.269,2024.116;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;186;1424,2944;Inherit;False;vertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;1176.712,3111.744;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.2,0.2,0.2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;182;1023.736,3084.962;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;118;1367.375,1195.316;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;146;-30.73234,362.4954;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;191;1098.321,2933.142;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;145;1541.751,1096.161;Inherit;False;Property;_Specular;Specular;11;0;Create;True;0;0;False;0;0.882;0.94;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;185;1311.018,2950.76;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinTimeNode;181;869.5617,3075.401;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;201;2489.415,915.616;Float;False;False;-1;2;ASEMaterialInspector;0;2;New Amplify Shader;1976390536c6c564abb90fe41f6ee334;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;200;2489.415,915.616;Float;False;False;-1;2;ASEMaterialInspector;0;2;New Amplify Shader;1976390536c6c564abb90fe41f6ee334;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;202;2489.415,915.616;Float;False;False;-1;2;ASEMaterialInspector;0;2;New Amplify Shader;1976390536c6c564abb90fe41f6ee334;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;199;2489.415,915.616;Float;False;True;-1;2;UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.ToonWater;0;2;ZDShader/LWRP/Environment/ToonWater;1976390536c6c564abb90fe41f6ee334;True;Base;0;0;Base;11;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;Hidden/InternalErrorShader;0;0;Standard;10;Workflow;1;Surface;1;  Blend;0;Two Sided;0;Cast Shadows;0;Receive Shadows;0;LOD CrossFade;0;Built-in Fog;1;Meta Pass;0;Vertex Position,InvertActionOnDeselection;1;0;4;True;False;False;False;False;;0
WireConnection;217;0;211;0
WireConnection;217;1;215;0
WireConnection;218;0;217;0
WireConnection;213;0;218;0
WireConnection;212;0;218;0
WireConnection;214;0;212;0
WireConnection;214;1;213;0
WireConnection;17;0;16;0
WireConnection;17;1;18;0
WireConnection;70;0;214;0
WireConnection;70;1;71;0
WireConnection;19;0;17;0
WireConnection;69;0;70;0
WireConnection;15;0;13;0
WireConnection;15;1;19;0
WireConnection;81;0;69;0
WireConnection;75;0;81;0
WireConnection;20;0;15;0
WireConnection;11;0;20;0
WireConnection;11;2;70;0
WireConnection;23;0;20;0
WireConnection;23;2;75;0
WireConnection;130;0;23;0
WireConnection;130;1;27;0
WireConnection;29;0;11;0
WireConnection;29;1;27;0
WireConnection;86;0;130;0
WireConnection;133;0;23;0
WireConnection;133;1;131;0
WireConnection;85;0;29;0
WireConnection;132;0;11;0
WireConnection;132;1;131;0
WireConnection;135;0;133;0
WireConnection;52;0;209;0
WireConnection;2;0;10;0
WireConnection;2;1;87;0
WireConnection;134;0;132;0
WireConnection;54;0;52;0
WireConnection;21;0;10;0
WireConnection;21;1;88;0
WireConnection;38;0;41;0
WireConnection;38;1;93;0
WireConnection;56;0;54;0
WireConnection;9;0;2;0
WireConnection;22;0;21;0
WireConnection;37;0;41;0
WireConnection;37;1;92;0
WireConnection;35;0;9;0
WireConnection;35;1;22;0
WireConnection;79;0;56;0
WireConnection;79;1;210;0
WireConnection;40;0;38;0
WireConnection;39;0;37;0
WireConnection;80;0;40;0
WireConnection;36;0;35;0
WireConnection;36;1;34;0
WireConnection;74;0;79;0
WireConnection;31;0;32;1
WireConnection;31;1;32;2
WireConnection;112;0;205;0
WireConnection;115;0;112;0
WireConnection;49;0;39;0
WireConnection;49;1;80;0
WireConnection;25;0;31;0
WireConnection;25;1;36;0
WireConnection;90;0;74;0
WireConnection;4;0;3;0
WireConnection;4;1;25;0
WireConnection;97;0;49;0
WireConnection;208;0;115;0
WireConnection;204;0;4;0
WireConnection;204;1;203;0
WireConnection;106;0;97;0
WireConnection;106;1;91;0
WireConnection;106;2;129;0
WireConnection;207;0;96;0
WireConnection;207;1;206;0
WireConnection;207;2;208;0
WireConnection;120;0;204;0
WireConnection;120;1;207;0
WireConnection;116;0;115;0
WireConnection;102;0;106;0
WireConnection;147;0;2;0
WireConnection;147;1;21;0
WireConnection;110;0;94;0
WireConnection;110;1;102;0
WireConnection;109;0;120;0
WireConnection;109;1;111;0
WireConnection;109;2;116;0
WireConnection;186;0;185;0
WireConnection;183;0;182;0
WireConnection;182;1;181;4
WireConnection;118;0;109;0
WireConnection;118;1;110;0
WireConnection;118;2;102;0
WireConnection;146;0;147;0
WireConnection;185;0;191;0
WireConnection;185;1;183;0
WireConnection;199;0;118;0
WireConnection;199;1;146;0
WireConnection;199;4;145;0
ASEEND*/
//CHKSM=6186939F007BAE9F41D1E4DD86F88EB5AD1644D0