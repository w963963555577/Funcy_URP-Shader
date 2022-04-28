using System.Collections.Generic;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;
using UnityEngine.Scripting.APIUpdating;
using UnityEngine;

public enum RenderQueueType
{
    Opaque,
    Transparent,
}
public class MRTPass : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {        
        public RenderPassEvent Event = RenderPassEvent.AfterRenderingOpaques;
        public FilterSettings filterSettings = new FilterSettings();
        public List<string> MRTNames = new List<string>();
        public RenderQueueRange renderQueueRange;
        public RenderTextureFormat mrtFormat = RenderTextureFormat.ARGBHalf;
        [HideInInspector][Range(1, 16)] public int downSample = 1;/*Hide Because MRT with downsample seems not working.*/
        public RenderObjectType renderObjectType = RenderObjectType.Opaque;
        public enum RenderObjectType { Opaque, Transparent, All }
        public Vector2Int limitQueueRange = new Vector2Int(2000, 3000);
        [Header("Clear RT Color Before Rendering")]
        public bool clear = false;
        [ColorUsage(true, true)] public Color clearColor = Color.black;
    }

    [System.Serializable]
    public class FilterSettings
    {        
        public LayerMask LayerMask;
        public string[] lightModes;

        public FilterSettings()
        {            
            LayerMask = 0;
        }
    }    

    public Settings settings = new Settings();
    
    public class Pass : ScriptableRenderPass
    {
        Settings settings;
        RenderQueueType renderQueueType;
        FilteringSettings m_FilteringSettings;
        string m_ProfilerTag;
        ProfilingSampler m_ProfilingSampler;
        
        List<ShaderTagId> m_ShaderTagIdList = new List<ShaderTagId>();
        RenderStateBlock m_RenderStateBlock;
        RenderTargetIdentifier colorTarget, depthTarget;
        RenderTargetHandle[] m_MRTs;
        RenderTargetIdentifier[] _mrt;
        public void InitTargets(RenderTargetIdentifier colorTarget, RenderTargetIdentifier depthTarget)
        {
            this.colorTarget = colorTarget;
            this.depthTarget = depthTarget;
        }
        public Pass(string profilerTag, Settings settings)
        {
            this.settings = settings;
            m_ProfilerTag = profilerTag;
            m_ProfilingSampler = new ProfilingSampler(profilerTag);
            this.renderPassEvent = settings.Event;            

            var shaderTags = settings.filterSettings.lightModes;
            
            m_FilteringSettings = new FilteringSettings(settings.renderQueueRange, settings.filterSettings.LayerMask);

            if (shaderTags != null && shaderTags.Length > 0)
            {
                foreach (var passName in shaderTags)
                    m_ShaderTagIdList.Add(new ShaderTagId(passName));
            }
            
            m_RenderStateBlock = new RenderStateBlock(RenderStateMask.Nothing);

            _mrt = new RenderTargetIdentifier[1 + settings.MRTNames.Count];
            m_MRTs = new RenderTargetHandle[settings.MRTNames.Count];
            for (int i = 0; i < settings.MRTNames.Count; i++)
            {
                m_MRTs[i].Init(settings.MRTNames[i]);
            }
        }
        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            var desc = new RenderTextureDescriptor(cameraTextureDescriptor.width, cameraTextureDescriptor.height, settings.mrtFormat, 0);            
            _mrt[0] = colorTarget;
            
            for (int i = 0; i < settings.MRTNames.Count; i++)
            {
                cmd.GetTemporaryRT(m_MRTs[i].id, desc);
                _mrt[i + 1] = m_MRTs[i].Identifier();
            }
            ConfigureTarget(_mrt, depthTarget);
        }
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            SortingCriteria sortingCriteria = (settings.renderObjectType == Settings.RenderObjectType.Opaque)
                ? renderingData.cameraData.defaultOpaqueSortFlags
                : SortingCriteria.CommonTransparent;
            //Debug.Log(string.Format("preview:{0}, sceneView:{1}, gameView:{2}", renderingData.cameraData.isPreviewCamera, renderingData.cameraData.isSceneViewCamera, renderingData.cameraData.isDefaultViewport));
            if (renderingData.cameraData.isPreviewCamera) return;
            DrawingSettings drawingSettings = CreateDrawingSettings(m_ShaderTagIdList, ref renderingData, sortingCriteria);

            ref CameraData cameraData = ref renderingData.cameraData;
            Camera camera = cameraData.camera;

            CommandBuffer cmd = CommandBufferPool.Get(m_ProfilerTag);


            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                if (RenderSettings.skybox && settings.clear) 
                {
                    //cmd.ClearRenderTarget(true, true, settings.clearColor);
                    var currentActive = RenderTexture.active;
                    foreach(var mrt in m_MRTs)
                    {
                        RenderTexture.active = (RenderTexture)Shader.GetGlobalTexture(mrt.id);
                        GL.Clear(true, true, settings.clearColor, 0.0f);
                    }
                    RenderTexture.active = currentActive;
                }

                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref m_FilteringSettings, ref m_RenderStateBlock);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            for (int i = 0; i < settings.MRTNames.Count; i++)
            {
                cmd.ReleaseTemporaryRT(m_MRTs[i].id);
            }
        }
    }
    
    Pass pass;

    public override void Create()
    {
        FilterSettings filter = settings.filterSettings;
        switch (settings.renderObjectType)
        {
            case Settings.RenderObjectType.Transparent:
                settings.renderQueueRange = RenderQueueRange.transparent;
                break;
            case Settings.RenderObjectType.Opaque:
                settings.renderQueueRange = RenderQueueRange.opaque;
                break;
            default:
                settings.renderQueueRange = RenderQueueRange.all;
                break;
        }
        settings.renderQueueRange.lowerBound = settings.limitQueueRange.x;
        settings.renderQueueRange.upperBound = settings.limitQueueRange.y;
        pass = new Pass(name, settings);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        pass.InitTargets(renderer.cameraColorTarget, renderer.cameraDepth);        
        renderer.EnqueuePass(pass);
    }
}


