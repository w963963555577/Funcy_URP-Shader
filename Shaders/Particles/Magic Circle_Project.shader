// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "ZDShader/URP/Particles/Custom Effects/Magic Circle-Project"
{
    Properties
    {
        [HideInInspector] _AlphaCutoff ("Alpha Cutoff ", Range(0, 1)) = 0.5
        [HideInInspector] _EmissionColor ("Emission Color", Color) = (1, 1, 1, 1)
        [HDR]_Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("MainTex", 2D) = "white" { }
        [HDR]_MagicArrowColor ("Color", Color) = (1, 1, 1, 1)
        _MagicArrowMap ("Magic Arrow Map", 2D) = "white" { }
        [HDR]_EdgeColor ("EdgeColor", Color) = (1, 0.1142083, 0, 1)
        _NoiseMap ("NoiseMap", 2D) = "white" { }
        _Angle ("Angle", Range(0, 360)) = 173.2921
        _CenterSplit ("Center Split", Range(0, 1)) = 0.5411765
        _Blur ("Blur", Float) = 0.05
    }

    SubShader
    {
        LOD 0

        
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }
        
        Cull Off
        HLSLINCLUDE
        #pragma target 3.0
        ENDHLSL
        
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZWrite On
            ZTest LEqual
            Offset 0, 0
            ColorMask RGBA
            
            
            HLSLPROGRAM
            
            #define REQUIRE_DEPTH_TEXTURE 1
            #define _RECEIVE_SHADOWS_OFF 1
            #pragma multi_compile_instancing
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

            

            sampler2D _NoiseMap;
            sampler2D _MagicArrowMap;
            sampler2D _MainTex;
            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            half4 _EdgeColor;
            half4 _NoiseMap_ST;
            half _CenterSplit;
            half4 _MagicArrowColor;
            half _Blur;
            half _Angle;
            CBUFFER_END


            struct VertexInput
            {
                float4 vertex: POSITION;
                float3 ase_normal: NORMAL;
                float4 ase_texcoord: TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 clipPos: SV_POSITION;
                #ifdef ASE_FOG
                    float fogFactor: TEXCOORD0;
                #endif
                float4 ase_texcoord1: TEXCOORD1;
                
                float4 screenUV: TEXCOORD0;
                float4 viewRayOS: TEXCOORD2;
                float3 cameraPosOS: TEXCOORD3;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // Tranforms position from object to camera space
            inline float3 ObjectToViewPos(float3 pos)
            {
                return mul(UNITY_MATRIX_V, mul(GetObjectToWorldMatrix(), float4(pos, 1.0))).xyz;
            }
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
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
                float3 vertexValue = defaultVertexValue;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    v.vertex.xyz = vertexValue;
                #else
                    v.vertex.xyz += vertexValue;
                #endif
                v.ase_normal = v.ase_normal;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                o.clipPos = vertexInput.positionCS;
                #ifdef ASE_FOG
                    o.fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                #endif


                o.screenUV = ComputeScreenPos(o.clipPos);
                
                float3 viewRay = ObjectToViewPos(v.vertex);
                
                o.viewRayOS.w = viewRay.z;
                
                viewRay *= -1;
                float4x4 ViewToObjectMatrix = mul(GetWorldToObjectMatrix(), UNITY_MATRIX_I_V);
                
                o.viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, viewRay);
                o.cameraPosOS = mul(ViewToObjectMatrix, float4(0.0h, 0.0h, 0.0h, 1.0h)).xyz;
                


                return o;
            }

            float2 projectorUV(VertexOutput IN)
            {
                IN.viewRayOS /= IN.viewRayOS.w;
                IN.screenUV = IN.screenUV / IN.screenUV.w;
                #if defined(UNITY_SINGLE_PASS_STEREO)
                    IN.screenUV.xy = UnityStereoTransformScreenSpaceTex(IN.screenUV.xy);
                #endif
                float sceneCameraSpaceDepth = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(IN.screenUV), _ZBufferParams);
                float3 decalSpaceScenePos = IN.cameraPosOS + IN.viewRayOS * sceneCameraSpaceDepth;
                
                float2 decalSpaceUV = decalSpaceScenePos.xy + 0.5;
                
                float mask = (abs(decalSpaceScenePos.x) < 0.5) * (abs(decalSpaceScenePos.y) < 0.5) * (abs(decalSpaceScenePos.z) < 0.5);

                clip(mask - 0.5);

                return decalSpaceUV.xy;
            }
            

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float3 appendResult132 = (float3(_Color.rgb));
				float3 appendResult143 = (float3(_EdgeColor.rgb));
				float2 currentUV216 = projectorUV(IN);
				float2 panner100 = ( 0.1 * _Time.y * float2( 0,-1 ) + currentUV216);
				float4 tex2DNode99 = tex2D( _NoiseMap, ( ( panner100 * _NoiseMap_ST.xy ) + _NoiseMap_ST.zw ) );
				float smoothstepResult117 = smoothstep( 0.45 , 0.55 , tex2DNode99.r);
				float smoothstepResult118 = smoothstep( 0.55 , 0.65 , tex2DNode99.r);
				float temp_output_120_0 = ( smoothstepResult117 - smoothstepResult118 );
				float temp_output_111_0 = saturate( length( ( ( float2( 0.5,0.5 ) - currentUV216 ) * float2( 2,2 ) ) ) );
				float smoothstepResult113 = smoothstep( ( _CenterSplit - 0.01 ) , ( _CenterSplit + 0.01 ) , temp_output_111_0);
				float3 lerpResult142 = lerp( appendResult132 , appendResult143 , ( temp_output_120_0 * smoothstepResult113 ));
				float3 appendResult134 = (float3(_MagicArrowColor.rgb));
				float temp_output_32_0 = (0.0 + (_Angle - 0.0) * (1.0 - 0.0) / (360.0 - 0.0));
				float temp_output_48_0 = min( _Blur , ( 1.0 - ( abs( ( temp_output_32_0 - 0.5 ) ) * 2.0 ) ) );
				float cos54 = cos( ( temp_output_32_0 * PI ) );
				float sin54 = sin( ( temp_output_32_0 * PI ) );
				float2 rotator54 = mul( currentUV216 - float2( 0.5,0.5 ) , float2x2( cos54 , -sin54 , sin54 , cos54 )) + float2( 0.5,0.5 );
				float smoothstepResult63 = smoothstep( ( 0.5 - temp_output_48_0 ) , ( 0.5 + temp_output_48_0 ) , rotator54.x);
				float cos59 = cos( ( ( temp_output_32_0 * PI ) * -1.0 ) );
				float sin59 = sin( ( ( temp_output_32_0 * PI ) * -1.0 ) );
				float2 rotator59 = mul( currentUV216 - float2( 0.5,0.5 ) , float2x2( cos59 , -sin59 , sin59 , cos59 )) + float2( 0.5,0.5 );
				float smoothstepResult65 = smoothstep( ( 0.5 - temp_output_48_0 ) , ( 0.5 + temp_output_48_0 ) , rotator59.x);
				float smoothstepResult126 = smoothstep( 0.05 , 0.1 , temp_output_111_0);
				float temp_output_130_0 = max( max( ( ( 1.0 - smoothstepResult63 ) * tex2D( _MagicArrowMap, rotator54 ).a ) , ( tex2D( _MagicArrowMap, rotator59 ).a * smoothstepResult65 ) ) , ( 1.0 - smoothstepResult126 ) );
				float3 lerpResult141 = lerp( lerpResult142 , appendResult134 , temp_output_130_0);
				
				float mulTime128 = _TimeParameters.x * 0.1;
				float cos6 = cos( ( mulTime128 * PI ) );
				float sin6 = sin( ( mulTime128 * PI ) );
				float2 rotator6 = mul( currentUV216 - float2( 0.5,0.5 ) , float2x2( cos6 , -sin6 , sin6 , cos6 )) + float2( 0.5,0.5 );
				float4 tex2DNode5 = tex2D( _MainTex, rotator6 );
				float cos73 = cos( ( -0.5 * PI ) );
				float sin73 = sin( ( -0.5 * PI ) );
				float2 rotator73 = mul( currentUV216 - float2( 0.5,0.5 ) , float2x2( cos73 , -sin73 , sin73 , cos73 )) + float2( 0.5,0.5 );
				float2 break12 = ( float2( 0.5,0.5 ) - rotator73 );
				float2 break76 = rotator73;
				float2 appendResult28 = (float2(break76.x , ( 1.0 - break76.y )));
				float2 break21 = ( float2( 0.5,0.5 ) - appendResult28 );
				float smoothstepResult81 = smoothstep( ( 0.0 - temp_output_48_0 ) , ( 0.0 + temp_output_48_0 ) , min( ( ( atan2( break12.y , break12.x ) / PI ) + temp_output_32_0 ) , ( ( atan2( break21.y , break21.x ) / PI ) + temp_output_32_0 ) ));
				float temp_output_77_0 = ( 1.0 - smoothstepResult81 );
				float smoothstepResult105 = smoothstep( 0.0 , 1.0 , tex2DNode99.r);
				float lerpResult123 = lerp( smoothstepResult105 , max( smoothstepResult105 , temp_output_120_0 ) , smoothstepResult113);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult141;
				float Alpha = max( ( tex2DNode5.r * tex2DNode5.a * min( temp_output_77_0 , lerpResult123 ) ) , ( temp_output_130_0 * temp_output_77_0 ) );
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
    }
    CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
    Fallback "Hidden/InternalErrorShader"
}
/*ASEBEGIN
Version=17800
95;76;1356;747;3823.831;228.3242;1.905177;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;10;-2816,384;Inherit;True;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;216;-2608,384;Inherit;False;currentUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;74;-2384,656;Inherit;False;1;0;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;-2336,464;Inherit;False;216;currentUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;73;-2160,464;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1614.929,1155.066;Inherit;False;Property;_Angle;Angle;6;0;Create;True;0;0;False;0;173.2921;360;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;32;-1296.777,1137.966;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;360;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;76;-1920,560;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleSubtractOpNode;39;-1088,1136;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;27;-1833.197,720.6853;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;40;-960,1136;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;28;-1644.12,715.629;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-960.9882,1513.131;Inherit;False;216;currentUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;98;-451.762,1287.629;Inherit;True;Property;_NoiseMap;NoiseMap;5;0;Create;True;0;0;False;0;6a1fffff897d00e459ab3c9226cbedc6;6a1fffff897d00e459ab3c9226cbedc6;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;-1388.12,763.629;Inherit;True;2;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;11;-1388.12,443.629;Inherit;True;2;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-832,1136;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;148;-576,1600;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.PannerNode;100;-557,1492;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-1;False;1;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;42;-720,1136;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;55;-1401.042,-6.632784;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-379.8627,1504.007;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1024,256;Inherit;False;Property;_Blur;Blur;8;0;Create;True;0;0;False;0;0.05;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;21;-1196.12,763.629;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;219;-1376,-192;Inherit;False;216;currentUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;12;-1196.172,436.0978;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ATan2OpNode;14;-972.1199,443.629;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;23;-956.1199,971.629;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;16;-956.1199,651.629;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;107;-774.4012,1694.356;Inherit;False;2;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ATan2OpNode;25;-972.1199,763.629;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;48;-768,256;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;54;-1040,-320;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;150;-243.8627,1500.007;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1191.657,2.994658;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;62;-589.8088,-409.0593;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;-764.1199,443.629;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;59;-1040,-96;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;84;-380.1046,-199.4015;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;22;-764.1199,763.629;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;-380.1046,-87.40152;Inherit;False;2;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-630.4012,1694.356;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;99;-195.7621,1287.629;Inherit;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;118;128,1632;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.55;False;2;FLOAT;0.65;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;-480,336;Inherit;False;2;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;69;-640,112;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleSubtractOpNode;82;-480,224;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;110;-502.4012,1694.356;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;49;-1376,-400;Inherit;True;Property;_MagicArrowMap;Magic Arrow Map;3;0;Create;True;0;0;False;0;594858368701aa048886de204e28d1ae;594858368701aa048886de204e28d1ae;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-556.1199,763.629;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;63;-318.498,-427.2229;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.49;False;2;FLOAT;0.51;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;117;128,1504;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.45;False;2;FLOAT;0.55;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-624,2032;Inherit;False;Property;_CenterSplit;Center Split;7;0;Create;True;0;0;False;0;0.5411765;360;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-556.1199,443.629;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;79;-88.68159,-397.9706;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;115;-272,1920;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;65;-342.4324,45.836;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.49;False;2;FLOAT;0.51;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;128;-1216.764,-550.0245;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;105;144,1264;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;-272,2032;Inherit;False;2;2;0;FLOAT;0.5;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-80,720;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-694.1751,-291.6501;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;120;336,1504;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;111;-326.4012,1694.356;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;30;-311.7652,530.6923;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;56;-704,-96;Inherit;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-80,832;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-35.97142,-262.7807;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-39.52801,-123.5464;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;113;-160,1696;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;81;71.00251,512.7748;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;125;602.6003,1478.789;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;8;-983.6998,-436.095;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;126;-9.665703,133.8501;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.05;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;127;-1025.764,-531.0245;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;131;791.848,853.022;Inherit;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;77;336,528;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;57;197.144,-151.6312;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;144;914.9062,1063.783;Inherit;False;Property;_EdgeColor;EdgeColor;4;1;[HDR];Create;True;0;0;False;0;1,0.1142083,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotatorNode;6;-775.6998,-436.095;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;123;640,1168;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;4;-775.6998,-676.095;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.OneMinusNode;129;241.1189,147.1605;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;96;577.3264,542.9425;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;130;333.9137,-112.4973;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;143;1110.137,1060.696;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;916.9044,1313.474;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;135;695.1545,66.14741;Inherit;False;Property;_MagicArrowColor;Color;2;1;[HDR];Create;False;0;0;False;0;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;132;987.0795,849.9352;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;5;-519.6998,-676.095;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;558.8008,-61.24439;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;142;1254.76,908.7174;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;134;890.386,63.06074;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;537.929,-341.6026;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;71;1505.528,-260.5464;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;141;1383.061,-142.4864;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;1;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2108.386,-352.7953;Half;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;Magic Circle;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;0;Forward;7;False;False;False;True;2;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;2;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;10;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Vertex Position,InvertActionOnDeselection;1;0;4;True;False;False;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;2;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;3;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;216;0;10;0
WireConnection;73;0;217;0
WireConnection;73;2;74;0
WireConnection;32;0;31;0
WireConnection;76;0;73;0
WireConnection;39;0;32;0
WireConnection;27;0;76;1
WireConnection;40;0;39;0
WireConnection;28;0;76;0
WireConnection;28;1;27;0
WireConnection;26;1;28;0
WireConnection;11;1;73;0
WireConnection;41;0;40;0
WireConnection;148;0;98;0
WireConnection;100;0;218;0
WireConnection;42;0;41;0
WireConnection;55;0;32;0
WireConnection;149;0;100;0
WireConnection;149;1;148;0
WireConnection;21;0;26;0
WireConnection;12;0;11;0
WireConnection;14;0;12;1
WireConnection;14;1;12;0
WireConnection;107;1;218;0
WireConnection;25;0;21;1
WireConnection;25;1;21;0
WireConnection;48;0;34;0
WireConnection;48;1;42;0
WireConnection;54;0;219;0
WireConnection;54;2;55;0
WireConnection;150;0;149;0
WireConnection;150;1;148;1
WireConnection;60;0;55;0
WireConnection;62;0;54;0
WireConnection;15;0;14;0
WireConnection;15;1;16;0
WireConnection;59;0;219;0
WireConnection;59;2;60;0
WireConnection;84;1;48;0
WireConnection;22;0;25;0
WireConnection;22;1;23;0
WireConnection;85;1;48;0
WireConnection;109;0;107;0
WireConnection;99;0;98;0
WireConnection;99;1;150;0
WireConnection;118;0;99;1
WireConnection;83;1;48;0
WireConnection;69;0;59;0
WireConnection;82;1;48;0
WireConnection;110;0;109;0
WireConnection;24;0;22;0
WireConnection;24;1;32;0
WireConnection;63;0;62;0
WireConnection;63;1;84;0
WireConnection;63;2;85;0
WireConnection;117;0;99;1
WireConnection;17;0;15;0
WireConnection;17;1;32;0
WireConnection;79;0;63;0
WireConnection;115;0;114;0
WireConnection;65;0;69;0
WireConnection;65;1;82;0
WireConnection;65;2;83;0
WireConnection;105;0;99;1
WireConnection;116;0;114;0
WireConnection;35;1;48;0
WireConnection;50;0;49;0
WireConnection;50;1;54;0
WireConnection;120;0;117;0
WireConnection;120;1;118;0
WireConnection;111;0;110;0
WireConnection;30;0;17;0
WireConnection;30;1;24;0
WireConnection;56;0;49;0
WireConnection;56;1;59;0
WireConnection;36;1;48;0
WireConnection;61;0;79;0
WireConnection;61;1;50;4
WireConnection;66;0;56;4
WireConnection;66;1;65;0
WireConnection;113;0;111;0
WireConnection;113;1;115;0
WireConnection;113;2;116;0
WireConnection;81;0;30;0
WireConnection;81;1;35;0
WireConnection;81;2;36;0
WireConnection;125;0;105;0
WireConnection;125;1;120;0
WireConnection;126;0;111;0
WireConnection;127;0;128;0
WireConnection;77;0;81;0
WireConnection;57;0;61;0
WireConnection;57;1;66;0
WireConnection;6;0;8;0
WireConnection;6;2;127;0
WireConnection;123;0;105;0
WireConnection;123;1;125;0
WireConnection;123;2;113;0
WireConnection;129;0;126;0
WireConnection;96;0;77;0
WireConnection;96;1;123;0
WireConnection;130;0;57;0
WireConnection;130;1;129;0
WireConnection;143;0;144;0
WireConnection;145;0;120;0
WireConnection;145;1;113;0
WireConnection;132;0;131;0
WireConnection;5;0;4;0
WireConnection;5;1;6;0
WireConnection;106;0;130;0
WireConnection;106;1;77;0
WireConnection;142;0;132;0
WireConnection;142;1;143;0
WireConnection;142;2;145;0
WireConnection;134;0;135;0
WireConnection;44;0;5;1
WireConnection;44;1;5;4
WireConnection;44;2;96;0
WireConnection;71;0;44;0
WireConnection;71;1;106;0
WireConnection;141;0;142;0
WireConnection;141;1;134;0
WireConnection;141;2;130;0
WireConnection;0;2;141;0
WireConnection;0;3;71;0
ASEEND*/
// CHKSM = 6BEB54ABF024915586D87A40EB27E181DA9E62F1