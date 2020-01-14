#ifndef BADDOG_WATER_SSR
#define BADDOG_WATER_SSR

	float UVJitter(in float2 uv)
	{
		return frac((52.9829189 * frac(dot(uv, float2(0.06711056, 0.00583715)))));
	}

	void SSRRayConvert(float3 worldPos, out float4 clipPos, out float3 screenPos)
	{
		clipPos = TransformWorldToHClip(worldPos);
		float k = ((1.0) / (clipPos.w));

		screenPos.xy = ComputeScreenPos(clipPos).xy * k;
		screenPos.z = k;

		#if defined(UNITY_SINGLE_PASS_STEREO)
			screenPos.xy = UnityStereoTransformScreenSpaceTex(screenPos.xy);
		#endif
	}

	float3 SSRRayMarch(float4 clipPosition, float3 worldPos,
		float3 worldNormal,
		float3 worldLightDir,
		float3 worldViewDir,
		half NoL,
		half NoV,
		half NoH,
		half LoH,
		half3 R,
		float2 screenUV)
	{
		float4 startClipPos;
		float3 startScreenPos;

		SSRRayConvert(worldPos, startClipPos, startScreenPos);

		float4 endClipPos;
		float3 endScreenPos;

		SSRRayConvert(worldPos + R, endClipPos, endScreenPos);

		if (((endClipPos.w) < (startClipPos.w)))
		{
			return float3(0, 0, 0);
		}

		float3 screenDir = endScreenPos - startScreenPos;

		float screenDirX = abs(screenDir.x);
		float screenDirY = abs(screenDir.y);

		float dirMultiplier = lerp( 1 / (_ScreenParams.y * screenDirY), 1 / (_ScreenParams.x * screenDirX), screenDirX > screenDirY ) * 4.0;

		screenDir *= dirMultiplier;

		half lastRayDepth = startClipPos.w;

		half sampleCount = 1 + UVJitter(clipPosition) * 0.1;

#if defined (SHADER_API_OPENGL) || defined (SHADER_API_D3D11) || defined (SHADER_API_D3D12)
		[unroll(64)]
#else
		UNITY_LOOP
#endif
		for(int i = 0; i < 64; i++)
		{
			float3 screenMatchUVZ = startScreenPos + screenDir * sampleCount;

			if((screenMatchUVZ.x <= 0) || (screenMatchUVZ.x >= 1) || (screenMatchUVZ.y <= 0) || (screenMatchUVZ.y >= 1))
			{
				break;
			}

			float sceneDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screenMatchUVZ.xy), _ZBufferParams);
			half rayDepth = 1.0 / screenMatchUVZ.z;
			half deltaDepth = rayDepth - sceneDepth;

			if((deltaDepth > 0) && (sceneDepth > startClipPos.w) && (deltaDepth < (abs(rayDepth - lastRayDepth) * 2)))
			{
				return float3(screenMatchUVZ.xy, 1);
			}

			lastRayDepth = rayDepth;
			sampleCount += 1;
		}

		float4 farClipPos;
		float3 farScreenPos;

		SSRRayConvert(worldPos + R * 100000, farClipPos, farScreenPos);

		if((farScreenPos.x > 0) && (farScreenPos.x < 1) && (farScreenPos.y > 0) && (farScreenPos.y < 1))
		{
			float farDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, farScreenPos.xy), _ZBufferParams);

			if(farDepth > startClipPos.w)
			{
				return float3(farScreenPos.xy, 1);
			}
		}

		return float3(0, 0, 0);
	}

	float3 GetSSRUVZ(float4 clipPosition , float3 worldPos,
		float3 worldNormal,
		float3 worldLightDir,
		float3 worldViewDir,
		half NoL,
		half NoV,
		half NoH,
		half LoH,
		half3 R,
		float2 screenUV)
	{
		#if defined(UNITY_SINGLE_PASS_STEREO)
			half ssrWeight = 1;

			half NoV = NoV * 2;
			ssrWeight *= (1 - NoV * NoV);
		#else
			float screenUVs = screenUV * 2 - 1;
			screenUVs *= screenUVs;

			half ssrWeight = saturate(1 - dot(screenUVs, screenUVs));

			half NoVs = NoV * 2.5;
			ssrWeight *= (1 - NoVs * NoVs);
		#endif

		if (ssrWeight > 0.005)
		{
			float3 uvz = SSRRayMarch(clipPosition, worldPos, worldNormal, worldLightDir, worldViewDir, NoL, NoV, NoH, LoH, R, screenUV);
			uvz.z *= ssrWeight;
			return uvz;
		}

		return float3(0, 0, 0);
	}

#endif

