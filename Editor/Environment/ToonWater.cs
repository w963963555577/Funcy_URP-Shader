using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
namespace UnityEditor.Rendering.Funcy.URP.ShaderGUI
{
    internal class ToonWater : BaseFuncyShaderGUI
    {
        const float π = 3.1415926535f;
        Texture2D RadiusSliderBK;
        #region KeyEvent
        public Key key = new Key();
        [Serializable]
        public class Key
        {
            public static bool LeftControl = false;
            public static bool LeftAlt = false;
        }


        void KeyEvent()
        {
            GetKey(KeyCode.LeftControl);
            GetKey(KeyCode.LeftAlt);

        }
        void GetKey(KeyCode keyCode)
        {
            var e = Event.current;

            if (e != null)
            {
                if (e.type == EventType.KeyDown)
                {
                    if (e.keyCode == keyCode) key.GetType().GetField(keyCode.ToString()).SetValue(key, true);
                }
                if (e.type == EventType.KeyUp)
                {
                    if (e.keyCode == keyCode) key.GetType().GetField(keyCode.ToString()).SetValue(key, false);
                }
            }
            HandleUtility.Repaint();
        }
        #endregion KeyEvent



        MaterialProperty color { get; set; } 
        MaterialProperty colorFar { get; set; }
        MaterialProperty normalMap { get; set; }
        MaterialProperty refractionScale { get; set; }
        MaterialProperty refractionIntensity { get; set; }
        MaterialProperty waveSpeed { get; set; }
        MaterialProperty waveDirection { get; set; }
        MaterialProperty foamColor { get; set; }
        MaterialProperty foamMap { get; set; }
        MaterialProperty foamScale { get; set; }
        MaterialProperty reflection { get; set; }
        MaterialProperty specular { get; set; }
        MaterialProperty specularColor { get; set; }
        MaterialProperty reflectRampMap { get; set; }
        MaterialProperty depth { get; set; }
        MaterialProperty depthArea { get; set; }
        MaterialProperty depthHard { get; set; }
        


        bool drawBaseMap = false;
        void FindProperties()
        {
            color = FindProperty("_Color", props);
            colorFar = FindProperty("_ColorFar", props);

            normalMap = FindProperty("_NormalMap", props);
            refractionScale = FindProperty("_RefractionScale", props);
            refractionIntensity = FindProperty("_RefractionIntensity", props);

            reflection = FindProperty("_Reflection", props);
            reflectRampMap = FindProperty("_RampMap", props);
            specularColor = FindProperty("_SpecularColor", props);
            specular = FindProperty("_Specular", props);

            foamColor = FindProperty("_FoamColor", props);
            foamMap = FindProperty("_FoamMap", props);
            foamScale = FindProperty("_FoamScale", props);
            waveSpeed = FindProperty("_WaveSpeed", props);
            waveDirection = FindProperty("_WaveDirection", props);

            
            depth = FindProperty("_Depth", props);
            depthArea = FindProperty("_DepthArea", props);
            depthHard = FindProperty("_DepthHard", props);
            
        }
        public override void OnEnable()
        {            
            EditorApplication.update += materialEditor.Repaint;

            RadiusSliderBK = Resources.Load("RadiusSliderBK") as Texture2D;
            
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
            
            DrawArea("Base Color", () => {
                materialEditor.ShaderProperty(color, color.displayName);
                materialEditor.ShaderProperty(colorFar, colorFar.displayName);
            });

            DrawArea("Refraction & Reflection", () =>
            {
                materialEditor.TexturePropertyTwoLines("Map".ToGUIContent(), normalMap, refractionScale, "Intensity".ToGUIContent(), refractionIntensity);
                materialEditor.ShaderProperty(reflection, reflection.displayName);
                materialEditor.TexturePropertySingleLine(reflectRampMap.displayName.ToGUIContent(), reflectRampMap);
                materialEditor.ShaderProperty(specularColor, specularColor.displayName);
                materialEditor.ShaderProperty(specular, specular.displayName);
                
            });

            DrawArea("Foam & Wave", () => {
                materialEditor.TexturePropertyTwoLines("Map".ToGUIContent(), foamMap, foamScale, "Color".ToGUIContent(), foamColor);
                materialEditor.ShaderProperty(waveSpeed, waveSpeed.displayName);                
                materialEditor.ShaderProperty(waveDirection, waveDirection.displayName);

            });

            DrawArea("Depth",()=> {
                materialEditor.ShaderProperty(depth, depth.displayName);
                materialEditor.ShaderProperty(depthArea, depthArea.displayName);
                materialEditor.ShaderProperty(depthHard, depthHard.displayName);

            });

            //base.OnMaterialGUI();

            MaterialChangeCheck();
        }

        
        bool PointInRect(Vector2 point, Rect rect)
        {
            Vector2 min = rect.position;
            Vector2 max = rect.position + rect.size;

            bool result = point.x >= min.x && point.y > min.y && point.x <= max.x && point.y <= max.y;

            return result;
        }


        public override void MaterialChanged(Material material)
        {
            if (material == null)
                return;
        }
    }
}