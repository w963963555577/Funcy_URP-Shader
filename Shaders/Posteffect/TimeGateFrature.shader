// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "Hidden/RenderFeature/TimeGateFrature"
{
    Properties
    {
        [HDR]_LineColor_1 ("LineColor 1", COLOR) = (0.1, 0.3, 1., 1.0)

    }

    SubShader
    {
        LOD 0

        
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }
        
        Cull Back
        AlphaToMask Off
        
        Pass
        {
            
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend One Zero
            ZWrite On
            ZTest LEqual
            Offset 0, 0
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

            struct VertexInput
            {
                float4 positionOS: POSITION;
                float2 uv0: TEXCOORD0;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 positionCS: SV_POSITION;
                float2 uv0: TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
            half4 _LineColor_1;
            CBUFFER_END
            
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.uv0 = v.uv0;

                float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
                float4 positionCS = TransformWorldToHClip(positionWS);

                o.positionCS = positionCS;
                return o;
            }
            float hash(in half2 p, in float scale)
            {
                // This is tiling part, adjusts with the scale...
                p = fmod(p, scale);
                return frac(sin(dot(p, half2(27.16898, 38.90563))) * 5151.5473453);
            }

            //----------------------------------------------------------------------------------------
            float noise(in half2 p, in float scale)
            {
                half2 f;
                
                p *= scale;

                
                f = frac(p);		// Separate integer from fractional
                p = floor(p);
                
                f = f * f * (3.0 - 2.0 * f);	// Cosine interpolation approximation
                
                float res = lerp(lerp(hash(p, scale),
                hash(p + half2(1.0, 0.0), scale), f.x),
                lerp(hash(p + half2(0.0, 1.0), scale),
                hash(p + half2(1.0, 1.0), scale), f.x), f.y);
                return res;
            }

            float stepAA(float a, float b)
            {
                float d = (b - a);
                return saturate(d / fwidth(d));
            }

            float N2(half2 p)
            {
                half3 p3 = frac(half3(p.xyx) * half3(443.897, 441.423, 437.195));
                p3 += dot(p3, p3.yzx + 19.19);
                return frac((p3.x + p3.y) * p3.z);
            }


            half4 frag(VertexOutput IN): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
                

                half2 uv = IN.uv0;
                half3 a = half3(0.014, 0.028, 0.0878) * 1.;
                half3 b = half3(0.102, 0.138, 0.230) * 2.;
                half3 d = half3(0.275, 0.5, 0.738) * 0.5;
                half3 c = lerp(lerp(a, b, noise(uv, 12.)), d, abs(uv.x * 2. - 1.));
                
                float bn = max(noise(uv, 1000.0), 0.75) * 1.25;
                
                float no = noise(half2(uv.xx), 8000.0) * 1.5;
                float noy2 = noise(half2(uv.yy), 10000.0) * 0.15;
                float no2 = round(noise(half2(uv.xx + _Time.y * 0.1), 20.) * 8.) * 0.125;
                float ny = round(noise(half2(uv.yy + no - _Time.y * 0.00625), 160.));
                float no3 = round(noise(half2(uv.xx), 200.0) * 160.) * 0.00625 - ny;
                float no3d = round(noise(half2(uv.xx - 0.1), 200.0) * 200.0) * 0.005;
                float co3 = (max(no3, 0.5)) * 1.5;
                float co = (max(no, 0.5)) * 1.5;
                float co2 = (max(noy2, 0.5)) * 1.5;
                
                c *= co;
                c += noy2;

                half3 linC1 = _LineColor_1.rgb;
                if (no3d > 0.895)
                {
                    c += half3(1.0.xxx);
                }
                else if(no3 > 0.895)
                {
                    c = linC1;
                }
                else if(no3 > 0.885)
                {
                    c = linC1;
                }
                
                float vli = (max(noise(half2((uv.yy * no2 * co3)), 1200.0), 0.975)) * 1.025;
                float vlid = (max(noise(half2((uv.yy + no2.xx + 0.0005.xx)), 120.), 0.925)) * 1.075;
                float vli2 = (max(noise(half2((uv.yy + no.xx)), 1200.0), 0.95)) * 1.05;
                float li3 = (max(noise(half2((uv.yy + no2.xx)), 4.), 0.95)) * 1.05;
                
                float li = (max(noise(half2((uv.yy + ny.xx)), 50.), 0.75)) * 1.25;
                float lid = (max(noise(half2((uv.yy + ny.xx + 0.004.xx)), 50.), 0.75)) * 1.25;
                float li2 = (max(noise(half2((uv.yy)), 750.), 0.95)) * 1.05;
                
                if(li2 > 0.99995)
                {
                    c = linC1;
                }
                else if(vlid > 0.9995)
                {
                    c += 2.25;
                }
                else if(li > 0.9995 || vli > 0.9995 || vli2 > 0.9995)
                {
                    c += 0.95;
                }
                else if(lid > 0.9995)
                {
                    c -= 0.75;
                }
                else
                {
                    c *= vli;
                }
                

                uv *= 40.0;
                //give ID's for each square
                half2 gv = frac(uv) - 0.5;
                half2 id = floor(uv);
                //random values
                float ran = N2(id);
                float ran2 = N2(id + 64.0);
                //offset each grid
                half2 dd = abs(gv) - (abs(sin((_Time.y * 4.2) * ran) * 0.5) - 0.05);
                //draw the square
                float rect = min(max(dd.x, dd.y), 0.0) + length(max(dd, 0.));
                float r = step(0., rect);
                //combine square and offset to the color var
                half3 square = (1. - r).xxx * (abs(sin((_Time.y * 4.2) * ran2)) * .8);

                c *= bn + square;

                return half4(c, max(co, max(no3, max(no, no2))));
            }
            
            ENDHLSL
            
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
    Fallback "Hidden/InternalErrorShader"
}
