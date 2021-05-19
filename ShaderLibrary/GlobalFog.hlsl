uniform half _GlobalFogEnabled;
uniform half4 _WorldPoint;
uniform half4 _GlobalFogColor;
uniform half _GlobalFogNoiseScale;
TEXTURE2D(_GlobalFogNoise);            SAMPLER(sampler_GlobalFogNoise);

half4 MixGlobalFog(float4 color, float3 positionWS)
{
    half fogArea = min(1.0, abs(length(positionWS - _WorldPoint.xyz) * _WorldPoint.w));
    half center = smoothstep(0.4, 1.1, 1.0 - fogArea);
    half g1 = SAMPLE_TEXTURE2D(_GlobalFogNoise, sampler_GlobalFogNoise, (positionWS.xz + _Time.y * 2.000 * float2(-0.317, -0.899641)) * _GlobalFogNoiseScale).r;
    half g2 = SAMPLE_TEXTURE2D(_GlobalFogNoise, sampler_GlobalFogNoise, (positionWS.xz + _Time.y * 1.513 * float2(0.217, -0.699641)) * _GlobalFogNoiseScale).r;
    half gray = max(g2, g1);
    fogArea = 1.0 - max(gray, center) * (1.0 - fogArea);
    
    color.rgb = lerp(color.rgb, _GlobalFogColor.rgb, _GlobalFogEnabled * fogArea * _GlobalFogColor.a);
    return color;
}