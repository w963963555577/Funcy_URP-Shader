Shader "Andrew/Mobile/Mobile_Tiles"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Base("Base", 2D) = "white" {}
		_Layer("Layer", 2D) = "white" {}
	}
	SubShader
	{
		Tags {
			"RenderType" = "Opaque"
		}

		Pass {
			Tags
			{
				"LightMode" = "ForwardBase"
			}

		 CGPROGRAM
		// Apparently need to add this declaration 
		#pragma multi_compile_fwdbase	

		#pragma vertex vert
		#pragma fragment frag

		// Need these files to get built-in macros
		#include "Lighting.cginc"
		#include "AutoLight.cginc"

		uniform float4 _Color;
		uniform sampler2D _Base; uniform float4 _Base_ST;
		uniform sampler2D _Layer; uniform float4 _Layer_ST;
		struct VertexInput
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float2 texcoord0 : TEXCOORD0;
			float2 texcoord1 : TEXCOORD1;
			UNITY_VERTEX_INPUT_INSTANCE_ID // necessary only if you want to access instanced properties in fragment Shader.
		};
		struct VertexOutput {
			float4 pos : SV_POSITION;
			float3 worldNormal : TEXCOORD0;
			float2 uv0 : TEXCOORD1;
			float2 uv1 : TEXCOORD3;
			SHADOW_COORDS(2)
			UNITY_VERTEX_INPUT_INSTANCE_ID // necessary only if you want to access instanced properties in fragment Shader.
		};
		UNITY_INSTANCING_BUFFER_START(MyProperties)
		UNITY_INSTANCING_BUFFER_END(MyProperties)

		VertexOutput vert(VertexInput v) {
			VertexOutput o = (VertexOutput)0;
			UNITY_SETUP_INSTANCE_ID(v);
			UNITY_TRANSFER_INSTANCE_ID(v, o); // necessary only if you want to access instanced properties in the fragment Shader.
			o.pos = UnityObjectToClipPos(v.vertex);
			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			o.uv0 = v.texcoord0;
			o.uv1 = v.texcoord1;
			// Pass shadow coordinates to pixel shader
			TRANSFER_SHADOW(o);
			return o;
		}
		float4 frag(VertexOutput i) : SV_Target
		{
			UNITY_SETUP_INSTANCE_ID(i); // necessary only if any instanced properties are going to be accessed in the fragment Shader.
			fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

			float4 _BaseColor = tex2D(_Base,TRANSFORM_TEX(i.uv0, _Base));
			float4 _Layer1Color = tex2D(_Layer,TRANSFORM_TEX(i.uv1, _Layer));
			float3 _diffuse = _Color * _BaseColor;
			_diffuse = _diffuse * (1 - _Layer1Color.a) + _Layer1Color.rgb*_Layer1Color.a;

			fixed shadow = SHADOW_ATTENUATION(i);
			fixed drarkAtt = max(0, dot(worldNormal, worldLightDir))*0.7 + 0.3;
			fixed mixedAtt = drarkAtt * 0.5 + lerp(0.5, 1, shadow);

			//_LightColor0.rgb*0.2 + UNITY_LIGHTMODEL_AMBIENT.xyz *0.1
			fixed3 mixedColor = saturate(_diffuse.rgb);
			fixed3 ambient = mixedColor * mixedAtt;

			return fixed4(ambient, 1.0);
		}
		ENDCG
		}
	}
		FallBack "Diffuse"
}