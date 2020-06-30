using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace UnityEditor.Rendering.Funcy.LWRP.ShaderGUI
{
    [InitializeOnLoad]
    internal class ZDCharacter_DoubleFace : ZDCharacter
    {
        public MaterialProperty detalMap { get; set; }
        public override void FindProperties()
        {
            detalMap = FindProperty("_diffuseDetal", props);
            base.FindProperties();
        }
        public override void BaseArea(Material mat)
        {
            materialEditor.TexturePropertySingleLine(baseMap.displayName.ToGUIContent(), baseMap, baseColor);

            materialEditor.TexturePropertySingleLine(detalMap.displayName.ToGUIContent(), detalMap);
            materialEditor.TexturePropertySingleLine(maskMap.displayName.ToGUIContent(
                string.Format("{0} \n\n{1} \n\n{2} \n\n{3}",
                "R= Emission Mask\n(發光遮罩)",
                "G= Shadow Refraction\n(陰影速率(折射))",
                "B= Specular Mask\n(反光遮罩)",
                "A= Gloss\n(光滑遮罩)")
                ), maskMap);


            materialEditor.TexturePropertySingleLine(selfMask.displayName.ToGUIContent(
                string.Format("{0} \n\n{1} \n\n{2} \n\n{3}",
                "R= Face Lightmap\n(臉部光影走向)",
                "G= Using Lignt UVChanel Mask\n( R 通道用的 UV Chanel)\n黑色=uv1,白色=uv2",
                "B= Self Shadow Mask\n(自投影遮罩)\n黑色=不顯示,白色=顯示",
                "A= Discoloration Area\n(變色遮罩)")
                ), selfMask);

            if (selfMask.textureValue != null)
            {
                materialEditor.ShaderProperty(selfMaskDirection, selfMaskDirection.displayName.ToGUIContent());
                selfMaskEnb.floatValue = 1.0f;
                mat.EnableKeyword("_SelfMaskEnable");
            }
            else
            {
                selfMaskDirection.floatValue = 0;
                selfMaskEnb.floatValue = 0.0f;
                mat.DisableKeyword("_SelfMaskEnable");
            }
        }
    }
}