Shader "Hidden/LWRP/VertexNormalUVDrawer"
{
    Properties
    {
        _UVChanel ("UVChanel", Int) = 1
    }
    
    SubShader
    {
        // =====================================================================================================================
        // TAGS AND SETUP ------------------------------------------
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Overlay" "IgnoreProjector" = "True" }
        LOD 300
        
        ZTest  Always
        ZWrite Off
        Cull   Off
        
        
        
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            
            #pragma vertex   vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct Attributes
            {
                float4 positionOS: POSITION;
                float3 normal: NORMAL;
                float4 tangent: TANGENT;
                float2 uv0: TEXCOORD0;
                float2 uv1: TEXCOORD1;
                float2 uv2: TEXCOORD2;
                float2 uv3: TEXCOORD3;
                float2 uv4: TEXCOORD4;
                float2 uv5: TEXCOORD5;
                float2 uv6: TEXCOORD6;
                float2 uv7: TEXCOORD7;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct Varyings
            {
                float3 positionWS: TEXCOORD0;
                float4 positionOS: TEXCOORD1;
                float3 normalOS: TEXCOORD2;
                float4 tangentOS: TEXCOORD3;
                float4 positionCS: SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            float4 _Point;
            float _BrushHardness;
            float _BrushSize;
            half _UVChanel;
            // =====================================================================================================================
            // VERTEX FRAGMENT ----------------------------------
            
            Varyings vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                
                output.positionOS = input.positionOS;
                // VertexPositionInputs contains position in multiple spaces (world, view, homogeneous clip space)
                // Our compiler will strip all unused references (say you don't use view space).
                // Therefore there is more flexibility at no additional cost with this struct.
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionWS = vertexInput.positionWS;
                
                output.normalOS = input.normal;
                output.tangentOS = input.tangent;
                float2 uvRemapped;
                if (_UVChanel == 0)uvRemapped = input.uv0;
                if(_UVChanel == 1)uvRemapped = input.uv1;
                if(_UVChanel == 2)uvRemapped = input.uv2;
                if(_UVChanel == 3)uvRemapped = input.uv3;
                if(_UVChanel == 4)uvRemapped = input.uv4;
                if(_UVChanel == 5)uvRemapped = input.uv5;
                if(_UVChanel == 6)uvRemapped = input.uv6;
                if(_UVChanel == 7)uvRemapped = input.uv7;
                
                uvRemapped.y = 1. - uvRemapped.y;
                uvRemapped = uvRemapped * 2. - 1.;
                
                
                output.positionCS = float4(uvRemapped.xy, 0.0, 1.0);
                
                
                
                return output;
            }
            
            float SignAlpha(float3 vec)
            {
                float3 vecSign = saturate(sign(vec));
                vecSign *= float3(0.5, 0.25, 0.125);
                return vecSign.x + vecSign.y + vecSign.z;
            }
            
            float4 frag(Varyings input): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                /*
                0.5,0.25,0.125
                
                +++ //.875
                --- //.0
                -++ //.375
                ++- //.75
                --+ //.125
                +-- //.5
                +-+ //.625
                -+- //.25
                */
                
                return float4(SignAlpha(input.normalOS).rrr, 1.0);
            }
            
            ENDHLSL
            
        }
    }
}
