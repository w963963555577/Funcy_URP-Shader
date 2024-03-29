﻿
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine.UIElements;
#endif

public class MobileBloomPass : ScriptableRenderPass
{
    [System.Serializable]
    public class Settings
    {
        public RenderPassEvent Event = RenderPassEvent.AfterRenderingTransparents;

        public Material blitMaterial = null;

        [Range(0, 5)]
        public float BlurAmount = 1f;

        public float BloomAmount = 1f;

        public float BloomThreshold = 0.0f;

        public float BloomAdd = 0.0f;

        [Range(0, 1)]
        public float OrigBlend = 1.0f;

        public bool blurRefraction = false;
    }

    Settings settings;
    ZDUniversalRenderFeature.RadiusBlurSettings radiusBlurSettings;
    public Material material;

    private RenderTargetIdentifier source;
    private RenderTargetIdentifier blurTemp = new RenderTargetIdentifier(blurTempString);
    private RenderTargetIdentifier blurTemp1 = new RenderTargetIdentifier(blurTemp1String);

    private RenderTargetHandle blurBuffer;
    private RenderTargetHandle bloomBuffer;

    static readonly int blAmountString = Shader.PropertyToID("_BloomAmount");
    static readonly int blurAmountString = Shader.PropertyToID("_BlurAmount");
    static readonly int blThresholdString = Shader.PropertyToID("_BloomThreshold");
    static readonly int blAddString = Shader.PropertyToID("_BloomAdd");
    static readonly int orBString = Shader.PropertyToID("_OrigBlend");
    static readonly int blurTempString = Shader.PropertyToID("_BlurTemp");
    static readonly int blurTemp1String = Shader.PropertyToID("_BlurTemp2");

    static readonly int refraction = Shader.PropertyToID("_RefractionBuffer");
    static readonly int intensity_Refraction = Shader.PropertyToID("_Intensity_RefractionBuffer");

    RenderTexture refractionBuffer;
    public MobileBloomPass(Settings settings, ZDUniversalRenderFeature.RadiusBlurSettings radiusBlurSettings)
    {
        this.settings = settings;
        this.radiusBlurSettings = radiusBlurSettings;
        this.renderPassEvent = settings.Event;
        this.material = settings.blitMaterial;

        blurBuffer.Init("_BlurBuffer");
        bloomBuffer.Init("_BloomBuffer");
    }

    public void Setup(RenderTargetIdentifier source)
    {
        this.source = source;
    }
    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        refractionBuffer = (RenderTexture)Shader.GetGlobalTexture(refraction);
    }
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        CommandBuffer cmd = CommandBufferPool.Get(GetType().Name);
        RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
        opaqueDesc.depthBufferBits = 0;

        cmd.GetTemporaryRT(blurBuffer.id, opaqueDesc, FilterMode.Bilinear);
        cmd.CopyTexture(source, blurBuffer.id);

        if (ZDUniversalRenderFeature.radialBlurControls.Count > 0)
        {
            cmd.EnableShaderKeyword("_RadiusBlur");
            Camera camera = renderingData.cameraData.camera;
            Matrix4x4 viewMatrix = camera.worldToCameraMatrix;
            Matrix4x4 VP = GL.GetGPUProjectionMatrix(camera.projectionMatrix, true) * viewMatrix;
            cmd.SetGlobalMatrix("_VPMatrix", VP);
            cmd.SetGlobalFloat("_BlurStrength", radiusBlurSettings.blurStrength);
            cmd.SetGlobalFloat("_BlurWidth", radiusBlurSettings.blurWidth);
            cmd.SetGlobalVector("_BlurWorldPosition", radiusBlurSettings.worldPosition);
        }
        else
        {
            cmd.DisableShaderKeyword("_RadiusBlur");
        }


        cmd.SetGlobalFloat(blurAmountString, settings.BlurAmount);
        cmd.SetGlobalFloat(blAmountString, settings.BloomAmount);
        cmd.SetGlobalFloat(blThresholdString, settings.BloomThreshold);
        cmd.SetGlobalFloat(blAddString, settings.BloomAdd);
        cmd.SetGlobalFloat(orBString, settings.OrigBlend);

        cmd.SetGlobalFloat(intensity_Refraction, refractionBuffer == null ? 0.0f : 1.0f);

        cmd.GetTemporaryRT(blurTempString, Screen.width / 4, Screen.height / 4, 0, FilterMode.Bilinear);
        cmd.GetTemporaryRT(blurTemp1String, Screen.width / 8, Screen.height / 8, 0, FilterMode.Bilinear);
        cmd.GetTemporaryRT(bloomBuffer.id, Screen.width / 4, Screen.height / 4, 0, FilterMode.Bilinear);

        cmd.Blit(blurBuffer.id, blurTemp, material, 0);
        cmd.Blit(blurTemp, blurTemp1, material, 1);
        cmd.Blit(blurTemp1, bloomBuffer.id, material, 1);
        cmd.Blit(blurBuffer.id, source, material, 2);

        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }
    public override void FrameCleanup(CommandBuffer cmd)
    {
        cmd.ReleaseTemporaryRT(blurBuffer.id);
        cmd.ReleaseTemporaryRT(blurTempString);
        cmd.ReleaseTemporaryRT(blurTemp1String);
        cmd.ReleaseTemporaryRT(bloomBuffer.id);
    }
}
#if UNITY_EDITOR
// IngredientDrawerUIE
[CustomPropertyDrawer(typeof(MobileBloomPass.Settings))]
public class MobileBloomPass_Settings : PropertyDrawer
{
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        EditorGUILayout.PropertyField(property, new GUIContent("Bloom Settings"));
    }
}
#endif