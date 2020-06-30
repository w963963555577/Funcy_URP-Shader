Shader "Hidden/Funcy/NormalandTangentDrawer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        [HDR]_TopColor ("Top Color", Color) = (1, 1, 1, 1)
        [HDR]_BottomColor ("Bottom Color", Color) = (0, 0, 0, 1)
        _ExtrudeMaxValue ("Extrude Max Value", Range(0, 1)) = 1
        _ExtrudeRandomValue ("Extrude Random Value", Range(0, 1)) = 1
        _NormalWidth ("NormalWidth", Float) = 5
        [Toggle(_DrawTangent)]_DrawTangent ("Draw Tangent", Float) = 0
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            
            Cull Off
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma shader_feature _DrawTangent
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float3 tangent: TANGENT;
                float2 uv: TEXCOORD0;
            };
            
            struct v2g
            {
                float4 vertex: POSITION;
                float3 normal: TEXCOORD0;
            };
            
            struct g2f
            {
                float4 vertex: SV_POSITION;
                float4 color: COLOR;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BottomColor;
            float4 _TopColor;
            float _ExtrudeMaxValue;
            float _ExtrudeRandomValue;
            float _NormalWidth;
            
            v2g vert(a2v v)
            {
                v2g o;
                o.vertex = v.vertex;
                #if _DrawTangent
                    o.normal = v.tangent;
                #else
                    o.normal = v.normal;
                #endif
                
                return o;
            }
            
            [maxvertexcount(9)]
            void geom(triangle v2g input[3], uint pid: SV_PRIMITIVEID, inout TriangleStream < g2f > outStream)
            {
                float extrudeAmount = _ExtrudeMaxValue;
                
                float normalWidth = _NormalWidth;
                
                float3 offset1 = float3(-1, 1, -1);
                float3 offset2 = float3(1, 1, 1);
                
                g2f o;
                for (int iter0 = 0; iter0 < 3; iter0 ++)
                {
                    float3 P = input[iter0].vertex.xyz;
                    float3 N = input[iter0].normal.xyz;
                    
                    o.vertex = TransformObjectToHClip(float4(P + N * _ExtrudeMaxValue, 1.0).xyz);
                    o.color = _BottomColor;
                    outStream.Append(o);
                    
                    o.vertex = TransformObjectToHClip(float4(P + 0.001 * normalWidth * offset1, 1.0).xyz);
                    o.color = _TopColor;
                    outStream.Append(o);
                    
                    o.vertex = TransformObjectToHClip(float4(P + 0.001 * normalWidth * offset2, 1.0).xyz);
                    o.color = _TopColor;
                    outStream.Append(o);
                    
                    
                    outStream.RestartStrip();
                }
            }
            
            float4 frag(g2f i): SV_Target
            {
                float4 col = i.color;
                return col;
            }
            ENDHLSL
            
        }
        
        Pass
        {
            Tags { "LightMode" = "LightweightForward" }
            
            Cull Off
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma shader_feature _DrawTangent
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float3 tangent: TANGENT;
                float2 uv: TEXCOORD0;
            };
            
            struct v2g
            {
                float4 vertex: POSITION;
                float3 normal: TEXCOORD0;
            };
            
            struct g2f
            {
                float4 vertex: SV_POSITION;
                float4 color: COLOR;
            };
            
            
            sampler2D _MainTex;
            
            float4 _MainTex_ST;
            float4 _BottomColor;
            float4 _TopColor;
            float _ExtrudeMaxValue;
            float _ExtrudeRandomValue;
            float _NormalWidth;
            
            v2g vert(a2v v)
            {
                v2g o;
                o.vertex = v.vertex;
                #if _DrawTangent
                    o.normal = v.tangent;
                #else
                    o.normal = v.normal;
                #endif
                
                return o;
            }
            
            [maxvertexcount(9)]
            void geom(triangle v2g input[3], uint pid: SV_PRIMITIVEID, inout TriangleStream < g2f > outStream)
            {
                float extrudeAmount = _ExtrudeMaxValue;
                
                
                float normalWidth = _NormalWidth;
                
                float3 offset1 = float3(-1, 1, 1);
                float3 offset2 = float3(-1, 1, -1);
                
                g2f o;
                for (int iter0 = 0; iter0 < 3; iter0 ++)
                {
                    float3 P = input[iter0].vertex.xyz;
                    float3 N = input[iter0].normal.xyz;
                    
                    o.vertex = TransformObjectToHClip(float4(P, 1.0).xyz);
                    o.color = _BottomColor;
                    outStream.Append(o);
                    
                    o.vertex = TransformObjectToHClip(float4(P + N * _ExtrudeMaxValue + 0.001 * normalWidth * offset1, 1.0).xyz);
                    o.color = _TopColor;
                    outStream.Append(o);
                    
                    o.vertex = TransformObjectToHClip(float4(P + N * _ExtrudeMaxValue + 0.001 * normalWidth * offset2, 1.0).xyz);
                    o.color = _TopColor;
                    outStream.Append(o);
                    
                    outStream.RestartStrip();
                }
            }
            
            float4 frag(g2f i): SV_Target
            {
                float4 col = i.color;
                return col;
            }
            ENDHLSL
            
        }
        
        Pass
        {
            Cull Off
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma shader_feature _DrawTangent
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float3 tangent: TANGENT;
                float2 uv: TEXCOORD0;
            };
            
            struct v2g
            {
                float4 vertex: POSITION;
                float3 normal: TEXCOORD0;
            };
            
            struct g2f
            {
                float4 vertex: SV_POSITION;
                float4 color: COLOR;
            };
            
            
            sampler2D _MainTex;
            
            float4 _MainTex_ST;
            float4 _BottomColor;
            float4 _TopColor;
            float _ExtrudeMaxValue;
            float _ExtrudeRandomValue;
            float _NormalWidth;
            
            v2g vert(a2v v)
            {
                v2g o;
                o.vertex = v.vertex;
                #if _DrawTangent
                    o.normal = v.tangent;
                #else
                    o.normal = v.normal;
                #endif
                
                return o;
            }
            
            [maxvertexcount(9)]
            void geom(triangle v2g input[3], uint pid: SV_PRIMITIVEID, inout TriangleStream < g2f > outStream)
            {
                float extrudeAmount = _ExtrudeMaxValue;
                
                
                float normalWidth = _NormalWidth;
                
                float3 offset1 = float3(1, 1, 1);
                float3 offset2 = float3(-1, 1, 1);
                
                g2f o;
                for (int iter0 = 0; iter0 < 3; iter0 ++)
                {
                    float3 P = input[iter0].vertex.xyz;
                    float3 N = input[iter0].normal.xyz;
                    
                    o.vertex = TransformObjectToHClip(float4(P, 1.0).xyz);
                    o.color = _BottomColor;
                    outStream.Append(o);
                    
                    o.vertex = TransformObjectToHClip(float4(P + N * _ExtrudeMaxValue + 0.001 * normalWidth * offset1, 1.0).xyz);
                    o.color = _TopColor;
                    outStream.Append(o);
                    
                    o.vertex = TransformObjectToHClip(float4(P + N * _ExtrudeMaxValue + 0.001 * normalWidth * offset2, 1.0).xyz);
                    o.color = _TopColor;
                    outStream.Append(o);
                    
                    outStream.RestartStrip();
                }
            }
            
            float4 frag(g2f i): SV_Target
            {
                float4 col = i.color;
                return col;
            }
            ENDHLSL
            
        }
    }
}
