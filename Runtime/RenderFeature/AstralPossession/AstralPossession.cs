
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


public class AstralPossession : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public RenderPassEvent Event = RenderPassEvent.AfterRenderingTransparents;
        

        public Material blurMaterial;
        public Material blitMaterial = null;

        [Range(2, 15)]
        public int blurPasses = 6;

        [Range(1, 4)]
        public int downsample = 2;

        public string silhouettesMap = "_Silhouettes";
        public string soulMap = "_SoulMap";
    }

    public Settings settings = new Settings();

    internal class Pass : ScriptableRenderPass
    {
        Settings settings;
        public Material blurMaterial;
        public Material blitMaterial;
        public int passes;
        public int downsample;

        

        private RenderTargetIdentifier source;        
        private RenderTargetIdentifier cameraColorRT = new RenderTargetIdentifier(cameraColorID);
        private RenderTargetIdentifier silhouettesRT;
        private RenderTargetIdentifier tmpRT1;
        private RenderTargetIdentifier tmpRT2;

        int tmpId1;
        int tmpId2;
        int silhouettesID;

        private readonly string tag;
        
        static readonly int cameraColorID = Shader.PropertyToID("_AstralPossession_CameraColor");
        
        public Pass(Settings settings, string tag)
        {
            this.settings = settings;
            this.renderPassEvent = settings.Event;
            this.tag = tag;            
            this.blurMaterial = settings.blurMaterial;
            this.blitMaterial = settings.blitMaterial;

        }

        public void Setup(RenderTargetIdentifier source)
        {
            this.source = source;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            var width = cameraTextureDescriptor.width / downsample;
            var height = cameraTextureDescriptor.height / downsample;

            tmpId1 = Shader.PropertyToID("tmpBlurRT1");
            tmpId2 = Shader.PropertyToID("tmpBlurRT2");
            silhouettesID = Shader.PropertyToID(settings.silhouettesMap);

            cmd.GetTemporaryRT(tmpId1, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.ARGB32);
            cmd.GetTemporaryRT(tmpId2, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.ARGB32);

            tmpRT1 = new RenderTargetIdentifier(tmpId1);
            tmpRT2 = new RenderTargetIdentifier(tmpId2);
            silhouettesRT = new RenderTargetIdentifier(silhouettesID);
            ConfigureTarget(tmpRT1);
            ConfigureTarget(tmpRT2);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(tag);
            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            opaqueDesc.depthBufferBits = 0;

            cmd.GetTemporaryRT(cameraColorID, opaqueDesc, FilterMode.Bilinear);
            cmd.CopyTexture(source, cameraColorRT);

            // first pass
            // cmd.GetTemporaryRT(tmpId1, opaqueDesc, FilterMode.Bilinear);
            cmd.SetGlobalFloat("_offset", 1.5f);
            cmd.Blit(silhouettesRT, tmpRT1, blurMaterial);

            for (var i = 1; i < passes - 1; i++)
            {
                cmd.SetGlobalFloat("_offset", 0.5f + i);
                cmd.Blit(tmpRT1, tmpRT2, blurMaterial);

                // pingpong
                var rttmp = tmpRT1;
                tmpRT1 = tmpRT2;
                tmpRT2 = rttmp;
            }

            // final pass
            cmd.SetGlobalFloat("_offset", 0.5f + passes - 1f);
            cmd.Blit(tmpRT1, tmpRT2, blurMaterial);
            cmd.SetGlobalTexture(settings.soulMap, tmpRT2);



            cmd.Blit(cameraColorRT, source, blitMaterial, 0);
            
            context.ExecuteCommandBuffer(cmd);            

            CommandBufferPool.Release(cmd);
        }
        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(cameraColorID);
            cmd.ReleaseTemporaryRT(tmpId1);
            cmd.ReleaseTemporaryRT(tmpId2);
            cmd.ReleaseTemporaryRT(silhouettesID);            
        }


    }


    Pass pass;

    public override void Create()
    {
        pass = new Pass(settings, this.name);
        pass.passes = settings.blurPasses;
        pass.downsample = settings.downsample;
    }

    public override void AddRenderPasses(UnityEngine.Rendering.Universal.ScriptableRenderer renderer, ref UnityEngine.Rendering.Universal.RenderingData renderingData)
    {
        pass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(pass);
    }
}

