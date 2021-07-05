// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZDShader/URP/Particles/Ghost Fire"
{
    Properties
    {
        [HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
        [HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
        [ASEBegin][HDR]_ColorUp("ColorUp", Color) = (0.8156863,0,8,1)
        [HDR]_ColorDown("ColorDown", Color) = (0,0.5337852,1.071773,1)
        [HDR]_ColorCenter("ColorCenter", Color) = (0,0.1782091,0.5188679,1)
        _MaxBrightness("Max Brightness", Float) = 1
        _MainTex("MainTex", 2D) = "white" {}
        _Speed("Speed", Float) = 1
        _RefractionIntensity("Refraction Intensity", Range( 0 , 0.5)) = 0.438
        _Clip("Clip", Range( 0 , 1)) = 0.15
        _EdgeBlur("EdgeBlur", Range( 0 , 0.2)) = 0.05
        _VertexIntensity("Vertex Intensity", Range( 0 , 1)) = 0
        _RefractionRange("Refraction Range", Vector) = (0.17,0.79,0,0)
        _CullOfBottom("Cull Of Bottom", Range( 0 , 1)) = 0.263
        [ASEEnd]_Soft("Soft", Range( 0 , 5)) = 0.5

    }

    SubShader
    {
		LOD 0

        
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Transparent" }
        
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

            float4 _RefractionRange;
            float4 _MainTex_ST;
            float4 _ColorCenter;
            float4 _ColorDown;
            float4 _ColorUp;
            float _VertexIntensity;
            float _RefractionIntensity;
            float _Speed;
            float _Clip;
            float _EdgeBlur;
            float _CullOfBottom;
            float _MaxBrightness;
            float _Soft;
            CBUFFER_END
            sampler2D _MainTex;


                        VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                float cos317 = cos( ( -0.5 * PI ) );
                float sin317 = sin( ( -0.5 * PI ) );
                float2 rotator317 = mul( v.ase_texcoord.xy - float2( 0.5,0.5 ) , float2x2( cos317 , -sin317 , sin317 , cos317 )) + float2( 0.5,0.5 );
                float2 baseUV319 = rotator317;
                float2 break323 = baseUV319;
                float mulTime239 = _TimeParameters.x * _Speed;
                float2 panner236 = ( mulTime239 * float2( 0,-0.9913 ) + baseUV319);
                float2 panner237 = ( mulTime239 * float2( 0.217,-0.799641 ) + baseUV319);
                float smoothstepResult243 = smoothstep( _RefractionRange.x , _RefractionRange.y , max( tex2Dlod( _MainTex, float4( frac( panner236 ), 0, 0.0) ).b , tex2Dlod( _MainTex, float4( frac( panner237 ), 0, 0.0) ).b ));
                float temp_output_253_0 = ( smoothstepResult243 * _RefractionIntensity );
                float temp_output_256_0 = saturate( ( ( break323.y - min( 0.4 , _RefractionIntensity ) ) + temp_output_253_0 ) );
                float3 temp_output_298_0 = ( v.normalOS * _VertexIntensity * temp_output_256_0 );
                
                o.ase_texcoord3.xy = v.ase_texcoord.xy;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord3.zw = 0;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    float3 defaultVertexValue = v.positionOS.xyz;
                #else
                    float3 defaultVertexValue = float3(0, 0, 0);
                #endif
                float3 vertexValue = temp_output_298_0;
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
                
                float cos317 = cos( ( -0.5 * PI ) );
                float sin317 = sin( ( -0.5 * PI ) );
                float2 rotator317 = mul( IN.ase_texcoord3.xy - float2( 0.5,0.5 ) , float2x2( cos317 , -sin317 , sin317 , cos317 )) + float2( 0.5,0.5 );
                float2 baseUV319 = rotator317;
                float2 break323 = baseUV319;
                float mulTime239 = _TimeParameters.x * _Speed;
                float2 panner236 = ( mulTime239 * float2( 0,-0.9913 ) + baseUV319);
                float2 panner237 = ( mulTime239 * float2( 0.217,-0.799641 ) + baseUV319);
                float smoothstepResult243 = smoothstep( _RefractionRange.x , _RefractionRange.y , max( tex2D( _MainTex, frac( panner236 ) ).b , tex2D( _MainTex, frac( panner237 ) ).b ));
                float temp_output_253_0 = ( smoothstepResult243 * _RefractionIntensity );
                float temp_output_256_0 = saturate( ( ( break323.y - min( 0.4 , _RefractionIntensity ) ) + temp_output_253_0 ) );
                float2 appendResult246 = (float2(break323.x , ( temp_output_256_0 + _RefractionRange.z )));
                float2 fireUV248 = appendResult246;
                float4 tex2DNode247 = tex2D( _MainTex, ( ( fireUV248 * _MainTex_ST.xy ) + _MainTex_ST.zw ) );
                float temp_output_250_0 = (tex2DNode247).r;
                float temp_output_251_0 = (tex2DNode247).g;
                float temp_output_369_0 = max( temp_output_250_0 , temp_output_251_0 );
                clip( temp_output_369_0 - 0.5);
                
                float3 Color = temp_cast_0;
                float Alpha = temp_output_369_0;
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
            
            Blend SrcAlpha One
            ZWrite Off
            ZTest Less
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

            #define ASE_NEEDS_VERT_NORMAL
            #define ASE_NEEDS_FRAG_WORLD_POSITION


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
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)

            float4 _RefractionRange;
            float4 _MainTex_ST;
            float4 _ColorCenter;
            float4 _ColorDown;
            float4 _ColorUp;
            float _VertexIntensity;
            float _RefractionIntensity;
            float _Speed;
            float _Clip;
            float _EdgeBlur;
            float _CullOfBottom;
            float _MaxBrightness;
            float _Soft;
            CBUFFER_END
            sampler2D _MainTex;
            uniform float4 _CameraDepthTexture_TexelSize;


            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                float cos317 = cos( ( -0.5 * PI ) );
                float sin317 = sin( ( -0.5 * PI ) );
                float2 rotator317 = mul( v.ase_texcoord.xy - float2( 0.5,0.5 ) , float2x2( cos317 , -sin317 , sin317 , cos317 )) + float2( 0.5,0.5 );
                float2 baseUV319 = rotator317;
                float2 break323 = baseUV319;
                float mulTime239 = _TimeParameters.x * _Speed;
                float2 panner236 = ( mulTime239 * float2( 0,-0.9913 ) + baseUV319);
                float2 panner237 = ( mulTime239 * float2( 0.217,-0.799641 ) + baseUV319);
                float smoothstepResult243 = smoothstep( _RefractionRange.x , _RefractionRange.y , max( tex2Dlod( _MainTex, float4( frac( panner236 ), 0, 0.0) ).b , tex2Dlod( _MainTex, float4( frac( panner237 ), 0, 0.0) ).b ));
                float temp_output_253_0 = ( smoothstepResult243 * _RefractionIntensity );
                float temp_output_256_0 = saturate( ( ( break323.y - min( 0.4 , _RefractionIntensity ) ) + temp_output_253_0 ) );
                float3 temp_output_298_0 = ( v.normalOS * _VertexIntensity * temp_output_256_0 );
                
                float3 ase_worldNormal = TransformObjectToWorldNormal(v.normalOS);
                o.ase_texcoord4.xyz = ase_worldNormal;
                
                float4 ase_clipPos = TransformObjectToHClip((v.positionOS).xyz);
                float4 screenPos = ComputeScreenPos(ase_clipPos);
                o.ase_texcoord5 = screenPos;
                
                o.ase_texcoord3.xy = v.ase_texcoord.xy;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord3.zw = 0;
                o.ase_texcoord4.w = 0;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    float3 defaultVertexValue = v.positionOS.xyz;
                #else
                    float3 defaultVertexValue = float3(0, 0, 0);
                #endif
                float3 vertexValue = temp_output_298_0;
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
                float cos317 = cos( ( -0.5 * PI ) );
                float sin317 = sin( ( -0.5 * PI ) );
                float2 rotator317 = mul( IN.ase_texcoord3.xy - float2( 0.5,0.5 ) , float2x2( cos317 , -sin317 , sin317 , cos317 )) + float2( 0.5,0.5 );
                float2 baseUV319 = rotator317;
                float4 lerpResult292 = lerp( _ColorDown , _ColorUp , baseUV319.y);
                float2 break323 = baseUV319;
                float mulTime239 = _TimeParameters.x * _Speed;
                float2 panner236 = ( mulTime239 * float2( 0,-0.9913 ) + baseUV319);
                float2 panner237 = ( mulTime239 * float2( 0.217,-0.799641 ) + baseUV319);
                float smoothstepResult243 = smoothstep( _RefractionRange.x , _RefractionRange.y , max( tex2D( _MainTex, frac( panner236 ) ).b , tex2D( _MainTex, frac( panner237 ) ).b ));
                float temp_output_253_0 = ( smoothstepResult243 * _RefractionIntensity );
                float temp_output_256_0 = saturate( ( ( break323.y - min( 0.4 , _RefractionIntensity ) ) + temp_output_253_0 ) );
                float2 appendResult246 = (float2(break323.x , ( temp_output_256_0 + _RefractionRange.z )));
                float2 fireUV248 = appendResult246;
                float4 tex2DNode247 = tex2D( _MainTex, ( ( fireUV248 * _MainTex_ST.xy ) + _MainTex_ST.zw ) );
                float temp_output_251_0 = (tex2DNode247).g;
                float smoothstepResult305 = smoothstep( 0.0 , _CullOfBottom , break323.y);
                float smoothstepResult340 = smoothstep( 0.7 , 1.0 , ( 1.0 - baseUV319.y ));
                float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - positionWSition );
                ase_worldViewDir = normalize(ase_worldViewDir);
                float3 ase_worldNormal = IN.ase_texcoord4.xyz;
                float fresnelNdotV326 = dot( ( ase_worldNormal * float3( -1,-1,-1 ) ), ase_worldViewDir );
                float fresnelNode326 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV326, 1.0 ) );
                float smoothstepResult331 = smoothstep( 0.0 , 1.0 , ( 1.0 - saturate( fresnelNode326 ) ));
                float temp_output_311_0 = ( temp_output_251_0 * saturate( ( ( smoothstepResult305 - min( _CullOfBottom , 0.4 ) ) + temp_output_253_0 ) ) * max( ( ( fireUV248.y + smoothstepResult340 ) * smoothstepResult340 ) , smoothstepResult331 ) );
                float smoothstepResult270 = smoothstep( ( _Clip - _EdgeBlur ) , ( _Clip + _EdgeBlur ) , temp_output_311_0);
                float temp_output_250_0 = (tex2DNode247).r;
                float4 lerpResult290 = lerp( _ColorCenter , lerpResult292 , saturate( ( smoothstepResult270 - temp_output_250_0 ) ));
                float3 appendResult356 = (float3(lerpResult290.rgb));
                float3 temp_cast_1 = (_MaxBrightness).xxx;
                float3 clampResult357 = clamp( appendResult356 , float3( 0,0,0 ) , temp_cast_1 );
                
                clip( temp_output_311_0 - _Clip);
                float4 screenPos = IN.ase_texcoord5;
                float4 ase_screenPosNorm = screenPos / screenPos.w;
                ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
                float screenDepth350 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
                float distanceDepth350 = abs( ( screenDepth350 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Soft ) );
                
                float3 BakedAlbedo = 0;
                float3 BakedEmission = 0;
                float3 Color = clampResult357;
                float Alpha = ( temp_output_311_0 * smoothstepResult270 * saturate( distanceDepth350 ) * (lerpResult290).a );
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
-1586;149;1507;912;-3046.919;2449.632;1.3;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;235;128,-1536;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;318;128,-1408;Inherit;False;1;0;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;317;384,-1536;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;238;1536,-256;Inherit;False;Property;_Speed;Speed;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;319;640,-1536;Inherit;False;baseUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;321;1664,-384;Inherit;False;319;baseUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;239;1664,-256;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;236;1840,-384;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.9913;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;237;1840,-256;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.217,-0.799641;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;255;2048,-256;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;254;2048,-384;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;231;1536,-1024;Inherit;True;Property;_MainTex;MainTex;4;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;233;2304,-384;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;234;2304,-176;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;252;2688,128;Inherit;False;Property;_RefractionIntensity;Refraction Intensity;6;0;Create;True;0;0;0;False;0;False;0.438;1;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;242;2608,-256;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;322;2176,-768;Inherit;False;319;baseUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;285;2697.556,-391.0848;Inherit;False;Constant;_subVal;subVal;7;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;263;2304,128;Inherit;False;Property;_RefractionRange;Refraction Range;10;0;Create;True;0;0;0;False;0;False;0.17,0.79,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMinOpNode;286;2880,-416;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;243;2816,-256;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.79;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;323;2336,-768;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;253;3072,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;284;2992,-416;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;245;3184,-480;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;256;3392,-480;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;359;3558.919,-436.2728;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;338;2285.585,-2084.95;Inherit;False;319;baseUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;329;1792,-1792;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;246;3747.295,-473.2753;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;248;3968,-512;Inherit;False;fireUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;330;2048,-1792;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,-1,-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;337;2440,-2085;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;249;1664,-1408;Inherit;False;248;fireUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;306;2304,-496;Inherit;False;Property;_CullOfBottom;Cull Of Bottom;11;0;Create;True;0;0;0;False;0;False;0.263;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;339;2560,-2048;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;326;2176,-1792;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;299;1792,-1280;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.GetLocalVarNode;344;2288,-2240;Inherit;False;248;fireUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;345;2448,-2240;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;300;1920,-1408;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;328;2432,-1792;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;340;2816,-2048;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.7;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;305;2534.924,-662.6226;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;308;2880,-560;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;301;2178.7,-1405.1;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;327;2688,-1792;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;347;2816,-2304;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;309;3008,-560;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;304;3184,-704;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;247;2688,-1408;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;349;3072,-2048;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;331;2944,-1792;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;341;3328,-1792;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;251;3072,-1280;Inherit;True;False;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;310;3392,-704;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;267;2816,-896;Inherit;False;Property;_Clip;Clip;7;0;Create;True;0;0;0;False;0;False;0.15;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;273;2816,-768;Inherit;False;Property;_EdgeBlur;EdgeBlur;8;0;Create;True;0;0;0;False;0;False;0.05;1;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;272;3200,-896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;271;3200,-1024;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;311;3456,-1280;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;250;3072,-1536;Inherit;True;True;False;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;324;3072,-2304;Inherit;False;319;baseUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;270;3584,-896;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;288;3712,-1280;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;325;3328,-2304;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ColorNode;294;3584,-2048;Inherit;False;Property;_ColorDown;ColorDown;1;1;[HDR];Create;True;0;0;0;False;0;False;0,0.5337852,1.071773,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;269;3584,-2304;Inherit;False;Property;_ColorUp;ColorUp;0;1;[HDR];Create;True;0;0;0;False;0;False;0.8156863,0,8,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;352;3933.037,-427.6794;Inherit;False;Property;_Soft;Soft;12;0;Create;True;0;0;0;False;0;False;0.5;0.2;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;289;3712,-1520;Inherit;False;Property;_ColorCenter;ColorCenter;2;1;[HDR];Create;True;0;0;0;False;0;False;0,0.1782091,0.5188679,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;292;3968,-1920;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;355;3957.314,-1322.432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;290;4136.64,-1557.895;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;350;4161.394,-594.2855;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;297;3968,-1024;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;351;4395.862,-585.0604;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;312;4007.322,-1184.256;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;358;4384,-1408;Inherit;False;Property;_MaxBrightness;Max Brightness;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;356;4480,-1536;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;366;4164.505,-1297.559;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;296;3840,-768;Inherit;False;Property;_VertexIntensity;Vertex Intensity;9;0;Create;True;0;0;0;False;0;False;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;365;4480,-2064;Inherit;False;Constant;_Float0;Float 0;13;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;4301.873,-929.1918;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;335;2672.121,-1145.592;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;357;4568.457,-1391.446;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;313;4352,-1152;Inherit;False;4;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;369;4226.6,-1920;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;367;4480,-1920;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;364;4726.9,-1241.635;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;361;4726.9,-1241.635;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;15;ZDShader/URP/Particles/Ghost Fire;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;False;0;True;True;8;5;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;1;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0;5;True;True;False;False;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;360;4736,-1920;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;15;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;SceneSelectionPass;0;0;SceneSelectionPass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SceneSelectionPass;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;362;4726.9,-1241.635;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;363;4726.9,-1241.635;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;689d3e8c4ac0d7c40a3407d6ee9e04bc;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;317;0;235;0
WireConnection;317;2;318;0
WireConnection;319;0;317;0
WireConnection;239;0;238;0
WireConnection;236;0;321;0
WireConnection;236;1;239;0
WireConnection;237;0;321;0
WireConnection;237;1;239;0
WireConnection;255;0;237;0
WireConnection;254;0;236;0
WireConnection;233;0;231;0
WireConnection;233;1;254;0
WireConnection;234;0;231;0
WireConnection;234;1;255;0
WireConnection;242;0;233;3
WireConnection;242;1;234;3
WireConnection;286;0;285;0
WireConnection;286;1;252;0
WireConnection;243;0;242;0
WireConnection;243;1;263;1
WireConnection;243;2;263;2
WireConnection;323;0;322;0
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
WireConnection;330;0;329;0
WireConnection;337;0;338;0
WireConnection;339;0;337;1
WireConnection;326;0;330;0
WireConnection;299;0;231;0
WireConnection;345;0;344;0
WireConnection;300;0;249;0
WireConnection;300;1;299;0
WireConnection;328;0;326;0
WireConnection;340;0;339;0
WireConnection;305;0;323;1
WireConnection;305;2;306;0
WireConnection;308;0;306;0
WireConnection;308;1;285;0
WireConnection;301;0;300;0
WireConnection;301;1;299;1
WireConnection;327;0;328;0
WireConnection;347;0;345;1
WireConnection;347;1;340;0
WireConnection;309;0;305;0
WireConnection;309;1;308;0
WireConnection;304;0;309;0
WireConnection;304;1;253;0
WireConnection;247;0;231;0
WireConnection;247;1;301;0
WireConnection;247;7;231;1
WireConnection;349;0;347;0
WireConnection;349;1;340;0
WireConnection;331;0;327;0
WireConnection;341;0;349;0
WireConnection;341;1;331;0
WireConnection;251;0;247;0
WireConnection;310;0;304;0
WireConnection;272;0;267;0
WireConnection;272;1;273;0
WireConnection;271;0;267;0
WireConnection;271;1;273;0
WireConnection;311;0;251;0
WireConnection;311;1;310;0
WireConnection;311;2;341;0
WireConnection;250;0;247;0
WireConnection;270;0;311;0
WireConnection;270;1;271;0
WireConnection;270;2;272;0
WireConnection;288;0;270;0
WireConnection;288;1;250;0
WireConnection;325;0;324;0
WireConnection;292;0;294;0
WireConnection;292;1;269;0
WireConnection;292;2;325;1
WireConnection;355;0;288;0
WireConnection;290;0;289;0
WireConnection;290;1;292;0
WireConnection;290;2;355;0
WireConnection;350;0;352;0
WireConnection;351;0;350;0
WireConnection;312;0;311;0
WireConnection;312;1;311;0
WireConnection;312;2;267;0
WireConnection;356;0;290;0
WireConnection;366;0;290;0
WireConnection;298;0;297;0
WireConnection;298;1;296;0
WireConnection;298;2;256;0
WireConnection;335;0;305;0
WireConnection;357;0;356;0
WireConnection;357;2;358;0
WireConnection;313;0;312;0
WireConnection;313;1;270;0
WireConnection;313;2;351;0
WireConnection;313;3;366;0
WireConnection;369;0;250;0
WireConnection;369;1;251;0
WireConnection;367;0;369;0
WireConnection;367;1;369;0
WireConnection;361;2;357;0
WireConnection;361;3;313;0
WireConnection;361;5;298;0
WireConnection;360;0;365;0
WireConnection;360;1;367;0
WireConnection;360;3;298;0
ASEEND*/
//CHKSM=14588C17E2656E23FAE07D86733CC1DEA28E97A5