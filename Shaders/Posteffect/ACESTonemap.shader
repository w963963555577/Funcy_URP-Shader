Shader "Hidden/Renderfeature/ACESTonemap"
{
    Properties
    {
        [HideInInspector]_MainTex ("Base (RGB)", 2D) = "white" { }
    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            Fog
            {
                Mode off
            }
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ACES.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
            };
            
            
            TEXTURE2D(_MainTex);        SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
            
            CBUFFER_END
            
            
            half3 AcesTonemap(half3 aces)
            {
                // --- Glow module --- //
                half saturation = rgb_2_saturation(aces);
                half ycIn = rgb_2_yc(aces);
                half s = sigmoid_shaper((saturation - 0.4) / 0.2);
                half addedGlow = 1.0 + glow_fwd(ycIn, RRT_GLOW_GAIN * s, RRT_GLOW_MID);
                aces *= addedGlow;
                
                // --- Red modifier --- //
                half hue = rgb_2_hue(aces);
                half centeredHue = center_hue(hue, RRT_RED_HUE);
                half hueWeight;
                {
                    //hueWeight = cubic_basis_shaper(centeredHue, RRT_RED_WIDTH);
                    hueWeight = smoothstep(0.0, 1.0, 1.0 - abs(2.0 * centeredHue / RRT_RED_WIDTH));
                    hueWeight *= hueWeight;
                }
                
                aces.r += hueWeight * saturation * (RRT_RED_PIVOT - aces.r) * (1.0 - RRT_RED_SCALE);
                
                // --- ACES to RGB rendering space --- //
                half3 acescg = max(0.0, ACES_to_ACEScg(aces));
                
                // --- Global desaturation --- //
                //acescg = mul(RRT_SAT_MAT, acescg);
                acescg = lerp(dot(acescg, AP1_RGB2Y).xxx, acescg, RRT_SAT_FACTOR.xxx);
                
                // Luminance fitting of *RRT.a1.0.3 + ODT.Academy.RGBmonitor_100nits_dim.a1.0.3*.
                // https://github.com/colour-science/colour-unity/blob/master/Assets/Colour/Notebooks/CIECAM02_Unity.ipynb
                // RMSE: 0.0012846272106
                #if defined(SHADER_API_SWITCH) // Fix halfing point overflow on extremely large values.
                    const half a = 2.7 * 0.01;
                    const half b = 0.2 * 0.01;
                    const half c = 2.936045 * 0.01;
                    const half d = 0.5 * 0.01;
                    const half e = 0.6 * 0.01;
                    half3 x = acescg;
                    half3 rgbPost = ((a * x + b)) * rcp((c * x + d) + e * rcp(x + FLT_MIN));
                #else
                    const half a = 2.7;
                    const half b = 0.2;
                    const half c = 2.936045;
                    const half d = 0.5;
                    const half e = 0.6;
                    half3 x = acescg;
                    half3 rgbPost = (x * (a * x + b)) * rcp(x * (c * x + d) + e);
                #endif
                
                // Scale luminance to linear code value
                // half3 linearCV = Y_2_linCV(rgbPost, CINEMA_WHITE, CINEMA_BLACK);
                
                // Apply gamma adjustment to compensate for dim surround
                half3 linearCV = darkSurround_to_dimSurround(rgbPost);
                
                // Apply desaturation to compensate for luminance difference
                //linearCV = mul(ODT_SAT_MAT, color);
                linearCV = lerp(dot(linearCV, AP1_RGB2Y).xxx, linearCV, ODT_SAT_FACTOR.xxx);
                
                // Convert to display primary encoding
                // Rendering space RGB to XYZ
                half3 XYZ = mul(AP1_2_XYZ_MAT, linearCV);
                
                // Apply CAT from ACES white point to assumed observer adapted white point
                XYZ = mul(D60_2_D65_CAT, XYZ);
                
                // CIE XYZ to display primaries
                linearCV = mul(XYZ_2_REC709_MAT, XYZ);
                
                
                return linearCV;
            }
            
            inline half3 GammaToLinearSpace(half3 sRGB)
            {
                // Approximate version from http://chilliant.blogspot.com.au/2012/08/srgb-approximations-for-hlsl.html?m=1
                return sRGB * (sRGB * (sRGB * 0.305306011h + 0.682171111h) + 0.012522878h);
                
                // Precise version, useful for debugging.
                //return half3(GammaToLinearSpaceExact(sRGB.r), GammaToLinearSpaceExact(sRGB.g), GammaToLinearSpaceExact(sRGB.b));
            }
            
            inline half3 LinearToGammaSpace(half3 linRGB)
            {
                linRGB = max(linRGB, half3(0.h, 0.h, 0.h));
                // An almost-perfect approximation from http://chilliant.blogspot.com.au/2012/08/srgb-approximations-for-hlsl.html?m=1
                return max(1.055h * pow(linRGB, 0.416666667h) - 0.055h, 0.h);
                
                // Exact version, useful for debugging.
                //return half3(LinearToGammaSpaceExact(linRGB.r), LinearToGammaSpaceExact(linRGB.g), LinearToGammaSpaceExact(linRGB.b));
            }
            
            
            v2f vert(appdata v)
            {
                v2f o = (v2f)0;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                return o;
            }
            
            half4 frag(v2f input): SV_Target
            {
                half4 col;
                col.rgb = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv).rgb;
                
                #if defined(UNITY_COLORSPACE_GAMMA)
                    col.rgb = GammaToLinearSpace(col.rgb);
                #endif
                
                col.rgb = unity_to_ACES(col.rgb);
                col.rgb = AcesTonemap(col.rgb);
                
                #if defined(UNITY_COLORSPACE_GAMMA)
                    col.rgb = LinearToGammaSpace(col.rgb);
                #endif
                return col;
            }
            ENDHLSL
            
        }
    }
}
