using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustomScreenTexture : ScriptableRendererFeature
{
    [System.Serializable]
    public class GlobalRenderTexture
    {
        public RenderTexture rt;
        public string name = "";
    }
    [System.Serializable]
    public class Settings
    {
        [Range(0, 6)] public int mipmapCount = 0;

        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingTransparents;        
        [Range(1, 10)] public int downSample = 1;

        
        public bool copyToFrameBuffer;
        [Header("Default UsePass")]        
        public Material material = null;
        public int usePass = 0;
        public string targetName = "_CustomScreenTexture";
        
        [Header("To Enable 'Copy To Frame Buffer' to active this.")]
        public Material grabMaterial = null;
        public int frameBufferUsePass = 0;
        public string grabTextureName = "_CustomScreenTextureColorRT";

        public List<GlobalRenderTexture> globalRenderTextures = new List<GlobalRenderTexture>();
        
    }

    public Settings settings = new Settings();

    class Pass : ScriptableRenderPass
    {        
        Settings settings;

        string tag;

        int colorId;
        int resultId;

        RenderTargetIdentifier colorRT;
        RenderTargetIdentifier resultRT;
        

        private RenderTargetIdentifier source { get; set; }

        public void Setup(RenderTargetIdentifier source)
        {
            this.source = source;
        }

        public Pass(Settings settings ,string tag)
        {
            this.settings = settings;
            this.tag = tag;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            var width = cameraTextureDescriptor.width;
            var height = cameraTextureDescriptor.height;
            if (settings.copyToFrameBuffer)
            {
                colorId = Shader.PropertyToID(settings.grabTextureName);
                colorRT = new RenderTargetIdentifier(colorId);
            }
            resultId = Shader.PropertyToID(settings.targetName);
            RenderTextureDescriptor rtd = new RenderTextureDescriptor(width / settings.downSample, height / settings.downSample, RenderTextureFormat.ARGB32, 0, settings.mipmapCount);
            rtd.useMipMap = settings.mipmapCount > 0;

            cmd.GetTemporaryRT(resultId, rtd, FilterMode.Bilinear);
            resultRT = new RenderTargetIdentifier(resultId);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(tag);

            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            opaqueDesc.depthBufferBits = 0;

            if(settings.copyToFrameBuffer)
            {
                cmd.GetTemporaryRT(colorId, opaqueDesc, FilterMode.Bilinear);
                cmd.CopyTexture(source, colorRT);
            }

            if (settings.material)
            {
                cmd.Blit(source, resultRT, settings.material, settings.usePass);
                if (settings.copyToFrameBuffer && settings.grabMaterial)
                {
                    cmd.Blit(resultRT, source, settings.grabMaterial, settings.frameBufferUsePass);
                }                    
            }

            foreach(var gt in settings.globalRenderTextures)
            {
                cmd.SetGlobalTexture(gt.name, gt.rt);
            }


            context.ExecuteCommandBuffer(cmd);

            cmd.Clear();

            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
        }
    }

    Pass pass;

    public override void Create()
    {
        pass = new Pass(settings, this.name);        
        pass.renderPassEvent = settings.renderPassEvent;        
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        var src = renderer.cameraColorTarget;
        pass.Setup(src);
        renderer.EnqueuePass(pass);
    }
}
