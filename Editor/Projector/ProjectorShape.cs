using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
namespace UnityEditor.Rendering.Funcy.LWRP.ShaderGUI
{
    internal class ProjectorShape : BaseFuncyShaderGUI
    {
        MaterialProperty color { get; set; }
        MaterialProperty circleSector { get; set; }
        MaterialProperty rectangle { get; set; }

        MaterialProperty circleAngle { get; set; }
        MaterialProperty thickness { get; set; }
        MaterialProperty rectangleWidth { get; set; }
        MaterialProperty rectangleHeight { get; set; }
        MaterialProperty rectanglePivot { get; set; }
        MaterialProperty falloff { get; set; }

        MaterialProperty projectionAngleDiscardThreshold { get; set; }
        MaterialProperty projectionAngleDiscardEnable { get; set; }

        public ShapeType shapeType = ShapeType.CircleSector;
        public enum ShapeType {None, CircleSector, Rectangle }

        bool drawBaseMap = false;
        void FindProperties()
        {
            color = FindProperty("_Color", props);
            circleSector = FindProperty("_CircleSector", props);
            rectangle = FindProperty("_Rectangle", props);

            circleAngle = FindProperty("_CircleAngle", props);
            thickness = FindProperty("_Thickness", props);
            rectangleWidth = FindProperty("_RectangleWidth", props);
            rectangleHeight = FindProperty("_RectangleHeight", props);
            rectanglePivot = FindProperty("_RectanglePivot", props);
            falloff = FindProperty("_Falloff", props);
            projectionAngleDiscardThreshold = FindProperty("_ProjectionAngleDiscardThreshold", props);
            projectionAngleDiscardEnable = FindProperty("_ProjectionAngleDiscardEnable", props);            
        }

        [SerializeField]Transform lightTransform, lightTransfrom_Tmp; 
        public override void OnEnable()
        {            
            EditorApplication.update += materialEditor.Repaint;
        }
        public override void OnClosed(Material material)
        {
            base.OnClosed(material);
            EditorApplication.update -= materialEditor.Repaint;
        }
        ShapeType SetShapeType(Material mat)
        {      
            bool circleSectorOn = Array.IndexOf(mat.shaderKeywords, "_CircleSector") != -1;
            bool rectangleOn = Array.IndexOf(mat.shaderKeywords, "_Rectangle") != -1;

            if (circleSectorOn && !rectangleOn)
            {                
                return ShapeType.CircleSector;
            }
            else if (!circleSectorOn && rectangleOn)
            {                
                return ShapeType.Rectangle;
            }
            else
            {                
                return ShapeType.None;
            }
        }
        void GetShapeType(Material mat)
        {            
            if (shapeType == ShapeType.CircleSector)
            {
                mat.EnableKeyword("_CircleSector");                
                mat.DisableKeyword("_Rectangle");
            }
            if (shapeType == ShapeType.Rectangle)
            {
                mat.DisableKeyword("_CircleSector");
                mat.EnableKeyword("_Rectangle");
            }
            if (shapeType == ShapeType.None)
            {
                mat.DisableKeyword("_CircleSector");
                mat.DisableKeyword("_Rectangle");
            }
        }
        public override void OnMaterialGUI()
        {
            FindProperties();
            Material mat = (Material)materialEditor.target;
            mat.enableInstancing = true;
            EditorGUI.BeginChangeCheck();
            shapeType = SetShapeType(mat);
            shapeType = (ShapeType)EditorGUILayout.EnumPopup("Shape Type", shapeType);
            GetShapeType(mat);

            bool circleSectorOn = Array.IndexOf(mat.shaderKeywords, "_CircleSector") != -1;
            bool rectangleOn = Array.IndexOf(mat.shaderKeywords, "_Rectangle") != -1;

            DrawArea("Base", () => {
                materialEditor.ShaderProperty(color, color.displayName);
                materialEditor.ShaderProperty(falloff, falloff.displayName);
                materialEditor.EnableInstancingField();
            });

            if (circleSectorOn)
                DrawArea("Circle And Sector", () =>
                {
                    materialEditor.ShaderProperty(circleAngle, "Angle");
                    materialEditor.ShaderProperty(thickness, "Thickness");
                });


            if (rectangleOn)
                DrawArea("Rectangle", () =>
                {                                        
                    materialEditor.ShaderProperty(rectangleWidth, "Width");
                    materialEditor.ShaderProperty(rectangleHeight, "Height");
                    materialEditor.ShaderProperty(rectanglePivot, "Pivot");
                });

            
            MaterialChangeCheck();
        }

        public override void MaterialChanged(Material material)
        {
            
        }
    }
}