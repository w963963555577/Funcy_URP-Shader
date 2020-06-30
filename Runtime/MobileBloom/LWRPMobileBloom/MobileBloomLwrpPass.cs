
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
namespace UnityEngine.Funcy.LWRP.Runtime
{
    internal class MobileBloomLwrpPass : ScriptableRenderPass
    {
        public Material material;

        private RenderTargetIdentifier source;
        private RenderTargetIdentifier blurTemp = new RenderTargetIdentifier(blurTempString);
        private RenderTargetIdentifier blurTemp1 = new RenderTargetIdentifier(blurTemp1String);
        private RenderTargetIdentifier blurTex = new RenderTargetIdentifier(blurTexString);
        private RenderTargetIdentifier tempCopy = new RenderTargetIdentifier(tempCopyString);

        private readonly string tag;
        private readonly float bloomAmount;
        private readonly float blurAmount;
        private readonly float bloomThreshold;
        private readonly float bloomAdd;
        private readonly float origBlend;

        static readonly int blAmountString = Shader.PropertyToID("_BloomAmount");
        static readonly int blurAmountString = Shader.PropertyToID("_BlurAmount");
        static readonly int blThresholdString = Shader.PropertyToID("_BloomThreshold");
        static readonly int blAddString = Shader.PropertyToID("_BloomAdd");
        static readonly int orBString = Shader.PropertyToID("_OrigBlend");

        static readonly int blurTempString = Shader.PropertyToID("_BlurTemp");
        static readonly int blurTemp1String = Shader.PropertyToID("_BlurTemp2");
        static readonly int blurTexString = Shader.PropertyToID("_BlurTex");
        static readonly int tempCopyString = Shader.PropertyToID("_TempCopy");

        public MobileBloomLwrpPass(RenderPassEvent renderPassEvent, Material material,
            float blurAmount, float bloomAmount, float bloomThreshold, float bloomAdd, float origBlend, string tag)
        {
            this.renderPassEvent = renderPassEvent;
            this.tag = tag;
            this.material = material;

            this.blurAmount = blurAmount;
            this.bloomAmount = bloomAmount;
            this.bloomThreshold = bloomThreshold;
            this.bloomAdd = bloomAdd;
            this.origBlend = origBlend;
        }

        public void Setup(RenderTargetIdentifier source)
        {
            this.source = source;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(tag);
            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            opaqueDesc.depthBufferBits = 0;
            
            cmd.GetTemporaryRT(tempCopyString, opaqueDesc, FilterMode.Bilinear);
            cmd.CopyTexture(source, tempCopy);

            cmd.SetGlobalFloat(blurAmountString, blurAmount);
            cmd.SetGlobalFloat(blAmountString, bloomAmount);
            cmd.SetGlobalFloat(blThresholdString, bloomThreshold);
            cmd.SetGlobalFloat(blAddString, bloomAdd);
            cmd.SetGlobalFloat(orBString, origBlend); 

            cmd.GetTemporaryRT(blurTempString, Screen.width / 4, Screen.height / 4, 0, FilterMode.Bilinear);
            cmd.GetTemporaryRT(blurTemp1String, Screen.width / 8, Screen.height / 8, 0, FilterMode.Bilinear);
            cmd.GetTemporaryRT(blurTexString, Screen.width / 4, Screen.height / 4, 0, FilterMode.Bilinear);

            Blit(cmd, tempCopy, blurTemp, material, 0);
            Blit(cmd, blurTemp, blurTemp1, material, 1);
            Blit(cmd, blurTemp1, blurTex, material, 1);            
            cmd.Blit(tempCopy, source, material, 2);
            
            context.ExecuteCommandBuffer(cmd);

            cmd.SetGlobalTexture("_ResultTex", tempCopy);

            CommandBufferPool.Release(cmd);
        }
        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(tempCopyString);
            cmd.ReleaseTemporaryRT(blurTempString);
            cmd.ReleaseTemporaryRT(blurTemp1String);
            cmd.ReleaseTemporaryRT(blurTexString);
        }


    }

}