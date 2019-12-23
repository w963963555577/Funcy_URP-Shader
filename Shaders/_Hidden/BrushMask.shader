// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hidden/LWRP/BrushMask"
{
    Properties
    {
		_BrushColor("BrushColor", Color) = (1,0.04245281,0.04245281,0)
		_AlphaMask("AlphaMask", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

    }

    SubShader
    {
		LOD 0

		

        Tags { "RenderPipeline"="LightweightPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        Cull Off
		HLSLINCLUDE
		#pragma target 2.0
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

            

			sampler2D _AlphaMask;
			CBUFFER_START( UnityPerMaterial )
			float4 _BrushColor;
			float4 _AlphaMask_ST;
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

			
            GraphVertexOutput vert (GraphVertexInput v)
            {
                GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
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
				float4 _offset = float4(-0.0005,-2.5E-05,2.5E-05,0.0005);
				float2 appendResult122 = (float2(_offset.x , _offset.x));
				float2 appendResult123 = (float2(_offset.x , _offset.y));
				float2 appendResult124 = (float2(_offset.x , _offset.z));
				float2 appendResult125 = (float2(_offset.x , _offset.w));
				float2 appendResult127 = (float2(_offset.y , _offset.x));
				float2 appendResult128 = (float2(_offset.y , _offset.y));
				float2 appendResult129 = (float2(_offset.y , _offset.z));
				float2 appendResult130 = (float2(_offset.y , _offset.w));
				float2 appendResult131 = (float2(_offset.z , _offset.x));
				float2 appendResult132 = (float2(_offset.z , _offset.y));
				float2 appendResult133 = (float2(_offset.z , _offset.z));
				float2 appendResult134 = (float2(_offset.z , _offset.w));
				float2 appendResult135 = (float2(_offset.w , _offset.x));
				float2 appendResult136 = (float2(_offset.w , _offset.y));
				float2 appendResult137 = (float2(_offset.w , _offset.z));
				float2 appendResult138 = (float2(_offset.w , _offset.w));
				float2 uv_AlphaMask = IN.ase_texcoord1.xy * _AlphaMask_ST.xy + _AlphaMask_ST.zw;
				float clampResult179 = clamp( ( ( ( ( tex2D( _AlphaMask, ( appendResult122 + IN.ase_texcoord1.xy ) ).r + tex2D( _AlphaMask, ( appendResult123 + IN.ase_texcoord1.xy ) ).r + tex2D( _AlphaMask, ( appendResult124 + IN.ase_texcoord1.xy ) ).r + tex2D( _AlphaMask, ( appendResult125 + IN.ase_texcoord1.xy ) ).r ) + ( tex2D( _AlphaMask, ( appendResult127 + IN.ase_texcoord1.xy ) ).r + tex2D( _AlphaMask, ( appendResult128 + IN.ase_texcoord1.xy ) ).r + tex2D( _AlphaMask, ( appendResult129 + IN.ase_texcoord1.xy ) ).r + tex2D( _AlphaMask, ( appendResult130 + IN.ase_texcoord1.xy ) ).r ) + ( tex2D( _AlphaMask, ( appendResult131 + IN.ase_texcoord1.xy ) ).r + tex2D( _AlphaMask, ( appendResult132 + IN.ase_texcoord1.xy ) ).r + tex2D( _AlphaMask, ( appendResult133 + IN.ase_texcoord1.xy ) ).r + tex2D( _AlphaMask, ( appendResult134 + IN.ase_texcoord1.xy ) ).r ) + ( tex2D( _AlphaMask, ( appendResult135 + IN.ase_texcoord1.xy ) ).r + tex2D( _AlphaMask, ( appendResult136 + IN.ase_texcoord1.xy ) ).r + tex2D( _AlphaMask, ( appendResult137 + IN.ase_texcoord1.xy ) ).r + tex2D( _AlphaMask, ( appendResult138 + IN.ase_texcoord1.xy ) ).r ) ) + tex2D( _AlphaMask, uv_AlphaMask ).r ) / 17.0 ) , 0.0 , 1.0 );
				
		        float3 Color = _BrushColor.rgb;
		        float Alpha = ( _BrushColor.a * clampResult179 );
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

            

			sampler2D _AlphaMask;
			CBUFFER_START( UnityPerMaterial )
			float4 _BrushColor;
			float4 _AlphaMask_ST;
			CBUFFER_END


			struct GraphVertexInput
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

			
			VertexOutput vert( GraphVertexInput v  )
			{
					VertexOutput o = (VertexOutput)0;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					o.ase_texcoord.xy = v.ase_texcoord.xy;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					o.ase_texcoord.zw = 0;
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
				float4 _offset = float4(-0.0005,-2.5E-05,2.5E-05,0.0005);
				float2 appendResult122 = (float2(_offset.x , _offset.x));
				float2 appendResult123 = (float2(_offset.x , _offset.y));
				float2 appendResult124 = (float2(_offset.x , _offset.z));
				float2 appendResult125 = (float2(_offset.x , _offset.w));
				float2 appendResult127 = (float2(_offset.y , _offset.x));
				float2 appendResult128 = (float2(_offset.y , _offset.y));
				float2 appendResult129 = (float2(_offset.y , _offset.z));
				float2 appendResult130 = (float2(_offset.y , _offset.w));
				float2 appendResult131 = (float2(_offset.z , _offset.x));
				float2 appendResult132 = (float2(_offset.z , _offset.y));
				float2 appendResult133 = (float2(_offset.z , _offset.z));
				float2 appendResult134 = (float2(_offset.z , _offset.w));
				float2 appendResult135 = (float2(_offset.w , _offset.x));
				float2 appendResult136 = (float2(_offset.w , _offset.y));
				float2 appendResult137 = (float2(_offset.w , _offset.z));
				float2 appendResult138 = (float2(_offset.w , _offset.w));
				float2 uv_AlphaMask = IN.ase_texcoord.xy * _AlphaMask_ST.xy + _AlphaMask_ST.zw;
				float clampResult179 = clamp( ( ( ( ( tex2D( _AlphaMask, ( appendResult122 + IN.ase_texcoord.xy ) ).r + tex2D( _AlphaMask, ( appendResult123 + IN.ase_texcoord.xy ) ).r + tex2D( _AlphaMask, ( appendResult124 + IN.ase_texcoord.xy ) ).r + tex2D( _AlphaMask, ( appendResult125 + IN.ase_texcoord.xy ) ).r ) + ( tex2D( _AlphaMask, ( appendResult127 + IN.ase_texcoord.xy ) ).r + tex2D( _AlphaMask, ( appendResult128 + IN.ase_texcoord.xy ) ).r + tex2D( _AlphaMask, ( appendResult129 + IN.ase_texcoord.xy ) ).r + tex2D( _AlphaMask, ( appendResult130 + IN.ase_texcoord.xy ) ).r ) + ( tex2D( _AlphaMask, ( appendResult131 + IN.ase_texcoord.xy ) ).r + tex2D( _AlphaMask, ( appendResult132 + IN.ase_texcoord.xy ) ).r + tex2D( _AlphaMask, ( appendResult133 + IN.ase_texcoord.xy ) ).r + tex2D( _AlphaMask, ( appendResult134 + IN.ase_texcoord.xy ) ).r ) + ( tex2D( _AlphaMask, ( appendResult135 + IN.ase_texcoord.xy ) ).r + tex2D( _AlphaMask, ( appendResult136 + IN.ase_texcoord.xy ) ).r + tex2D( _AlphaMask, ( appendResult137 + IN.ase_texcoord.xy ) ).r + tex2D( _AlphaMask, ( appendResult138 + IN.ase_texcoord.xy ) ).r ) ) + tex2D( _AlphaMask, uv_AlphaMask ).r ) / 17.0 ) , 0.0 , 1.0 );
				

				float Alpha = ( _BrushColor.a * clampResult179 );
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
	CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.BrushMask"
	
}
/*ASEBEGIN
Version=17500
8;2;1426;844;2793.181;-595.0046;1;True;False
Node;AmplifyShaderEditor.Vector4Node;121;-2008.153,813.305;Inherit;False;Constant;_offset;offset;2;0;Create;True;0;0;False;0;-0.0005,-2.5E-05,2.5E-05,0.0005;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;119;-912,1280;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;128;-512,704;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;123;-512,-64;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;129;-512,896;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;130;-512,1088;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;133;-512,1664;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;124;-512,128;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;125;-512,320;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;122;-512,-256;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;135;-512,2048;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;127;-512,512;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;134;-512,1856;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;136;-512,2240;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;137;-512,2432;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;138;-512,2624;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;131;-512,1280;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;132;-512,1472;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;154;-352,1280;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;162;-352,2048;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;148;-352,704;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;144;-352,320;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;156;-352,1472;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;158;-352,1664;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;160;-352,1856;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;150;-352,896;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;146;-352,512;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;168;-352,2624;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;166;-352,2432;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;164;-352,2240;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;111;-944,1568;Inherit;True;Property;_AlphaMask;AlphaMask;1;0;Create;True;0;0;False;0;None;ae3cb27b4c1f8704094bcb482d8c3ee4;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;139;-352,-256;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;140;-352,-64;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;152;-352,1088;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;142;-352,128;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;113;-224,-286;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;147;-224,482;Inherit;True;Property;_TextureSample4;Texture Sample 4;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;151;-224,866;Inherit;True;Property;_TextureSample6;Texture Sample 6;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;145;-224,290;Inherit;True;Property;_TextureSample3;Texture Sample 3;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;143;-224,98;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;169;-224,2592;Inherit;True;Property;_TextureSample15;Texture Sample 15;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;141;-224,-94;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;163;-224,2016;Inherit;True;Property;_TextureSample12;Texture Sample 12;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;149;-224,674;Inherit;True;Property;_TextureSample5;Texture Sample 5;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;157;-224,1440;Inherit;True;Property;_TextureSample9;Texture Sample 9;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;167;-224,2400;Inherit;True;Property;_TextureSample14;Texture Sample 14;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;165;-224,2208;Inherit;True;Property;_TextureSample13;Texture Sample 13;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;161;-224,1824;Inherit;True;Property;_TextureSample11;Texture Sample 11;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;159;-224,1632;Inherit;True;Property;_TextureSample10;Texture Sample 10;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;153;-224,1058;Inherit;True;Property;_TextureSample7;Texture Sample 7;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;155;-224,1248;Inherit;True;Property;_TextureSample8;Texture Sample 8;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;171;416,912;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;173;416,1200;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;172;416,1056;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;170;416,768;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;174;672,928;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;180;592,1184;Inherit;True;Property;_TextureSample17;Texture Sample 17;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;177;880,928;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;181;1008,928;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;17;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;179;1233.29,918.8513;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;104;752,224;Inherit;False;Property;_BrushColor;BrushColor;0;0;Create;True;0;0;False;0;1,0.04245281,0.04245281,0;0.9811321,0.1527234,0.1527234,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;1211.31,596.2141;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;1222,269;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;116;1385.479,434.7408;Float;False;True;-1;2;UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.BrushMask;0;3;Hidden/LWRP/BrushMask;e2514bdcf5e5399499a9eb24d175b9db;True;Base;0;0;Base;5;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;2;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=LightweightForward;False;0;Hidden/InternalErrorShader;0;0;Standard;8;Surface;1;  Blend;0;Two Sided;0;Cast Shadows;0;Receive Shadows;0;Built-in Fog;0;LOD CrossFade;0;Vertex Position,InvertActionOnDeselection;1;0;3;True;False;True;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;117;225.2438,226.3857;Float;False;False;-1;2;ASEMaterialInspector;0;3;New Amplify Shader;e2514bdcf5e5399499a9eb24d175b9db;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;118;225.2438,226.3857;Float;False;False;-1;2;ASEMaterialInspector;0;3;New Amplify Shader;e2514bdcf5e5399499a9eb24d175b9db;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=LightweightPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthOnly;True;0;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;128;0;121;2
WireConnection;128;1;121;2
WireConnection;123;0;121;1
WireConnection;123;1;121;2
WireConnection;129;0;121;2
WireConnection;129;1;121;3
WireConnection;130;0;121;2
WireConnection;130;1;121;4
WireConnection;133;0;121;3
WireConnection;133;1;121;3
WireConnection;124;0;121;1
WireConnection;124;1;121;3
WireConnection;125;0;121;1
WireConnection;125;1;121;4
WireConnection;122;0;121;1
WireConnection;122;1;121;1
WireConnection;135;0;121;4
WireConnection;135;1;121;1
WireConnection;127;0;121;2
WireConnection;127;1;121;1
WireConnection;134;0;121;3
WireConnection;134;1;121;4
WireConnection;136;0;121;4
WireConnection;136;1;121;2
WireConnection;137;0;121;4
WireConnection;137;1;121;3
WireConnection;138;0;121;4
WireConnection;138;1;121;4
WireConnection;131;0;121;3
WireConnection;131;1;121;1
WireConnection;132;0;121;3
WireConnection;132;1;121;2
WireConnection;154;0;131;0
WireConnection;154;1;119;0
WireConnection;162;0;135;0
WireConnection;162;1;119;0
WireConnection;148;0;128;0
WireConnection;148;1;119;0
WireConnection;144;0;125;0
WireConnection;144;1;119;0
WireConnection;156;0;132;0
WireConnection;156;1;119;0
WireConnection;158;0;133;0
WireConnection;158;1;119;0
WireConnection;160;0;134;0
WireConnection;160;1;119;0
WireConnection;150;0;129;0
WireConnection;150;1;119;0
WireConnection;146;0;127;0
WireConnection;146;1;119;0
WireConnection;168;0;138;0
WireConnection;168;1;119;0
WireConnection;166;0;137;0
WireConnection;166;1;119;0
WireConnection;164;0;136;0
WireConnection;164;1;119;0
WireConnection;139;0;122;0
WireConnection;139;1;119;0
WireConnection;140;0;123;0
WireConnection;140;1;119;0
WireConnection;152;0;130;0
WireConnection;152;1;119;0
WireConnection;142;0;124;0
WireConnection;142;1;119;0
WireConnection;113;0;111;0
WireConnection;113;1;139;0
WireConnection;147;0;111;0
WireConnection;147;1;146;0
WireConnection;151;0;111;0
WireConnection;151;1;150;0
WireConnection;145;0;111;0
WireConnection;145;1;144;0
WireConnection;143;0;111;0
WireConnection;143;1;142;0
WireConnection;169;0;111;0
WireConnection;169;1;168;0
WireConnection;141;0;111;0
WireConnection;141;1;140;0
WireConnection;163;0;111;0
WireConnection;163;1;162;0
WireConnection;149;0;111;0
WireConnection;149;1;148;0
WireConnection;157;0;111;0
WireConnection;157;1;156;0
WireConnection;167;0;111;0
WireConnection;167;1;166;0
WireConnection;165;0;111;0
WireConnection;165;1;164;0
WireConnection;161;0;111;0
WireConnection;161;1;160;0
WireConnection;159;0;111;0
WireConnection;159;1;158;0
WireConnection;153;0;111;0
WireConnection;153;1;152;0
WireConnection;155;0;111;0
WireConnection;155;1;154;0
WireConnection;171;0;147;1
WireConnection;171;1;149;1
WireConnection;171;2;151;1
WireConnection;171;3;153;1
WireConnection;173;0;163;1
WireConnection;173;1;165;1
WireConnection;173;2;167;1
WireConnection;173;3;169;1
WireConnection;172;0;155;1
WireConnection;172;1;157;1
WireConnection;172;2;159;1
WireConnection;172;3;161;1
WireConnection;170;0;113;1
WireConnection;170;1;141;1
WireConnection;170;2;143;1
WireConnection;170;3;145;1
WireConnection;174;0;170;0
WireConnection;174;1;171;0
WireConnection;174;2;172;0
WireConnection;174;3;173;0
WireConnection;180;0;111;0
WireConnection;177;0;174;0
WireConnection;177;1;180;1
WireConnection;181;0;177;0
WireConnection;179;0;181;0
WireConnection;114;0;104;4
WireConnection;114;1;179;0
WireConnection;116;0;104;0
WireConnection;116;1;114;0
ASEEND*/
//CHKSM=8DCAFBA3F94AFAC6F27B8F823D189E6CBC99368F