﻿using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.Mathematics;
using UnityEditor;
using UnityEngine;

namespace UnityEditor.Rendering.Funcy.LWRP.ShaderGUI
{
    [InitializeOnLoad]
    internal class ZDCharacter : BaseFuncyShaderGUI
    {
        static List<Material> zdCharacterMaterials = new List<Material>();
        static ZDCharacter()
        {
            EditorApplication.delayCall += () => {
                EditorApplication.update += () => {
                    zdCharacterMaterials = Resources.FindObjectsOfTypeAll<Material>().ToList().FindAll(m => m.shader == Shader.Find("ZDShader/LWRP/Character"));
                };
            };
        }

        #region Properties
        MaterialProperty diffuse { get; set; }
        MaterialProperty color { get; set; }

        MaterialProperty subsurfaceScattering { get; set; }
        MaterialProperty subsurfaceRadius { get; set; }
        

        MaterialProperty selfMaskDirection { get; set; }

        MaterialProperty mask { get; set; }
        MaterialProperty flash { get; set; }

        MaterialProperty edgeLightWidth { get; set; }
        MaterialProperty edgeLightIntensity { get; set; }
        

        MaterialProperty emissionColor { get; set; }
        MaterialProperty emissionxBase { get; set; }
        MaterialProperty emissionOn { get; set; }
        MaterialProperty emissionFlow { get; set; }
        MaterialProperty gloss { get; set; }
        MaterialProperty specularColor { get; set; }
        MaterialProperty shadowRamp { get; set; }
        MaterialProperty selfShadowRamp { get; set; }


        MaterialProperty outlineEnable { get; set; }
        MaterialProperty outlineWidthControl { get; set; }

        MaterialProperty picker_0 { get; set; }
        MaterialProperty shadowColor0 { get; set; }
        MaterialProperty picker_1 { get; set; }
        MaterialProperty shadowColor1 { get; set; }
        MaterialProperty shadowColorElse { get; set; }

        MaterialProperty customLightColor { get; set; }
        MaterialProperty customLightIntensity { get; set; }


        MaterialProperty receiveShadow { get; set; }
        MaterialProperty selfMask { get; set; }
        MaterialProperty selfMaskEnable { get; set; }
        MaterialProperty shadowRefraction { get; set; }
        MaterialProperty shadowOffset { get; set; }

        MaterialProperty discolorationColor_0 { get; set; }
        MaterialProperty discolorationColor_1 { get; set; }
        MaterialProperty discolorationColor_2 { get; set; }
        MaterialProperty discolorationColor_3 { get; set; }
        MaterialProperty discolorationColor_4 { get; set; }
        MaterialProperty discolorationColor_5 { get; set; }
        MaterialProperty discolorationColor_6 { get; set; }        
        MaterialProperty discolorationColor_7 { get; set; }
        MaterialProperty discolorationColor_8 { get; set; }
        MaterialProperty discolorationColor_9 { get; set; }
        MaterialProperty[] discolorationColorList = new MaterialProperty[10];
        MaterialProperty discolorationSystem { get; set; }
        MaterialProperty discolorationColorCount { get; set; }

        MaterialProperty outlineWidth_MinWidth_MaxWidth_Dist_DistBlur { get; set; }

        MaterialProperty outlineColor { get; set; }
        MaterialProperty diffuseBlend { get; set; }


        public enum ExpressionFormat { Wink, FaceSheet }
        MaterialProperty expressionEnable { get; set; }
        MaterialProperty selectExpressionMap { get; set; }
        MaterialProperty expressionMap { get; set; }
        MaterialProperty expressionQMap { get; set; }
        MaterialProperty expressionFormat_Wink { get; set; }
        MaterialProperty expressionFormat_FaceSheet { get; set; }
        MaterialProperty selectBrow { get; set; }
        MaterialProperty selectFace { get; set; }
        MaterialProperty selectMouth { get; set; }

        MaterialProperty browRect { get; set; }
        MaterialProperty faceRect { get; set; }
        MaterialProperty mouthRect { get; set; }

        MaterialProperty effectiveMap { get; set; }
        MaterialProperty faceLightMapCombineMode { get; set; }
        MaterialProperty floatModel { get; set; }
        MaterialProperty effectiveColor { get; set; }


        MaterialProperty srcBlend { get; set; }
        MaterialProperty dstBlend { get; set; }

        #endregion
        bool drawBaseMap = false;
        public void FindProperties()
        {
            FindProperties(this);
            diffuse = FindProperty("_diffuse", props);
            mask = FindProperty("_mask", props);
           
            discolorationColorList = new MaterialProperty[] {
                discolorationColor_0, discolorationColor_1,discolorationColor_2, discolorationColor_3,
                discolorationColor_4, discolorationColor_5,discolorationColor_6, discolorationColor_7,
                discolorationColor_8,discolorationColor_9
            };           
        }


        public override void OnEnable()
        {            
            EditorApplication.update += materialEditor.Repaint;            
        }
        public override void OnDisable()
        {
            base.OnDisable();
            EditorApplication.update -= materialEditor.Repaint;
            //Debug.Log("Closed");

        }


        public ExpressionFormat format = ExpressionFormat.FaceSheet;

        ExpressionFormat SetExpressionFormat(Material mat)
        {
            bool wink = Array.IndexOf(mat.shaderKeywords, "_ExpressionFormat_Wink") != -1;
            bool facesheet = Array.IndexOf(mat.shaderKeywords, "_ExpressionFormat_FaceSheet") != -1;

            if (facesheet && !wink)
            {
                return ExpressionFormat.FaceSheet;
            }
            else if (!facesheet && wink)
            {
                return ExpressionFormat.Wink;
            }
            else
            {
                mat.EnableKeyword("_ExpressionFormat_FaceSheet");
                mat.DisableKeyword("_ExpressionFormat_Wink");
                return ExpressionFormat.FaceSheet;
            }
        }
        void GetExpressionFormat(Material mat)
        {            
            if (format == ExpressionFormat.FaceSheet)
            {
                mat.EnableKeyword("_ExpressionFormat_FaceSheet");
                mat.DisableKeyword("_ExpressionFormat_Wink");
            }
            if (format == ExpressionFormat.Wink)
            {
                mat.DisableKeyword("_ExpressionFormat_FaceSheet");
                mat.EnableKeyword("_ExpressionFormat_Wink");
            }
        }


        public override void OnMaterialGUI()
        {
            FindProperties();
            Material mat = materialEditor.target as Material;
            EditorGUI.BeginChangeCheck();
            
            DrawArea("Base", () => {
                BaseArea(mat);
            });

            DrawArea("Subsurface Scattering", () => {
                materialEditor.ShaderProperty(subsurfaceScattering, subsurfaceScattering.displayName);                
                materialEditor.ShaderProperty(subsurfaceRadius, subsurfaceRadius.displayName);
            });

            DrawArea("Effective", () =>
            {
                GUILayout.BeginVertical("Box");
                { 
                GUILayout.Label("Base Effective", EditorStyles.boldLabel);
                GUILayout.BeginVertical("Box");
                                    
                    materialEditor.ShaderProperty(emissionOn, "Emission");
                    materialEditor.ShaderProperty(emissionFlow, emissionFlow.displayName);                    
                    Rect baseRect = GUILayoutUtility.GetLastRect();
                    var current = baseRect;

                    EditorGUI.BeginDisabledGroup(emissionOn.floatValue == 0.0f);
                    {
                        GUILayout.Space(10);
                        GUILayout.Space(10);
                        current.x += 5; current.y += 16; current.width /= 3.0f; current.x = baseRect.x + baseRect.width - current.width;
                        materialEditor.ColorProperty(current, emissionColor, "");
                        current = baseRect;

                        materialEditor.ShaderProperty(emissionxBase, "Mup Base");

                    }
                    EditorGUI.EndDisabledGroup();


                    current = baseRect;
                    current.y += 16; current.width /= 3.0f; current.x = baseRect.x + baseRect.width - current.width;

                    materialEditor.ShaderProperty(specularColor, specularColor.displayName);
                    materialEditor.ShaderProperty(gloss, gloss.displayName);
                    GUILayout.Space(10);
                }
                GUILayout.EndVertical();
                GUILayout.EndVertical();


                GUILayout.BeginVertical("Box");
                GUILayout.Label("Edge Light", EditorStyles.boldLabel);
                GUILayout.BeginVertical("Box");
                {                    
                    materialEditor.ShaderProperty(edgeLightWidth, "Width");
                    materialEditor.ShaderProperty(edgeLightIntensity, "Intensity");
                    GUILayout.Space(10);
                }
                GUILayout.EndVertical();
                GUILayout.EndVertical();

                GUILayout.BeginVertical("Box");
                GUILayout.Label("Effective Disslove", EditorStyles.boldLabel);
                GUILayout.BeginVertical("Box");
                {
                    materialEditor.TexturePropertySingleLine(effectiveMap.displayName.ToGUIContent(), effectiveMap, effectiveColor);
                    materialEditor.ShaderProperty(faceLightMapCombineMode, faceLightMapCombineMode.displayName);
                    GUILayout.Space(10);
                }
                GUILayout.EndVertical();
                GUILayout.Space(10);
                GUILayout.EndVertical();

                GUILayout.BeginVertical("Box");
                GUILayout.Label("Blend Mode", EditorStyles.boldLabel);
                GUILayout.BeginVertical("Box");
                {
                    materialEditor.ShaderProperty(srcBlend, "");
                    materialEditor.ShaderProperty(dstBlend, "");                    
                }
                GUILayout.EndVertical();
                GUILayout.Space(10);
                GUILayout.EndVertical();






                materialEditor.ShaderProperty(flash, flash.displayName);
            });

            DrawArea("Outline", () =>
            {
                materialEditor.ShaderProperty(outlineEnable, "Enable");
                GUILayout.Space(10);
                materialEditor.TexturePropertySingleLine("Width Mask".ToGUIContent(), outlineWidthControl);
                
                Vector4 outCtrlProperties = outlineWidth_MinWidth_MaxWidth_Dist_DistBlur.vectorValue;
                outCtrlProperties.x = EditorGUILayout.FloatField("Min Width",outCtrlProperties.x);
                outCtrlProperties.y = EditorGUILayout.FloatField("Max Width", outCtrlProperties.y);
                outCtrlProperties.z = EditorGUILayout.FloatField("Fade Length Scale", outCtrlProperties.z);
                outlineWidth_MinWidth_MaxWidth_Dist_DistBlur.vectorValue = outCtrlProperties;

                //materialEditor.ShaderProperty(outliineCtrlProperties, outliineCtrlProperties.displayName);

                materialEditor.ShaderProperty(diffuseBlend, diffuseBlend.displayName);
                materialEditor.ShaderProperty(outlineColor, outlineColor.displayName);

                foreach (var m in zdCharacterMaterials)
                {
                    if (m != mat)
                    {
                        m.SetVector(outlineWidth_MinWidth_MaxWidth_Dist_DistBlur.name, outlineWidth_MinWidth_MaxWidth_Dist_DistBlur.vectorValue);
                        m.SetFloat(diffuseBlend.name, diffuseBlend.floatValue);                        
                    }
                }
                
            });

            DrawArea("Discoloration System", () =>
            {
                materialEditor.ShaderProperty(discolorationSystem, "Enable");
                EditorGUI.BeginDisabledGroup(mat.GetFloat("_DiscolorationSystem") == 0.0);
                materialEditor.ShaderProperty(discolorationColorCount, discolorationColorCount.displayName.ToGUIContent());
                mat.SetFloat("_DiscolorationColorCount", Mathf.Floor(mat.GetFloat("_DiscolorationColorCount")));
                byte[] discolorationLabelByte = new byte[] { 0, 28, 57, 85, 113, 142, 170, 198, 227, 255 };
                string[] discolorationLabel = new string[] { "No", "Skin", "Eye",  "Color", "Color", "Color", "Color", "Hair", "Headress", "Headress" };
                int[] discolorationLabelNumber = new int[] { -1, -1, -1, 1, 2, 3, 4, -1, 1, 2 };
                for (int i = 0; i < mat.GetFloat("_DiscolorationColorCount"); i++)
                {
                    if (i == 0)
                    {
                        GUILayout.Label(" ");
                        var currentRect = GUILayoutUtility.GetLastRect();
                        EditorGUI.LabelField(currentRect, discolorationLabel[i], EditorStyles.boldLabel);
                        currentRect.x += 60;
                        EditorGUI.LabelField(currentRect, "");
                        currentRect.x += 20;
                        EditorGUI.LabelField(currentRect, string.Format("RGB= {0}", discolorationLabelByte[i]));
                        currentRect.x -= 80;
                        currentRect.x = currentRect.x + EditorGUIUtility.currentViewWidth - 165;
                        EditorGUI.LabelField(currentRect, "此　區　不　變　色", EditorStyles.boldLabel);
                    }
                    else
                    {
                        materialEditor.ShaderProperty(discolorationColorList[i], " ");
                        var currentRect = GUILayoutUtility.GetLastRect();
                        EditorGUI.LabelField(currentRect, discolorationLabel[i], EditorStyles.boldLabel);
                        currentRect.x += 60;
                        EditorGUI.LabelField(currentRect, (discolorationLabelNumber[i] > 0 ? discolorationLabelNumber[i].ToString() : ""));
                        currentRect.x += 20;
                        EditorGUI.LabelField(currentRect, string.Format("RGB= {0}", discolorationLabelByte[i]));
                    }
                }
                EditorGUI.EndDisabledGroup();
            });

            DrawArea("Shadow Replacer", () => {

                GUILayout.BeginHorizontal();
                {
                    GUILayout.Label("Pick color",EditorStyles.boldLabel);
                    GUILayout.FlexibleSpace();
                    GUILayout.Label("Replace shadow color", EditorStyles.boldLabel);
                }
                GUILayout.EndHorizontal();                

                Rect baseRect = GUILayoutUtility.GetLastRect();
                var current = baseRect;

                for (int i = 0; i < 4; i++) GUILayout.Space(10);

                #region Start Picker
                {
                    current.y += 16; current.width /= 3.0f;
                    materialEditor.ColorProperty(current, picker_0, "");
                    current = baseRect;
                    current.y += 16; current.width /= 3.0f; current.x = baseRect.x + baseRect.width - current.width;
                    materialEditor.ColorProperty(current, shadowColor0, "");
                }
                #endregion // Start Picker

                #region Start Picker
                {
                    current = baseRect;
                    current.y += 32; current.width /= 3.0f;
                    materialEditor.ColorProperty(current, picker_1, "");
                    current = baseRect;
                    current.y += 32; current.width /= 3.0f; current.x = baseRect.x + baseRect.width - current.width;
                    materialEditor.ColorProperty(current, shadowColor1, "");
                }
                #endregion // Start Picker
                
                materialEditor.ShaderProperty(shadowColorElse, "Else Area");
                drawBaseMap = EditorGUILayout.Toggle("Draw Base Map", drawBaseMap);
                if (drawBaseMap)
                {
                    EditorGUI.BeginDisabledGroup(true);
                    //EditorGUI.DrawTextureTransparent();
                    EditorGUI.EndDisabledGroup();
                }
            });

            DrawArea("Expression System", () =>
            {
                materialEditor.ShaderProperty(expressionEnable, "Enable");
                EditorGUI.BeginDisabledGroup(mat.GetFloat("_ExpressionEnable") == 0.0);
                materialEditor.ShaderProperty(selectExpressionMap, selectExpressionMap.displayName);
                materialEditor.TexturePropertySingleLine(expressionMap.displayName.ToGUIContent(), expressionMap);
                materialEditor.TexturePropertySingleLine(expressionQMap.displayName.ToGUIContent(), expressionQMap);
                var currentFormat = SetExpressionFormat(mat);
                format = SetExpressionFormat(mat);
                format = (ExpressionFormat)EditorGUILayout.EnumPopup("Format", format);
                GetExpressionFormat(mat);

                GUILayout.Space(6);
                GUILayout.Label("Reset Rect", EditorStyles.boldLabel);
                GUILayout.BeginHorizontal();
                if (GUILayout.Button("PC"))
                {
                    switch (format)
                    {
                        case ExpressionFormat.Wink:
                            faceRect.vectorValue = new float4(0.0f, .06f, .5f, .5f);
                            break;
                        case ExpressionFormat.FaceSheet:
                            browRect.vectorValue = new float4(0.0f, .5f, .73f, .3f);
                            faceRect.vectorValue = new float4(0.0f, .06f, .73f, .37f);
                            mouthRect.vectorValue = new float4(0.0f, -1.11f, .4f, .28f);
                            break;
                    }

                }
                if (GUILayout.Button("Combine"))
                {
                    switch (format)
                    {
                        case ExpressionFormat.Wink:
                            faceRect.vectorValue = new float4(0.0f, .26f, .67f, .36f);
                            break;
                        case ExpressionFormat.FaceSheet:
                            browRect.vectorValue = new float4(0.0f, .68f, .855f, .3f);
                            faceRect.vectorValue = new float4(0.0f, .26f, .855f, .3f);
                            mouthRect.vectorValue = new float4(0.0f, -.63f, .5f, .3f);
                            break;
                    }
                }
                GUILayout.EndHorizontal();

                if (format == ExpressionFormat.FaceSheet)
                {
                    materialEditor.ShaderProperty(selectBrow, selectBrow.displayName);
                    materialEditor.ShaderProperty(browRect, browRect.displayName);
                }
               
                materialEditor.ShaderProperty(selectFace, selectFace.displayName);
                materialEditor.ShaderProperty(faceRect, faceRect.displayName);

                if (format == ExpressionFormat.FaceSheet)
                {
                    materialEditor.ShaderProperty(selectMouth, selectMouth.displayName);
                    materialEditor.ShaderProperty(mouthRect, mouthRect.displayName);
                }
                EditorGUI.EndDisabledGroup();
            });

            DrawArea("Custom Lighting", () => {
                materialEditor.ShaderProperty(customLightColor, "Color");
                materialEditor.ShaderProperty(customLightIntensity, "Intansity");

                //materialEditor.ShaderProperty(FindProperty("_CustomLightInstanceID"), "_CustomLightInstanceID");
            });

            DrawArea("Settings",()=> {
                materialEditor.ShaderProperty(receiveShadow, receiveShadow.displayName); 
                materialEditor.ShaderProperty(shadowRefraction, shadowRefraction.displayName);
                materialEditor.ShaderProperty(shadowOffset, shadowOffset.displayName);
                materialEditor.ShaderProperty(shadowRamp, shadowRamp.displayName);
                materialEditor.ShaderProperty(selfShadowRamp, selfShadowRamp.displayName);
                materialEditor.RenderQueueField();
            });

            DrawArea("Float Model", () => {
                materialEditor.ShaderProperty(floatModel, floatModel.displayName);
            });

            MaterialChangeCheck();
        }

        public virtual void BaseArea(Material mat)
        {
            materialEditor.TexturePropertySingleLine(diffuse.displayName.ToGUIContent(), diffuse, color);
            materialEditor.TexturePropertySingleLine(mask.displayName.ToGUIContent(
                string.Format("{0} \n\n{1} \n\n{2} \n\n{3}",
                "R= Emission Mask\n(發光遮罩)",
                "G= Shadow Refraction\n(陰影速率(折射))",
                "B= Specular Mask\n(反光遮罩)",
                "A= Gloss\n(光滑遮罩)")
                ), mask);


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
                selfMaskEnable.floatValue = 1.0f;
                mat.EnableKeyword("_SelfMaskEnable");
            }
            else
            {
                selfMaskDirection.floatValue = 0;
                selfMaskEnable.floatValue = 0.0f;
                mat.DisableKeyword("_SelfMaskEnable");
            }
        }

        public override void MaterialChanged(Material material)
        {
            if (material == null)
                return;

            
        }
        
    }
}