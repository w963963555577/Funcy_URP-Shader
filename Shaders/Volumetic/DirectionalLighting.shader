Shader "ZDShader/URP/Volume/Directional Lighting"
{
    Properties
    {
        _SampleNum ("Sample", Range(1, 128)) = 16
        _SampleDensity ("Sample Density", Range(0.01, 1.0)) = 0.4
        
        
        _LightingRadius ("Radius", Range(0.01, 1.5)) = .6
        _LightingSampleWeight ("Sample Weight", Range(0.1, 1)) = .9
        
        [HDR]_LightingColor ("Color", Color) = (2, 1, 0.0, 1)
        //_LightingIntensity ("Intensity", Float) = 2.0
        
        _ShadowRamp ("Shadow Ramp", 2D) = "white" { }
        _ShadowColor ("Shadow Color", Color) = (0.07, 0.0, 0.2, 1)
        _ShadowIntensity ("Shadow Intensity", Range(0, 1)) = 0.2
        
        _ShadowSaturation ("Shadow Saturation", Float) = 0.0
    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent-499" }
        
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "MRTTransparent" }
            
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            ZWrite Off
            ZTest Always
            
            
            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma shader_feature_local _Additional_Light_Shadow
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
            half _SampleNum;
            half _SampleDensity;
            
            half _LightingRadius;
            half _LightingSampleWeight;
            
            half4 _LightingColor;
            // half _LightingIntensity;
            half4 _ShadowRamp_ST;
            
            half4 _ShadowColor;
            half _ShadowIntensity;
            
            half _ShadowSaturation;
            CBUFFER_END
            
            TEXTURE2D(_CameraDepthTexture); SAMPLER(sampler_CameraDepthTexture);
            TEXTURE2D(_CameraOpaqueTexture); SAMPLER(sampler_CameraOpaqueTexture);
            TEXTURE2D(_ShadowRamp); SAMPLER(sampler_ShadowRamp);
            
            struct VertexInput
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                float4 positionCS: SV_POSITION;
                float4 srcPos: TEXCOORD0;
                float4 mainLightViewPosition: TEXCOORD1;
                float3 viewDirection: TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.positionCS = TransformObjectToHClip(v.vertex.xyz);
                o.srcPos = ComputeScreenPos(o.positionCS);
                
                Light mainLight = GetMainLight();
                
                o.mainLightViewPosition = ComputeScreenPos(TransformObjectToHClip(mul(GetWorldToObjectMatrix(), _WorldSpaceCameraPos.xyz - float4(mainLight.direction, 1.0)).xyz));
                o.viewDirection = mul(unity_CameraToWorld, float3(0, 0, 1));
                
                return o;
            }
            float ShadowRamp(float2 uv)
            {
                return SAMPLE_TEXTURE2D(_ShadowRamp, sampler_ShadowRamp, TRANSFORM_TEX(uv.xy, _ShadowRamp)).r;
            }
            
            half VolumetricShadow(float2 lightViewPosition, float2 viewPos, float viewFading)
            {
                half finalShadow = 0.0;
                
                float2 uvDelta = (viewPos.xy - lightViewPosition.xy)  ;
                float ramp = ShadowRamp(uvDelta);
                uvDelta *= 1.0h * ramp / _SampleNum * _SampleDensity  ;
                
                half shadow = 1.0;
                #if defined(SHADER_API_OPENGL) || defined(SHADER_API_D3D11) || defined(SHADER_API_D3D12)
                    [unroll(64)]
                #else
                    UNITY_LOOP
                #endif
                for (int iter = 0; iter < _SampleNum ; iter ++)
                {
                    viewPos -= uvDelta;
                    
                    half d = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, viewPos).r ;
                    d = Linear01Depth(d, _ZBufferParams);
                    //d = saturate(smoothstep(.999, 1, 1.0 - (_ZBufferParams.z * d + _ZBufferParams.w)));
                    finalShadow += d;
                }
                
                finalShadow *= (1.0 * _LightingSampleWeight / _SampleNum) ;
                
                return finalShadow ;
            }
            
            half3 RGB2HSV(half3 c)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
                
                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }
            
            half3 HSV2RGB(half3 c)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }
            
            half4 frag(VertexOutput i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                float2 uv = (i.srcPos.xyz / i.srcPos.w).xy;
                i.mainLightViewPosition.xyz /= i.mainLightViewPosition.w;
                Light mainLight = GetMainLight();
                
                float3 viewDirXZ = normalize(float3(i.viewDirection.x, i.viewDirection.y, i.viewDirection.z));
                float3 lightDirXZ = normalize(float3(mainLight.direction.x, mainLight.direction.y, mainLight.direction.z));
                half viewFading = saturate(dot(viewDirXZ, lightDirXZ));
                
                // depth
                float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, uv).r ;
                depth = Linear01Depth(depth, _ZBufferParams) / 2.0;
                
                float2 distance = i.mainLightViewPosition.xy - uv;
                distance.y *= _ScreenParams.y / _ScreenParams.x;
                float distanceDecay = saturate(_LightingRadius - length(distance));
                depth *= distanceDecay;
                
                half finalShadow = VolumetricShadow(i.mainLightViewPosition.xy, uv, viewFading);
                
                float3 mainColor = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, uv).rgb;
                finalShadow *= finalShadow;
                float f_Shadow = saturate(finalShadow) * depth ;
                finalShadow = saturate(finalShadow);
                
                
                half3 a = mainColor.rgb;
                
                half3 sa = a;
                
                sa = RGB2HSV(sa);
                sa.y += _ShadowSaturation;
                sa = HSV2RGB(sa);
                
                
                half3 b = finalShadow * _LightingColor.rgb + (1.0 - finalShadow) * _ShadowColor.rgb * sa.rgb;
                //return float4(viewFading.rrr, 1.0);
                return half4(lerp(a, b, _ShadowIntensity) + f_Shadow.rrr * _LightingColor.rgb, viewFading);
            }
            
            ENDHLSL
            
        }
    }
}