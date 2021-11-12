
#define SIN_DENSITY 0.4
#define COLOR_DIFFERENCE 0.8

float rand(half2 co)
{
    return frac(sin(dot(co.xy, half2(12.9898, 78.233))) * 43758.5453) * 5.0;
}
float rand2(half2 co)
{
    return frac(sin(dot(co.xy, half2(12.9898, 78.233))) * 43758.5453) * 50.0;
}

float linearstep(float a, float b, float x)
{
    return clamp((b - x) / (b - a), 0.0, 1.0);
}


//x - circle alpha
//y - circle color
//Thanks to FabriceNeyret2 for this idea
float2 circle(float2 uv, float pixelSize, float sinDna, float cosDna, float _sign)
{
    float height = _sign * sinDna;
    float depth = abs((_sign * 0.5 + 0.5) - (cosDna * 0.25 + 0.5));	//this 0.25 is quite bad here
    float size = 0.2 + depth * 0.1;
    float alpha = 1.0 - smoothstep(size - pixelSize,
    size + pixelSize,
    distance(uv, float2(0.5, height)));
    
    return float2(
        alpha,
        depth * COLOR_DIFFERENCE + (1.0 - COLOR_DIFFERENCE)
    );
}