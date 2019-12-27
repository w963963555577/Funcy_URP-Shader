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
		_Depth("Depth", Float) = 1
		_Specular("Specular", Range( 0 , 1)) = 0
		[HideInInspector]_ReflectionMap("_ReflectionMap", 2D) = "black" {}
		_DepthArea("DepthArea", Float) = 0
		_DepthHard("DepthHard", Float) = 0
		[HDR]_SpecularColor("SpecularColor", Color) = (1,1,1,0)

    }

    SubShader
    {
		LOD 0

		

        Tags { "RenderPipeline"="LightweightPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        Cull Back
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL

		
        Pass
        {
            Tags { "LightMode"="LightweightForward" }
            Name "Base"

            Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
			ZWrite Off
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

            

			sampler2D _NormalMap;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _ReflectionMap;
			sampler2D _FoamMap;
			CBUFFER_START( UnityPerMaterial )
			float _WaveDirection;
			float _WaveSpeed;
			float _RefractionScale;
			float _Specular;
			float _Depth;
			float4 _SpecularColor;
			float _RefractionIntensity;
			float _Reflection;
			float4 _Color;
			float4 _ColorFar;
			float4 _FoamColor;
			float _FoamScale;
			float _DepthArea;
			float _DepthHard;
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
				float4 ase_texcoord3 : TEXCOORD3;
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
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				o.ase_texcoord1.xyz = ase_worldPos;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord3.w = 0;
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
				float3 ase_worldPos = IN.ase_texcoord1.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 normalizeResult293 = normalize( ( _MainLightPosition.xyz + ( ase_worldViewDir * float3( -1,-1,-1 ) ) ) );
				float temp_output_218_0 = ( ( _WaveDirection * PI ) / 180.0 );
				float2 appendResult214 = (float2(cos( temp_output_218_0 ) , sin( temp_output_218_0 )));
				float2 temp_output_70_0 = ( appendResult214 * _WaveSpeed );
				float2 temp_output_20_0 = (ase_worldPos).xz;
				float2 panner11 = ( 0.8146843 * _Time.y * temp_output_70_0 + temp_output_20_0);
				float2 uv_Ref085 = ( panner11 / _RefractionScale );
				float4 tex2DNode2 = tex2D( _NormalMap, uv_Ref085 );
				float2 appendResult75 = (float2(( length( temp_output_70_0 ) * -1.0 ) , 0.0));
				float2 panner23 = ( 0.513432 * _Time.y * appendResult75 + temp_output_20_0);
				float2 uv_Ref186 = ( panner23 / _RefractionScale );
				float4 tex2DNode21 = tex2D( _NormalMap, uv_Ref186 );
				float2 temp_output_35_0 = ( (tex2DNode2).rg - (tex2DNode21).rg );
				float3 appendResult299 = (float3(temp_output_35_0 , 0.5));
				float dotResult288 = dot( normalizeResult293 , ( appendResult299 / 0.3 ) );
				float4 screenPos = IN.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth112 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth112 = abs( ( screenDepth112 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depth ) );
				float temp_output_115_0 = saturate( distanceDepth112 );
				float2 appendResult31 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float4 lerpResult207 = lerp( _Color , _ColorFar , pow( temp_output_115_0 , 1.5 ));
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float4 fetchOpaqueVal111 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( ase_grabScreenPosNorm ), 1.0 );
				float4 lerpResult109 = lerp( ( ( tex2D( _ReflectionMap, ( appendResult31 + ( temp_output_35_0 * _RefractionIntensity ) ) ) * _Reflection ) + lerpResult207 ) , fetchOpaqueVal111 , ( 1.0 - temp_output_115_0 ));
				float2 uv_Foam0134 = ( panner11 / _FoamScale );
				float2 uv_Foam1135 = ( panner23 / _FoamScale );
				float screenDepth52 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth52 = abs( ( screenDepth52 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthArea ) );
				float depthArea90 = ( pow( saturate( ( 1.0 - distanceDepth52 ) ) , _DepthHard ) * 5.0 );
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV129 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode129 = ( 0.0 + 0.65 * pow( 1.0 - fresnelNdotV129, 1.0 ) );
				float temp_output_102_0 = saturate( ( (( (tex2D( _FoamMap, uv_Foam0134 )).rgb + ( (tex2D( _FoamMap, uv_Foam1135 )).rgb * float3( 0.5,0.5,0.5 ) ) )).x * depthArea90 * fresnelNode129 ) );
				float4 lerpResult118 = lerp( lerpResult109 , ( _FoamColor * temp_output_102_0 ) , temp_output_102_0);
				
		        float3 Color = ( ( saturate( ( pow( saturate( dotResult288 ) , (0.0 + (_Specular - 0.0) * (10.0 - 0.0) / (1.0 - 0.0)) ) * pow( temp_output_115_0 , 10.0 ) ) ) * _SpecularColor ) + lerpResult118 ).rgb;
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

	
    }
    Fallback "Hidden/InternalErrorShader"
	CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.ToonWater"
	
}
/*ASEBEGIN
Version=17500
14;11;1426;838;1366.013;178.5836;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;83;-5437.193,489.9264;Inherit;False;1623.743;646.2594;Wave Animation;12;71;75;81;69;70;211;212;213;214;215;217;218;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PiNode;215;-5405.72,718.86;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-5424,592;Inherit;False;Property;_WaveDirection;Wave Angle (World Y axis);6;0;Create;False;0;0;False;0;0.5;15.9454;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;217;-5226.059,695.7402;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;218;-5130.031,588.8594;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;180;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;213;-4992,672;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;212;-4992,592;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;214;-4800,608;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-4882.45,825.9262;Inherit;False;Property;_WaveSpeed;WaveSpeed;5;0;Create;False;0;0;False;0;0.5;1.2;0.01;2.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-4658.451,601.9264;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;69;-4450.451,841.9262;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;84;-3517.929,-849.2041;Inherit;False;2102.859;1578.865;Wave UV;19;86;85;130;29;27;23;11;20;15;19;13;17;18;16;131;132;133;134;135;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;13;-3021.929,-801.2041;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-4258.452,841.9262;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;20;-2557.929,-705.2041;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;75;-4034.452,841.9262;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2336,-240;Inherit;False;Property;_RefractionScale;Refraction Scale (1=1 meter);3;0;Create;False;0;0;False;0;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;11;-2317.929,-705.2041;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.707,0.707;False;1;FLOAT;0.8146843;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;23;-2317.929,-481.204;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;0.513432;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;130;-1952,-480;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;29;-1949.929,-705.2041;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;-1728,-480;Inherit;False;uv_Ref1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-1728,-704;Inherit;False;uv_Ref0;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-2336,448;Inherit;False;Property;_FoamScale;Foam Scale (1=1 meter);9;0;Create;False;0;0;False;0;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;209;-1328,1920;Inherit;False;Property;_DepthArea;DepthArea;14;0;Create;True;0;0;False;0;0;19.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;89;-1165,1856;Inherit;False;1335.996;513.6545;Depth Area;7;90;74;56;79;54;52;210;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;133;-1952,208;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;10;-1162.499,-172.1983;Inherit;True;Property;_NormalMap;NormalMap;2;1;[NoScaleOffset];Create;True;0;0;False;0;1b785ba7e757439478e6db434e0d3dd2;1b785ba7e757439478e6db434e0d3dd2;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;87;-1088,48;Inherit;False;85;uv_Ref0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-1088,240;Inherit;False;86;uv_Ref1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;21;-864,240;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-864,48;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;82;-1275.39,839.4171;Inherit;False;2127.772;833.7234;Foam;16;94;102;106;97;91;49;39;80;37;40;38;92;93;41;110;129;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;135;-1728,208;Inherit;False;uv_Foam1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DepthFade;52;-1120,1904;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;132;-1952,-16;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;41;-1206.682,938.7628;Inherit;True;Property;_FoamMap;FoamMap;8;1;[NoScaleOffset];Create;True;0;0;False;0;199d83fd2aca7214481411272c61f368;9fbef4b79ca3b784ba023cb1331520d5;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-1210.403,1331.334;Inherit;False;135;uv_Foam1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;134;-1728,-16;Inherit;False;uv_Foam0;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;54;-880,1904;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;22;-576,240;Inherit;True;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;275;-39.18459,192.2734;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComponentMaskNode;9;-576,48;Inherit;True;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-320,48;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-1210.403,1139.334;Inherit;False;134;uv_Foam0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;38;-966.6823,1338.763;Inherit;True;Property;_TextureSample3;Texture Sample 3;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;273;31.68489,-126.8255;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;230.0066,274.3226;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,-1,-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;56;-720,1904;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-736,2000;Inherit;False;Property;_DepthHard;DepthHard;15;0;Create;True;0;0;False;0;0;32.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;205;-639.9858,2732.357;Inherit;False;Property;_Depth;Depth;11;0;Create;True;0;0;False;0;1;5.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;242;-17.73688,696.2855;Inherit;False;Constant;_two;two;16;0;Create;True;0;0;False;0;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;37;-966.6823,1146.763;Inherit;True;Property;_Sample;Sample;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;299;-134.913,487.0164;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;40;-662.6819,1338.763;Inherit;True;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-997.428,530.4125;Inherit;False;Property;_RefractionIntensity;Refraction Intensity;4;0;Create;False;0;0;False;0;1;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;79;-560,1904;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;284;431.3507,32.77082;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;32;-592,-240;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;241;263.5315,612.3577;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;293;573.7201,73.71665;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-422.6818,1338.763;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.5,0.5,0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-304,1904;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;112;-493.0876,2613.38;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-112,48;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;39;-662.6819,1146.763;Inherit;True;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-368,-240;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;193.5145,1684.293;Inherit;True;Property;_ReflectionMap;_ReflectionMap;13;1;[HideInInspector];Create;True;0;0;False;0;None;None;False;black;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-96,1904;Inherit;False;depthArea;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;115;-80.58837,2528.061;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;463.6962,363.9886;Inherit;False;Property;_Specular;Specular;12;0;Create;True;0;0;False;0;0;0.9;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;288;772.7061,96.91688;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-121.3,-202.5;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.3,0.3;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-406.6818,1034.763;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.2,0.2,0.2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;280;776.5244,365.3972;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;129;21.20695,1379.604;Inherit;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.65;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;292;903.1963,139.5462;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;96;576,1984;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;0,0,0,0;0.4283108,0.6634538,0.7264151,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;203;512,1888;Inherit;False;Property;_Reflection;Reflaction;10;0;Create;False;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;208;258.7165,2394.435;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;206;576,2160;Inherit;False;Property;_ColorFar;ColorFar;1;0;Create;True;0;0;False;0;0,0,0,0;0.1739943,0.2754355,0.3207547,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;91;-192,1360;Inherit;False;90;depthArea;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;479,1696;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;97;-198.6819,1066.763;Inherit;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;805.4005,1723.904;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;279;1080.67,125.6439;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;207;806.1319,2052.515;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;296;1069.25,275.2611;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;48,1072;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;120;1113.387,1677.217;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;94;208,880;Inherit;False;Property;_FoamColor;FoamColor;7;1;[HDR];Create;True;0;0;False;0;0,0,0,0;1.185501,1.25868,1.419674,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;111;836.0999,2343.6;Inherit;False;Global;_GrabScreen0;Grab Screen 0;8;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;102;265.3181,1066.763;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;116;168.1301,2538.188;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;283;1244.115,143.6802;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;297;1395.915,170.7877;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;282;974.355,474.347;Inherit;False;Property;_SpecularColor;SpecularColor;16;1;[HDR];Create;True;0;0;False;0;1,1,1,0;0.2311321,0.461162,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;109;1039.269,2024.116;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;496,880;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;1450.824,316.8667;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;187;819.5617,2894;Inherit;False;847.4383;360.4009;Vertex Offset;6;181;182;183;185;186;191;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;118;1096.318,853.9293;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinTimeNode;181;869.5617,3075.401;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;19;-3037.929,-593.204;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;1176.712,3111.744;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.2,0.2,0.2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;-2765.929,-569.3574;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-3245.929,-593.204;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PosVertexDataNode;191;1098.321,2933.142;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;186;1424,2944;Inherit;False;vertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;182;1023.736,3084.962;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;235;1539.629,432.1971;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;185;1311.018,2950.76;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;16;-3469.929,-593.204;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.Vector4Node;18;-3453.929,-513.204;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-320,272;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;221;2461.415,899.616;Float;False;False;-1;2;ASEMaterialInspector;0;3;New Amplify Shader;e2514bdcf5e5399499a9eb24d175b9db;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthOnly;True;0;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;220;2461.415,899.616;Float;False;False;-1;2;ASEMaterialInspector;0;3;New Amplify Shader;e2514bdcf5e5399499a9eb24d175b9db;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;219;1999.482,295.1128;Float;False;True;-1;2;UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.ToonWater;0;3;ZDShader/LWRP/Environment/ToonWater;e2514bdcf5e5399499a9eb24d175b9db;True;Base;0;0;Base;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;Hidden/InternalErrorShader;0;0;Standard;8;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;Built-in Fog;0;LOD CrossFade;0;Vertex Position,InvertActionOnDeselection;1;0;3;True;False;False;False;;0
WireConnection;217;0;211;0
WireConnection;217;1;215;0
WireConnection;218;0;217;0
WireConnection;213;0;218;0
WireConnection;212;0;218;0
WireConnection;214;0;212;0
WireConnection;214;1;213;0
WireConnection;70;0;214;0
WireConnection;70;1;71;0
WireConnection;69;0;70;0
WireConnection;81;0;69;0
WireConnection;20;0;13;0
WireConnection;75;0;81;0
WireConnection;11;0;20;0
WireConnection;11;2;70;0
WireConnection;23;0;20;0
WireConnection;23;2;75;0
WireConnection;130;0;23;0
WireConnection;130;1;27;0
WireConnection;29;0;11;0
WireConnection;29;1;27;0
WireConnection;86;0;130;0
WireConnection;85;0;29;0
WireConnection;133;0;23;0
WireConnection;133;1;131;0
WireConnection;21;0;10;0
WireConnection;21;1;88;0
WireConnection;2;0;10;0
WireConnection;2;1;87;0
WireConnection;135;0;133;0
WireConnection;52;0;209;0
WireConnection;132;0;11;0
WireConnection;132;1;131;0
WireConnection;134;0;132;0
WireConnection;54;0;52;0
WireConnection;22;0;21;0
WireConnection;9;0;2;0
WireConnection;35;0;9;0
WireConnection;35;1;22;0
WireConnection;38;0;41;0
WireConnection;38;1;93;0
WireConnection;295;0;275;0
WireConnection;56;0;54;0
WireConnection;37;0;41;0
WireConnection;37;1;92;0
WireConnection;299;0;35;0
WireConnection;40;0;38;0
WireConnection;79;0;56;0
WireConnection;79;1;210;0
WireConnection;284;0;273;0
WireConnection;284;1;295;0
WireConnection;241;0;299;0
WireConnection;241;1;242;0
WireConnection;293;0;284;0
WireConnection;80;0;40;0
WireConnection;74;0;79;0
WireConnection;112;0;205;0
WireConnection;36;0;35;0
WireConnection;36;1;34;0
WireConnection;39;0;37;0
WireConnection;31;0;32;1
WireConnection;31;1;32;2
WireConnection;90;0;74;0
WireConnection;115;0;112;0
WireConnection;288;0;293;0
WireConnection;288;1;241;0
WireConnection;25;0;31;0
WireConnection;25;1;36;0
WireConnection;49;0;39;0
WireConnection;49;1;80;0
WireConnection;280;0;145;0
WireConnection;292;0;288;0
WireConnection;208;0;115;0
WireConnection;4;0;3;0
WireConnection;4;1;25;0
WireConnection;97;0;49;0
WireConnection;204;0;4;0
WireConnection;204;1;203;0
WireConnection;279;0;292;0
WireConnection;279;1;280;0
WireConnection;207;0;96;0
WireConnection;207;1;206;0
WireConnection;207;2;208;0
WireConnection;296;0;115;0
WireConnection;106;0;97;0
WireConnection;106;1;91;0
WireConnection;106;2;129;0
WireConnection;120;0;204;0
WireConnection;120;1;207;0
WireConnection;102;0;106;0
WireConnection;116;0;115;0
WireConnection;283;0;279;0
WireConnection;283;1;296;0
WireConnection;297;0;283;0
WireConnection;109;0;120;0
WireConnection;109;1;111;0
WireConnection;109;2;116;0
WireConnection;110;0;94;0
WireConnection;110;1;102;0
WireConnection;298;0;297;0
WireConnection;298;1;282;0
WireConnection;118;0;109;0
WireConnection;118;1;110;0
WireConnection;118;2;102;0
WireConnection;19;0;17;0
WireConnection;183;0;182;0
WireConnection;15;0;13;0
WireConnection;15;1;19;0
WireConnection;17;0;16;0
WireConnection;17;1;18;0
WireConnection;186;0;185;0
WireConnection;182;1;181;4
WireConnection;235;0;298;0
WireConnection;235;1;118;0
WireConnection;185;0;191;0
WireConnection;185;1;183;0
WireConnection;147;0;2;0
WireConnection;147;1;21;0
WireConnection;219;0;235;0
ASEEND*/
//CHKSM=BAE0FA1FF4D093ED58BCE2CC52884FFE1261017F