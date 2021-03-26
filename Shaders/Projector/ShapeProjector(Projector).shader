Shader "ZDShader/URP/Projector/ShadowProjector(Projector)"
{
    Properties
    {
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
    }
    SubShader
    {
        Tags { "RenderType" = "Overlay" "Queue" = "Transparent-499" "DisableBatching" = "True" }
        // Shader code
        Pass
        {
            Cull Back
            ZWrite Off
            Blend SrcAlpha One
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local FSR_PROJECTOR_FOR_LWRP
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            
            #include "../../ShaderLibrary/EnableCbuffer.cginc"
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex: POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f
            {
                float4 uvShadow: TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 pos: SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            #if defined(FSR_RECEIVER) // FSR_RECEIVER keyword is used by Projection Receiver Renderer component which is contained in Fast Shadow Receiver.
                
                CBUFFER_START(ProjectorTransform)
                float4x4 _FSRProjector;
                float4 _FSRProjectDir;
                CBUFFER_END
                
                void fsrTransformVertex(float4 v, out float4 clipPos, out float4 shadowUV)
                {
                    clipPos = UnityObjectToClipPos(v);
                    shadowUV = mul(_FSRProjector, v);
                }
                float3 fsrProjectorDir()
                {
                    return _FSRProjectDir.xyz;
                }
                
            #elif defined(FSR_PROJECTOR_FOR_LWRP)
                
                CBUFFER_START(ProjectorTransform)
                uniform float4x4 _FSRWorldToProjector;
                uniform float4 _FSRWorldProjectDir;
                CBUFFER_END
                
                void fsrTransformVertex(float4 v, out float4 clipPos, out float4 shadowUV)
                {
                    float4 worldPos;
                    worldPos.xyz = mul(unity_ObjectToWorld, v).xyz;
                    worldPos.w = 1.0f;
                    #if defined(STEREO_CUBEMAP_RENDER_ON)
                        worldPos.xyz += ODSOffset(worldPos.xyz, unity_HalfStereoSeparation.x);
                    #endif
                    clipPos = mul(UNITY_MATRIX_VP, worldPos);
                    shadowUV = mul(_FSRWorldToProjector, worldPos);
                }
                float3 fsrProjectorDir()
                {
                    return UnityWorldToObjectDir(_FSRWorldProjectDir.xyz);
                }
                
            #else // !defined(FSR_RECEIVER)
                
                CBUFFER_START(ProjectorTransform)
                float4x4 unity_Projector;
                float4x4 unity_ProjectorClip;
                CBUFFER_END
                
                void fsrTransformVertex(float4 v, out float4 clipPos, out float4 shadowUV)
                {
                    clipPos = UnityObjectToClipPos(v);
                    shadowUV = mul(unity_Projector, v);
                    shadowUV.z = mul(unity_ProjectorClip, v).x;
                }
                float3 fsrProjectorDir()
                {
                    return normalize(float3(unity_Projector[2][0], unity_Projector[2][1], unity_Projector[2][2]));
                }
                
            #endif // FSR_RECEIVER
            
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
            
            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                fsrTransformVertex(v.vertex, o.pos, o.uvShadow);
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }
            
            #include "Shapes.hlsl"
            
            fixed4 frag(v2f i): SV_Target
            {
                fixed2 uv = UNITY_PROJ_COORD(i.uvShadow).xy;
                
                
                float4 col = float4(0.0h, 0.0h, 0.0h, 0.0h);
                
                _Falloff = _Falloff * _Falloff;
                
                float2 centerUV = (0.5h.rr - uv) * 2.0h;
                col += CircleSector(centerUV) * _CircleSector;
                col += Rectangle(uv) * _Rectangle;
                
                fixed2 uvRect = abs((uv - 0.5.xx) * 2.0);
                clip(1.0 - max(uvRect.x, uvRect.y));
                return col;
            }
            
            
            ENDHLSL
            
        }
    }
    
    CustomEditor "UnityEditor.Rendering.Funcy.LWRP.ShaderGUI.ProjectorShape"
}