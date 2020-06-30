
using UnityEngine;
using UnityEngine.Funcy.LWRP.Runtime;
using UnityEngine.Rendering.Universal;


public class MobileBloomLwrp : ScriptableRendererFeature
{
    [System.Serializable]
    public class MobileBloomSettings
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
    }

    public MobileBloomSettings settings = new MobileBloomSettings();

    MobileBloomLwrpPass mobilePostProcessLwrpPass;

    public override void Create()
    {
        mobilePostProcessLwrpPass = new MobileBloomLwrpPass(settings.Event, settings.blitMaterial, settings.BlurAmount, settings.BloomAmount, settings.BloomThreshold, settings.BloomAdd, settings.OrigBlend, this.name);
    }

    public override void AddRenderPasses(UnityEngine.Rendering.Universal.ScriptableRenderer renderer, ref UnityEngine.Rendering.Universal.RenderingData renderingData)
    {
        mobilePostProcessLwrpPass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(mobilePostProcessLwrpPass);
    }
}


