//see README here:
//github.com/ColinLeung-NiloCat/UnityURPUnlitScreenSpaceDecalShader

Shader "ZDShader/LWRP/Projector/Shape"
{
    Properties
    {
        [Header(Please use a cube to render)]
        _Color ("Color", color) = (1, 1, 1, 1)
        
        [Toggle(_CircleSector)] _CircleSector ("Circle And Sector Mode", float) = 0
        [Toggle(_Rectangle)] _Rectangle ("Rectangle Mode", float) = 0
 
        //Circle Projector
        _CircleAngle ("Circle Angle", range(0, 360)) = 30
        _Thickness ("Circle Thickness", range(0, 1)) = 1.0
        
        //Rectangle Projector
        _RectangleWidth ("Rectangle Width", range(0, 1)) = 1
        _RectangleHeight ("Rectangle Height", range(0, 1)) = 1
        
        
        _Falloff ("Fall Off", Float) = 4

                
        [HideInInspector][Toggle(_ProjectionAngleDiscardEnable)] _ProjectionAngleDiscardEnable ("_ProjectionAngleDiscardEnable (default = on)", float) = 1
        [HideInInspector]_ProjectionAngleDiscardThreshold ("_ProjectionAngleDiscardThreshold (default = 0)", range(-1, 1)) = 0
       
        //Hide Property
        [HideInInspector]_StencilRef ("_StencilRef", Float) = 0
        [HideInInspector]_StencilComp ("_StencilComp", Float) = 0 //0 = disable
        [HideInInspector]_ZTest ("_ZTest", Float) = 0 //0 = disable
        
    }
    
    SubShader
    {
        Tags { "RenderType" = "Overlay" "Queue" = "Transparent" "IgnoreProjector" = "True" }
        
        Pass
        {
            Stencil
            {
                Ref 0
                Comp[_StencilComp]
            }
            
            Cull Front
            ZTest[_ZTest]
            
            ZWrite Off
            Blend SrcAlpha One
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            // make fog work
            #pragma multi_compile_fog
            
            #pragma target 3.0
            
            #pragma shader_feature_local _CircleSector
            #pragma shader_feature_local _Rectangle
            
            #pragma shader_feature_local _ProjectionAngleDiscardEnable
            
            #include "UnityCG.cginc"
            
            #define PI 3.1415926535897932384626433832795
            
            struct appdata
            {
                float4 vertex: POSITION;
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float4 screenUV: TEXCOORD0;
                float4 viewRayOS: TEXCOORD2;
                float3 cameraPosOS: TEXCOORD3;
            };
            
            CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;float4 _MainTex_ST;
            float _ProjectionAngleDiscardThreshold;
            half4 _Color;
            
            //Circle Projector
            float _CircleAngle;
            float _Thickness;
            
            //Rectangle Projector
            float _RectangleWidth;
            float _RectangleHeight;
            
            
            float _Falloff;
            CBUFFER_END
            
            sampler2D _CameraDepthTexture;
            
            
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
            
            v2f vert(appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenUV = ComputeScreenPos(o.vertex);
                float3 viewRay = UnityObjectToViewPos(v.vertex);
                
                o.viewRayOS.w = viewRay.z;
                
                viewRay *= -1;
                float4x4 ViewToObjectMatrix = mul(unity_WorldToObject, UNITY_MATRIX_I_V);
                
                o.viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, viewRay);
                o.cameraPosOS = mul(ViewToObjectMatrix, float4(0, 0, 0, 1)).xyz;
                
                return o;
            }
            
            
            
            
            float2 projectorUV(v2f i)
            {
                i.viewRayOS /= i.viewRayOS.w;
                
                float sceneCameraSpaceDepth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, i.screenUV));
                float3 decalSpaceScenePos = i.cameraPosOS + i.viewRayOS * sceneCameraSpaceDepth;
                
                float2 decalSpaceUV = decalSpaceScenePos.xy + 0.5;
                
                float mask = (abs(decalSpaceScenePos.x) < 0.5) * (abs(decalSpaceScenePos.y) < 0.5) * (abs(decalSpaceScenePos.z) < 0.5);
                
                #if _ProjectionAngleDiscardEnable
                    float3 normalized_ddx = normalize(ddx(decalSpaceScenePos));
                    float3 normalized_ddy = normalize(ddy(decalSpaceScenePos));
                    float3 decalSpaceHardNormal = cross(normalized_ddx, normalized_ddy);
                    mask *= decalSpaceHardNormal.z > _ProjectionAngleDiscardThreshold;
                #endif
                //call discard
                clip(mask - 0.5);//if ZWrite is off, clip() is fast enough on mobile, because it won't access the DepthBuffer, so no pipeline stall.
                //===================================================
                
                // sample the decal texture
                return decalSpaceUV.xy;
            }
            
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
                result.a = alpha;
                return result;
            }
            
            half4 Rectangle(float2 uv)
            {
                half4 result = half4(0, 0, 0, 1);
                
                float2 absUV = abs((RotateUV((uv - 0.5.rr) * 1.41414 / float2(_RectangleWidth, _RectangleHeight) + 0.5.rr, 0.5.rr, PI / 4.0) - 0.5.rr));
                float area = pow((saturate(absUV.r + absUV.g)), pow(_Falloff, 0.5));
                result.rgb = area.rrr * _Color;
                result.a = (1.0 - step(1.0, area)) * area ;
                return result;
            }
            
            half4 frag(v2f i): SV_Target
            {
                float2 uv = projectorUV(i);
                float4 col = float4(0, 0, 0, 1);
                
                _Falloff = _Falloff * _Falloff;
                #if _CircleSector
                    float2 centerUV = (0.5.rr - uv) * 2.0;
                    col = CircleSector(centerUV);
                #endif
                #if _Rectangle
                    col = Rectangle(uv);
                #endif
                
                
                return col;
            }
            ENDCG
            
        }
    }
        CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.ProjectorShape"
}