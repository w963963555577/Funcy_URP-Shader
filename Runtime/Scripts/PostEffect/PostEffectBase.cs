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
        //context.command.Blit(context.source, context.destination,sheet);        
    }
}