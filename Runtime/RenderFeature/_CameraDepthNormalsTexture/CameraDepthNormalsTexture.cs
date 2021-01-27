
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CameraDepthNormalsTexture : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public LayerMask layerMask;        
    }

    public Settings settings = new Settings();

    internal class Pass : ScriptableRenderPass
    {
        private RenderTargetHandle destination;

        private Material depthNormalsMaterial = null;
        private FilteringSettings m_FilteringSettings;
        ShaderTagId m_ShaderTagId ;
        string tag;

        public Pass(RenderQueueRange renderQueueRange, LayerMask layerMask, Material material, string tag)
        {
            m_FilteringSettings = new FilteringSettings(renderQueueRange, layerMask);
            this.depthNormalsMaterial = material;
        }

        public void Setup(RenderTargetHandle destination)
        {
            this.destination = destination;
            m_ShaderTagId = new ShaderTagId("UniversalForward");
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            RenderTextureDescriptor descriptor = cameraTextureDescriptor;
            descriptor.depthBufferBits = 32;
            descriptor.colorFormat = RenderTextureFormat.ARGB32;

            cmd.GetTemporaryRT(destination.id, descriptor, FilterMode.Point);
            ConfigureTarget(destination.Identifier());
            ConfigureClear(ClearFlag.All, Color.black);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(tag);

            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            var sortFlags = renderingData.cameraData.defaultOpaqueSortFlags;
            var drawSettings = CreateDrawingSettings(m_ShaderTagId, ref renderingData, sortFlags);
            drawSettings.perObjectData = PerObjectData.None;

            var cameraData = renderingData.cameraData;
            Camera camera = cameraData.camera;

            if (cameraData.isStereoEnabled)
            {
                context.StartMultiEye(camera);
            }

            drawSettings.overrideMaterial = depthNormalsMaterial;

            context.DrawRenderers(renderingData.cullResults, ref drawSettings, ref m_FilteringSettings);


            cmd.SetGlobalTexture("_CameraDepthNormalsTexture", destination.id);

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            if (destination != RenderTargetHandle.CameraTarget)
            {
                cmd.ReleaseTemporaryRT(destination.id);
                destination = RenderTargetHandle.CameraTarget;
            }
        }
    }


    Pass depthNormalsPass;
    RenderTargetHandle depthNormalsTexture;
    Material depthNormalsMaterial;

    public override void Create()
    {
        depthNormalsMaterial = CoreUtils.CreateEngineMaterial("Hidden/Renderfeature/DepthNormal");
        depthNormalsPass = new Pass(RenderQueueRange.opaque, settings.layerMask, depthNormalsMaterial, this.name);
        depthNormalsPass.renderPassEvent = RenderPassEvent.AfterRenderingPrePasses;
        depthNormalsTexture.Init("_CameraDepthNormalsTexture");
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        depthNormalsPass.Setup(depthNormalsTexture);
        renderer.EnqueuePass(depthNormalsPass);
    }
}

