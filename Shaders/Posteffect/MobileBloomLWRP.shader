Shader "Hidden/Renderfeature/Bloom"
{
    Properties
    {
        [HideInInspector]_MainTex ("Base (RGB)", 2D) = "white" { }
        //_RefractionMask ("RefractionMask", 2D) = "black" { }
        //_BlurStrength ("Strength", Range(0, 2)) = 1
        //_BlurWidth ("Width", Float) = 0.2776577
        //_Center ("Center", Vector) = (0.5, 0.5, 0, 0)
    }
    HLSLINCLUDE
    
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    TEXTURE2D(_MainTex);
    SAMPLER(sampler_MainTex);
    TEXTURE2D(_BloomBuffer);
    SAMPLER(sampler_BloomBuffer);
    
    TEXTURE2D(_RefractionBuffer);
    SAMPLER(sampler_RefractionBuffer);
    
    uniform float4 _BumpMap_ST;
    uniform half _Intensity_RefractionBuffer;
    
    uniform half _BloomAdd;
    uniform half _BloomThreshold;
    uniform half _BloomAmount;
    uniform half _BlurAmount;
    uniform half _OrigBlend;
    uniform half4 _MainTex_TexelSize;
    #if _RadiusBlur
        uniform half4x4 _VPMatrix;
        uniform half _BlurStrength;
        uniform half _BlurWidth;
        uniform half3 _BlurWorldPosition;
    #endif
    struct AttributesDefault
    {
        float4 vertex: POSITION;
        float2 uv: TEXCOORD0;
    };
    
    struct v2fb
    {
        half4 pos: SV_POSITION;
        half4 uv: TEXCOORD0;
    };
    
    struct v2f
    {
        half4 pos: SV_POSITION;
        half2 uv: TEXCOORD0;
        #if _RadiusBlur
            half4 dirAndDistAndT: TEXCOORD1;
            half2 pushUV[10]: TEXCOORD2;
        #endif
    };
    
    v2f vert(AttributesDefault v)
    {
        v2f o = (v2f)0;
        o.pos = TransformObjectToHClip(v.vertex.xyz);
        o.uv = v.uv;
        
        #if _RadiusBlur
            half4 projPos = mul(_VPMatrix, half4(_BlurWorldPosition.xyz, 1.0));
            half3 ndcPos = projPos.xyz * rcp(projPos.w);
            half3 viewportPos = half3(ndcPos.x * 0.5 + 0.5, 1.0 - (ndcPos.y * 0.5 + 0.5), 0.0);
            half2 center = viewportPos.xy;
            half2 dir = center - o.uv;
            half dist = sqrt(dir.x * dir.x + dir.y * dir.y);
            o.dirAndDistAndT = half4(dir * rcp(dist), dist, saturate(dist * _BlurStrength));
            // some sample positions
            half samples[10] = {
                - 0.08, -0.05, -0.03, -0.02, -0.01, 0.01, 0.02, 0.03, 0.05, 0.08
            };
            for (int n = 0; n < 10; n ++)
            {
                o.pushUV[n] = dir * samples[n] * _BlurWidth;
            }
        #endif
        return o;
    }
    
    v2fb vertBlur(AttributesDefault v)
    {
        v2fb o = (v2fb)0;
        o.pos = TransformWorldToHClip(TransformObjectToWorld(v.vertex.xyz));
        half2 uv = v.uv;
        half2 offset = (_MainTex_TexelSize.xy) * _BlurAmount;
        o.uv = half4(uv - offset, uv + offset);
        return o;
    }
    
    half4 fragBloom(v2fb i): SV_Target
    {
        half4 result = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv.xy);
        result += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv.xw);
        result += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv.zy);
        result += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv.zw);
        return max(result * 0.25h - _BloomThreshold, 0.0h);
    }
    
    half4 fragBlur(v2fb i): COLOR
    {
        half4 result = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv.xy);
        result += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv.xw);
        result += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv.zy);
        result += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv.zw);
        return result * 0.25h;
    }
    
    half4 fragBlurBloom(v2f i): COLOR
    {
        half2 uv = i.uv;
        half4 maskColor = SAMPLE_TEXTURE2D(_RefractionBuffer, sampler_RefractionBuffer, uv) * _Intensity_RefractionBuffer;
        half2 ditortion = (uv - 0.5.xx) * 2.0 * max(max(maskColor.r, maskColor.g), maskColor.b) * (1.0 - length((uv - 0.5.xx)));
        uv += ditortion;
        half4 c = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
        
        #if _RadiusBlur
            half4 sum = c;
            for (int n = 0; n < 10; n ++)
            {
                sum += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + i.pushUV[n]);
            }
            
            //eleven samples...
            sum *= 0.0909;
            
            c.rgb = lerp(c, sum, i.dirAndDistAndT.w).rgb;
        #endif
        half4 b = SAMPLE_TEXTURE2D(_BloomBuffer, sampler_BloomBuffer, uv) * _BloomAmount;
        
        return(c * _OrigBlend + b) * 0.5h * (1.0 + _BloomAdd);
    }
    
    ENDHLSL
    
    Subshader
    {
        Pass //0
        {
            ZTest Always Cull Off ZWrite Off
            Fog
            {
                Mode off
            }
            
            HLSLPROGRAM
            
            #pragma vertex vertBlur
            #pragma fragment fragBloom
            #pragma fragmentoption ARB_precision_hint_fastest
            ENDHLSL
            
        }
        Pass //1
        {
            ZTest Always Cull Off ZWrite Off
            Fog
            {
                Mode off
            }
            
            HLSLPROGRAM
            
            #pragma vertex vertBlur
            #pragma fragment fragBlur
            #pragma fragmentoption ARB_precision_hint_fastest
            ENDHLSL
            
        }
        Pass //2
        {
            ZTest Always Cull Off ZWrite Off
            Fog
            {
                Mode off
            }
            HLSLPROGRAM
            
            #pragma multi_compile _ _RadiusBlur
            #pragma vertex vert
            #pragma fragment fragBlurBloom
            #pragma fragmentoption ARB_precision_hint_fastest
            ENDHLSL
            
        }
    }
}
