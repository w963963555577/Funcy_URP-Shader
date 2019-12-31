using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(GrayscaleRenderer), PostProcessEvent.AfterStack, "Funcy/PostEffectTest")]
public sealed class Grayscale : PostProcessEffectSettings
{

}

public sealed class GrayscaleRenderer : PostProcessEffectRenderer<Grayscale>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Funcy/TestPostEffect"));
        var buffer = RenderTexture.GetTemporary(context.width/10, context.height/10);
        context.command.Blit(context.source, buffer);        
    }
}