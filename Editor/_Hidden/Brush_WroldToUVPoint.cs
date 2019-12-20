using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
namespace UnityEditor.Rendering.Funcy.LWRP.ShaderGUI
{
    internal class Brush_WroldToUVPoint : BaseFuncyShaderGUI
    {
        MaterialProperty brushHardness { get; set; }
        MaterialProperty brushSize { get; set; }

        bool drawBaseMap = false;
        void FindProperties()
        {
            brushHardness = FindProperty("_BrushHardness", props);
            brushSize = FindProperty("_BrushSize", props);
        }
        public override void OnEnable()
        {            
            EditorApplication.update += materialEditor.Repaint;
        }
        public override void OnClosed(Material material)
        {
            base.OnClosed(material);
            EditorApplication.update -= materialEditor.Repaint;
        }
        public override void OnMaterialGUI()
        {
            FindProperties();

            EditorGUI.BeginChangeCheck();

            materialEditor.ShaderProperty(brushSize, brushSize.displayName);
            materialEditor.ShaderProperty(brushHardness, brushHardness.displayName);

            if (EditorGUI.EndChangeCheck())
            {
                foreach (var obj in materialEditor.targets)
                    MaterialChanged((Material)obj);
                
            }
        }

        public override void MaterialChanged(Material material)
        {
            if (material == null)
                return;

            Debug.Log("Change");
        }
    }
}