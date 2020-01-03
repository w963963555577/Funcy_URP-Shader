// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/LWRP/Environment/ToonWaterFallSplash"
{
    Properties
    {
		[HDR]_FoamColor("FoamColor", Color) = (0,0,0,0)
		_Offset("Offset", Float) = 1
		_FoamScale3("Foam Scale (1=1 meter)", Float) = 1
		_Speed("Speed", Float) = 1
		_SoftEdge("SoftEdge", Range( 0.01 , 10)) = 0

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

            Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

            HLSLPROGRAM
            #define _RECEIVE_SHADOWS_OFF 1
            #define ASE_SRP_VERSION 60902

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

            

			CBUFFER_START( UnityPerMaterial )
			float _Speed;
			float _FoamScale3;
			float _Offset;
			float4 _FoamColor;
			float _SoftEdge;
			CBUFFER_END


            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct GraphVertexOutput
            {
                float4 position : POSITION;
				#ifdef ASE_FOG
				float fogCoord : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
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
			

            GraphVertexOutput vert (GraphVertexInput v)
            {
                GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				float2 appendResult340 = (float2(0.0 , ( _Speed * 0.7070103 )));
				float2 uv0400 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner316 = ( 1.0 * _Time.y * appendResult340 + uv0400);
				float2 uv_Foam0326 = ( panner316 / _FoamScale3 );
				float simplePerlin2D344 = snoise( uv_Foam0326 );
				simplePerlin2D344 = simplePerlin2D344*0.5 + 0.5;
				float2 appendResult341 = (float2(0.0 , ( _Speed * 1.137131 )));
				float2 panner317 = ( 1.0 * _Time.y * appendResult341 + uv0400);
				float2 uv_Foam1324 = ( panner317 / _FoamScale3 );
				float simplePerlin2D349 = snoise( uv_Foam1324*0.5 );
				simplePerlin2D349 = simplePerlin2D349*0.5 + 0.5;
				float temp_output_366_0 = saturate( ( simplePerlin2D344 * simplePerlin2D349 ) );
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = v.vertex.xyz;
				#else
				float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( temp_output_366_0 * v.ase_normal * _Offset );
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
				float2 uv0400 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner316 = ( 1.0 * _Time.y * appendResult340 + uv0400);
				float2 uv_Foam0326 = ( panner316 / _FoamScale3 );
				float simplePerlin2D344 = snoise( uv_Foam0326 );
				simplePerlin2D344 = simplePerlin2D344*0.5 + 0.5;
				float2 appendResult341 = (float2(0.0 , ( _Speed * 1.137131 )));
				float2 panner317 = ( 1.0 * _Time.y * appendResult341 + uv0400);
				float2 uv_Foam1324 = ( panner317 / _FoamScale3 );
				float simplePerlin2D349 = snoise( uv_Foam1324*0.5 );
				simplePerlin2D349 = simplePerlin2D349*0.5 + 0.5;
				float temp_output_366_0 = saturate( ( simplePerlin2D344 * simplePerlin2D349 ) );
				float4 lerpResult372 = lerp( float4( float3(1,1,1) , 0.0 ) , _FoamColor , temp_output_366_0);
				
				float2 uv0382 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float cos386 = cos( 0.7853975 );
				float sin386 = sin( 0.7853975 );
				float2 rotator386 = mul( uv0382 - float2( 0.5,0.5 ) , float2x2( cos386 , -sin386 , sin386 , cos386 )) + float2( 0.5,0.5 );
				float2 break393 = abs( ( ( rotator386 - float2( 0.5,0.5 ) ) * float2( 1.414,1.414 ) ) );
				
		        float3 Color = lerpResult372.rgb;
		        float Alpha = ( temp_output_366_0 * ( 1.0 - pow( ( break393.x + break393.y ) , ( 1.0 / _SoftEdge ) ) ) );
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
12;17;1426;832;3905.556;635.3959;1.836709;True;False
Node;AmplifyShaderEditor.CommentaryNode;301;-3644.002,-433.6431;Inherit;False;2102.859;1578.865;Wave UV;13;326;325;324;323;322;317;316;337;338;339;340;341;400;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;337;-2987.417,-132.9651;Inherit;False;Property;_Speed;Speed;3;0;Create;True;0;0;False;0;1;6.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;339;-2752,-48;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.137131;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;338;-2751.586,-174.0842;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.7070103;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;382;960,3664;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;341;-2592,-48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;400;-2762.237,-337.6851;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;340;-2592,-176;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;387;1014.937,3793.937;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;0.7853975;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;316;-2398.045,-302.9463;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.7070103;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;317;-2360.554,-63.22421;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,1.137131;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;322;-2462.073,863.561;Inherit;False;Property;_FoamScale3;Foam Scale (1=1 meter);2;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;386;1200,3664;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;2.15;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;325;-2078.073,399.561;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;323;-2078.073,623.561;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;383;1376,3664;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;326;-1854.073,399.561;Inherit;False;uv_Foam0;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;324;-1854.073,623.561;Inherit;False;uv_Foam1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;384;1520,3664;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;1.414,1.414;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;348;-355.3185,2485.42;Inherit;False;324;uv_Foam1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;385;1664,3664;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;345;-346.0203,2268.869;Inherit;False;326;uv_Foam0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;393;1824,3664;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NoiseGeneratorNode;349;-150.1057,2485.42;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;344;-149.7551,2269.102;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;396;1872,3968;Inherit;False;Property;_SoftEdge;SoftEdge;4;0;Create;True;0;0;False;0;0;0.01;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;397;2144,3920;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;39;157.1815,2290.684;Inherit;True;True;True;True;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;40;157.1815,2482.683;Inherit;True;True;True;True;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;394;2064,3664;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;395;2291.174,3672.528;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;381;441.1316,2427.151;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;373;1183.534,2659.468;Inherit;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;False;0;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;362;369.4766,3595.597;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;366;2092.105,3105.062;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;367;1100.25,2845.483;Inherit;False;Property;_FoamColor;FoamColor;0;1;[HDR];Create;True;0;0;False;0;0,0,0,0;19.74236,27.6399,31.46902,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;398;2528,3680;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;357;371.9213,3754.008;Inherit;False;Property;_Offset;Offset;1;0;Create;True;0;0;False;0;1;4.59;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;399;2339.572,3090.359;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;372;2308.619,2930.873;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;363;1677.201,3229.087;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;221;2461.415,899.616;Float;False;False;-1;2;ASEMaterialInspector;0;3;New Amplify Shader;e2514bdcf5e5399499a9eb24d175b9db;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthOnly;True;0;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;220;2461.415,899.616;Float;False;False;-1;2;ASEMaterialInspector;0;3;New Amplify Shader;e2514bdcf5e5399499a9eb24d175b9db;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;219;2829.181,3209.01;Float;False;True;-1;2;ASEMaterialInspector;0;3;ZDShader/LWRP/Environment/ToonWaterFallSplash;e2514bdcf5e5399499a9eb24d175b9db;True;Base;0;0;Base;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;Hidden/InternalErrorShader;0;0;Standard;8;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;Built-in Fog;0;LOD CrossFade;0;Vertex Position,InvertActionOnDeselection;1;0;3;True;False;False;False;;0
WireConnection;339;0;337;0
WireConnection;338;0;337;0
WireConnection;341;1;339;0
WireConnection;340;1;338;0
WireConnection;316;0;400;0
WireConnection;316;2;340;0
WireConnection;317;0;400;0
WireConnection;317;2;341;0
WireConnection;386;0;382;0
WireConnection;386;2;387;0
WireConnection;325;0;316;0
WireConnection;325;1;322;0
WireConnection;323;0;317;0
WireConnection;323;1;322;0
WireConnection;383;0;386;0
WireConnection;326;0;325;0
WireConnection;324;0;323;0
WireConnection;384;0;383;0
WireConnection;385;0;384;0
WireConnection;393;0;385;0
WireConnection;349;0;348;0
WireConnection;344;0;345;0
WireConnection;397;1;396;0
WireConnection;39;0;344;0
WireConnection;40;0;349;0
WireConnection;394;0;393;0
WireConnection;394;1;393;1
WireConnection;395;0;394;0
WireConnection;395;1;397;0
WireConnection;381;0;39;0
WireConnection;381;1;40;0
WireConnection;366;0;381;0
WireConnection;398;0;395;0
WireConnection;399;0;366;0
WireConnection;399;1;398;0
WireConnection;372;0;373;0
WireConnection;372;1;367;0
WireConnection;372;2;366;0
WireConnection;363;0;366;0
WireConnection;363;1;362;0
WireConnection;363;2;357;0
WireConnection;219;0;372;0
WireConnection;219;1;399;0
WireConnection;219;3;363;0
ASEEND*/
//CHKSM=8CC5FA3995BBB2AF0A7003FFCCC53D484E7BB235