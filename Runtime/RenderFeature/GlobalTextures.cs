
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


public class GlobalTextures : ScriptableRendererFeature
{
    [System.Serializable]
    public class Map
    {
        public string name = "";
        public Texture targetMap;        
    }

    [System.Serializable]
    public class Settings
    {
        public List<Map> maps = new List<Map>();

    }

    public Settings settings = new Settings();

    class Pass : ScriptableRenderPass
    {
        Settings settings;

        string tag;

        public Pass(Settings settings, string tag)
        {
            this.settings = settings;
            this.tag = tag;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(tag);

            foreach (var m in settings.maps)
            {
                cmd.SetGlobalTexture(m.name, m.targetMap);
            }

            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            CommandBufferPool.Release(cmd);
        }
    }

    Pass pass;


    public override void Create()
    {
        pass = new Pass(settings, this.name);
        pass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;

        if (!isActive)
        {
            foreach (var m in settings.maps)
            {
                Shader.SetGlobalTexture(m.name, null);
            }
        }        
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {        
        renderer.EnqueuePass(pass);
    }


}
