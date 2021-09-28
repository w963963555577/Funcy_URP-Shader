TEXTURE2D(_PositionMask);           SAMPLER(sampler_PositionMask);
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
    
    half2 positionMask = SAMPLE_TEXTURE2D_LOD(_PositionMask, sampler_PositionMask, TRANSFORM_TEX(nv1.xy, _PositionMask), 0).xw;
    //half4 positionMask = tex2Dlod(_PositionMask, half4(TRANSFORM_TEX(nv.xy, _PositionMask), 0, 0.0));
    half3 objectOrigin = mul(o2w, half4(0, 0, 0, 1)).xyz;
    
    half chanelMask = positionMask.x * positionMask.y;
    
    half speedMax = 7.19 * _Speed * 0.2;
    half motionSpeedMax = 8.19 * _Speed * 0.2;
    
    
    half _DistanceFromOrigin = distance(objectOrigin.y, nv.y);
    half _anchored = sin((_Time.y + (objectOrigin.x + objectOrigin.z) * 0.333 + nv.x) * speedMax + nv.y * _Amount + (objectOrigin.x + objectOrigin.z) * 0.333) * _Distance * (_DistanceFromOrigin * 0.333);
    
    half _nxz = sin(_Time.y * ((speedMax * 0.1) * motionSpeedMax) + nv.y * _Amount * (motionSpeedMax * 0.1));
    
    nv.x += _anchored * (1. - _nxz) * chanelMask * scale.x;
    nv.z += _anchored * (_nxz) * chanelMask * scale.z;
    
    nv1 = mul(w2o, half4(nv, 1.0));
    return nv1;
}

half4 WindAnimation(half4 nv1, half2 uv, half4x4 o2w, half4x4 w2o)
{
    half3 WindDirection = half3(1.0, 0.0, 0.0);
    half4 positionWS = mul(o2w, nv1);
    half3 scale = half3(
        length(o2w._m00_m10_m20),
        length(o2w._m01_m11_m21),
        length(o2w._m02_m12_m22)
    );
    half3 nv = positionWS.xyz;
    
    half2 positionMask = SAMPLE_TEXTURE2D_LOD(_PositionMask, sampler_PositionMask, TRANSFORM_TEX(nv1.xy, _PositionMask), 0).xw;
    half uvMask = SAMPLE_TEXTURE2D_LOD(_PositionMask, sampler_PositionMask, TRANSFORM_TEX(uv.xy, _PositionMask), 0).y;
    //half4 positionMask = tex2Dlod(_PositionMask, half4(TRANSFORM_TEX(nv.xy, _PositionMask), 0, 0.0));
    half3 objectOrigin = mul(o2w, half4(0, 0, 0, 1)).xyz;
    
    half chanelMask = positionMask.x * positionMask.y * uvMask;
    
    half speedMax = 7.19 * _Speed * 0.2;
    half motionSpeedMax = 8.19 * _Speed * 0.2;
    
    
    half _DistanceFromOrigin = distance(objectOrigin.y, nv.y);
    half _anchored = sin((_Time.y + (objectOrigin.x + objectOrigin.z) * 0.333 + nv.x) * speedMax + nv.y * _Amount + (objectOrigin.x + objectOrigin.z) * 0.333) * _Distance * (_DistanceFromOrigin * 0.333);
    
    half _nxz = sin(_Time.y * ((speedMax * 0.1) * motionSpeedMax) + nv.y * _Amount * (motionSpeedMax * 0.1));
    
    nv.x += _anchored * (1. - _nxz) * chanelMask * scale.x;
    nv.z += _anchored * (_nxz) * chanelMask * scale.z;
    
    nv1 = mul(w2o, half4(nv, 1.0));
    return nv1;
}
