using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
namespace UnityEditor.Rendering.Funcy.LWRP.ShaderGUI
{
    internal class ZDCharacter : BaseFuncyShaderGUI
    {
        MaterialProperty baseMap { get; set; }
        MaterialProperty baseColor { get; set; }
        MaterialProperty maskMap { get; set; }
        MaterialProperty flash { get; set; }
        MaterialProperty emissionColor { get; set; }
        MaterialProperty emissionxBase { get; set; }
        MaterialProperty emissionxOn { get; set; }
        MaterialProperty gloss { get; set; }
        MaterialProperty specularColor { get; set; }
        MaterialProperty shadowRemap { get; set; }
        MaterialProperty discolorationOn { get; set; }
        MaterialProperty discoloration { get; set; }

        MaterialProperty pciker0 { get; set; }
        MaterialProperty shadowColor0 { get; set; }
        MaterialProperty pciker1 { get; set; }
        MaterialProperty shadowColor1 { get; set; }
        MaterialProperty shadowColorElse { get; set; }

        MaterialProperty customLighting { get; set; }
        MaterialProperty customLightColor { get; set; }
        MaterialProperty customLightDirection { get; set; }

        MaterialProperty receiveShadow { get; set; }
        MaterialProperty shadowRefrection { get; set; }
        //MaterialProperty invertLightDirection { get; set; }
        

        bool drawBaseMap = false;
        void FindProperties()
        {
            baseMap = FindProperty("_diffuse", props);
            baseColor = FindProperty("_Color", props);
            maskMap = FindProperty("_mask", props);

            flash = FindProperty("_Flash", props);
            emissionColor = FindProperty("_EmissionColor", props);
            emissionxBase = FindProperty("_EmissionxBase", props);
            emissionxOn = FindProperty("_EmissionOn", props);
            gloss = FindProperty("_Gloss", props);
            specularColor = FindProperty("_SpecularColor", props);
            shadowRemap = FindProperty("_ShadowRamp", props);

            discoloration = FindProperty("_Discoloration", props);
            discolorationOn = FindProperty("_DiscolorationOn", props);
            
            pciker0 = FindProperty("_Picker_0", props);
            shadowColor0 = FindProperty("_ShadowColor0", props);
            pciker1 = FindProperty("_Picker_1", props);
            shadowColor1 = FindProperty("_ShadowColor1", props);
            shadowColorElse = FindProperty("_ShadowColorElse", props);

            customLighting = FindProperty("_CustomLighting", props);
            customLightColor = FindProperty("_CustomLightColor", props);
            customLightDirection = FindProperty("_CustomLightDirection", props);

            receiveShadow = FindProperty("_ReceiveShadow", props);
            shadowRefrection= FindProperty("_ShadowRefraction", props);
            
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
        public override void OnMaterialGUI()
        {
            FindProperties();

            EditorGUI.BeginChangeCheck();
            
            DrawArea("Base", () => {
                materialEditor.TexturePropertySingleLine(baseMap.displayName.ToGUIContent(), baseMap, baseColor);
                materialEditor.TexturePropertySingleLine(maskMap.displayName.ToGUIContent(), maskMap);
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

                materialEditor.ShaderProperty(discolorationOn, discolorationOn.displayName);
                EditorGUI.BeginDisabledGroup(discolorationOn.floatValue == 0.0f);
                {
                    materialEditor.ShaderProperty(discoloration, discoloration.displayName);
                }
                EditorGUI.EndDisabledGroup();
                materialEditor.ShaderProperty(flash, flash.displayName);
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

            DrawArea("Settings",()=> {
                materialEditor.ShaderProperty(receiveShadow, receiveShadow.displayName);
                materialEditor.ShaderProperty(shadowRefrection, shadowRefrection.displayName);
                materialEditor.ShaderProperty(shadowRemap, shadowRemap.displayName);
                //materialEditor.ShaderProperty(invertLightDirection, invertLightDirection.displayName);
            });

            DrawArea("Custom Lighting", () => {
                materialEditor.ShaderProperty(customLighting, "Enable " + customLighting.displayName);
                materialEditor.ShaderProperty(customLightColor, "Color");
                lightTransform = EditorGUILayout.ObjectField("Ctrl Transform",lightTransform, typeof(Transform), true) as Transform;
                if (lightTransfrom_Tmp != lightTransform)
                {
                    lightTransfrom_Tmp = lightTransform;
                    if (lightTransfrom_Tmp) lightTransform.forward = -customLightDirection.vectorValue;
                }
                if (lightTransform)
                    customLightDirection.vectorValue = -lightTransform.forward;

            });

            //base.OnMaterialGUI();

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