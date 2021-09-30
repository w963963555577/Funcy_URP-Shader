// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "ZDShader/Skybox/Cubemap"
{
    Properties
    {
        _Tint ("Tint Color", Color) = (.5, .5, .5, .5)
        [Gamma] _Exposure ("Exposure", Range(0, 8)) = 1.0
        _Rotation ("Rotation", Range(0, 360)) = 0
        [NoScaleOffset] _Tex ("Cubemap   (HDR)", Cube) = "grey" { }
        _RotationBackground ("Rotation Background", Range(0, 360)) = 0
        _AutoRotationSpeed ("Auto Rotation Speed", Range(0, 10)) = 0
        [NoScaleOffset] _TexBackground ("Cubemap Background   (HDR)", Cube) = "black" { }
        
        _Speed ("Speed", Range(0, 1)) = 0.1
        
        [Enum(AlphaBlend, 0, Additive, 1)]_BlendWithBackground ("Blend With Background", Float) = 0
    }
    
    SubShader
    {
        Tags { "Queue" = "Background" "RenderType" = "Background" "PreviewType" = "Skybox" }
        Cull Off ZWrite Off
        
        Pass
        {
            
            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0
            
            #pragma vertex vert
            #pragma fragment frag
            
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            #define UNITY_PI 3.14159265359
            #define unity_ColorSpaceDouble half4(2.0, 2.0, 2.0, 2.0)
            CBUFFER_START(UnityPerMaterial)
            half4 _Tex_HDR;
            half4 _TexBackground_HDR;
            half4 _Tint;
            half _Exposure;
            half _Rotation;
            half _RotationBackground;
            half _AutoRotationSpeed;
            half _BlendWithBackground;
            CBUFFER_END
            
            
            TEXTURECUBE(_Tex);                                 SAMPLER(sampler_Tex);
            TEXTURECUBE(_TexBackground);                       SAMPLER(sampler_TexBackground);
            
            float3 RotateAroundYInDegrees(float3 vertex, float degrees)
            {
                float alpha = degrees * UNITY_PI * 0.00555555556;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return float3(mul(m, vertex.xz), vertex.y).xzy;
            }
            
            half3 DecodeHDR(half4 data, half4 decodeInstructions)
            {
                // Take into account texture alpha if decodeInstructions.w is true(the alpha value affects the RGB channels)
                half alpha = decodeInstructions.w * (data.a - 1.0) + 1.0;
                
                // If Linear mode is not supported we can skip exponent part
                #if defined(UNITY_COLORSPACE_GAMMA)
                    return(decodeInstructions.x * alpha) * data.rgb;
                #else
                    #if defined(UNITY_USE_NATIVE_HDR)
                        return decodeInstructions.x * data.rgb; // Multiplier for future HDRI relative to absolute conversion.
                    #else
                        return(decodeInstructions.x * pow(alpha, decodeInstructions.y)) * data.rgb;
                    #endif
                #endif
            }
            
            struct appdata_t
            {
                float4 vertex: POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float3 texcoord0: TEXCOORD0;
                float3 texcoord1: TEXCOORD1;
                
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            v2f vert(appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                float3 rotated0 = RotateAroundYInDegrees(v.vertex.xyz, _Rotation);
                float3 rotated1 = RotateAroundYInDegrees(v.vertex.xyz, _RotationBackground + _Time.y * _AutoRotationSpeed);
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.texcoord0 = rotated0;
                o.texcoord1 = rotated1;
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                half4 tex = SAMPLE_TEXTURECUBE(_Tex, sampler_Tex, i.texcoord0);
                half4 texBackground = SAMPLE_TEXTURECUBE(_TexBackground, sampler_TexBackground, i.texcoord1);
                half3 c = lerp(texBackground.rgb, tex.rgb, max(tex.a, _BlendWithBackground));                
                c = DecodeHDR(half4(c, tex.a), _Tex_HDR);
                texBackground.rgb = DecodeHDR(texBackground, _TexBackground_HDR);
                c = c * _Tint.rgb * unity_ColorSpaceDouble.rgb + texBackground.rgb * _BlendWithBackground;
                c *= _Exposure;
                return half4(c, 1);
            }
            ENDHLSL
            
        }
    }
    
    
    Fallback Off
}
