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
            
            #include "Shapes.hlsl"
            #include "Packages/com.zd.urp.funcy/ShaderLibrary/ProjectorUV.hlsl"
            
            
            v2f vert(appdata v)
            {
                v2f o;
                
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.screenUV = ComputeScreenPos(o.vertex, _ProjectionParams.x);
                
                float4x4 o2w = GetObjectToWorldMatrix();
                float4x4 w2o = GetWorldToObjectMatrix();
                InitProjectorVertexData(v.vertex, o2w, w2o, o.viewRayOS, o.cameraPosOS);
                
                return o;
            }
            
            
            half4 frag(v2f i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                float2 uv = projectorUV(i.viewRayOS, i.cameraPosOS, i.screenUV, 1.0.xx, 0.0);
                
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
    
    CustomEditor "UnityEditor.Rendering.Funcy.URP.ShaderGUI.ProjectorShape"
}