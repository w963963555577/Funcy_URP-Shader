//see README here:
//github.com/ColinLeung-NiloCat/UnityURPUnlitScreenSpaceDecalShader

Shader "ZDShader/URP/Projector/Shape(Depth)"
{
    Properties
    {
        [Header(Please use a cube to render)]
        [HDR]_Color ("Color", color) = (1, 1, 1, 1)
        
        _Amount ("Amount", range(0, 1)) = 0.0
        
        [Toggle] _CircleSector ("Circle And Sector Mode", float) = 0
        [Toggle] _Rectangle ("Rectangle Mode", float) = 0
        
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
    }
    
    SubShader
    {
        Tags { "RenderType" = "Overlay" "Queue" = "Transparent-499" "DisableBatching" = "True" }
        
        Pass
        {
            Cull Front
            ZWrite Off
            ZTest GEqual
            Blend SrcAlpha One
            
            HLSLPROGRAM
            
            #define REQUIRE_DEPTH_TEXTURE 1
            
            #pragma vertex vert
            #pragma fragment frag
            
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma target 3.0
            
            
            #pragma shader_feature_local _ProjectionAngleDiscardEnable
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                    
            
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
            half _Amount;
            
            //Circle Projector
            float _CircleAngle;
            float _Thickness;
            
            //Rectangle Projector
            float _RectangleWidth;
            float _RectangleHeight;
            float2 _RectanglePivot;
            
            float _Falloff;
            
            //Toggle
            half _CircleSector;
            half _Rectangle;
            
            CBUFFER_END
            
            // Tranforms position from object to camera space
            inline float3 ObjectToViewPos(float3 pos)
            {
                return mul(UNITY_MATRIX_V, mul(GetObjectToWorldMatrix(), float4(pos, 1.0))).xyz;
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = TransformObjectToHClip(v.vertex);
                o.screenUV = ComputeScreenPos(o.vertex, _ProjectionParams.x);
                
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

            #include "Shapes.hlsl"

            half4 frag(v2f i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                float2 uv = projectorUV(i);
                
                float4 col = float4(0.0h, 0.0h, 0.0h, 0.0h);
                
                _Falloff = _Falloff * _Falloff;
                
                float2 centerUV = (0.5h.rr - uv) * 2.0h;
                col += CircleSector(centerUV) * _CircleSector;
                col += Rectangle(uv) * _Rectangle;
                
                
                return col;
            }
            ENDHLSL
            
        }
    }
    
    CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.ProjectorShape"
}