//see README here: https://github.com/ColinLeung-NiloCat/UnityURP-MobileScreenSpacePlanarReflection

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using System.Reflection;

#if UNITY_EDITOR
using UnityEditor.SceneManagement;
#endif
public class GlobalFogs : ScriptableRendererFeature
{        
    [System.Serializable]
    public class PassSettings
    {
        [System.NonSerialized] public bool isActive = false;
        [System.NonSerialized] public Vector3 worldPosition = Vector3.zero;
        [System.NonSerialized] public float distance = 999.0f;
        [System.NonSerialized] public Color color = new Color(0.5754717f, 0.01390948f, 0.0f, 0.0f);
        public Texture2D noiseMap;
        public float mapScale = 1.0f;
    }
    public PassSettings Settings = new PassSettings();

    public class CustomRenderPass : ScriptableRenderPass
    {        
        PassSettings settings;
        
        public CustomRenderPass(PassSettings settings)
        {
            this.settings = settings;
        }


        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in an performance manner.
        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {

        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cb = CommandBufferPool.Get("GlobalFogs");
            cb.SetGlobalVector("_WorldPoint", new Vector4(settings.worldPosition.x, settings.worldPosition.y, settings.worldPosition.z, 1.0f / settings.distance));
            cb.SetGlobalColor("_GlobalFogColor", settings.color);
            cb.SetGlobalFloat("_GlobalFogNoiseScale", 1.0f / settings.mapScale);
            cb.SetGlobalTexture("_GlobalFogNoise", settings.noiseMap);
            if (settings.isActive)
            {
                Shader.SetGlobalFloat("_GlobalFogEnabled", 1.0f);
            }
            else
            {
                Shader.SetGlobalFloat("_GlobalFogEnabled", 0.0f);
            }
            context.ExecuteCommandBuffer(cb);
            CommandBufferPool.Release(cb);

        }

        /// Cleanup any allocated resources that were created during the execution of this render pass.
        public override void FrameCleanup(CommandBuffer cmd)
        {
          
        }
    }

    CustomRenderPass m_ScriptablePass;

    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass(Settings);


        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;//we must wait _CameraOpaqueTexture & _CameraDepthTexture is usable
        
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


