#define PI 3.1415926535897932384626433832795

////Func
float Remap(float value, float from1, float to1, float from2, float to2)
{
    return(value - from1) / (to1 - from1) * (to2 - from2) + from2;
}

float2 RotateUV(float2 uv, float2 pivot, float rotation)
{
    float sine = sin(rotation);
    float cosine = cos(rotation);
    float2 rotator = mul(uv - pivot, float2x2(cosine, -sine, sine, cosine)) + pivot;
    return rotator;
}


////Shapes
half4 CircleSector(float2 centerUV)
{
    half4 result = half4(0, 0, 0, 1);
    _CircleAngle = Remap(_CircleAngle, 0.0, 360.0, 0.0, 1.0);
    
    float reduce = saturate(_CircleAngle - 0.5);
    float arc1 = (atan2(centerUV.y, centerUV.x) / PI + 1.0 - reduce);
    float arc2 = (atan2(-centerUV.y, centerUV.x) / PI + 1.0 - reduce);
    float circle = saturate(length(centerUV));
    float circleControlable = 1.0 - pow(saturate(length(centerUV / (1.0 - _Thickness + 0.1 * (1.0 - _Thickness)))), _Falloff);
    
    float areaPart1 = (1.0 - saturate(arc1 / _CircleAngle));
    float areaPart2 = (1.0 - saturate(arc2 / _CircleAngle));
    float areaPart = saturate((saturate((areaPart1 + areaPart2)) * (1.0 - circle)));
    
    float areaCol = lerp((1.0 - areaPart), 1.0, _CircleAngle);
    areaCol = lerp(areaCol, circle, saturate(_CircleAngle - 0.7070707));
    areaCol = pow(areaCol, _Falloff);
    result.rgb = (areaCol + circleControlable).rrr * _Color;
    
    arc1 = (atan2(centerUV.y, centerUV.x) / PI + 1.0);
    arc2 = (atan2(-centerUV.y, centerUV.x) / PI + 1.0);
    areaPart1 = (1.0 - saturate(arc1 / _CircleAngle));
    areaPart2 = (1.0 - saturate(arc2 / _CircleAngle));
    areaPart = saturate(((areaPart1 + areaPart2) * (1.0 - circle)));
    
    float alpha = (1.0 - step(areaPart, 0.0)) * (1.0 - areaPart) * step(1.0 - circle, _Thickness);
    result.a = alpha * 0.35;
    _Amount = Remap(_Amount, 0.0, 1, 1.0 - _Thickness, 1.0);
    result.a += alpha * 0.65 * smoothstep(1.0 - _Amount - 0.005, 1.0 - _Amount + 0.005, (1.0 - circle));
    return result;
}

half4 Rectangle(float2 uv)
{
    half4 result = half4(0.0h, 0.0h, 0.0h, 1.0h);
    float2 scaleRect = float2(_RectangleWidth, _RectangleHeight);
    _RectanglePivot += float2(0.5h, 0.5h);
    float2 uvS = (uv - _RectanglePivot) / scaleRect + _RectanglePivot;
    
    uvS = RotateUV(uvS, float2(0.5h, 0.5h), PI / 4.0h);
    float2 absUV = abs(uvS - 0.5h) * 1.4141414h ;
    
    float area = pow((saturate(absUV.r + absUV.g)), pow(_Falloff, 0.5h));
    result.rgb = area.rrr * _Color;
    float alpha = (1.0h - step(1.0h, area)) * area;
    result.a = alpha * 0.35;
    result.a += alpha * 0.65 * smoothstep(1.0 - _Amount - 0.005, 1.0 - _Amount + 0.005, uv.y);
    return result;
}
