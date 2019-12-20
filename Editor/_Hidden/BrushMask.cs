using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
namespace UnityEditor.Rendering.Funcy.LWRP.ShaderGUI
{
    internal class BrushMask : BaseFuncyShaderGUI
    {
        MaterialProperty brushColor { get; set; }        

        bool drawBaseMap = false;
        void FindProperties()
        {
            brushColor = FindProperty("_BrushColor", props);            
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

            materialEditor.ShaderProperty(brushColor, brushColor.displayName);

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