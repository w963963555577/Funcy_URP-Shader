Shader "ZDShader/LWRP/Volume/Lens Flare"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Flare Map", 2D) = "clear" { }
        _SampleNum ("Sample", Range(0, 6)) = 5.5
        _FlareStep ("Step", Range(0, 1)) = 0.45
        [HDR]_LightingColor ("Color", Color) = (1.5, 1.1, 0.5, 0.5)
        //_LightingIntensity ("Intensity", Float) = 2.0
    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Overlay" }
        
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend SrcAlpha One
            Cull Front
            ZWrite Off
            ZTest Always
            
            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
            half _SampleNum;
            half _FlareStep;
            half4 _LightingColor;
            CBUFFER_END
            
            sampler2D _MainTex;
            struct VertexInput
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct VertexOutput
            {
                int vertexID: vertexID;
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
                
                o.viewDirection = mul(unity_CameraToWorld, float3(0, 0, 1));
                float3 viewDirXZ = normalize(float3(o.viewDirection.x, o.viewDirection.y, o.viewDirection.z));
                float3 lightDirXZ = normalize(float3(mainLight.direction.x, mainLight.direction.y, mainLight.direction.z));
                half viewFading = saturate(dot(viewDirXZ, lightDirXZ));
                
                o.mainLightViewPosition = ComputeScreenPos(TransformObjectToHClip(mul(GetWorldToObjectMatrix(), float4(_WorldSpaceCameraPos.xyz - mainLight.direction.xyz, 1.0)).xyz));
                
                return o;
            }
            
            float2 RotateUV(float2 uv, half radius, half2 pivot)
            {
                float2x2 rotationMatrix = float2x2(cos(radius), -sin(radius), sin(radius), cos(radius));
                uv -= pivot;
                uv = mul(uv, rotationMatrix);
                uv += pivot;
                return uv;
            }
            half4 Tex2DFromLightDirection(float3 lightViewPosition, float3 viewPos, half viewFading)
            {
                float2 flareNearCood = viewPos.xyz - float2(0.5, 0.5);
                float2 flareFarCood = viewPos.xyz - lightViewPosition.xyz;
                
                flareNearCood.y *= _ScreenParams.y / _ScreenParams.x;
                flareNearCood *= _ScreenParams.x / 256.0;
                flareFarCood.y *= _ScreenParams.y / _ScreenParams.x;
                flareFarCood *= _ScreenParams.x / 256.0;
                half4 finalColor = half4(0, 0, 0, 0);
                
                for (int iter = 0; iter < _SampleNum; iter ++)
                {
                    float2 flareCood = flareFarCood + (flareNearCood - flareFarCood) * _FlareStep * (iter + 0.5);
                    half sizeFading = abs(_SampleNum / 2.0 - iter - 1.0) / 2.0;
                    
                    flareCood = RotateUV(flareCood.xy, sizeFading * 3.14159 * (lightViewPosition.x + lightViewPosition.y), 0.0.xx);
                    float2 rotatedCoord = RotateUV(flareCood.xy * 0.7070707, 0.25 * 3.1415926535, 0.0.xx);
                    
                    flareCood /= viewFading * sizeFading;
                    flareCood += 1.0.xx;
                    flareCood /= 2.0;
                    //flareCood = normalize(flareCood);
                    half4 col = tex2D(_MainTex, saturate(flareCood.xy));
                    half edgeFading = 1.0 - saturate(smoothstep(.6, 1, length((0.5.xx - viewPos.xy) * 2.0)));
                    half currentAlpha = (1.0 - smoothstep(0.99, 1.0, abs(rotatedCoord.x) + abs(rotatedCoord.y))) * col.r * col.a * sizeFading * edgeFading * viewFading;
                    finalColor += half4(col.rgb, currentAlpha);
                }
                
                finalColor = saturate(finalColor) * _LightingColor;
                return finalColor ;
            }
            
            half4 frag(VertexOutput i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                float3 uv = (i.srcPos.xyz / i.srcPos.w).xyz;
                i.mainLightViewPosition.xyz /= i.mainLightViewPosition.w ;
                Light mainLight = GetMainLight();
                
                float3 viewDir = i.viewDirection.xyz;
                float3 lightDir = mainLight.direction.xyz;
                half viewFading = saturate(dot(viewDir, lightDir));
                
                half4 finalColor = Tex2DFromLightDirection(i.mainLightViewPosition.xyz, uv.xyz, smoothstep(0, 1, pow(saturate(viewFading), 4.0)));
                
                
                //return float4(viewFading.rrr, 1.0);
                return finalColor;
            }
            
            ENDHLSL
            
        }
    }
}
