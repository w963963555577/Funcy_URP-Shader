
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustomShadingTexture : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public LayerMask layerMask;
        public Material material;
        public string drawLightModel = "UniversalForward";
        public string sampleTextureName = "_CustomMap";
        public FilterMode filterMode = FilterMode.Point;
        [Range(1, 10)] public int downSample = 1;

        public RenderObjectType renderObjectType = RenderObjectType.Opaque;
        public enum RenderObjectType { Opaque, Transparent, All }
        public RenderQueueRange renderQueueRange;
        public Vector2Int limitQueueRange = new Vector2Int(3000, 3000);

    }

    public Settings settings = new Settings();

    internal class Pass : ScriptableRenderPass
    {
        Settings settings;
        private RenderTargetHandle destination;

        private Material material = null;
        private FilteringSettings m_FilteringSettings;
        ShaderTagId m_ShaderTagId;
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
            descriptor.width /=  settings.downSample;
            descriptor.height /= settings.downSample;
            cmd.GetTemporaryRT(destination.id, descriptor, settings.filterMode);
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

            if(material)
            {
                drawSettings.overrideMaterial = material;
                drawSettings.enableInstancing = material.enableInstancing;
            }
            
            drawSettings.enableDynamicBatching = true; // default value is true. please change it before draw call if needed.            
            drawSettings.enableDynamicBatching = renderingData.supportsDynamicBatching;

            
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

    public override void Create()
    {
        RenderQueueRange queueRange;
        switch (settings.renderObjectType)
        {
            case Settings.RenderObjectType.Transparent:
                queueRange = RenderQueueRange.transparent;
                break;
            case Settings.RenderObjectType.Opaque:
                queueRange = RenderQueueRange.opaque;
                break;
            default:
                queueRange = RenderQueueRange.all;
                break;
        }
        queueRange.lowerBound = settings.limitQueueRange.x;
        queueRange.upperBound = settings.limitQueueRange.y;
        

        pass = new Pass(queueRange, settings, settings.material, this.name);
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

