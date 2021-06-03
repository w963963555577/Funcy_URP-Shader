// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/URP/CharacterEffect/AstralPossession"
{
    Properties
    {
        [HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
        [ASEBegin]_diffuse("BaseColor", 2D) = "white" {}
        _mask("ESSGMask", 2D) = "white" {}
        _EdgeLightWidth("EdgeLightWidth", Range( 0 , 1)) = 0.3
        _EdgeLightIntensity("EdgeLightIntensity", Range( 0 , 1)) = 0.3
        [HDR]_Color("Color", Color) = (1,1,1,1)
        [ASEEnd][HDR]_EmissionColor("EmissionColor", Color) = (1,1,1,1)
        [HideInInspector] _texcoord( "", 2D ) = "white" {}

    }

    SubShader
    {
		LOD 0

        
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        
        Cull Back
        AlphaToMask Off
        
        Pass
        {
            
            Name "Forward"
            Tags { "LightMode"="UniversalForward" }
            
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            ZTest LEqual
            Offset 0 , 0
            ColorMask RGBA
            
            
            HLSLPROGRAM
            
            #define ASE_SRP_VERSION 70301
            #define REQUIRE_DEPTH_TEXTURE 1

            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            #pragma multi_compile_instancing
            #if ASE_SRP_VERSION <= 70108
                #define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
            #endif

            #define ASE_NEEDS_FRAG_WORLD_POSITION
            #define ASE_NEEDS_VERT_NORMAL
            #define ASE_NEEDS_FRAG_POSITION
            #define ASE_NEEDS_VERT_POSITION


            struct VertexInput
            {
                float4 positionOS: POSITION;
                float3 normalOS: NORMAL;
                float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 positionCS: SV_POSITION;
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    float3 positionWS: TEXCOORD0;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    float4 shadowCoord: TEXCOORD1;
                #endif
                #ifdef ASE_FOG
                    float fogFactor: TEXCOORD2;
                #endif
                float4 ase_texcoord3 : TEXCOORD3;
                float4 ase_texcoord4 : TEXCOORD4;
                float4 ase_texcoord5 : TEXCOORD5;
                float4 ase_texcoord6 : TEXCOORD6;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)

            float4 _Color;
            float4 _diffuse_ST;
            float4 _EmissionColor;
            float4 _mask_ST;
            float _EdgeLightWidth;
            float _EdgeLightIntensity;
            CBUFFER_END
            sampler2D _diffuse;
            sampler2D _mask;
            uniform float4 _CameraDepthTexture_TexelSize;


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
            

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                float3 appendResult73 = (float3(0.0 , sin( _TimeParameters.x ) , 0.0));
                float3 temp_output_76_0 = ( appendResult73 * float3( 0,0.1,0 ) );
                
                float3 ase_worldNormal = TransformObjectToWorldNormal(v.normalOS);
                o.ase_texcoord4.xyz = ase_worldNormal;
                
                float3 temp_output_81_0 = ( v.positionOS.xyz + temp_output_76_0 );
                float3 vertexPos83 = temp_output_81_0;
                float4 ase_clipPos83 = TransformObjectToHClip((vertexPos83).xyz);
                float4 screenPos83 = ComputeScreenPos(ase_clipPos83);
                o.ase_texcoord6 = screenPos83;
                
                o.ase_texcoord3.xy = v.ase_texcoord.xy;
                o.ase_texcoord5 = v.positionOS;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord3.zw = 0;
                o.ase_texcoord4.w = 0;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    float3 defaultVertexValue = v.positionOS.xyz;
                #else
                    float3 defaultVertexValue = float3(0, 0, 0);
                #endif
                float3 vertexValue = temp_output_76_0;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    v.positionOS.xyz = vertexValue;
                #else
                    v.positionOS.xyz += vertexValue;
                #endif
                v.normalOS = v.normalOS;

                float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
                float4 positionCS = TransformWorldToHClip(positionWS);

                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    o.positionWS = positionWS;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    VertexPositionInputs vertexInput = (VertexPositionInputs)0;
                    vertexInput.positionWS = positionWS;
                    vertexInput.positionCS = positionCS;
                    o.shadowCoord = GetShadowCoord(vertexInput);
                #endif
                #ifdef ASE_FOG
                    o.fogFactor = ComputeFogFactor(positionCS.z);
                #endif
                o.positionCS = positionCS;
                return o;
            }


            half4 frag(VertexOutput IN ): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    float3 positionWSition = IN.positionWS;
                #endif
                float4 ShadowCoords = float4(0, 0, 0, 0);

                #if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                        ShadowCoords = IN.shadowCoord;
                    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                        ShadowCoords = TransformWorldToShadowCoord(positionWSition);
                    #endif
                #endif
                float2 uv_diffuse = IN.ase_texcoord3.xy * _diffuse_ST.xy + _diffuse_ST.zw;
                float4 tex2DNode6 = tex2D( _diffuse, uv_diffuse );
                float4 temp_output_42_0 = ( _Color * tex2DNode6 );
                float3 appendResult35 = (float3(temp_output_42_0.rgb));
                float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - positionWSition );
                ase_worldViewDir = normalize(ase_worldViewDir);
                float3 ase_worldNormal = IN.ase_texcoord4.xyz;
                float dotResult14 = dot( ase_worldViewDir , ase_worldNormal );
                float dotResult21 = dot( ase_worldViewDir , ( _MainLightPosition.xyz - ( ase_worldNormal * 0.82 ) ) );
                float smoothstepResult27 = smoothstep( ( 1.0 - _EdgeLightWidth ) , ( 1.0 - ( _EdgeLightWidth * 0.7 ) ) , max( ( 1.0 - dotResult14 ) , max( dotResult21 , 0.0 ) ));
                float fresnel_edge_light32 = ( smoothstepResult27 * _EdgeLightIntensity );
                float3 lerpResult34 = lerp( appendResult35 , float3( 1,1,1 ) , fresnel_edge_light32);
                float2 uv_mask = IN.ase_texcoord3.xy * _mask_ST.xy + _mask_ST.zw;
                float3 appendResult59 = (float3(( _EmissionColor * tex2DNode6 * tex2D( _mask, uv_mask ).r ).rgb));
                
                float2 appendResult49 = (float2(IN.ase_texcoord5.xyz.x , IN.ase_texcoord5.xyz.y));
                float2 panner46 = ( 0.5 * _Time.y * float2( -1,-0.5 ) + appendResult49);
                float simplePerlin2D44 = snoise( panner46*4.0 );
                simplePerlin2D44 = simplePerlin2D44*0.5 + 0.5;
                float smoothstepResult50 = smoothstep( 0.0 , 0.05 , ( tex2DNode6.a * simplePerlin2D44 ));
                float4 screenPos83 = IN.ase_texcoord6;
                float4 ase_screenPosNorm83 = screenPos83 / screenPos83.w;
                ase_screenPosNorm83.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm83.z : ase_screenPosNorm83.z * 0.5 + 0.5;
                float screenDepth83 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm83.xy ),_ZBufferParams);
                float distanceDepth83 = abs( ( screenDepth83 - LinearEyeDepth( ase_screenPosNorm83.z,_ZBufferParams ) ) / ( 1.0 ) );
                
                float3 BakedAlbedo = 0;
                float3 BakedEmission = 0;
                float3 Color = ( lerpResult34 + appendResult59 );
                float Alpha = ( (temp_output_42_0).a * max( tex2DNode6.a , smoothstepResult50 ) * min( distanceDepth83 , 1.0 ) );
                float AlphaClipThreshold = 0.5;
                float AlphaClipThresholdShadow = 0.5;

                #ifdef _ALPHATEST_ON
                    clip(Alpha - AlphaClipThreshold);
                #endif

                #ifdef LOD_FADE_CROSSFADE
                    LODDitheringTransition(IN.positionCS.xyz, unity_LODFade.x);
                #endif

                #ifdef ASE_FOG
                    Color = MixFog(Color, IN.fogFactor);
                #endif

                return half4(Color, Alpha);
            }
            
            ENDHLSL
            
        }

       
    }
    CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
    Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18909
-1920;70;1920;1029;1158.821;1177.237;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;31;-2816,-256;Inherit;False;1268;745;;19;13;12;16;18;14;15;21;20;17;23;24;27;25;28;29;26;30;32;39;Fresnel Edge Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;13;-2768,0;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;17;-2768,176;Inherit;False;Constant;_082;0.82;1;0;Create;True;0;0;0;False;0;False;0.82;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;20;-2640,304;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-2512,48;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;12;-2768,-208;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;18;-2384,48;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2384,176;Inherit;False;Property;_EdgeLightWidth;EdgeLightWidth;2;0;Create;True;0;0;0;False;0;False;0.3;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;21;-2512,-208;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;14;-2512,-80;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;23;-2384,-208;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-2176,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;48;-1211.822,275.3182;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;75;44.58809,36.74312;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;15;-2384,-80;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;74;242.5175,0.1318848;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;28;-2128,176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;49;-1005.822,285.3182;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;39;-2048,0;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;24;-2256,-208;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;73;449.5997,-78.81104;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;46;-851.3,293.1001;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-1,-0.5;False;1;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;5;-1051,-444;Inherit;True;Property;_diffuse;BaseColor;0;0;Create;False;0;0;0;False;0;False;None;7a6c4915886d9f44c8d1e7e7e0e49b90;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SmoothstepOpNode;27;-2128,-208;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2384,304;Inherit;False;Property;_EdgeLightIntensity;EdgeLightIntensity;3;0;Create;True;0;0;0;False;0;False;0.3;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;44;-639.3,332.1;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;57;-1056,-256;Inherit;True;Property;_mask;ESSGMask;1;0;Create;False;0;0;0;False;0;False;None;7a6c4915886d9f44c8d1e7e7e0e49b90;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;6;-795,-444;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1968,-208;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;621.2145,-66.22594;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0.1,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;80;-77.221,-915.9371;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;41;-398.1285,-507.0101;Inherit;False;Property;_Color;Color;4;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;81;211.3789,-854.8369;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;54;-625.5216,-808.7819;Inherit;False;Property;_EmissionColor;EmissionColor;5;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-518.7217,184.6181;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;58;-768,-256;Inherit;True;Property;_TextureSample1;Texture Sample 1;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-1808,-208;Inherit;False;fresnel_edge_light;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-142.565,-428.1662;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;35;0,-384;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-376.3168,-137.8526;Inherit;False;32;fresnel_edge_light;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;50;-337.0216,107.5181;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;83;512.9789,-554.5372;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-384,-768;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;59;-161.5216,-729.7819;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;52;197.4785,-169.5819;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;38;276,-250;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;34;177,-440;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMinOpNode;82;815.8789,-798.937;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;78;362.5656,-709.8943;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;726.2784,-402.1819;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;377.4784,-490.7819;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-42.98877,-122.8354;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;77;343.5656,-824.8943;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;79;554.5656,-820.8943;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;67;998,-518;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;14;ZDShader/URP/CharacterEffect/AstralPossession;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;True;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0;5;False;True;False;False;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;68;823,-497;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;69;823,-497;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;70;823,-497;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;66;680,-874;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;14;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;16;0;13;0
WireConnection;16;1;17;0
WireConnection;18;0;20;0
WireConnection;18;1;16;0
WireConnection;21;0;12;0
WireConnection;21;1;18;0
WireConnection;14;0;12;0
WireConnection;14;1;13;0
WireConnection;23;0;21;0
WireConnection;29;0;25;0
WireConnection;15;0;14;0
WireConnection;74;0;75;0
WireConnection;28;0;25;0
WireConnection;49;0;48;1
WireConnection;49;1;48;2
WireConnection;39;0;29;0
WireConnection;24;0;15;0
WireConnection;24;1;23;0
WireConnection;73;1;74;0
WireConnection;46;0;49;0
WireConnection;27;0;24;0
WireConnection;27;1;28;0
WireConnection;27;2;39;0
WireConnection;44;0;46;0
WireConnection;6;0;5;0
WireConnection;6;7;5;1
WireConnection;30;0;27;0
WireConnection;30;1;26;0
WireConnection;76;0;73;0
WireConnection;81;0;80;0
WireConnection;81;1;76;0
WireConnection;51;0;6;4
WireConnection;51;1;44;0
WireConnection;58;0;57;0
WireConnection;58;7;57;1
WireConnection;32;0;30;0
WireConnection;42;0;41;0
WireConnection;42;1;6;0
WireConnection;35;0;42;0
WireConnection;50;0;51;0
WireConnection;83;1;81;0
WireConnection;55;0;54;0
WireConnection;55;1;6;0
WireConnection;55;2;58;1
WireConnection;59;0;55;0
WireConnection;52;0;6;4
WireConnection;52;1;50;0
WireConnection;38;0;42;0
WireConnection;34;0;35;0
WireConnection;34;2;33;0
WireConnection;82;0;83;0
WireConnection;53;0;38;0
WireConnection;53;1;52;0
WireConnection;53;2;82;0
WireConnection;56;0;34;0
WireConnection;56;1;59;0
WireConnection;60;0;33;0
WireConnection;60;1;50;0
WireConnection;77;0;81;0
WireConnection;79;0;77;0
WireConnection;79;1;78;4
WireConnection;67;2;56;0
WireConnection;67;3;53;0
WireConnection;67;5;76;0
ASEEND*/
//CHKSM=2C27BA149863A61231AEC69B074FF485A484A33C