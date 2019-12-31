using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
namespace UnityEditor.Rendering.Funcy.LWRP.ShaderGUI
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

        public class EditorMouseEvent
        {
            public static Vector2 mouseDetla;
            static Vector2 mouseDownPoint;

            public static bool isMousePress = false;
            static bool mousePressTmp = false;
            public static void GetMousePress(Event e, out Vector2 downPoint)
            {
                downPoint = Vector2.zero;
                if (e.type == EventType.MouseDown && e.button == 0)
                {
                    isMousePress = true;
                }
                if (e.type == EventType.MouseUp && e.button == 0)
                {
                    isMousePress = false;
                    mouseDetla = Vector2.zero;
                }

                if (mousePressTmp != isMousePress)
                {
                    mousePressTmp = isMousePress;
                    mouseDownPoint = e.mousePosition;
                    downPoint = mouseDownPoint;
                }

                if (isMousePress)
                {
                    mouseDetla = e.mousePosition - mouseDownPoint;
                }
            }
        }


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
        MaterialProperty reflectMap { get; set; }
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
                materialEditor.ShaderProperty(specularColor, specularColor.displayName);
                materialEditor.ShaderProperty(specular, specular.displayName);

            });

            DrawArea("Foam & Wave", () => {
                materialEditor.TexturePropertyTwoLines("Map".ToGUIContent(), foamMap, foamScale, "Color".ToGUIContent(), foamColor);
                materialEditor.ShaderProperty(waveSpeed, waveSpeed.displayName);
                RadiusSlider(waveDirection);

            });

            DrawArea("Depth",()=> {
                materialEditor.ShaderProperty(depth, depth.displayName);
                materialEditor.ShaderProperty(depthArea, depthArea.displayName);
                materialEditor.ShaderProperty(depthHard, depthHard.displayName);

            });

            //base.OnMaterialGUI();

            MaterialChangeCheck();
        }

        void RadiusSlider(MaterialProperty materialProperty)
        {
            KeyEvent();
            var e = Event.current;
            var clearStyle = new GUIStyle();
            float angle = materialProperty.floatValue;

            Vector2 mouseDownPoint;
            EditorMouseEvent.GetMousePress(e, out mouseDownPoint);

            Vector2 forward = new Vector2(Mathf.Cos(angle * π / 180f), Mathf.Sin(angle * π / 180f));

            GUILayout.Box(new GUIContent(RadiusSliderBK), clearStyle, GUILayout.Width(100), GUILayout.Height(100));

            var laseRect = GUILayoutUtility.GetLastRect();

            Vector2 center = new Vector2(laseRect.x + laseRect.size.x / 2f, laseRect.y + laseRect.size.y / 2f);
            GUI.Label(new Rect(center - new Vector2(35, 45), new Vector2(100, 100)), "    Press\n【LeftCtrl】\n   to Step");

            Vector2 current = center - new Vector2(6, 6) - forward * 49f;

            if (PointInRect(e.mousePosition, laseRect) && EditorMouseEvent.isMousePress)
            {

                Vector2 vector = (e.mousePosition - center).normalized;
                angle = Vector2.SignedAngle(new Vector2(1, 0), vector) + 180;
                if (Key.LeftControl)
                {
                    angle = Mathf.Floor(angle);
                    float addVal = 45f - (angle % 45f);
                    angle += addVal;
                }
                materialProperty.floatValue = angle;
            }


            GUI.Button(new Rect(current, new Vector2(20, 20)), EditorGUIUtility.IconContent("d_winbtn_mac_inact"), clearStyle);

            GUILayout.Space(10);

            HandleUtility.Repaint();
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