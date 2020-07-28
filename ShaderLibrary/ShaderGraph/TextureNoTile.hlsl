float4 hash4(float2 p)
{
    return frac(sin(float4(1.0 + dot(p, float2(37.0, 17.0)),
    2.0 + dot(p, float2(11.0, 47.0)),
    3.0 + dot(p, float2(41.0, 29.0)),
    4.0 + dot(p, float2(23.0, 31.0)))) * 103.0);
}
void TextureNoTile_float(Texture2D < float4 > map, in float2 uv, in SamplerState state, out float4 Out)
{
    float2 p = floor(uv);
    float2 f = frac(uv);
    
    // voronoi contribution
    float4 va = 0.0;
    float wt = 0.0;
    for (int j = -1; j <= 1; j ++)
    for (int i = -1; i <= 1; i ++)
    {
        float2 g = float2(i, j);
        float4 o = hash4(p + g);
        float2 r = g - f + o.xy;
        float d = dot(r, r);
        float w = exp(-5.0 * d);
        float4 c = SAMPLE_TEXTURE2D(map, state, uv + o.zw);
        va += w * c;
        wt += w;
    }
    
    // normalization
    Out = va / wt;
}