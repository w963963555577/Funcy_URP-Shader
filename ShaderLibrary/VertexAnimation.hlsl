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
float4 _PositionMask_ST;
float _Speed;
float _Amount;
float _Distance;
float _ZMotion;
float _ZMotionSpeed;
float _OriginWeight;

half _DebugMask;

TEXTURE2D(_PositionMask);       SAMPLER(sampler_PositionMask);

float4 WindAnimation(float4 nv1)
{
    float4 nv = mul(GetObjectToWorldMatrix(), nv1);
    float4 positionMask = _PositionMask.SampleLevel(sampler_PositionMask, TRANSFORM_TEX(nv1.xy, _PositionMask), 0);
    
    float4 objectOrigin = mul(GetObjectToWorldMatrix(), float4(0, 0, 0, 1));
    float4 positionWS = mul(GetObjectToWorldMatrix(), nv1);
    float chanelMask = positionMask.r * positionMask.a;
    
    float _DistanceFromOrigin = distance(objectOrigin.y, nv.y);
    float _anchored = sin((_Time.y + nv.x + objectOrigin.x + objectOrigin.z) * _Speed + nv.y * _Amount) * _Distance * (_DistanceFromOrigin / 3);
    float _unanchored = sin((_Time.y + nv.z + objectOrigin.x + objectOrigin.z) * _Speed + nv.y * _Amount) * _Distance;
    float _nxz = _ZMotion * sin(_Time.y * (_Speed / 10 * _ZMotionSpeed) + nv.y * _Amount * (_ZMotionSpeed / 10));
    nv.x += lerp(_unanchored, _anchored, _OriginWeight) * (1 - _nxz) * chanelMask;
    nv.z += lerp(_unanchored, _anchored, _OriginWeight) * (_nxz) * chanelMask;
    
    nv1 = mul(GetWorldToObjectMatrix(), nv);
    return nv1;
}
