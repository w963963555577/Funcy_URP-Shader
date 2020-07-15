// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "Hidden/ZDShader/LWRP/Face Expression"
{
    Properties
    {
        [HideInInspector] _AlphaCutoff ("Alpha Cutoff ", Range(0, 1)) = 0.5
        [HideInInspector] _EmissionColor ("Emission Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_MainTex ("MainTex", 2D) = "white" { }
        _Color ("Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_ExpressionMap ("Expression Map", 2D) = "white" { }
        [NoScaleOffset]_SelfMask ("SelfMask", 2D) = "white" { }
        _ShadowDistruction ("ShadowDistruction", Color) = (0.9716981, 0.5819566, 0.5179334, 1)
        [IntRange]_SelectBrow ("Select Brow", Range(1, 4)) = 1
        [IntRange]_SelectFace ("Select Face", Range(1, 8)) = 1
        [IntRange]_SelectMouth ("Select Mouth ", Range(1, 8)) = 1
        [Toggle]_AntiAliasing1 ("Anti Aliasing", Float) = 1
        [Toggle]_ReceiveShadow ("Receive Shadow", Float) = 0
        [Toggle(_OutlineEnable) ]_OutlineEnable1 ("Enable Outline", Float) = 1
        _ShadowRamp ("ShadowRamp", Range(0, 1)) = 1
        [HideInInspector] _texcoord ("", 2D) = "white" { }
    }
    
    SubShader
    {
        LOD 0
        
        
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }
        
        Cull Back
        HLSLINCLUDE
        #pragma target 3.0
        ENDHLSL
        
        UsePass "Hidden/LWRP/General/ShadowCaster"
        UsePass "Hidden/LWRP/General/DepthOnly"
        UsePass "Hidden/LWRP/General/Outline"
        UsePass "Hidden/LWRP/General/ShadowCaster"
        UsePass "Hidden/LWRP/General/DepthOnly"
        UsePass "Hidden/LWRP/General/Outline"
        
        Pass
        {
            
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend One Zero, One Zero
            ZWrite On
            ZTest LEqual
            Offset 0, 0
            ColorMask RGBA
            
            
            HLSLPROGRAM
            
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #define ASE_FOG 1
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
            
            #if ASE_SRP_VERSION <= 70108
                #define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
            #endif
            
            #define ASE_NEEDS_FRAG_WORLD_POSITION
            #define ASE_NEEDS_FRAG_SHADOWCOORDS
            #define ASE_NEEDS_VERT_NORMAL
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            
            
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
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    float3 worldPos: TEXCOORD0;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    float4 shadowCoord: TEXCOORD1;
                #endif
                #ifdef ASE_FOG
                    float fogFactor: TEXCOORD2;
                #endif
                float4 ase_texcoord3: TEXCOORD3;
                float4 ase_texcoord4: TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            sampler2D _MainTex;
            sampler2D _ExpressionMap;
            sampler2D _SelfMask;
            CBUFFER_START(UnityPerMaterial)
            float4 _ShadowDistruction;
            float4 _Color;
            float _SelectMouth;
            float _SelectFace;
            float _SelectBrow;
            float _ReceiveShadow;
            float _ShadowRamp;
            float _AntiAliasing1;
            float _OutlineEnable1;
            CBUFFER_END
            
            
            float2 GetMouthArea414(float2 uv, float mouthCount, float selectMouth)
            {
                float pX = (uv.x * 0.5 + floor((selectMouth - 1.0) / 4.0) * 0.5 + 1.0) / 2.0;
                float pY = (uv.y * 0.5 + (mouthCount - fmod(selectMouth - 1.0, 4.0) / 2.0) + 1.5) / (mouthCount / 2.0);
                return float2(pX, pY);
            }
            
            float2 GetMouthArea415(float2 uv, float mouthCount, float selectMouth)
            {
                float pX = (uv.x * 0.5 + floor((selectMouth - 1.0) / 4.0) * 0.5 + 1.0) / 2.0;
                float pY = (uv.y * 0.5 + (mouthCount - fmod(selectMouth - 1.0, 4.0) / 2.0) + 1.5) / (mouthCount / 2.0);
                return float2(pX, pY);
            }
            
            float2 GetEyeArea279(float2 uv, float eyesCount, float selectFace)
            {
                return float2(uv.x * 0.5, (uv.y / eyesCount) + ((eyesCount - (selectFace)) / eyesCount));
            }
            
            float2 GetEyeArea275(float2 uv, float eyesCount, float selectFace)
            {
                return float2(uv.x * 0.5, (uv.y / eyesCount) + ((eyesCount - (selectFace)) / eyesCount));
            }
            
            float2 GetBrowArea444(float2 uv, float browCount, float selectBrow)
            {
                return float2(uv.x * 0.5 + 0.5, 0.5
                + (uv.y / (browCount * 2.0)) + ((browCount - selectBrow) / (browCount * 2.0)));
            }
            
            float2 GetBrowArea456(float2 uv, float browCount, float selectBrow)
            {
                return float2(uv.x * 0.5 + 0.5, 0.5
                + (uv.y / (browCount * 2.0)) + ((browCount - selectBrow) / (browCount * 2.0)));
            }
            
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
                o.ase_texcoord4.xyz = ase_worldNormal;
                
                o.ase_texcoord3.xy = v.ase_texcoord.xy;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord3.zw = 0;
                o.ase_texcoord4.w = 0;
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
                
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float4 positionCS = TransformWorldToHClip(positionWS);
                
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    o.worldPos = positionWS;
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
                o.clipPos = positionCS;
                return o;
            }
            
            half4 frag(VertexOutput IN): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    float3 WorldPosition = IN.worldPos;
                #endif
                float4 ShadowCoords = float4(0, 0, 0, 0);
                
                #if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                        ShadowCoords = IN.shadowCoord;
                    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                        ShadowCoords = TransformWorldToShadowCoord(WorldPosition);
                    #endif
                #endif
                float2 uv_MainTex6 = IN.ase_texcoord3.xy;
                float4 tex2DNode6 = tex2D(_MainTex, uv_MainTex6);
                float2 uv0213 = IN.ase_texcoord3.xy * float2(1, 1) + float2(0, 0);
                float2 uvcoord323 = uv0213;
                float2 uv414 = uvcoord323;
                float mouthCount414 = 8.0;
                float selectMouth414 = _SelectMouth;
                float2 localGetMouthArea414 = GetMouthArea414(uv414, mouthCount414, selectMouth414);
                float2 uv415 = float2(0.5, 0.5);
                float mouthCount415 = 8.0;
                float selectMouth415 = _SelectMouth;
                float2 localGetMouthArea415 = GetMouthArea415(uv415, mouthCount415, selectMouth415);
                float4 _MouthTRS = float4(2, 4, 0, 0.079);
                float2 appendResult336 = (float2(_MouthTRS.x, _MouthTRS.y));
                float2 appendResult335 = (float2(_MouthTRS.z, _MouthTRS.w));
                float4 tex2DNode337 = tex2D(_ExpressionMap, ((((localGetMouthArea414 - localGetMouthArea415) * appendResult336) + localGetMouthArea415) + appendResult335));
                float2 break356 = abs(((uvcoord323 - float2(0.5, 0.34)) * float2(1, 2)));
                float smoothstepResult357 = smoothstep(0.2, 0.3, break356.y);
                float smoothstepResult421 = smoothstep(0.23, 0.27, break356.x);
                float4 lerpResult306 = lerp(tex2DNode6, tex2DNode337, ((1.0 - smoothstepResult357) * (1.0 - smoothstepResult421) * tex2DNode337.a));
                float2 uv279 = uvcoord323;
                float eyesCount279 = 8.0;
                float selectFace279 = _SelectFace;
                float2 localGetEyeArea279 = GetEyeArea279(uv279, eyesCount279, selectFace279);
                float2 uv275 = float2(0.5, 0.5);
                float eyesCount275 = 8.0;
                float selectFace275 = _SelectFace;
                float2 localGetEyeArea275 = GetEyeArea275(uv275, eyesCount275, selectFace275);
                float4 _EyeTRS = float4(1, 4, 0, -0.02);
                float2 appendResult232 = (float2(_EyeTRS.x, _EyeTRS.y));
                float2 appendResult233 = (float2(_EyeTRS.z, _EyeTRS.w));
                float4 tex2DNode215 = tex2D(_ExpressionMap, ((((localGetEyeArea279 - localGetEyeArea275) * appendResult232) + localGetEyeArea275) + appendResult233));
                float smoothstepResult296 = smoothstep(0.25, 0.25, abs(((uvcoord323 - float2(0.5, 0.54)) * float2(2, 2))).y);
                float4 lerpResult455 = lerp(lerpResult306, tex2DNode215, (tex2DNode215.a * (1.0 - smoothstepResult296)));
                float2 uv444 = uvcoord323;
                float browCount444 = 4.0;
                float selectBrow444 = _SelectBrow;
                float2 localGetBrowArea444 = GetBrowArea444(uv444, browCount444, selectBrow444);
                float2 uv456 = float2(0.5, 0.5);
                float browCount456 = 4.0;
                float selectBrow456 = _SelectBrow;
                float2 localGetBrowArea456 = GetBrowArea456(uv456, browCount456, selectBrow456);
                float4 _BrowTRS = float4(1, 4, 0, -0.077);
                float2 appendResult437 = (float2(_BrowTRS.x, _BrowTRS.y));
                float2 appendResult433 = (float2(_BrowTRS.z, _BrowTRS.w));
                float4 tex2DNode436 = tex2D(_ExpressionMap, ((((localGetBrowArea444 - localGetBrowArea456) * appendResult437) + localGetBrowArea456) + appendResult433));
                float2 temp_cast_0 = (0.65).xx;
                float smoothstepResult452 = smoothstep(0.15, 0.19, abs(((uvcoord323 - temp_cast_0) * float2(2, 3))).y);
                float4 lerpResult363 = lerp(lerpResult455, tex2DNode436, (tex2DNode436.a * (1.0 - smoothstepResult452)));
                float4 temp_output_493_0 = (_Color * (float4(1, 1, 1, 0) * lerpResult363));
                float temp_output_501_0 = (1.0 - _ShadowRamp);
                float ase_lightAtten = 0;
                Light ase_lightAtten_mainLight = GetMainLight(ShadowCoords);
                ase_lightAtten = ase_lightAtten_mainLight.distanceAttenuation * ase_lightAtten_mainLight.shadowAttenuation;
                float smoothstepResult479 = smoothstep((0.5 - temp_output_501_0), (0.5 + temp_output_501_0), (1.0 - ase_lightAtten));
                float4 transform461 = mul(GetObjectToWorldMatrix(), float4(0, 0, 1, 0));
                float3 appendResult460 = (float3(transform461.xyz));
                float3 objectDirection463 = appendResult460;
                float3 appendResult465 = (float3(_MainLightPosition.xyz.x, 0.0, _MainLightPosition.xyz.z));
                float3 normalizeResult458 = normalize((appendResult465 * float3(-1, -1, -1)));
                float3 lightXZDirection462 = normalizeResult458;
                float3 normalizeResult470 = normalize(cross(objectDirection463, lightXZDirection462));
                float2 uv0472 = IN.ase_texcoord3.xy * float2(1, 1) + float2(0, 0);
                float2 appendResult484 = (float2(((normalizeResult470.y * 1.0) * uv0472.x), uv0472.y));
                float4 tex2DNode476 = tex2D(_SelfMask, appendResult484);
                float dotResult469 = dot(objectDirection463, lightXZDirection462);
                float temp_output_505_0 = (0.01 + ((acos((dotResult469 * - 1.0)) / PI) - 0.0) * (0.99 - 0.01) / (1.0 - 0.0));
                float smoothstepResult498 = smoothstep((tex2DNode476.r - 0.0), (tex2DNode476.r + 0.0), temp_output_505_0);
                float temp_output_508_0 = (((_ReceiveShadow)?(saturate(((1.0 - smoothstepResult479) + (1.0 - tex2DNode476.b)))): (1.0)) * ((_AntiAliasing1)?((1.0 - step(tex2DNode476.r, temp_output_505_0))): ((1.0 - smoothstepResult498))));
                float4 lerpResult511 = lerp((_ShadowDistruction * temp_output_493_0), temp_output_493_0, temp_output_508_0);
                float3 ase_worldViewDir = (_WorldSpaceCameraPos.xyz - WorldPosition);
                ase_worldViewDir = normalize(ase_worldViewDir);
                float3 ase_worldNormal = IN.ase_texcoord4.xyz;
                float fresnelNdotV507 = dot(ase_worldNormal, ase_worldViewDir);
                float fresnelNode507 = (0.0 + 1.0 * pow(1.0 - fresnelNdotV507, 5.0));
                
                float lerpResult284 = lerp(_OutlineEnable1, 1.0, 1.0);
                clip(tex2DNode6.a - 0.5);
                
                float3 BakedAlbedo = 0;
                float3 BakedEmission = 0;
                float3 Color = (lerpResult511 + (temp_output_508_0 * fresnelNode507)).rgb;
                float Alpha = (lerpResult284 * tex2DNode6.a);
                float AlphaClipThreshold = 0.5;
                
                #ifdef _ALPHATEST_ON
                    clip(Alpha - AlphaClipThreshold);
                #endif
                
                #ifdef ASE_FOG
                    Color = MixFog(Color, IN.fogFactor);
                #endif
                
                #ifdef LOD_FADE_CROSSFADE
                    LODDitheringTransition(IN.clipPos.xyz, unity_LODFade.x);
                #endif
                
                return half4(Color, Alpha);
            }
            
            ENDHLSL
            
        }
        
        
        Pass
        {
            
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            
            ZWrite On
            ZTest LEqual
            
            HLSLPROGRAM
            
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #define ASE_FOG 1
            #define ASE_SRP_VERSION 70201
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            
            
            
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
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    float3 worldPos: TEXCOORD0;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    float4 shadowCoord: TEXCOORD1;
                #endif
                float4 ase_texcoord2: TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            sampler2D _MainTex;
            CBUFFER_START(UnityPerMaterial)
            float4 _ShadowDistruction;
            float4 _Color;
            float _SelectMouth;
            float _SelectFace;
            float _SelectBrow;
            float _ReceiveShadow;
            float _ShadowRamp;
            float _AntiAliasing1;
            float _OutlineEnable1;
            CBUFFER_END
            
            
            
            float3 _LightDirection;
            
            VertexOutput ShadowPassVertex(VertexInput v)
            {
                VertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.ase_texcoord2.xy = v.ase_texcoord.xy;
                
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord2.zw = 0;
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
                
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    o.worldPos = positionWS;
                #endif
                
                float3 normalWS = TransformObjectToWorldDir(v.ase_normal);
                
                float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
                
                #if UNITY_REVERSED_Z
                    clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
                #else
                    clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
                #endif
                
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    VertexPositionInputs vertexInput = (VertexPositionInputs)0;
                    vertexInput.positionWS = positionWS;
                    vertexInput.positionCS = clipPos;
                    o.shadowCoord = GetShadowCoord(vertexInput);
                #endif
                o.clipPos = clipPos;
                
                return o;
            }
            
            half4 ShadowPassFragment(VertexOutput IN): SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                    float3 WorldPosition = IN.worldPos;
                #endif
                float4 ShadowCoords = float4(0, 0, 0, 0);
                
                #if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                        ShadowCoords = IN.shadowCoord;
                    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                        ShadowCoords = TransformWorldToShadowCoord(WorldPosition);
                    #endif
                #endif
                
                float lerpResult284 = lerp(_OutlineEnable1, 1.0, 1.0);
                float2 uv_MainTex6 = IN.ase_texcoord2.xy;
                float4 tex2DNode6 = tex2D(_MainTex, uv_MainTex6);
                clip(tex2DNode6.a - 0.5);
                
                float Alpha = (lerpResult284 * tex2DNode6.a);
                float AlphaClipThreshold = 0.5;
                
                #ifdef _ALPHATEST_ON
                    clip(Alpha - AlphaClipThreshold);
                #endif
                
                #ifdef LOD_FADE_CROSSFADE
                    LODDitheringTransition(IN.clipPos.xyz, unity_LODFade.x);
                #endif
                return 0;
            }
            
            ENDHLSL
            
        }
    }
    CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.ZDFace"
    Fallback "Hidden/InternalErrorShader"
}
/*ASEBEGIN
Version=17800
-57;36;1421;729;-3899.095;1086.096;1.167952;True;False
Node;AmplifyShaderEditor.SamplerNode;6;-336,320;Inherit;True;Property;_MainTex;MainTex;0;1;[NoScaleOffset];Create;True;0;0;False;0;-1;e3e14811c89ae304fa03631997c641e3;2841407f972556240893e8d273740f1d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;283;4657.163,-881.6981;Inherit;False;Property;_OutlineEnable1;Enable Outline;10;0;Create;False;0;0;False;1;Toggle(_OutlineEnable) ;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;284;4845.163,-973.6981;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;520;5073.887,-560.2897;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;471;3718.424,-751.4495;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;462;-2688,-48;Inherit;False;lightXZDirection;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;503;3686.424,192.5508;Inherit;False;2;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;501;3510.424,96.55083;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;422;704,2160;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;458;-2912,-32;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;508;4326.424,-591.4492;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;500;4518.424,-1007.449;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;504;3206.424,64.55084;Inherit;False;Property;_ShadowRamp;ShadowRamp;11;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;419;-1216,1504;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;507;3958.424,-287.4491;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;461;-3424,-304;Inherit;False;1;0;FLOAT4;0,0,1,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;323;-2688,240;Inherit;False;uvcoord;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;459;-3040,-32;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,-1,-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;463;-2688,-240;Inherit;False;objectDirection;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;499;4470.424,-671.4493;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;279;-1443.145,740.2756;Inherit;False;return float2(uv.x * 0.5, (uv.y / eyesCount) + ((eyesCount - (selectFace)) / eyesCount))@;2;False;3;True;uv;FLOAT2;0,0;In;;Float;False;True;eyesCount;FLOAT;0;In;;Float;False;True;selectFace;FLOAT;0;In;;Float;False;GetEyeArea;True;False;0;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;474;3366.424,-815.4496;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;472;1910.424,-335.4491;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;281;-803.1451,740.2756;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;437;-1536,2720;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;479;3558.424,-687.4493;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;510;3894.424,-735.4495;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;497;3462.424,-223.4492;Inherit;False;Property;_AntiAliasing1;Anti Aliasing;8;0;Create;False;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;307;720,1184;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;466;1421.558,-710.3414;Inherit;False;462;lightXZDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;234;-1075.145,740.2756;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;495;3286.424,-719.4492;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;491;3238.424,-255.4492;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;460;-3232,-256;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;494;4134.424,-735.4495;Inherit;False;Property;_ReceiveShadow;Receive Shadow;9;0;Create;True;0;0;False;0;0;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;363;1443.6,1012.9;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ACosOpNode;482;1901.558,-806.3413;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;512;1901.558,-710.3414;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;509;2573.558,-214.3414;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;486;2125.558,-102.3414;Inherit;False;Constant;_Blur;Blur;6;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;511;4314.957,-954.6681;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;498;2989.558,-486.3413;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;476;2493.558,-486.3413;Inherit;True;Property;_TextureSample3;Texture Sample 3;0;0;Create;True;0;0;False;0;-1;0c230181afe21fc489e9e1c3accd7c23;0c230181afe21fc489e9e1c3accd7c23;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;514;960,976;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;483;1901.558,-214.3414;Inherit;True;Property;_SelfMask;SelfMask;3;1;[NoScaleOffset];Create;False;0;0;False;0;fb79ac1bf2a1cf04db313a0a9bcd7ab8;0c230181afe21fc489e9e1c3accd7c23;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.NormalizeNode;470;1773.558,-710.3414;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;480;2237.558,-486.3413;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;465;-3232,-32;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;488;4006.424,-719.4492;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;506;4072.151,-1010.2;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;457;-351.0771,3026.023;Inherit;False;Constant;_Float0;Float 0;12;0;Create;True;0;0;False;0;0.65;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;493;2157.558,-806.3413;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;487;1805.558,-1014.341;Inherit;False;Property;_ShadowDistruction;ShadowDistruction;4;0;Create;True;0;0;False;0;0.9716981,0.5819566,0.5179334,1;0.9716981,0.5819566,0.5179334,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;478;1901.558,-582.3414;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CrossProductOpNode;467;1629.558,-710.3414;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;502;3670.424,96.55083;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;484;2365.558,-486.3413;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;490;3318.424,-463.4491;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;473;1421.558,-790.3413;Inherit;False;463;objectDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;485;1773.558,-806.3413;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;469;1645.558,-806.3413;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;454;256,2720;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;477;2109.558,-550.3414;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;213;-2896,240;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;211;1536,640;Inherit;False;2;2;0;COLOR;1,1,1,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;505;2285.558,-678.3414;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.01;False;4;FLOAT;0.99;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;423;896,1824;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;475;2157.558,-678.3414;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;464;-3456,-16;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;448;-1248,2272;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;446;-1104,2272;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;335;-1536,2048;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;361;-224,1952;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.34;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;415;-1456,1632;Inherit;False;                float pX = (uv.x * 0.5 + floor((selectMouth - 1.0) / 4.0) * 0.5 + 1.0) / 2.0@$                float pY = (uv.y * 0.5 + (mouthCount - fmod(selectMouth - 1.0, 4.0) / 2.0) + 1.5) / (mouthCount / 2.0)@$                return float2(pX, pY)@;2;False;3;True;uv;FLOAT2;0,0;In;;Float;False;True;mouthCount;FLOAT;0;In;;Float;False;True;selectMouth;FLOAT;0;In;;Float;False;GetMouthArea;True;False;0;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;359;704,1952;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;341;-1712,1504;Inherit;False;323;uvcoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;445;-832,2272;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;232;-1459.145,1156.276;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;231;-1731.145,1156.276;Inherit;False;Constant;_EyeTRS;EyeTRS;4;0;Create;True;0;0;False;0;1,4,0,-0.02;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;356;256,1952;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;339;-1808,1760;Inherit;False;Constant;_MouthCount;Mouth Count;4;1;[IntRange];Create;True;0;0;False;0;8;1;1;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;456;-1472,2416;Inherit;False;return float2(uv.x * 0.5+0.5,0.5$ + (uv.y / (browCount*2.0)) + ((browCount - selectBrow) / (browCount*2.0)))@;2;False;3;True;uv;FLOAT2;0,0;In;;Float;False;True;browCount;FLOAT;0;In;;Float;False;True;selectBrow;FLOAT;0;In;;Float;False;GetBrowArea;True;False;0;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;215;-675.1451,740.2756;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;325;-339.5364,1752.421;Inherit;False;323;uvcoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;310;272,1184;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;431;-1808,2528;Inherit;False;Constant;_BrowCount;Brow Count;4;1;[IntRange];Create;True;0;0;False;0;4;1;1;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;436;-672,2272;Inherit;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;427;-1728,2720;Inherit;False;Constant;_BrowTRS;Brow TRS;4;0;Create;True;0;0;False;0;1,4,0,-0.077;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;450;144,2720;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;311;32,1184;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;218;-1811.145,964.2756;Inherit;False;Constant;_EyesCount;Eyes Count;3;1;[IntRange];Create;True;0;0;False;0;8;1;1;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;416;-928,1504;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;414;-1456,1504;Inherit;False;                float pX = (uv.x * 0.5 + floor((selectMouth - 1.0) / 4.0) * 0.5 + 1.0) / 2.0@$                float pY = (uv.y * 0.5 + (mouthCount - fmod(selectMouth - 1.0, 4.0) / 2.0) + 1.5) / (mouthCount / 2.0)@$                return float2(pX, pY)@;2;False;3;True;uv;FLOAT2;0,0;In;;Float;False;True;mouthCount;FLOAT;0;In;;Float;False;True;selectMouth;FLOAT;0;In;;Float;False;GetMouthArea;True;False;0;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;233;-1459.145,1252.276;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;358;16,1952;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;1,2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;449;-224,2720;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;496;2853.63,-861.7016;Inherit;False;Step Antialiasing;-1;;3;2a825e80dfb3290468194f83380797bd;0;2;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;296;496,1184;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.25;False;2;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;421;480,2160;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.23;False;2;FLOAT;0.27;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;417;-800,1504;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;432;-1808,2624;Inherit;False;Property;_SelectBrow;Select Brow;5;1;[IntRange];Create;True;0;0;False;0;1;0;1;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;468;2781.558,-486.3413;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;481;3142.424,-815.4496;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;280;-1219.145,740.2756;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;214;-912,480;Inherit;True;Property;_ExpressionMap;Expression Map;2;1;[NoScaleOffset];Create;True;0;0;False;0;19b85be7d9dbda040861f91eb60b6fbb;19b85be7d9dbda040861f91eb60b6fbb;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ColorNode;198;1808,-1216;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;False;1;;1,1,1,1;0.9716981,0.5819566,0.5179334,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;455;1182.206,840.6492;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;275;-1443.145,932.2756;Inherit;False;return float2(uv.x * 0.5, (uv.y / eyesCount) + ((eyesCount - (selectFace)) / eyesCount))@;2;False;3;True;uv;FLOAT2;0,0;In;;Float;False;True;eyesCount;FLOAT;0;In;;Float;False;True;selectFace;FLOAT;0;In;;Float;False;GetEyeArea;True;False;0;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;306;912,672;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;447;-960,2272;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;357;480,1952;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;336;-1536,1952;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;338;-1808,1856;Inherit;False;Property;_SelectMouth;Select Mouth ;7;1;[IntRange];Create;True;0;0;False;0;1;0;1;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;337;-672,1504;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;276;-1715.145,836.2756;Inherit;False;Constant;_center;center;6;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;418;-1072,1504;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;444;-1472,2272;Inherit;False;return float2(uv.x * 0.5+0.5,0.5$ + (uv.y / (browCount*2.0)) + ((browCount - selectBrow) / (browCount*2.0)))@;2;False;3;True;uv;FLOAT2;0,0;In;;Float;False;True;browCount;FLOAT;0;In;;Float;False;True;selectBrow;FLOAT;0;In;;Float;False;GetBrowArea;True;False;0;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;334;-1728,1952;Inherit;False;Constant;_MouthTRS;Mouth TRS;5;0;Create;True;0;0;False;0;2,4,0,0.079;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;429;-1712,2368;Inherit;False;Constant;_Vector1;Vector 1;6;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;288;-208,1184;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.54;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;236;-931.1451,740.2756;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-1811.145,1060.276;Inherit;False;Property;_SelectFace;Select Face;6;1;[IntRange];Create;True;0;0;False;0;1;8;1;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;340;-1712,1600;Inherit;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;False;0;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;522;5074.519,-810.0731;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;324;-1715.145,740.2756;Inherit;False;323;uvcoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;518;2916.517,-690.8973;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;433;-1536,2816;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;452;480,2720;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.15;False;2;FLOAT;0.19;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;313;160,1184;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;451;704,2720;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;515;918.2003,2603.47;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;355;144,1952;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;438;-1712,2272;Inherit;False;323;uvcoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;453;16,2720;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,3;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;519;4737.746,-1138.247;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;5123.746,-1138.247;Float;False;True;-1;2;UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.ZDFace;0;5;Hidden/ZDShader/LWRP/Face Expression;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;6;Above;Hidden/LWRP/General/ShadowCaster;Above;Hidden/LWRP/General/DepthOnly;Above;Hidden/LWRP/General/Outline;Above;Hidden/LWRP/General/ShadowCaster;Above;Hidden/LWRP/General/DepthOnly;Above;Hidden/LWRP/General/Outline;Standard;11;Surface;0;  Blend;0;Two Sided;1;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;1;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;False;False;False;;0
Node;AmplifyShaderEditor.CommentaryNode;513;1380.423,-1745.449;Inherit;False;3325;2073;FaceLightmap;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;327;-1856,1456;Inherit;False;1506;697;Mouth Area;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;426;-1856,2224;Inherit;False;1506;697;Mouth Area;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;322;-1859.145,692.2756;Inherit;False;1506;697;Eyes Area;0;;1,1,1,1;0;0
WireConnection;284;0;283;0
WireConnection;520;0;6;4
WireConnection;520;1;6;4
WireConnection;471;0;479;0
WireConnection;462;0;458;0
WireConnection;503;1;501;0
WireConnection;501;0;504;0
WireConnection;422;0;421;0
WireConnection;458;0;459;0
WireConnection;508;0;494;0
WireConnection;508;1;497;0
WireConnection;500;0;511;0
WireConnection;500;1;499;0
WireConnection;419;0;414;0
WireConnection;419;1;415;0
WireConnection;323;0;213;0
WireConnection;459;0;465;0
WireConnection;463;0;460;0
WireConnection;499;0;508;0
WireConnection;499;1;507;0
WireConnection;279;0;324;0
WireConnection;279;1;218;0
WireConnection;279;2;217;0
WireConnection;474;0;481;0
WireConnection;281;0;236;0
WireConnection;281;1;233;0
WireConnection;437;0;427;1
WireConnection;437;1;427;2
WireConnection;479;0;474;0
WireConnection;479;1;502;0
WireConnection;479;2;503;0
WireConnection;510;0;471;0
WireConnection;510;1;495;0
WireConnection;497;0;491;0
WireConnection;497;1;490;0
WireConnection;307;0;296;0
WireConnection;234;0;280;0
WireConnection;234;1;232;0
WireConnection;495;0;476;3
WireConnection;491;0;498;0
WireConnection;460;0;461;0
WireConnection;494;1;488;0
WireConnection;363;0;455;0
WireConnection;363;1;436;0
WireConnection;363;2;515;0
WireConnection;482;0;485;0
WireConnection;512;0;470;0
WireConnection;509;0;476;1
WireConnection;509;1;486;0
WireConnection;511;0;506;0
WireConnection;511;1;493;0
WireConnection;511;2;508;0
WireConnection;498;0;505;0
WireConnection;498;1;468;0
WireConnection;498;2;509;0
WireConnection;476;0;483;0
WireConnection;476;1;484;0
WireConnection;514;0;215;4
WireConnection;514;1;307;0
WireConnection;470;0;467;0
WireConnection;480;0;477;0
WireConnection;480;1;472;1
WireConnection;465;0;464;1
WireConnection;465;2;464;3
WireConnection;488;0;510;0
WireConnection;506;0;487;0
WireConnection;506;1;493;0
WireConnection;493;0;198;0
WireConnection;493;1;211;0
WireConnection;467;0;473;0
WireConnection;467;1;466;0
WireConnection;502;1;501;0
WireConnection;484;0;480;0
WireConnection;484;1;472;2
WireConnection;490;0;518;0
WireConnection;485;0;469;0
WireConnection;469;0;473;0
WireConnection;469;1;466;0
WireConnection;454;0;450;0
WireConnection;477;0;512;1
WireConnection;211;1;363;0
WireConnection;505;0;475;0
WireConnection;423;0;359;0
WireConnection;423;1;422;0
WireConnection;423;2;337;4
WireConnection;475;0;482;0
WireConnection;475;1;478;0
WireConnection;448;0;444;0
WireConnection;448;1;456;0
WireConnection;446;0;448;0
WireConnection;446;1;437;0
WireConnection;335;0;334;3
WireConnection;335;1;334;4
WireConnection;361;0;325;0
WireConnection;415;0;340;0
WireConnection;415;1;339;0
WireConnection;415;2;338;0
WireConnection;359;0;357;0
WireConnection;445;0;447;0
WireConnection;445;1;433;0
WireConnection;232;0;231;1
WireConnection;232;1;231;2
WireConnection;356;0;355;0
WireConnection;456;0;429;0
WireConnection;456;1;431;0
WireConnection;456;2;432;0
WireConnection;215;0;214;0
WireConnection;215;1;281;0
WireConnection;310;0;313;0
WireConnection;436;0;214;0
WireConnection;436;1;445;0
WireConnection;450;0;453;0
WireConnection;311;0;288;0
WireConnection;416;0;418;0
WireConnection;416;1;415;0
WireConnection;414;0;341;0
WireConnection;414;1;339;0
WireConnection;414;2;338;0
WireConnection;233;0;231;3
WireConnection;233;1;231;4
WireConnection;358;0;361;0
WireConnection;449;0;325;0
WireConnection;449;1;457;0
WireConnection;496;1;476;1
WireConnection;496;2;505;0
WireConnection;296;0;310;1
WireConnection;421;0;356;0
WireConnection;417;0;416;0
WireConnection;417;1;335;0
WireConnection;468;0;476;1
WireConnection;468;1;486;0
WireConnection;280;0;279;0
WireConnection;280;1;275;0
WireConnection;455;0;306;0
WireConnection;455;1;215;0
WireConnection;455;2;514;0
WireConnection;275;0;276;0
WireConnection;275;1;218;0
WireConnection;275;2;217;0
WireConnection;306;0;6;0
WireConnection;306;1;337;0
WireConnection;306;2;423;0
WireConnection;447;0;446;0
WireConnection;447;1;456;0
WireConnection;357;0;356;1
WireConnection;336;0;334;1
WireConnection;336;1;334;2
WireConnection;337;0;214;0
WireConnection;337;1;417;0
WireConnection;418;0;419;0
WireConnection;418;1;336;0
WireConnection;444;0;438;0
WireConnection;444;1;431;0
WireConnection;444;2;432;0
WireConnection;288;0;325;0
WireConnection;236;0;234;0
WireConnection;236;1;275;0
WireConnection;522;0;284;0
WireConnection;522;1;520;0
WireConnection;518;0;476;1
WireConnection;518;1;505;0
WireConnection;433;0;427;3
WireConnection;433;1;427;4
WireConnection;452;0;454;1
WireConnection;313;0;311;0
WireConnection;451;0;452;0
WireConnection;515;0;436;4
WireConnection;515;1;451;0
WireConnection;355;0;358;0
WireConnection;453;0;449;0
WireConnection;1;2;500;0
WireConnection;1;3;522;0
ASEEND*/
// CHKSM = 6D0E85987BD7D52F4117BAD7AA5DE023909BF7FC