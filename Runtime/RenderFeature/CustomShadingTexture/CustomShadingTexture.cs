
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustomShadingTexture : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public LayerMask layerMask;
        public Shader shader;
        public string drawLightModel = "UniversalForward";
        public string sampleTextureName = "_CustomMap";        
    }

    public Settings settings = new Settings();

    internal class Pass : ScriptableRenderPass
    {
        Settings settings;
        private RenderTargetHandle destination;

        private Material material = null;
        private FilteringSettings m_FilteringSettings;
        ShaderTagId m_ShaderTagId ;
        string tag;

        public Pass(RenderQueueRange renderQueueRange, Settings set, Material material, string tag)
        {
            settings = set;
            m_FilteringSettings = new FilteringSettings(renderQueueRange, set.layerMask);
            this.material = material;
        }

        public void Setup(RenderTargetHandle destination)
        {
            this.destination = destination;
            m_ShaderTagId = new ShaderTagId(settings.drawLightModel);
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

            drawSettings.overrideMaterial = material;

            context.DrawRenderers(renderingData.cullResults, ref drawSettings, ref m_FilteringSettings);


            cmd.SetGlobalTexture(settings.sampleTextureName, destination.id);

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


    Pass pass;
    RenderTargetHandle texture;
    Material material;

    public override void Create()
    {
        material = CoreUtils.CreateEngineMaterial(settings.shader);
        pass = new Pass(RenderQueueRange.opaque, settings, material, this.name);
        pass.renderPassEvent = RenderPassEvent.AfterRenderingPrePasses;
        texture.Init(settings.sampleTextureName);
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        pass.Setup(texture);
        renderer.EnqueuePass(pass);
    }
}

