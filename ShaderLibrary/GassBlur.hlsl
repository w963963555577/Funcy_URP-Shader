
float4 GassBlur(Texture2D map, SamplerState state, float2 uv, float blurRadius, float2 texelSize, float depthValue)
{
    float4 col = 0;
    float sigma = blurRadius / 3.0f;
    float sigma2 = sigma * sigma;
    float left = 1 / (2 * sigma2 * 3.1415926f);

    for (int x = -blurRadius; x <= blurRadius; ++ x)
    {
        for (int y = -blurRadius; y <= blurRadius; ++ y)
        {
            float4 color = SAMPLE_TEXTURE2D(map, state, (uv + float2(x, y) * texelSize * depthValue));

            float weight = left * exp( - (x * x + y * y) / (2 * sigma2));
            col += color * weight;
        }
    }

    return col;
}

