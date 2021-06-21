// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hidden/RenderFeature/TimeGate"
{
    Properties
    {
        [HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
        [HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
        [ASEBegin][HDR]_Color("Color", Color) = (1,1,1,1)
        [HDR]_ColorFar("ColorFar", Color) = (0.5377358,0.5377358,0.5377358,1)
        [HDR]_DropColor("DropColor", Color) = (1,1,1,1)
        [ASEEnd]_Float0("Float 0", Range( 0 , 1)) = 0

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
            
            Blend Off
            ZWrite Off
            ZTest Always
            Offset 0 , 0
            ColorMask RGBA
            
            
            HLSLPROGRAM
            
            #define ASE_SRP_VERSION 70301
            #define ASE_USING_SAMPLING_MACROS 1

            
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
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)

            float4 _ColorFar;
            float4 _Color;
            float4 _DropColor;
            float _Float0;
            CBUFFER_END
            TEXTURE2D(_CustomScreenTextureColorRT);
            TEXTURE2D(_TimeGateMap);
            SAMPLER(sampler_linear_repeat);
            SAMPLER(sampler_CustomScreenTextureColorRT);


            float vDrop1_g6( float2 uv, float t, float count, float stretch, float2 speed, float2 trailLength )
            {
            	uv.x = uv.x * count;
            	float dx = frac(uv.x);
            	uv.x = floor(uv.x);
            	uv.y *= stretch;
            	float o = sin(uv.x * 215.4);
            	float s = cos(uv.x * 33.1) * speed.x + speed.y;
            	float trail = lerp(trailLength.y, trailLength.x, s);
            	float yv = frac(uv.y + t * s + o) * trail;
            	yv = 1.0 / yv;
            	yv = smoothstep(0.0, 1.0, yv * yv);
            	yv = sin(yv * PI) * (s * 5.0);
            	float d2 = sin(dx * PI);
            	return yv * (d2 * d2);
            }
            
            float vDrop1_g5( float2 uv, float t, float count, float stretch, float2 speed, float2 trailLength )
            {
            	uv.x = uv.x * count;
            	float dx = frac(uv.x);
            	uv.x = floor(uv.x);
            	uv.y *= stretch;
            	float o = sin(uv.x * 215.4);
            	float s = cos(uv.x * 33.1) * speed.x + speed.y;
            	float trail = lerp(trailLength.y, trailLength.x, s);
            	float yv = frac(uv.y + t * s + o) * trail;
            	yv = 1.0 / yv;
            	yv = smoothstep(0.0, 1.0, yv * yv);
            	yv = sin(yv * PI) * (s * 5.0);
            	float d2 = sin(dx * PI);
            	return yv * (d2 * d2);
            }
            
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

                o.ase_texcoord3.xy = v.ase_texcoord.xy;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord3.zw = 0;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    float3 defaultVertexValue = v.positionOS.xyz;
                #else
                    float3 defaultVertexValue = float3(0, 0, 0);
                #endif
                float3 vertexValue = defaultVertexValue;
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
                float2 appendResult74 = (float2(( _ScreenParams.x / _ScreenParams.y ) , 1.0));
                float2 temp_output_75_0 = ( ( IN.ase_texcoord3.xy - float2( 0.5,0.5 ) ) * float2( 1.41414,1.41414 ) * appendResult74 );
                float temp_output_130_0 = length( temp_output_75_0 );
                float temp_output_163_0 = ( 1.0 - temp_output_130_0 );
                float cos159 = cos( ( ( _Float0 * PI ) * -5.0 * temp_output_163_0 ) );
                float sin159 = sin( ( ( _Float0 * PI ) * -5.0 * temp_output_163_0 ) );
                float2 rotator159 = mul( IN.ase_texcoord3.xy - float2( 0.5,0.5 ) , float2x2( cos159 , -sin159 , sin159 , cos159 )) + float2( 0.5,0.5 );
                float smoothstepResult191 = smoothstep( 0.0 , 1.0 , _Float0);
                float temp_output_200_0 = ( 1.0 - abs( ( ( smoothstepResult191 - 0.5 ) * 2.0 ) ) );
                float2 break77 = temp_output_75_0;
                float temp_output_88_0 = pow( ( pow( ( break77.x * break77.x ) , 4.0 ) + pow( ( break77.y * break77.y ) , 4.0 ) ) , 0.125 );
                float2 appendResult80 = (float2(( 0.3 / temp_output_88_0 ) , ( atan2( break77.y , break77.x ) * 0.3183099 )));
                float2 panner84 = ( 1.0 * _Time.y * float2( 0.1,0.02 ) + appendResult80);
                float smoothstepResult96 = smoothstep( 0.05 , 1.0 , temp_output_88_0);
                float temp_output_122_0 = ( 1.0 - smoothstepResult96 );
                float2 appendResult115 = (float2(panner84.x , ( ( 1.0 - SAMPLE_TEXTURE2D_LOD( _TimeGateMap, sampler_linear_repeat, panner84, 2.0 ).a ) * ( temp_output_122_0 * temp_output_122_0 * temp_output_122_0 ) )));
                float4 tex2DNode120 = SAMPLE_TEXTURE2D_GRAD( _TimeGateMap, sampler_linear_repeat, panner84, ddx( appendResult115 ), ddy( appendResult115 ) );
                float2 appendResult132 = (float2(( atan2( break77.x , break77.y ) * 0.3183099 ) , ( 6.0 / ( temp_output_130_0 + 0.1 ) )));
                float2 uv1_g6 = appendResult132;
                float mulTime136 = _TimeParameters.x * 0.5;
                float t1_g6 = mulTime136;
                float count1_g6 = 256.0;
                float stretch1_g6 = 0.05;
                float2 speed1_g6 = float2( 0.1,0.7 );
                float2 trailLength1_g6 = float2( 10,15 );
                float localvDrop1_g6 = vDrop1_g6( uv1_g6 , t1_g6 , count1_g6 , stretch1_g6 , speed1_g6 , trailLength1_g6 );
                float temp_output_140_0 = localvDrop1_g6;
                float2 uv1_g5 = appendResult132;
                float t1_g5 = mulTime136;
                float count1_g5 = 128.0;
                float stretch1_g5 = 0.05;
                float2 speed1_g5 = float2( 0.1,0.7 );
                float2 trailLength1_g5 = float2( 35,95 );
                float localvDrop1_g5 = vDrop1_g5( uv1_g5 , t1_g5 , count1_g5 , stretch1_g5 , speed1_g5 , trailLength1_g5 );
                float temp_output_143_0 = localvDrop1_g5;
                float ps254 = max( max( tex2DNode120.r , tex2DNode120.b ) , ( max( temp_output_140_0 , temp_output_143_0 ) * temp_output_122_0 ) );
                float temp_output_196_0 = ( 0.1 * temp_output_200_0 * ps254 );
                float2 normalizeResult207 = normalize( ( IN.ase_texcoord3.xy - float2( 0.5,0.5 ) ) );
                float2 temp_output_209_0 = ( IN.ase_texcoord3.xy + ( ( sin( (-1.570796 + (_Float0 - 0.0) * (0.4111 - -1.570796) / (1.0 - 0.0)) ) + 1.0 ) * float2( 0.5,0.5 ) * normalizeResult207 ) );
                float2 lerpResult227 = lerp( ( rotator159 + temp_output_196_0 ) , temp_output_209_0 , smoothstepResult191);
                float4 tex2DNode156 = SAMPLE_TEXTURE2D( _CustomScreenTextureColorRT, sampler_CustomScreenTextureColorRT, ( lerpResult227 + temp_output_196_0 ) );
                float4 lerpResult262 = lerp( tex2DNode156 , _ColorFar , smoothstepResult191);
                float simplePerlin2D141 = snoise( appendResult132 );
                simplePerlin2D141 = simplePerlin2D141*0.5 + 0.5;
                float4 lerpResult95 = lerp( _ColorFar , ( ( tex2DNode120 * _Color ) + ( ( ( temp_output_140_0 * 0.25 * simplePerlin2D141 ) + ( temp_output_143_0 * 0.25 ) ) * _DropColor ) ) , smoothstepResult96);
                float2 break240 = max( ( 1.0 - temp_output_209_0 ) , float2( 0,0 ) );
                float2 break214 = max( temp_output_209_0 , float2( 0,0 ) );
                float smoothstepResult234 = smoothstep( 0.0 , ( 0.1 * temp_output_200_0 ) , min( min( break240.x , break214.x ) , min( break240.y , break214.y ) ));
                float4 lerpResult157 = lerp( lerpResult262 , lerpResult95 , ( 1.0 - smoothstepResult234 ));
                
                float3 BakedAlbedo = 0;
                float3 BakedEmission = 0;
                float3 Color = lerpResult157.rgb;
                float Alpha = 1;
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
-1898;117;1840;998;6929.335;2020.587;2.689269;True;False
Node;AmplifyShaderEditor.ScreenParams;72;-3519.999,604.8;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;73;-3263.999,636.8;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;70;-3519.999,476.8;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;74;-3072,640;Inherit;False;FLOAT2;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;71;-3263.999,476.8;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-2944,512;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;1.41414,1.41414;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;77;-2816,512;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-2576.906,856.0625;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-2576.906,728.0625;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;91;-2448.906,856.0625;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;89;-2448.906,728.0625;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-2258.206,792.0625;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;88;-2143.207,789.4623;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;0.125;False;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;76;-2688,512;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-2560,512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.3183099;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;79;-2432,640;Inherit;False;2;0;FLOAT;0.3;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;80;-2304,512;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;84;-2176,512;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.02;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerStateNode;83;-2432,256;Inherit;False;0;0;0;1;-1;1;0;SAMPLER2D;;False;1;SAMPLERSTATE;0
Node;AmplifyShaderEditor.SmoothstepOpNode;96;-1920,1024;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.05;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;67;-2432,0;Inherit;True;Global;_TimeGateMap;_TimeGateMap;0;0;Create;True;0;0;0;False;0;False;None;;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.LengthOpNode;130;-3072,1536;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;122;-1664,1024;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;68;-2176,0;Inherit;True;Property;_TextureSample4;Texture Sample 4;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;MipLevel;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;2;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;121;-1856,160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-1408,1024;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;131;-2560,1536;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;127;-2688,1408;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-2560,1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.3183099;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;133;-2432,1536;Inherit;False;2;0;FLOAT;6;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-1646.985,292.4486;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;116;-1920,256;Inherit;False;FLOAT;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;132;-2304,1408;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-5888,-896;Inherit;False;Property;_Float0;Float 0;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;136;-2304,1664;Inherit;False;1;0;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;115;-1792,0;Inherit;False;FLOAT2;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;203;-5248,-1024;Inherit;False;Constant;_targetPoint;targetPoint;6;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DdxOpNode;118;-1664,0;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;140;-2048,1408;Inherit;False;ParticleDrop;-1;;6;7cd94fab3a6f8a842b7d8ee387206121;0;6;4;FLOAT;256;False;5;FLOAT;0.05;False;6;FLOAT2;0.1,0.7;False;7;FLOAT2;10,15;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;158;-5248,-1152;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;212;-5247.868,-635.4539;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1.570796;False;4;FLOAT;0.4111;False;1;FLOAT;0
Node;AmplifyShaderEditor.DdyOpNode;119;-1664,128;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;143;-2048,1664;Inherit;False;ParticleDrop;-1;;5;7cd94fab3a6f8a842b7d8ee387206121;0;6;4;FLOAT;128;False;5;FLOAT;0.05;False;6;FLOAT2;0.1,0.7;False;7;FLOAT2;35,95;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;253;-1536,1536;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;191;-5636.893,-145.7778;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;205;-4992,-1024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;204;-4992,-1280;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;120;-1536,0;Inherit;True;Property;_TextureSample5;Texture Sample 5;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Derivative;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;197;-5504,128;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;259;-1150.855,573.2126;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;207;-4864,-1280;Inherit;True;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;260;-1280,1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;206;-4864,-1024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;-4736,-1024;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;258;-896,768;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;198;-5376,128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;209;-4480,-1152;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;163;-4943.04,354.8222;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;160;-5339.301,-414.0001;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;254;-759.5529,786.606;Inherit;False;ps;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;199;-5248,128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;239;-4480,-1408;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;255;-4736,-384;Inherit;False;254;ps;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;200;-5120,128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-5022.5,-423;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;-5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;-4543.696,-350.2002;Inherit;True;3;3;0;FLOAT;0.1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;159;-4812.951,-680.77;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;141;-2176,1152;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;243;-4352,-1152;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;242;-4352,-1408;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-1792,1664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;214;-4224,-1152;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;240;-4224,-1408;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;-1792,1408;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.25;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;256;-4445.992,-668.2577;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;145;-2048,1920;Inherit;False;Property;_DropColor;DropColor;4;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1.510966,1.80074,2.639016,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;98;-1408,512;Inherit;False;Property;_Color;Color;2;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1.414214,1.414214,1.414214,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;144;-1664,1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;246;-3968,-1152;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;227;-4176.591,-694.5699;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMinOpNode;245;-3968,-1408;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;248;-3243.77,-1104.679;Inherit;False;2;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;263;-3702.876,-694.6309;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMinOpNode;247;-3712,-1280;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;155;-3328,-768;Inherit;True;Global;_CustomScreenTextureColorRT;_CustomScreenTextureColorRT;1;0;Create;True;0;0;0;False;0;False;None;;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-1024,384;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-1536,1408;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;234;-3072,-1280;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.28;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;156;-2944,-768;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;100;-1408,256;Inherit;False;Property;_ColorFar;ColorFar;3;1;[HDR];Create;True;0;0;0;False;0;False;0.5377358,0.5377358,0.5377358,1;0.03688945,0.05951124,0.1221388,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;134;-896,384;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;222;-2176,-1152;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;95;-768,384;Inherit;False;3;0;COLOR;1,1,1,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;262;-725.7644,-20.03989;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;261;-1105.13,-63.49781;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;126;-2304,1536;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;249;-2816,-1280;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;230;-4738.085,333.2998;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;157;-384,256;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;-128,256;Half;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;14;Hidden/RenderFeature/TimeGate;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;True;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;7;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0;5;False;True;False;False;False;False;;True;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;14;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,-253;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;14;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;SceneSelectionPass;0;0;SceneSelectionPass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SceneSelectionPass;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;14;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;14;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;73;0;72;1
WireConnection;73;1;72;2
WireConnection;74;0;73;0
WireConnection;71;0;70;0
WireConnection;75;0;71;0
WireConnection;75;2;74;0
WireConnection;77;0;75;0
WireConnection;90;0;77;1
WireConnection;90;1;77;1
WireConnection;85;0;77;0
WireConnection;85;1;77;0
WireConnection;91;0;90;0
WireConnection;89;0;85;0
WireConnection;87;0;89;0
WireConnection;87;1;91;0
WireConnection;88;0;87;0
WireConnection;76;0;77;1
WireConnection;76;1;77;0
WireConnection;81;0;76;0
WireConnection;79;1;88;0
WireConnection;80;0;79;0
WireConnection;80;1;81;0
WireConnection;84;0;80;0
WireConnection;96;0;88;0
WireConnection;130;0;75;0
WireConnection;122;0;96;0
WireConnection;68;0;67;0
WireConnection;68;1;84;0
WireConnection;68;7;83;0
WireConnection;121;0;68;4
WireConnection;124;0;122;0
WireConnection;124;1;122;0
WireConnection;124;2;122;0
WireConnection;131;0;130;0
WireConnection;127;0;77;0
WireConnection;127;1;77;1
WireConnection;128;0;127;0
WireConnection;133;1;131;0
WireConnection;123;0;121;0
WireConnection;123;1;124;0
WireConnection;116;0;84;0
WireConnection;132;0;128;0
WireConnection;132;1;133;0
WireConnection;115;0;116;0
WireConnection;115;1;123;0
WireConnection;118;0;115;0
WireConnection;140;2;132;0
WireConnection;140;3;136;0
WireConnection;212;0;152;0
WireConnection;119;0;115;0
WireConnection;143;2;132;0
WireConnection;143;3;136;0
WireConnection;253;0;140;0
WireConnection;253;1;143;0
WireConnection;191;0;152;0
WireConnection;205;0;212;0
WireConnection;204;0;158;0
WireConnection;204;1;203;0
WireConnection;120;0;67;0
WireConnection;120;1;84;0
WireConnection;120;3;118;0
WireConnection;120;4;119;0
WireConnection;120;7;83;0
WireConnection;197;0;191;0
WireConnection;259;0;120;1
WireConnection;259;1;120;3
WireConnection;207;0;204;0
WireConnection;260;0;253;0
WireConnection;260;1;122;0
WireConnection;206;0;205;0
WireConnection;208;0;206;0
WireConnection;208;2;207;0
WireConnection;258;0;259;0
WireConnection;258;1;260;0
WireConnection;198;0;197;0
WireConnection;209;0;158;0
WireConnection;209;1;208;0
WireConnection;163;0;130;0
WireConnection;160;0;152;0
WireConnection;254;0;258;0
WireConnection;199;0;198;0
WireConnection;239;0;209;0
WireConnection;200;0;199;0
WireConnection;153;0;160;0
WireConnection;153;2;163;0
WireConnection;196;1;200;0
WireConnection;196;2;255;0
WireConnection;159;0;158;0
WireConnection;159;2;153;0
WireConnection;141;0;132;0
WireConnection;243;0;209;0
WireConnection;242;0;239;0
WireConnection;147;0;143;0
WireConnection;214;0;243;0
WireConnection;240;0;242;0
WireConnection;142;0;140;0
WireConnection;142;2;141;0
WireConnection;256;0;159;0
WireConnection;256;1;196;0
WireConnection;144;0;142;0
WireConnection;144;1;147;0
WireConnection;246;0;240;1
WireConnection;246;1;214;1
WireConnection;227;0;256;0
WireConnection;227;1;209;0
WireConnection;227;2;191;0
WireConnection;245;0;240;0
WireConnection;245;1;214;0
WireConnection;248;1;200;0
WireConnection;263;0;227;0
WireConnection;263;1;196;0
WireConnection;247;0;245;0
WireConnection;247;1;246;0
WireConnection;99;0;120;0
WireConnection;99;1;98;0
WireConnection;146;0;144;0
WireConnection;146;1;145;0
WireConnection;234;0;247;0
WireConnection;234;2;248;0
WireConnection;156;0;155;0
WireConnection;156;1;263;0
WireConnection;156;7;155;1
WireConnection;134;0;99;0
WireConnection;134;1;146;0
WireConnection;222;0;234;0
WireConnection;95;0;100;0
WireConnection;95;1;134;0
WireConnection;95;2;96;0
WireConnection;262;0;156;0
WireConnection;262;1;100;0
WireConnection;262;2;191;0
WireConnection;261;0;156;0
WireConnection;261;1;120;0
WireConnection;249;0;234;0
WireConnection;230;1;163;0
WireConnection;157;0;262;0
WireConnection;157;1;95;0
WireConnection;157;2;222;0
WireConnection;1;2;157;0
ASEEND*/
//CHKSM=C01D63A1CD8D18EA3638BC64593CFD3BEB871FA3