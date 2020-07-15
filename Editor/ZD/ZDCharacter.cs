using System.Collections;
using System.Collections.Generic;
using System.Linq;
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

        public MaterialProperty baseMap { get; set; }
        public MaterialProperty baseColor { get; set; }
        
        public MaterialProperty selfMaskDirection { get; set; }

        public MaterialProperty maskMap { get; set; }
        public MaterialProperty flash { get; set; }

        public MaterialProperty edgeLightWidth { get; set; }
        public MaterialProperty edgeLightIntensity { get; set; }
        

        public MaterialProperty emissionColor { get; set; }
        public MaterialProperty emissionxBase { get; set; }
        public MaterialProperty emissionxOn { get; set; }
        public MaterialProperty gloss { get; set; }
        public MaterialProperty specularColor { get; set; }
        public MaterialProperty shadowRemap { get; set; }
        public MaterialProperty selfShadowRemap { get; set; }


        public MaterialProperty outlineEnable { get; set; }
        public MaterialProperty outlineMask { get; set; }

        public MaterialProperty pciker0 { get; set; }
        public MaterialProperty shadowColor0 { get; set; }
        public MaterialProperty pciker1 { get; set; }
        public MaterialProperty shadowColor1 { get; set; }
        public MaterialProperty shadowColorElse { get; set; }

        public MaterialProperty customLightColor { get; set; }
        public MaterialProperty customLightIntensity { get; set; }


        public MaterialProperty receiveShadow { get; set; }
        public MaterialProperty selfMask { get; set; }
        public MaterialProperty selfMaskEnb { get; set; }
        public MaterialProperty shadowRefrection { get; set; }
        public MaterialProperty shadowOffset { get; set; }

        public MaterialProperty discolorationColor0 { get; set; }
        public MaterialProperty discolorationColor1 { get; set; }
        public MaterialProperty discolorationColor2 { get; set; }
        public MaterialProperty discolorationColor3 { get; set; }
        public MaterialProperty discolorationColor4 { get; set; }
        public MaterialProperty discolorationColor5 { get; set; }
        public MaterialProperty discolorationColor6 { get; set; }        
        public MaterialProperty discolorationColor7 { get; set; }
        public MaterialProperty discolorationColor8 { get; set; }
        public MaterialProperty discolorationColor9 { get; set; }
        MaterialProperty[] discolorationColorList = new MaterialProperty[10];
        public MaterialProperty discolorationSystem { get; set; }
        public MaterialProperty discolorationColorCount { get; set; }

        public MaterialProperty outliineCtrlProperties { get; set; }

        public MaterialProperty outlineColor { get; set; }
        public MaterialProperty diffuseBlend { get; set; }


        public MaterialProperty expressionEnable { get; set; }
        public MaterialProperty expressionMap { get; set; }
        public MaterialProperty selectBrow { get; set; }
        public MaterialProperty selectFace { get; set; }
        public MaterialProperty selectMouth { get; set; }

        public MaterialProperty browRect { get; set; }
        public MaterialProperty faceRect { get; set; }
        public MaterialProperty mouthRect { get; set; }

        bool drawBaseMap = false;
        public virtual void FindProperties()
        {
            baseMap = FindProperty("_diffuse", props);
            baseColor = FindProperty("_Color", props);

            selfMaskDirection = FindProperty("_SelfMaskDirection", props);

            maskMap = FindProperty("_mask", props);
            selfMask = FindProperty("_SelfMask", props);
            selfMaskEnb = FindProperty("_SelfMaskEnable", props);
            flash = FindProperty("_Flash", props);

            edgeLightWidth = FindProperty("_EdgeLightWidth", props);
            edgeLightIntensity = FindProperty("_EdgeLightIntensity", props);

            emissionColor = FindProperty("_EmissionColor", props);
            emissionxBase = FindProperty("_EmissionxBase", props);
            emissionxOn = FindProperty("_EmissionOn", props);
            gloss = FindProperty("_Gloss", props);
            specularColor = FindProperty("_SpecularColor", props);
            shadowRemap = FindProperty("_ShadowRamp", props);
            selfShadowRemap = FindProperty("_SelfShadowRamp", props);

            outlineEnable = FindProperty("_OutlineEnable", props);
            outlineMask = FindProperty("_OutlineWidthControl", props);

            pciker0 = FindProperty("_Picker_0", props);
            shadowColor0 = FindProperty("_ShadowColor0", props);
            pciker1 = FindProperty("_Picker_1", props);
            shadowColor1 = FindProperty("_ShadowColor1", props);
            shadowColorElse = FindProperty("_ShadowColorElse", props);

            customLightColor = FindProperty("_CustomLightColor", props);
            customLightIntensity = FindProperty("_CustomLightIntensity", props);

            receiveShadow = FindProperty("_ReceiveShadow", props);
            shadowRefrection= FindProperty("_ShadowRefraction", props);
            shadowOffset = FindProperty("_ShadowOffset", props);

            discolorationColorList = new MaterialProperty[] {
                discolorationColor0, discolorationColor1,discolorationColor2, discolorationColor3,
                discolorationColor4, discolorationColor5,discolorationColor6, discolorationColor7,
                discolorationColor8,discolorationColor9
            };

            for (int i = 0; i < 10; i++)
            {
                discolorationColorList[i] = FindProperty(string.Format("_DiscolorationColor_{0}", i ), props);
            }

            discolorationSystem = FindProperty("_DiscolorationSystem", props);
            discolorationColorCount = FindProperty("_DiscolorationColorCount", props);


            outliineCtrlProperties = FindProperty("_OutlineWidth_MinWidth_MaxWidth_Dist_DistBlur", props);
            outlineColor = FindProperty("_OutlineColor", props);
            diffuseBlend = FindProperty("_DiffuseBlend", props);


            expressionEnable = FindProperty("_ExpressionEnable", props);
            expressionMap = FindProperty("_ExpressionMap", props);
            selectBrow = FindProperty("_SelectBrow", props);
            selectFace = FindProperty("_SelectFace", props);
            selectMouth = FindProperty("_SelectMouth", props);
            browRect = FindProperty("_BrowRect", props);
            faceRect = FindProperty("_FaceRect", props);
            mouthRect = FindProperty("_MouthRect", props);
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
        public override void OnMaterialGUI()
        {
            FindProperties();
            Material mat = materialEditor.target as Material;
            EditorGUI.BeginChangeCheck();
            
            DrawArea("Base", () => {
                BaseArea(mat);
            });            

            DrawArea("Effective", () =>
            {
                materialEditor.ShaderProperty(emissionxOn, "Emission");
                Rect baseRect = GUILayoutUtility.GetLastRect();
                var current = baseRect;

                EditorGUI.BeginDisabledGroup(emissionxOn.floatValue == 0.0f);
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

                GUILayout.Label("Edge Light", EditorStyles.boldLabel);
                materialEditor.ShaderProperty(edgeLightWidth, "Width");
                materialEditor.ShaderProperty(edgeLightIntensity, "Intensity");
                GUILayout.Space(10);                

                materialEditor.ShaderProperty(flash, flash.displayName);
            });

            DrawArea("Outline", () =>
            {
                materialEditor.ShaderProperty(outlineEnable, "Enable");
                GUILayout.Space(10);
                materialEditor.TexturePropertySingleLine("Width Mask".ToGUIContent(), outlineMask);
                
                Vector4 outCtrlProperties = outliineCtrlProperties.vectorValue;
                outCtrlProperties.x = EditorGUILayout.FloatField("Min Width",outCtrlProperties.x);
                outCtrlProperties.y = EditorGUILayout.FloatField("Max Width", outCtrlProperties.y);
                outCtrlProperties.z = EditorGUILayout.FloatField("Fade Length Scale", outCtrlProperties.z);
                outliineCtrlProperties.vectorValue = outCtrlProperties;

                //materialEditor.ShaderProperty(outliineCtrlProperties, outliineCtrlProperties.displayName);

                materialEditor.ShaderProperty(diffuseBlend, diffuseBlend.displayName);
                materialEditor.ShaderProperty(outlineColor, outlineColor.displayName);

                foreach (var m in zdCharacterMaterials)
                {
                    if (m != mat)
                    {
                        m.SetVector(outliineCtrlProperties.name, outliineCtrlProperties.vectorValue);
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
                    materialEditor.ColorProperty(current, pciker0, "");
                    current = baseRect;
                    current.y += 16; current.width /= 3.0f; current.x = baseRect.x + baseRect.width - current.width;
                    materialEditor.ColorProperty(current, shadowColor0, "");
                }
                #endregion // Start Picker

                #region Start Picker
                {
                    current = baseRect;
                    current.y += 32; current.width /= 3.0f;
                    materialEditor.ColorProperty(current, pciker1, "");
                    current = baseRect;
                    current.y += 32; current.width /= 3.0f; current.x = baseRect.x + baseRect.width - current.width;
                    materialEditor.ColorProperty(current, shadowColor1, "");
                }
                #endregion // Start Picker
                
                materialEditor.ShaderProperty(shadowColorElse, "Else Area");
                drawBaseMap = EditorGUILayout.Toggle("Draw Base Map",drawBaseMap);
                if (drawBaseMap)
                {
                    EditorGUI.BeginDisabledGroup(true);
                    EditorGUILayout.ObjectField(baseMap.textureValue, typeof(Texture2D), false, GUILayout.Width(EditorGUIUtility.currentViewWidth*0.8f), GUILayout.Height(EditorGUIUtility.currentViewWidth*0.8f));
                    EditorGUI.EndDisabledGroup();
                }
            });


            DrawArea("Expression System", () => {

                materialEditor.ShaderProperty(expressionEnable, "Enable");
                EditorGUI.BeginDisabledGroup(mat.GetFloat("_ExpressionEnable") == 0.0);
                materialEditor.TexturePropertySingleLine(expressionMap.displayName.ToGUIContent(), expressionMap);
                materialEditor.ShaderProperty(selectBrow, selectBrow.displayName);
                materialEditor.ShaderProperty(browRect, browRect.displayName);
                materialEditor.ShaderProperty(selectFace, selectFace.displayName);
                materialEditor.ShaderProperty(faceRect, faceRect.displayName);
                materialEditor.ShaderProperty(selectMouth, selectMouth.displayName);
                materialEditor.ShaderProperty(mouthRect, mouthRect.displayName);
                EditorGUI.EndDisabledGroup();
            });

            DrawArea("Custom Lighting", () => {
                materialEditor.ShaderProperty(customLightColor, "Color");
                materialEditor.ShaderProperty(customLightIntensity, "Intansity");

                //materialEditor.ShaderProperty(FindProperty("_CustomLightInstanceID"), "_CustomLightInstanceID");
            });

            DrawArea("Settings",()=> {
                materialEditor.ShaderProperty(receiveShadow, receiveShadow.displayName); 
                materialEditor.ShaderProperty(shadowRefrection, shadowRefrection.displayName);
                materialEditor.ShaderProperty(shadowOffset, shadowOffset.displayName);
                materialEditor.ShaderProperty(shadowRemap, shadowRemap.displayName);
                materialEditor.ShaderProperty(selfShadowRemap, selfShadowRemap.displayName);
            });

            MaterialChangeCheck();
        }

        public virtual void BaseArea(Material mat)
        {
            materialEditor.TexturePropertySingleLine(baseMap.displayName.ToGUIContent(), baseMap, baseColor);
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

        public override void MaterialChanged(Material material)
        {
            if (material == null)
                return;

            
        }
        
    }
}