sampler2D _PositionMask;
/* Copy to your shader
half4 _PositionMask_ST;
half _Speed;
half _Amount;
half _Distance;
half _ZMotion;
half _ZMotionSpeed;
half _OriginWeight;

half _DebugMask;

TEXTURE2D(_PositionMask);       SAMPLER(sampler_PositionMask);
*/

/*
And use these line
half4 positionMask = _PositionMask.SampleLevel(sampler_PositionMask, TRANSFORM_TEX(input.positionOS.xy, _PositionMask), 0);
input.positionOS = WindAnimation(input.positionOS, _PositionMask_ST, _Speed, _Amount, _Distance, _ZMotion, _ZMotionSpeed, _OriginWeight, _DebugMask, positionMask);
*/

//WindAnimation
/*
↓↓↓↓Copy↓↓↓↓

CBUFFER_START(UnityPerMaterial)
half4 _PositionMask_ST;
half _Speed;
half _Amount;
half _Distance;
half _ZMotion;
half _ZMotionSpeed;
half _DebugMask;
CBUFFER_END
TEXTURE2D(_PositionMask);       SAMPLER(sampler_PositionMask);
*/
/*
half2 GradientNoiseDir(half2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    half x = (34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(half2(x - floor(x + 0.5), abs(x) - 0.5));
}

half GradientNoise(half2 uv, half scale)
{
    half2 p = uv * scale;
    half2 ip = floor(p);
    half2 fp = frac(p);
    half d00 = dot(GradientNoiseDir(ip), fp);
    half d01 = dot(GradientNoiseDir(ip + half2(0, 1)), fp - half2(0, 1));
    half d10 = dot(GradientNoiseDir(ip + half2(1, 0)), fp - half2(1, 0));
    half d11 = dot(GradientNoiseDir(ip + half2(1, 1)), fp - half2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}
*/
half4 WindAnimation(half4 nv1, half4x4 o2w, half4x4 w2o)
{
    half3 WindDirection = half3(1.0, 0.0, 0.0);
    half4 positionWS = mul(o2w, nv1);
    half3 scale = half3(
        length(o2w._m00_m10_m20),
        length(o2w._m01_m11_m21),
        length(o2w._m02_m12_m22)
    );
    half3 nv = positionWS.xyz;
    
    half4 positionMask = tex2Dlod(_PositionMask, half4(TRANSFORM_TEX(nv1.xy, _PositionMask), 0, 0.0));
    //half4 positionMask = tex2Dlod(_PositionMask, half4(TRANSFORM_TEX(nv.xy, _PositionMask), 0, 0.0));
    half3 objectOrigin = mul(o2w, half4(0, 0, 0, 1)).xyz;
    
    half chanelMask = positionMask.r * positionMask.a;
    
    half speedMax = 7.19 * _Speed / 5.0;
    half motionSpeedMax = 8.19 * _Speed / 5.0;
    
    
    half _DistanceFromOrigin = distance(objectOrigin.y, nv.y);
    half _anchored = sin((_Time.y + (objectOrigin.x + objectOrigin.z) / 3. + nv.x) * speedMax + nv.y * _Amount + (objectOrigin.x + objectOrigin.z) / 3.0) * _Distance * (_DistanceFromOrigin / 3.);
    
    half _nxz = sin(_Time.y * ((speedMax / 10.) * motionSpeedMax) + nv.y * _Amount * (motionSpeedMax / 10.));
    
    nv.x += _anchored * (1. - _nxz) * chanelMask * scale.x;
    nv.z += _anchored * (_nxz) * chanelMask * scale.z;
    
    nv1 = mul(w2o, half4(nv, 1.0));
    return nv1;
}
