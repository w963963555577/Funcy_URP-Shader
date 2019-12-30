// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/LWRP/Environment/ToonWaterFall"
{
    Properties
    {
		[HDR]_Color("Color", Color) = (0,0,0,0)
		[HDR]_FoamColor("FoamColor", Color) = (0,0,0,0)
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		_Depth("Depth", Float) = 1
		_Offset("Offset", Float) = 1
		_FoamScale3("Foam Scale (1=1 meter)", Float) = 1
		_Speed("Speed", Float) = 1

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

            

			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float _Speed;
			float _FoamScale3;
			float _Depth;
			float _Offset;
			float4 _Color;
			float4 _FoamColor;
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

			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			
			float SHADERGRAPH_SAMPLE_SCENE_DEPTH_LOD(float2 uv)
			{
				#if defined(REQUIRE_DEPTH_TEXTURE)
				#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
				 	float rawDepth = SAMPLE_TEXTURE2D_ARRAY_LOD(_CameraDepthTexture, sampler_CameraDepthTexture, uv, unity_StereoEyeIndex, 0).r;
				#else
				 	float rawDepth = SAMPLE_DEPTH_TEXTURE_LOD(_CameraDepthTexture, sampler_CameraDepthTexture, uv, 0);
				#endif
				return rawDepth;
				#endif // REQUIRE_DEPTH_TEXTURE
				return 0;
			}
			

            GraphVertexOutput vert (GraphVertexInput v)
            {
                GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				float2 appendResult340 = (float2(0.0 , ( _Speed * 0.7070103 )));
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float2 temp_output_314_0 = (ase_worldPos).xz;
				float2 panner316 = ( 1.0 * _Time.y * appendResult340 + temp_output_314_0);
				float2 uv_Foam0326 = ( panner316 / _FoamScale3 );
				float simplePerlin2D344 = snoise( uv_Foam0326*5.0 );
				simplePerlin2D344 = simplePerlin2D344*0.5 + 0.5;
				float2 appendResult341 = (float2(0.0 , ( _Speed * 1.137131 )));
				float2 panner317 = ( 1.0 * _Time.y * appendResult341 + temp_output_314_0);
				float2 uv_Foam1324 = ( panner317 / _FoamScale3 );
				float simplePerlin2D349 = snoise( uv_Foam1324*3.0 );
				simplePerlin2D349 = simplePerlin2D349*0.5 + 0.5;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth112 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH_LOD( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth112 = abs( ( screenDepth112 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depth ) );
				float temp_output_359_0 = saturate( pow( ( 1.0 - saturate( distanceDepth112 ) ) , 4.0 ) );
				
				o.ase_texcoord1.xyz = ase_worldPos;
				o.ase_texcoord2 = screenPos;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = v.vertex.xyz;
				#else
				float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( ( saturate( ( simplePerlin2D344 * simplePerlin2D349 ) ) * temp_output_359_0 ) * v.ase_normal * _Offset );
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
				float2 appendResult340 = (float2(0.0 , ( _Speed * 0.7070103 )));
				float3 ase_worldPos = IN.ase_texcoord1.xyz;
				float2 temp_output_314_0 = (ase_worldPos).xz;
				float2 panner316 = ( 1.0 * _Time.y * appendResult340 + temp_output_314_0);
				float2 uv_Foam0326 = ( panner316 / _FoamScale3 );
				float2 appendResult341 = (float2(0.0 , ( _Speed * 1.137131 )));
				float2 panner317 = ( 1.0 * _Time.y * appendResult341 + temp_output_314_0);
				float2 uv_Foam1324 = ( panner317 / _FoamScale3 );
				float4 screenPos = IN.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth112 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth112 = abs( ( screenDepth112 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depth ) );
				float temp_output_359_0 = saturate( pow( ( 1.0 - saturate( distanceDepth112 ) ) , 4.0 ) );
				float3 temp_output_366_0 = saturate( ( (tex2D( _MainTex, uv_Foam0326 )).rgb + (tex2D( _MainTex, uv_Foam1324 )).rgb + pow( temp_output_359_0 , 3.0 ) ) );
				float4 lerpResult372 = lerp( _Color , _FoamColor , float4( temp_output_366_0 , 0.0 ));
				
		        float3 Color = lerpResult372;
		        float Alpha = temp_output_366_0.x;
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
	CustomEditor "ASEMaterialInspector"
	
}
/*ASEBEGIN
Version=17500
14;11;1426;838;96.87116;-2247.861;1.663779;True;False
Node;AmplifyShaderEditor.CommentaryNode;301;-3644.002,-433.6431;Inherit;False;2102.859;1578.865;Wave UV;14;326;325;324;323;322;317;316;314;312;337;338;339;340;341;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;337;-2987.417,-132.9651;Inherit;False;Property;_Speed;Speed;6;0;Create;True;0;0;False;0;1;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;339;-2752,-48;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.137131;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;338;-2751.586,-174.0842;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.7070103;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;312;-3148.002,-385.6431;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;340;-2592,-176;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;341;-2592,-48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;314;-2681.583,-308.9932;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;205;-848.593,3668.053;Inherit;False;Property;_Depth;Depth;3;0;Create;True;0;0;False;0;1;7.68;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;322;-2462.073,863.561;Inherit;False;Property;_FoamScale3;Foam Scale (1=1 meter);5;0;Create;False;0;0;False;0;1;14.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;316;-2398.045,-302.9463;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.7070103;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;317;-2360.554,-63.22421;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,1.137131;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DepthFade;112;-549.6951,3588.977;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;325;-2078.073,399.561;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;323;-2078.073,623.561;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;115;-289.1957,3463.757;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;116;-126,3468.8;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;326;-1854.073,399.561;Inherit;False;uv_Foam0;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;324;-1854.073,623.561;Inherit;False;uv_Foam1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;333;-492.1366,2487.92;Inherit;False;326;uv_Foam0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;41;-544.4187,2239.383;Inherit;True;Property;_MainTex;MainTex;2;1;[NoScaleOffset];Create;True;0;0;False;0;199d83fd2aca7214481411272c61f368;94b2470d29df55e4fad7f0aee4b2243f;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;345;-353.8376,2847.347;Inherit;False;326;uv_Foam0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;342;49.99996,3452.8;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;334;-504.2726,2564.299;Inherit;False;324;uv_Foam1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;348;-363.1358,3063.898;Inherit;False;324;uv_Foam1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;344;-157.5724,2847.58;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;37;-146.8189,2290.684;Inherit;True;Property;_Sample;Sample;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;349;-155.1357,3063.898;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;38;-146.8189,2482.683;Inherit;True;Property;_TextureSample3;Texture Sample 3;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;359;385.0728,3470.979;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;40;157.1815,2482.683;Inherit;True;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;39;157.1815,2290.684;Inherit;True;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;364;446.4954,2723.327;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;354;132.7772,2885.114;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;353;300.0526,2955.061;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;336;481.241,2440.342;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;362;369.4766,3595.597;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;347;624.4511,3124.728;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;357;371.9213,3754.008;Inherit;False;Property;_Offset;Offset;4;0;Create;True;0;0;False;0;1;5.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;367;1138.242,2948.669;Inherit;False;Property;_FoamColor;FoamColor;1;1;[HDR];Create;True;0;0;False;0;0,0,0,0;1.277174,1.684005,2.530476,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;94;1132.907,2688.999;Inherit;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.4961718,0.8993904,1.895376,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;366;740.3984,2652.18;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;363;805.5233,3256.691;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;372;1525.107,2885.343;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;220;2461.415,899.616;Float;False;False;-1;2;ASEMaterialInspector;0;3;New Amplify Shader;e2514bdcf5e5399499a9eb24d175b9db;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;221;2461.415,899.616;Float;False;False;-1;2;ASEMaterialInspector;0;3;New Amplify Shader;e2514bdcf5e5399499a9eb24d175b9db;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthOnly;True;0;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;219;1934.758,2923.701;Float;False;True;-1;2;ASEMaterialInspector;0;3;ZDShader/LWRP/Environment/ToonWaterFall;e2514bdcf5e5399499a9eb24d175b9db;True;Base;0;0;Base;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;Hidden/InternalErrorShader;0;0;Standard;8;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;Built-in Fog;0;LOD CrossFade;0;Vertex Position,InvertActionOnDeselection;1;0;3;True;False;False;False;;0
WireConnection;339;0;337;0
WireConnection;338;0;337;0
WireConnection;340;1;338;0
WireConnection;341;1;339;0
WireConnection;314;0;312;0
WireConnection;316;0;314;0
WireConnection;316;2;340;0
WireConnection;317;0;314;0
WireConnection;317;2;341;0
WireConnection;112;0;205;0
WireConnection;325;0;316;0
WireConnection;325;1;322;0
WireConnection;323;0;317;0
WireConnection;323;1;322;0
WireConnection;115;0;112;0
WireConnection;116;0;115;0
WireConnection;326;0;325;0
WireConnection;324;0;323;0
WireConnection;342;0;116;0
WireConnection;344;0;345;0
WireConnection;37;0;41;0
WireConnection;37;1;333;0
WireConnection;349;0;348;0
WireConnection;38;0;41;0
WireConnection;38;1;334;0
WireConnection;359;0;342;0
WireConnection;40;0;38;0
WireConnection;39;0;37;0
WireConnection;364;0;359;0
WireConnection;354;0;344;0
WireConnection;354;1;349;0
WireConnection;353;0;354;0
WireConnection;336;0;39;0
WireConnection;336;1;40;0
WireConnection;336;2;364;0
WireConnection;347;0;353;0
WireConnection;347;1;359;0
WireConnection;366;0;336;0
WireConnection;363;0;347;0
WireConnection;363;1;362;0
WireConnection;363;2;357;0
WireConnection;372;0;94;0
WireConnection;372;1;367;0
WireConnection;372;2;366;0
WireConnection;219;0;372;0
WireConnection;219;1;366;0
WireConnection;219;3;363;0
ASEEND*/
//CHKSM=3CAF2392F7500332F45033E8E2886E7B2BC70A06