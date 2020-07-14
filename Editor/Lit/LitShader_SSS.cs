using System;
using UnityEngine;
using UnityEditor;

namespace UnityEditor.Rendering.Funcy.LWRP.ShaderGUI
{
    internal class LitShader_SSS : BaseShaderGUI
    {
        // Properties
        private LitGUI.LitProperties litProperties;
        MaterialProperty sssColor { get; set; }
        MaterialProperty sssMap { get; set; }
        MaterialProperty sssRadius { get; set; }
        MaterialProperty sss { get; set; }

        MaterialProperty rimLightColor { get; set; }
        MaterialProperty maxHDR { get; set; }        

        // collect properties from the material properties
        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            litProperties = new LitGUI.LitProperties(properties);

            sss = FindProperty("_SubsurfaceScattering", properties);
            sssRadius = FindProperty("_SubsurfaceRadius", properties);
            sssColor = FindProperty("_SubsurfaceColor", properties);
            sssMap = FindProperty("_SubsurfaceMap", properties);

            rimLightColor = FindProperty("_RimLightColor", properties);
            maxHDR = FindProperty("_MaxHDR", properties);
        }

        // material changed check
        public override void MaterialChanged(Material material)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            SetMaterialKeywords(material, LitGUI.SetMaterialKeywords);
        }

        // material main surface options
        public override void DrawSurfaceOptions(Material material)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            // Use default labelWidth
            EditorGUIUtility.labelWidth = 0f;

            // Detect any changes to the material
            EditorGUI.BeginChangeCheck();
            if (litProperties.workflowMode != null)
            {
                DoPopup(LitGUI.Styles.workflowModeText, litProperties.workflowMode, Enum.GetNames(typeof(LitGUI.WorkflowMode)));
            }

            base.DrawSurfaceOptions(material);
        }

        // material main surface inputs
        public override void DrawSurfaceInputs(Material material)
        {
            base.DrawSurfaceInputs(material);
            LitGUI.Inputs(litProperties, materialEditor, material);
            DrawEmissionProperties(material, true);
            DrawTileOffset(materialEditor, baseMapProp);
        }

        // material main advanced options
        public override void DrawAdvancedOptions(Material material)
        {
            if (litProperties.reflections != null && litProperties.highlights != null)
            {
                EditorGUI.BeginChangeCheck();
                {
                    materialEditor.ShaderProperty(litProperties.highlights, LitGUI.Styles.highlightsText);
                    materialEditor.ShaderProperty(litProperties.reflections, LitGUI.Styles.reflectionsText);
                    EditorGUI.BeginChangeCheck();
                }
            }

            base.DrawAdvancedOptions(material);
        }

        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            // _Emission property is lost after assigning Standard shader to the material
            // thus transfer it before assigning the new shader
            if (material.HasProperty("_Emission"))
            {
                material.SetColor("_EmissionColor", material.GetColor("_Emission"));
            }

            base.AssignNewShaderToMaterial(material, oldShader, newShader);

            if (oldShader == null || !oldShader.name.Contains("Legacy Shaders/"))
            {
                SetupMaterialBlendMode(material);
                return;
            }

            SurfaceType surfaceType = SurfaceType.Opaque;
            BlendMode blendMode = BlendMode.Alpha;
            if (oldShader.name.Contains("/Transparent/Cutout/"))
            {
                surfaceType = SurfaceType.Opaque;
                material.SetFloat("_AlphaClip", 1);
            }
            else if (oldShader.name.Contains("/Transparent/"))
            {
                // NOTE: legacy shaders did not provide physically based transparency
                // therefore Fade mode
                surfaceType = SurfaceType.Transparent;
                blendMode = BlendMode.Alpha;
            }
            material.SetFloat("_Surface", (float)surfaceType);
            material.SetFloat("_Blend", (float)blendMode);

            if (oldShader.name.Equals("Standard (Specular setup)"))
            {
                material.SetFloat("_WorkflowMode", (float)LitGUI.WorkflowMode.Specular);
                Texture texture = material.GetTexture("_SpecGlossMap");
                if (texture != null)
                    material.SetTexture("_MetallicSpecGlossMap", texture);
            }
            else
            {
                material.SetFloat("_WorkflowMode", (float)LitGUI.WorkflowMode.Metallic);
                Texture texture = material.GetTexture("_MetallicGlossMap");
                if (texture != null)
                    material.SetTexture("_MetallicSpecGlossMap", texture);
            }

            MaterialChanged(material);
        }
        public override void OnGUI(MaterialEditor materialEditorIn, MaterialProperty[] properties)
        {
            base.OnGUI(materialEditorIn, properties);
            DrawArea("Subsurface Scattering", () => {
                materialEditor.ShaderProperty(sss, sss.displayName);
                materialEditor.TexturePropertySingleLine(sssMap.displayName.ToGUIContent(), sssMap, sssColor, sssRadius);
            });

            DrawArea("Rim Lighting", () => {
                materialEditor.ShaderProperty(rimLightColor, rimLightColor.displayName);                
                materialEditor.ShaderProperty(maxHDR, maxHDR.displayName);                 

                //materialEditor.TexturePropertySingleLine(sssMap.displayName.ToGUIContent(), sssMap, sssColor, sssRadius);
            });
        }
    }
}