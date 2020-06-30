Shader "SupGames/Mobile/BloomLwrp"
{
    Properties
    {
        [HideInInspector]_MainTex ("Base (RGB)", 2D) = "white" { }
        _Intensity ("Intensity", Range(0, 1)) = 0.0
        _BumpMask ("BumpMask", 2D) = "black" { }
    }
    HLSLINCLUDE
    
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    
    TEXTURE2D(_MainTex);
    SAMPLER(sampler_MainTex);
    TEXTURE2D(_BlurTex);
    SAMPLER(sampler_BlurTex);
    
    TEXTURE2D(_BumpMask);
    SAMPLER(sampler_BumpMask);
    
    uniform float4 _BumpMap_ST;
    uniform half _Intensity;
    
    uniform half _BloomAdd;
    uniform half _BloomThreshold;
    uniform half _BloomAmount;
    uniform half _BlurAmount;
    uniform half _OrigBlend;
    uniform half4 _MainTex_TexelSize;
    
    
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
    };
    
    v2f vert(AttributesDefault v)
    {
        v2f o = (v2f)0;
        o.pos = TransformWorldToHClip(TransformObjectToWorld(v.vertex.xyz));
        o.uv = v.uv;
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
        
        float2 uv0_BumpMap = uv.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
        uv0_BumpMap.x *= _MainTex_TexelSize.y / _MainTex_TexelSize.x;
        float2 panner40 = (_Time.y * float2(0, -0.01) + uv0_BumpMap + float2(0.01, 0.01));
        float2 panner42 = (_Time.y * float2(0, -0.01) + uv0_BumpMap - float2(0.01, 0.01));
        
        half4 maskColor = SAMPLE_TEXTURE2D(_BumpMask, sampler_BumpMask, uv);
        
        uv += (uv - 0.5.xx) * 2.0 * max(max(maskColor.r, maskColor.g), maskColor.b);       
        
        half4 c = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
        half4 b = SAMPLE_TEXTURE2D(_BlurTex, sampler_BlurTex, uv) * _BloomAmount;
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
            
            #pragma vertex vert
            #pragma fragment fragBlurBloom
            #pragma fragmentoption ARB_precision_hint_fastest
            ENDHLSL
            
        }
    }
}
