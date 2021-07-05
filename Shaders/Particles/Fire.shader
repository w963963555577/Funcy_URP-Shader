// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/URP/Particles/Fire"
{
    Properties
    {
        [HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
        [HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
        [ASEBegin][HDR]_ColorUp("ColorUp", Color) = (5.216475,0.05107744,0,1)
        [HDR]_ColorDown("ColorDown", Color) = (44.72704,2.107557,0,1)
        [HDR]_ColorCenter("ColorCenter", Color) = (3.441591,0.7027332,0,1)
        _MaxBrightness("Max Brightness", Float) = 1
        _MainTex("MainTex", 2D) = "white" {}
        _Speed("Speed", Float) = 1
        _RotateUV("RotateUV", Range( -1 , 1)) = -0.5
        _RefractionIntensity("Refraction Intensity", Range( 0 , 0.5)) = 0.438
        _Clip("Clip", Range( 0 , 1)) = 0.15
        _EdgeBlur("EdgeBlur", Range( 0 , 0.2)) = 0.05
        _VertexIntensity("Vertex Intensity", Range( 0 , 1)) = 0
        _RefractionRange("Refraction Range", Vector) = (0.17,0.79,0,0)
        [ASEEnd]_CullOfBottom("Cull Of Bottom", Range( 0 , 1)) = 0.263

    }

    SubShader
    {
		LOD 0

        
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        
        Cull Off
        AlphaToMask Off
        
        Pass
        {
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }
            
            Blend One Zero
            Cull Back
            ZWrite On
            ZTest LEqual
            Offset 0 , 0
            ColorMask RGBA
            
            
            HLSLPROGRAM
            
            #define ASE_SRP_VERSION 70301

            
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

            half4 _RefractionRange;
            half4 _MainTex_ST;
            half4 _ColorCenter;
            half4 _ColorDown;
            half4 _ColorUp;
            half _RotateUV;
            half _RefractionIntensity;
            half _Speed;
            half _VertexIntensity;
            half _Clip;
            half _EdgeBlur;
            half _CullOfBottom;
            half _MaxBrightness;
            CBUFFER_END
            sampler2D _MainTex;


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
                float3 temp_cast_0 = (1.0).xxx;
                
                float cos317 = cos( ( _RotateUV * PI ) );
                float sin317 = sin( ( _RotateUV * PI ) );
                half2 rotator317 = mul( IN.ase_texcoord3.xy - float2( 0.5,0.5 ) , float2x2( cos317 , -sin317 , sin317 , cos317 )) + float2( 0.5,0.5 );
                half2 baseUV319 = rotator317;
                half2 break323 = baseUV319;
                half mulTime239 = _TimeParameters.x * _Speed;
                half2 panner236 = ( mulTime239 * float2( 0,-0.9913 ) + baseUV319);
                half2 panner237 = ( mulTime239 * float2( 0.217,-0.799641 ) + baseUV319);
                half smoothstepResult243 = smoothstep( _RefractionRange.x , _RefractionRange.y , max( tex2D( _MainTex, frac( panner236 ) ).b , tex2D( _MainTex, frac( panner237 ) ).b ));
                half temp_output_253_0 = ( smoothstepResult243 * _RefractionIntensity );
                half temp_output_256_0 = saturate( ( ( break323.y - min( 0.4 , _RefractionIntensity ) ) + temp_output_253_0 ) );
                half2 appendResult246 = (half2(break323.x , ( temp_output_256_0 + _RefractionRange.z )));
                half2 fireUV248 = appendResult246;
                half4 tex2DNode247 = tex2D( _MainTex, ( ( fireUV248 * _MainTex_ST.xy ) + _MainTex_ST.zw ) );
                half temp_output_250_0 = (tex2DNode247).r;
                half temp_output_251_0 = (tex2DNode247).g;
                half temp_output_362_0 = max( temp_output_250_0 , temp_output_251_0 );
                clip( temp_output_362_0 - 0.5);
                
                float3 Color = temp_cast_0;
                float Alpha = temp_output_362_0;
                float AlphaClipThreshold = 0.5;

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

        
        Pass
        {
            
            Name "Forward"
            Tags { "LightMode"="UniversalForward" }
            
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Offset 0 , 0
            ColorMask RGBA
            
            
            HLSLPROGRAM
            
            #define ASE_SRP_VERSION 70301

            
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

            #define ASE_NEEDS_VERT_NORMAL


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

            half4 _RefractionRange;
            half4 _MainTex_ST;
            half4 _ColorCenter;
            half4 _ColorDown;
            half4 _ColorUp;
            half _RotateUV;
            half _RefractionIntensity;
            half _Speed;
            half _VertexIntensity;
            half _Clip;
            half _EdgeBlur;
            half _CullOfBottom;
            half _MaxBrightness;
            CBUFFER_END
            sampler2D _MainTex;


            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                float cos317 = cos( ( _RotateUV * PI ) );
                float sin317 = sin( ( _RotateUV * PI ) );
                half2 rotator317 = mul( v.ase_texcoord.xy - float2( 0.5,0.5 ) , float2x2( cos317 , -sin317 , sin317 , cos317 )) + float2( 0.5,0.5 );
                half2 baseUV319 = rotator317;
                half2 break323 = baseUV319;
                half mulTime239 = _TimeParameters.x * _Speed;
                half2 panner236 = ( mulTime239 * float2( 0,-0.9913 ) + baseUV319);
                half2 panner237 = ( mulTime239 * float2( 0.217,-0.799641 ) + baseUV319);
                half smoothstepResult243 = smoothstep( _RefractionRange.x , _RefractionRange.y , max( tex2Dlod( _MainTex, float4( frac( panner236 ), 0, 0.0) ).b , tex2Dlod( _MainTex, float4( frac( panner237 ), 0, 0.0) ).b ));
                half temp_output_253_0 = ( smoothstepResult243 * _RefractionIntensity );
                half temp_output_256_0 = saturate( ( ( break323.y - min( 0.4 , _RefractionIntensity ) ) + temp_output_253_0 ) );
                
                o.ase_texcoord3.xy = v.ase_texcoord.xy;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord3.zw = 0;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    float3 defaultVertexValue = v.positionOS.xyz;
                #else
                    float3 defaultVertexValue = float3(0, 0, 0);
                #endif
                float3 vertexValue = ( v.normalOS * _VertexIntensity * temp_output_256_0 );
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
                float cos317 = cos( ( _RotateUV * PI ) );
                float sin317 = sin( ( _RotateUV * PI ) );
                half2 rotator317 = mul( IN.ase_texcoord3.xy - float2( 0.5,0.5 ) , float2x2( cos317 , -sin317 , sin317 , cos317 )) + float2( 0.5,0.5 );
                half2 baseUV319 = rotator317;
                half4 lerpResult292 = lerp( _ColorDown , _ColorUp , baseUV319.y);
                half2 break323 = baseUV319;
                half mulTime239 = _TimeParameters.x * _Speed;
                half2 panner236 = ( mulTime239 * float2( 0,-0.9913 ) + baseUV319);
                half2 panner237 = ( mulTime239 * float2( 0.217,-0.799641 ) + baseUV319);
                half smoothstepResult243 = smoothstep( _RefractionRange.x , _RefractionRange.y , max( tex2D( _MainTex, frac( panner236 ) ).b , tex2D( _MainTex, frac( panner237 ) ).b ));
                half temp_output_253_0 = ( smoothstepResult243 * _RefractionIntensity );
                half temp_output_256_0 = saturate( ( ( break323.y - min( 0.4 , _RefractionIntensity ) ) + temp_output_253_0 ) );
                half2 appendResult246 = (half2(break323.x , ( temp_output_256_0 + _RefractionRange.z )));
                half2 fireUV248 = appendResult246;
                half4 tex2DNode247 = tex2D( _MainTex, ( ( fireUV248 * _MainTex_ST.xy ) + _MainTex_ST.zw ) );
                half temp_output_251_0 = (tex2DNode247).g;
                half smoothstepResult305 = smoothstep( 0.0 , _CullOfBottom , break323.y);
                half temp_output_311_0 = ( temp_output_251_0 * saturate( ( ( smoothstepResult305 - min( _CullOfBottom , 0.4 ) ) + temp_output_253_0 ) ) );
                half smoothstepResult270 = smoothstep( ( _Clip - _EdgeBlur ) , ( _Clip + _EdgeBlur ) , temp_output_311_0);
                half temp_output_250_0 = (tex2DNode247).r;
                half4 lerpResult290 = lerp( _ColorCenter , lerpResult292 , saturate( ( smoothstepResult270 - temp_output_250_0 ) ));
                half3 appendResult356 = (half3(lerpResult290.rgb));
                half3 temp_cast_1 = (_MaxBrightness).xxx;
                half3 clampResult357 = clamp( appendResult356 , float3( 0,0,0 ) , temp_cast_1 );
                
                clip( temp_output_311_0 - _Clip);
                
                float3 BakedAlbedo = 0;
                float3 BakedEmission = 0;
                float3 Color = clampResult357;
                float Alpha = ( temp_output_311_0 * smoothstepResult270 * (lerpResult290).a );
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
-1586;149;1507;912;-2957.07;2521.063;1.4209;True;False
Node;AmplifyShaderEditor.RangedFloatNode;360;840.4574,-514.6331;Inherit;False;Property;_RotateUV;RotateUV;6;0;Create;True;0;0;0;False;0;False;-0.5;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;235;1152,-640;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;318;1152,-512;Inherit;False;1;0;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;317;1408,-640;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;238;1536,-256;Inherit;False;Property;_Speed;Speed;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;319;1664,-640;Inherit;False;baseUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;239;1664,-256;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;321;1664,-384;Inherit;False;319;baseUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;237;1840,-256;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.217,-0.799641;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;236;1840,-384;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.9913;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;254;2048,-384;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;231;2048,-1024;Inherit;True;Property;_MainTex;MainTex;4;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FractNode;255;2048,-256;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;233;2304,-384;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;234;2304,-176;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;252;2779.03,61.3887;Inherit;False;Property;_RefractionIntensity;Refraction Intensity;7;0;Create;True;0;0;0;False;0;False;0.438;1;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;322;2176,-768;Inherit;False;319;baseUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;263;2416,16;Inherit;False;Property;_RefractionRange;Refraction Range;11;0;Create;True;0;0;0;False;0;False;0.17,0.79,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;242;2608,-256;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;285;2697.556,-391.0848;Inherit;False;Constant;_subVal;subVal;7;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;243;2816,-256;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.79;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;323;2336,-768;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMinOpNode;286;2880,-416;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;253;3072,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;284;2992,-416;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;245;3184,-480;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;256;3392,-480;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;359;3558.919,-436.2728;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;246;3747.295,-473.2753;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;248;3971.309,-571.0789;Inherit;False;fireUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureTransformNode;299;1842.7,-1293.1;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RangedFloatNode;306;2304,-496;Inherit;False;Property;_CullOfBottom;Cull Of Bottom;12;0;Create;True;0;0;0;False;0;False;0.263;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;249;1874.7,-1405.1;Inherit;False;248;fireUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMinOpNode;308;2880,-560;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;300;2034.7,-1405.1;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;305;2534.924,-662.6226;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;309;3008,-560;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;301;2178.7,-1405.1;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;247;2688,-1408;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;304;3184,-704;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;273;2826.262,-722.5972;Inherit;False;Property;_EdgeBlur;EdgeBlur;9;0;Create;True;0;0;0;False;0;False;0.05;1;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;310;3392,-704;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;251;3008,-1200;Inherit;True;False;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;267;2821.616,-849.0342;Inherit;False;Property;_Clip;Clip;8;0;Create;True;0;0;0;False;0;False;0.15;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;272;3110.262,-893.5972;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;271;3110.262,-989.597;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;311;3362.134,-1180.382;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;250;3008,-1408;Inherit;True;True;False;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;324;3348.947,-2166.478;Inherit;False;319;baseUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;270;3572.15,-985.7557;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;288;3718.965,-1293.854;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;325;3508.947,-2166.478;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ColorNode;294;3552,-1728;Inherit;False;Property;_ColorDown;ColorDown;1;1;[HDR];Create;True;0;0;0;False;0;False;44.72704,2.107557,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;269;3544.7,-1906.9;Inherit;False;Property;_ColorUp;ColorUp;0;1;[HDR];Create;True;0;0;0;False;0;False;5.216475,0.05107744,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;355;3957.314,-1322.432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;292;3808.795,-1822.17;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;289;3712,-1520;Inherit;False;Property;_ColorCenter;ColorCenter;2;1;[HDR];Create;True;0;0;0;False;0;False;3.441591,0.7027332,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;290;4136.64,-1557.895;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;361;4153.263,-1297.555;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;312;3968,-1152;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;356;4413.457,-1434.446;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;358;4401.457,-1269.446;Inherit;False;Property;_MaxBrightness;Max Brightness;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;296;3909.119,-812.7612;Inherit;False;Property;_VertexIntensity;Vertex Intensity;10;0;Create;True;0;0;0;False;0;False;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;297;4001.691,-954.5571;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;369;4608,-2304;Inherit;False;Constant;_Float1;Float 0;13;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;341;3100.136,-1716.331;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;349;3119.619,-2111.732;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;345;2448,-2240;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;330;2048,-1792;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,-1,-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;338;2285.585,-2084.95;Inherit;False;319;baseUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;329;1840,-1792;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;328;2480,-1792;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;340;2848,-2080;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.7;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;335;2672.121,-1145.592;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;339;2656,-2080;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;313;4294.179,-1163.755;Inherit;False;3;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;326;2224,-1792;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;357;4568.457,-1391.446;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;344;2288,-2240;Inherit;False;248;fireUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;337;2440,-2085;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;4301.873,-929.1918;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClipNode;370;4608,-2176;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;327;2656,-1792;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;347;2848,-2320;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;331;2816,-1792;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;362;4224,-2176;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;365;4726.9,-1241.635;Half;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;15;ZDShader/URP/Particles/Fire;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;True;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0;5;True;True;False;False;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;366;4726.9,-1241.635;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;367;4726.9,-1241.635;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;368;4726.9,-1241.635;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;364;4864,-2304;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;15;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;SceneSelectionPass;0;0;SceneSelectionPass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SceneSelectionPass;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;318;0;360;0
WireConnection;317;0;235;0
WireConnection;317;2;318;0
WireConnection;319;0;317;0
WireConnection;239;0;238;0
WireConnection;237;0;321;0
WireConnection;237;1;239;0
WireConnection;236;0;321;0
WireConnection;236;1;239;0
WireConnection;254;0;236;0
WireConnection;255;0;237;0
WireConnection;233;0;231;0
WireConnection;233;1;254;0
WireConnection;234;0;231;0
WireConnection;234;1;255;0
WireConnection;242;0;233;3
WireConnection;242;1;234;3
WireConnection;243;0;242;0
WireConnection;243;1;263;1
WireConnection;243;2;263;2
WireConnection;323;0;322;0
WireConnection;286;0;285;0
WireConnection;286;1;252;0
WireConnection;253;0;243;0
WireConnection;253;1;252;0
WireConnection;284;0;323;1
WireConnection;284;1;286;0
WireConnection;245;0;284;0
WireConnection;245;1;253;0
WireConnection;256;0;245;0
WireConnection;359;0;256;0
WireConnection;359;1;263;3
WireConnection;246;0;323;0
WireConnection;246;1;359;0
WireConnection;248;0;246;0
WireConnection;299;0;231;0
WireConnection;308;0;306;0
WireConnection;308;1;285;0
WireConnection;300;0;249;0
WireConnection;300;1;299;0
WireConnection;305;0;323;1
WireConnection;305;2;306;0
WireConnection;309;0;305;0
WireConnection;309;1;308;0
WireConnection;301;0;300;0
WireConnection;301;1;299;1
WireConnection;247;0;231;0
WireConnection;247;1;301;0
WireConnection;304;0;309;0
WireConnection;304;1;253;0
WireConnection;310;0;304;0
WireConnection;251;0;247;0
WireConnection;272;0;267;0
WireConnection;272;1;273;0
WireConnection;271;0;267;0
WireConnection;271;1;273;0
WireConnection;311;0;251;0
WireConnection;311;1;310;0
WireConnection;250;0;247;0
WireConnection;270;0;311;0
WireConnection;270;1;271;0
WireConnection;270;2;272;0
WireConnection;288;0;270;0
WireConnection;288;1;250;0
WireConnection;325;0;324;0
WireConnection;355;0;288;0
WireConnection;292;0;294;0
WireConnection;292;1;269;0
WireConnection;292;2;325;1
WireConnection;290;0;289;0
WireConnection;290;1;292;0
WireConnection;290;2;355;0
WireConnection;361;0;290;0
WireConnection;312;0;311;0
WireConnection;312;1;311;0
WireConnection;312;2;267;0
WireConnection;356;0;290;0
WireConnection;341;0;349;0
WireConnection;341;1;331;0
WireConnection;349;0;347;0
WireConnection;349;1;340;0
WireConnection;345;0;344;0
WireConnection;330;0;329;0
WireConnection;328;0;326;0
WireConnection;340;0;339;0
WireConnection;335;0;305;0
WireConnection;339;0;337;1
WireConnection;313;0;312;0
WireConnection;313;1;270;0
WireConnection;313;2;361;0
WireConnection;326;0;330;0
WireConnection;357;0;356;0
WireConnection;357;2;358;0
WireConnection;337;0;338;0
WireConnection;298;0;297;0
WireConnection;298;1;296;0
WireConnection;298;2;256;0
WireConnection;370;0;362;0
WireConnection;370;1;362;0
WireConnection;327;0;328;0
WireConnection;347;0;345;1
WireConnection;347;1;340;0
WireConnection;331;0;327;0
WireConnection;362;0;250;0
WireConnection;362;1;251;0
WireConnection;365;2;357;0
WireConnection;365;3;313;0
WireConnection;365;5;298;0
WireConnection;364;0;369;0
WireConnection;364;1;370;0
ASEEND*/
//CHKSM=E2A0241EADFF822BC447777F4E1A9E37E14CCDBE