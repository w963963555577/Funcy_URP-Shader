Shader "ZDShader/LWRP/Volume/Point Lighting"
{
    Properties
    {
        _SampleNum ("Sample", Range(1, 128)) = 128
        _SampleDensity ("Sample Density", Range(0.01, 1.0)) = 1.0
        

        _LightingRadius ("Radius", Range(0.0, 1.5)) = 1.5

        [HDR]_LightingColor ("Color", Color) = (1, 1, 1.0, 1)
        //_LightingIntensity ("Intensity", Float) = 2.0
        
        _ShadowRamp ("Shadow Ramp", 2D) = "white" { }
        _ShadowColor ("Shadow Color", Color) = (0.07, 0.0, 0.2, 1)
        _ShadowIntensity ("Shadow Intensity", Range(0, 1)) = 0.0

        _ShadowSaturation ("Shadow Saturation", Float) = 0.0
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent-450" }
        
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            
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
                float3 normalWS: TEXCOORD3;
                float3 positionWS: TEXCOORD4;
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
                
                o.mainLightViewPosition = ComputeScreenPos(TransformObjectToHClip(float4(0.0, 0.0, 0.0, 1.0).xyz));
                o.viewDirection = _WorldSpaceCameraPos.xyz;
                o.normalWS = TransformObjectToWorldNormal(v.normal);
                o.positionWS = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
                return o;
            }
            float ShadowRamp(float2 uv)
            {
                return SAMPLE_TEXTURE2D(_ShadowRamp, sampler_ShadowRamp, TRANSFORM_TEX(uv.xy, _ShadowRamp)).r;
            }

            half VolumetricShadow(float2 lightViewPosition, float2 viewPos)
            {
                half finalShadow = 0.0;

                float2 uvDelta = (viewPos.xy - lightViewPosition.xy)  ;
                float ramp = ShadowRamp(uvDelta);
                uvDelta *= _LightingRadius * ramp / _SampleNum * _SampleDensity  ;
                
                half shadow = 1.0;
                
                for (int iter = 0; iter < _SampleNum; iter ++)
                {
                    viewPos -= uvDelta ;
                    
                    half d = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, viewPos).r ;
                    
                    d = Linear01Depth(d, _ZBufferParams);
                    finalShadow += d;
                }
                
                finalShadow *= (1.0 / _SampleNum) ;

                return finalShadow ;
            }

            half4 frag(VertexOutput i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                float2 uv = (i.srcPos.xyz / i.srcPos.w).xy;
                i.mainLightViewPosition.xyz /= i.mainLightViewPosition.w;
                

                // depth
                float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, uv).r ;
                depth = Linear01Depth(depth, _ZBufferParams) / 2.0;

                float2 distance = i.mainLightViewPosition.xy - uv;
                distance.y *= _ScreenParams.y / _ScreenParams.x;
                float distanceDecay = saturate(0.01 - length(distance));
                depth *= distanceDecay;

                half finalShadow = VolumetricShadow(i.mainLightViewPosition.xy, uv);

                finalShadow *= finalShadow;
                
                float3 worldViewDir = normalize(i.positionWS.xyz - _WorldSpaceCameraPos.xyz);
                float fresnel = pow(saturate(dot(i.normalWS, worldViewDir)), 5.0);
                //fresnel =pow(1.0 -fresnel, 5.0);

                finalShadow = pow(saturate(finalShadow), 1 + _ShadowIntensity * 5.0);


                return half4(lerp(_ShadowColor.rgb, _LightingColor.rgb, finalShadow), finalShadow * fresnel * _LightingColor.a);
            }
            
            ENDHLSL
            
        }
    }
}