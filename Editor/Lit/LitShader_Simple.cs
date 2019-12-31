using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEditor.Rendering;

namespace UnityEditor.Rendering.Funcy.LWRP.ShaderGUI
{
    internal class LitShader_Simple : BaseShaderGUI
    {
        // Properties
        private LitGUI.LitProperties litProperties;
        MaterialProperty speed { get; set; }
        MaterialProperty amount { get; set; }
        MaterialProperty distance { get; set; }

        MaterialProperty positionMask { get; set; }
        MaterialProperty debugMask { get; set; }


        // collect properties from the material properties
        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            litProperties = new LitGUI.LitProperties(properties);
            speed = FindProperty("_Speed", properties);
            amount = FindProperty("_Amount", properties);
            distance = FindProperty("_Distance", properties);
            positionMask = FindProperty("_PositionMask", properties);
            debugMask = FindProperty("_DebugMask", properties);
        }

        // material changed check
        public override void MaterialChanged(Material material)
        {
            if (material == null)
                return;

            SetMaterialKeywords(material, LitGUI.SetMaterialKeywords);
        }

        // material main surface options
        public override void DrawSurfaceOptions(Material material)
        {
            if (material == null)
                return;

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
            material.SetFloat("_Smoothness", 0);
            material.SetFloat("_GlossMapScale", 1);
            material.SetFloat("_Metallic", 0);
            material.SetTexture("_MetallicGlossMap", null);
            material.SetTexture("_SpecGlossMap", null);
            //LitGUI.Inputs(litProperties, materialEditor, material);
            DrawEmissionProperties(material, true);
            //DrawTileOffset(materialEditor, baseMapProp);
        }

        // material main advanced options
        public override void DrawAdvancedOptions(Material material)
        {
            if (litProperties.reflections != null && litProperties.highlights != null)
            {
                EditorGUI.BeginChangeCheck();
                {
                    //materialEditor.ShaderProperty(litProperties.highlights, LitGUI.Styles.highlightsText);
                    //materialEditor.ShaderProperty(litProperties.reflections, LitGUI.Styles.reflectionsText);
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
            base.OnGUI(materialEditorIn,properties);
            /*
            DrawArea("Tree Winding",()=> {
                materialEditor.ShaderProperty(speed, speed.displayName);
                materialEditor.ShaderProperty(amount, amount.displayName);
                materialEditor.ShaderProperty(distance, distance.displayName);
                materialEditor.TexturePropertySingleLine(positionMask.displayName.ToGUIContent(), positionMask);
                materialEditor.TextureScaleOffsetProperty(positionMask);
                materialEditor.ShaderProperty(debugMask, debugMask.displayName);
            });
            */
        }
    }
}