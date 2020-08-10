sampler2D _PositionMask;
/* Copy to your shader
float4 _PositionMask_ST;
float _Speed;
float _Amount;
float _Distance;
float _ZMotion;
float _ZMotionSpeed;
float _OriginWeight;

half _DebugMask;

TEXTURE2D(_PositionMask);       SAMPLER(sampler_PositionMask);
*/

/*
And use these line
float4 positionMask = _PositionMask.SampleLevel(sampler_PositionMask, TRANSFORM_TEX(input.positionOS.xy, _PositionMask), 0);
input.positionOS = WindAnimation(input.positionOS, _PositionMask_ST, _Speed, _Amount, _Distance, _ZMotion, _ZMotionSpeed, _OriginWeight, _DebugMask, positionMask);
*/

//WindAnimation
/*
↓↓↓↓Copy↓↓↓↓

CBUFFER_START(UnityPerMaterial)
float4 _PositionMask_ST;
float _Speed;
float _Amount;
float _Distance;
float _ZMotion;
float _ZMotionSpeed;
half _DebugMask;
CBUFFER_END
TEXTURE2D(_PositionMask);       SAMPLER(sampler_PositionMask);
*/
/*
float2 GradientNoiseDir(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    float x = (34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

float GradientNoise(float2 uv, float scale)
{
    float2 p = uv * scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(GradientNoiseDir(ip), fp);
    float d01 = dot(GradientNoiseDir(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(GradientNoiseDir(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(GradientNoiseDir(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}
*/
float4 WindAnimation(float4 nv1, float4x4 o2w, float4x4 w2o)
{
    float3 WindDirection = float3(1.0, 0.0, 0.0);
    float4 positionWS = mul(o2w, nv1);
    float3 scale = float3(
        length(o2w._m00_m10_m20),
        length(o2w._m01_m11_m21),
        length(o2w._m02_m12_m22)
    );
    float3 nv = positionWS.xyz;
    
    float4 positionMask = tex2Dlod(_PositionMask, float4(TRANSFORM_TEX(nv1.xy, _PositionMask), 0, 0.0));
    //float4 positionMask = tex2Dlod(_PositionMask, float4(TRANSFORM_TEX(nv.xy, _PositionMask), 0, 0.0));
    float3 objectOrigin = mul(o2w, float4(0, 0, 0, 1)).xyz;
    
    float chanelMask = positionMask.r * positionMask.a;
    
    float speedMax = 7.19 * _Speed / 5.0;
    float motionSpeedMax = 8.19 * _Speed / 5.0;
    
    
    float _DistanceFromOrigin = distance(objectOrigin.y, nv.y);
    float _anchored = sin((_Time.y + (objectOrigin.x + objectOrigin.z) / 3. + nv.x) * speedMax + nv.y * _Amount + (objectOrigin.x + objectOrigin.z) / 3.0) * _Distance * (_DistanceFromOrigin / 3.);
    
    float _nxz = sin(_Time.y * ((speedMax / 10.) * motionSpeedMax) + nv.y * _Amount * (motionSpeedMax / 10.));
    
    nv.x += _anchored * (1. - _nxz) * chanelMask * scale.x;
    nv.z += _anchored * (_nxz) * chanelMask * scale.z;
    
    nv1 = mul(w2o, float4(nv, 1.0));
    return nv1;
}
