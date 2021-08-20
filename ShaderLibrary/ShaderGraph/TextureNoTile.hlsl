half4 hash4(half2 p)
{
    return frac(sin(half4(1.0 + dot(p, half2(37.0, 17.0)),
    2.0 + dot(p, half2(11.0, 47.0)),
    3.0 + dot(p, half2(41.0, 29.0)),
    4.0 + dot(p, half2(23.0, 31.0)))) * 103.0);
}
void TextureNoTile_half(Texture2D < half4 > map, in half2 uv, in SamplerState state, out half4 Out)
{
    half2 p = floor(uv);
    half2 f = frac(uv);
    
    // voronoi contribution
    half4 va = 0.0;
    half wt = 0.0;
    for (int j = -1; j <= 1; j ++)
    for (int i = -1; i <= 1; i ++)
    {
        half2 g = half2(i, j);
        half4 o = hash4(p + g);
        half2 r = g - f + o.xy;
        half d = dot(r, r);
        half w = exp(-5.0 * d);
        half4 c = SAMPLE_TEXTURE2D(map, state, uv + o.zw);
        va += w * c;
        wt += w;
    }
    
    // normalization
    Out = va / wt;
}