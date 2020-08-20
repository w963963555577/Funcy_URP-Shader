Shader "Andrew/Mobile/Mobile_Base"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
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
		uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
		struct VertexInput
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float2 uv0 : TEXCOORD0;
			UNITY_VERTEX_INPUT_INSTANCE_ID // necessary only if you want to access instanced properties in fragment Shader.
		};
		struct VertexOutput {
			float4 pos : SV_POSITION;
			float2 uv0 : TEXCOORD0;
			float3 worldNormal : TEXCOORD1;
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
			o.uv0 = v.uv0;
			// Pass shadow coordinates to pixel shader
			TRANSFER_SHADOW(o);
			return o;
		}
		float4 frag(VertexOutput i) : SV_Target
		{
			UNITY_SETUP_INSTANCE_ID(i); // necessary only if any instanced properties are going to be accessed in the fragment Shader.
			fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

			float4 _BaseColor = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
			float3 _diffuse = _Color * _BaseColor;

			fixed shadow = SHADOW_ATTENUATION(i);
			fixed drarkAtt = max(0, dot(worldNormal, worldLightDir))*0.7 + 0.3;
			fixed mixedAtt = drarkAtt * 0.5 + lerp(0.5, 1, shadow);

			//_LightColor0.rgb*0.2 + UNITY_LIGHTMODEL_AMBIENT.xyz *0.1
			fixed3 mixedColor = saturate(_diffuse.rgb);
			fixed3 ambient = mixedColor * mixedAtt;

			return fixed4(ambient, 1.0);//+ _LightColor0.rgb
		}
		ENDCG
		}
	}
		FallBack "Diffuse"
}