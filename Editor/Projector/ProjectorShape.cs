using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
namespace UnityEditor.Rendering.Funcy.URP.ShaderGUI
{
    internal class ProjectorShape : BaseFuncyShaderGUI
    {
        MaterialProperty color { get; set; }
        MaterialProperty amount { get; set; }
        MaterialProperty circleSector { get; set; }
        MaterialProperty rectangle { get; set; }

        MaterialProperty circleAngle { get; set; }
        MaterialProperty thickness { get; set; }
        MaterialProperty rectangleWidth { get; set; }
        MaterialProperty rectangleHeight { get; set; }
        MaterialProperty rectanglePivot { get; set; }
        MaterialProperty falloff { get; set; }

        
        

        public ShapeType shapeType = ShapeType.CircleSector;
        public enum ShapeType {None, CircleSector, Rectangle }

        bool drawBaseMap = false;
        void FindProperties()
        {
            color = FindProperty("_Color", props);
            amount = FindProperty("_Amount", props);
            circleSector = FindProperty("_CircleSector", props);
            rectangle = FindProperty("_Rectangle", props);

            circleAngle = FindProperty("_CircleAngle", props);
            thickness = FindProperty("_Thickness", props);
            rectangleWidth = FindProperty("_RectangleWidth", props);
            rectangleHeight = FindProperty("_RectangleHeight", props);
            rectanglePivot = FindProperty("_RectanglePivot", props);
            falloff = FindProperty("_Falloff", props);            
            
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
            bool circleSectorOn = mat.GetFloat("_CircleSector") == 1.0f;
            bool rectangleOn = mat.GetFloat("_Rectangle") == 1.0f;

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
                mat.SetFloat("_CircleSector", 1.0f);
                mat.SetFloat("_Rectangle", 0.0f);                
            }
            if (shapeType == ShapeType.Rectangle)
            {
                mat.SetFloat("_CircleSector", 0.0f);
                mat.SetFloat("_Rectangle", 1.0f);
            }
            if (shapeType == ShapeType.None)
            {
                mat.SetFloat("_CircleSector", 0.0f);
                mat.SetFloat("_Rectangle", 0.0f);
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

            bool circleSectorOn = mat.GetFloat("_CircleSector") == 1.0f;
            bool rectangleOn = mat.GetFloat("_Rectangle") == 1.0f;


            DrawArea("Base", () => {
                materialEditor.ShaderProperty(color, color.displayName);
                materialEditor.ShaderProperty(falloff, falloff.displayName);
                materialEditor.ShaderProperty(amount, amount.displayName);
                
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