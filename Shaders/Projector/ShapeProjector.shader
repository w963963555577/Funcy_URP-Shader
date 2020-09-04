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
        _RectanglePivot ("Pivot", Vector) = (0.0, 0.0, 0, 0)
        
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
        Tags { "RenderType" = "Overlay" "Queue" = "Transparent-499" "DisableBatching" = "True" }
        
        Pass
        {
            Stencil
            {
                Ref 0
                Comp[_StencilComp]
            }
            
            Cull Front                        
            ZWrite Off
            ZTest [_ZTest]
            Blend SrcAlpha One
            
            HLSLPROGRAM
            
            #define REQUIRE_DEPTH_TEXTURE 1
            
            #pragma vertex vert
            #pragma fragment frag
            
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma target 3.0
            
            #pragma shader_feature_local _CircleSector
            #pragma shader_feature_local _Rectangle
            
            #pragma shader_feature_local _ProjectionAngleDiscardEnable
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            
            
            #define PI 3.1415926535897932384626433832795
            
            struct appdata
            {
                float4 vertex: POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float4 screenUV: TEXCOORD0;
                float4 viewRayOS: TEXCOORD2;
                float3 cameraPosOS: TEXCOORD3;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            
            CBUFFER_START(UnityPerMaterial)
            float _ProjectionAngleDiscardThreshold;
            half4 _Color;
            
            //Circle Projector
            float _CircleAngle;
            float _Thickness;
            
            //Rectangle Projector
            float _RectangleWidth;
            float _RectangleHeight;
            float2 _RectanglePivot;
            
            float _Falloff;
            CBUFFER_END
            
            // Tranforms position from object to camera space
            inline float3 ObjectToViewPos(float3 pos)
            {
                return mul(UNITY_MATRIX_V, mul(GetObjectToWorldMatrix(), float4(pos, 1.0))).xyz;
            }
            
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
                
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = TransformObjectToHClip(v.vertex);
                o.screenUV = ComputeScreenPos(o.vertex);
                
                float3 viewRay = ObjectToViewPos(v.vertex);
                
                o.viewRayOS.w = viewRay.z;
                
                viewRay *= -1;
                float4x4 ViewToObjectMatrix = mul(GetWorldToObjectMatrix(), UNITY_MATRIX_I_V);
                
                o.viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, viewRay);
                o.cameraPosOS = mul(ViewToObjectMatrix, float4(0.0h, 0.0h, 0.0h, 1.0h)).xyz;
                
                
                return o;
            }
            
            
            float2 projectorUV(v2f i)
            {
                i.viewRayOS /= i.viewRayOS.w;
                i.screenUV = i.screenUV / i.screenUV.w;
                #if defined(UNITY_SINGLE_PASS_STEREO)
                    i.screenUV.xy = UnityStereoTransformScreenSpaceTex(i.screenUV.xy);
                #endif
                float sceneCameraSpaceDepth = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(i.screenUV), _ZBufferParams);
                float3 decalSpaceScenePos = i.cameraPosOS + i.viewRayOS * sceneCameraSpaceDepth;
                
                float2 decalSpaceUV = decalSpaceScenePos.xy + 0.5;
                
                float mask = (abs(decalSpaceScenePos.x) < 0.5) * (abs(decalSpaceScenePos.y) < 0.5) * (abs(decalSpaceScenePos.z) < 0.5);
                
                
                float3 decalSpaceHardNormal = normalize(cross(ddx(decalSpaceScenePos), ddy(decalSpaceScenePos)));
                mask *= decalSpaceHardNormal.z > _ProjectionAngleDiscardThreshold ? 1.0: 0.0;//compare scene hard normal with decal projector's dir, decalSpaceHardNormal.z equals dot(decalForwardDir,sceneHardNormalDir)
                
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
                half4 result = half4(0.0h, 0.0h, 0.0h, 1.0h);
                float2 scaleRect = float2(_RectangleWidth, _RectangleHeight);
                _RectanglePivot += float2(0.5h, 0.5h);
                float2 uvS = (uv - _RectanglePivot) / scaleRect + _RectanglePivot;
                if (uvS.x > 1.0h || uvS.x < 0.0h || uvS.y > 1.0h || uvS.y < 0.0h)
                {
                    uvS = 0.0h.rr;
                }
                else
                {
                    uvS = RotateUV(uvS, float2(0.5h, 0.5h), PI / 4.0h);
                }
                
                float2 absUV = abs(uvS - 0.5h) * 1.4141414h ;
                
                float area = pow((saturate(absUV.r + absUV.g)), pow(_Falloff, 0.5h));
                result.rgb = area.rrr * _Color;
                result.a = (1.0h - step(1.0h, area)) * area;
                
                return result;
            }
            
            half4 frag(v2f i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                float2 uv = projectorUV(i);
                
                float4 col = float4(0.0h, 0.0h, 0.0h, 1.0h);
                
                _Falloff = _Falloff * _Falloff;
                #if _CircleSector
                    float2 centerUV = (0.5h.rr - uv) * 2.0h;
                    col = CircleSector(centerUV);
                #endif
                #if _Rectangle
                    col = Rectangle(uv);
                #endif
                
                return col;
            }
            ENDHLSL
            
        }
    }
    
    CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.ProjectorShape"
}