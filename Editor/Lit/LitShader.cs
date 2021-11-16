using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;

namespace UnityEditor.Rendering.Funcy.URP.ShaderGUI
{
    internal class LitShader : BaseShaderGUI
    {
        // Properties
        private LitGUI.LitProperties litProperties;
        private MaterialProperty ssprEnabled;
        private MaterialProperty flowEmissionEnabled;
        private MaterialProperty editorAppearMode;
        MaterialProperty wind { get; set; }
        MaterialProperty speed { get; set; }
        MaterialProperty amount { get; set; }
        MaterialProperty distance { get; set; }
        MaterialProperty positionMask { get; set; }
        
        // collect properties from the material properties
        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            litProperties = new LitGUI.LitProperties(properties);
            editorAppearMode = FindProperty("_EditorAppearMode", properties, false);
            ssprEnabled = FindProperty("_SSPREnabled", properties, false);
            flowEmissionEnabled = FindProperty("_FlowEmissionEnabled", properties, false);
            wind = FindProperty("_WindEnabled", properties, false);
            speed = FindProperty("_Speed", properties, false);
            amount = FindProperty("_Amount", properties, false);
            distance = FindProperty("_Distance", properties, false);
            positionMask = FindProperty("_PositionMask", properties, false);            
            
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
            if (editorAppearMode.floatValue == 1.0f)
                LitGUI.Inputs(litProperties, materialEditor, material);
            DrawEmissionProperties(material, true);
            DrawTileOffset(materialEditor, baseMapProp);
        }

        // material main advanced options
        public override void DrawAdvancedOptions(Material material)
        {
            if (litProperties.reflections != null && litProperties.highlights != null)
            {
                if (editorAppearMode.floatValue == 1.0f)
                {
                    EditorGUI.BeginChangeCheck();
                    {
                        materialEditor.ShaderProperty(litProperties.highlights, LitGUI.Styles.highlightsText);
                        materialEditor.ShaderProperty(litProperties.reflections, LitGUI.Styles.reflectionsText);
                        EditorGUI.BeginChangeCheck();
                    }
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
            if (materialEditorIn == null)
                throw new ArgumentNullException("materialEditorIn");

            FindProperties(properties); // MaterialProperties can be animated so we do not cache them but fetch them every event to ensure animated values are updated correctly
            materialEditor = materialEditorIn;
            Material material = materialEditor.target as Material;

            if (material.HasProperty("_EditorAppearMode"))
            {
                string text = string.Format("<b><size=12>WorkMode: {0}</size></b>", editorAppearMode.floatValue == 1 ? "Complex" : "Simple");
                if (GUILayout.Button(text, "ShurikenModuleTitle")) 
                {
                    editorAppearMode.floatValue = 1.0f - editorAppearMode.floatValue;
                }
            }

            // Make sure that needed setup (ie keywords/renderqueue) are set up if we're switching some existing
            // material to a lightweight shader.
            if (m_FirstTimeApply)
            {
                OnOpenGUI(material, materialEditorIn);
                m_FirstTimeApply = false;
            }

            if (material == null)
                throw new ArgumentNullException("material");

            EditorGUI.BeginChangeCheck();
            

            DrawArea(Styles.SurfaceInputs.text, () =>
            {
                DrawSurfaceInputs(material);
                EditorGUILayout.Space();
            });


            DrawArea(Styles.AdvancedLabel.text, () =>
            {
                DrawAdvancedOptions(material);
                EditorGUILayout.Space();
            });

            DrawArea(Styles.SurfaceOptions.text, () =>
            {
                DrawSurfaceOptions(material);
                EditorGUILayout.Space();
            });

            DrawAdditionalFoldouts(material);

            if (material.HasProperty("_SSPREnabled") && editorAppearMode.floatValue == 1.0f)
            {
                DrawArea("Screen Space Planar Reflections", () =>
            {
                ChangeCheckArea_Float(material, ssprEnabled, "Enabled");

            });
            }
            if (material.HasProperty("_FlowEmissionEnabled") && editorAppearMode.floatValue == 1.0f)
            {
                DrawArea("Flow Emossion", () =>
                {
                    ChangeCheckArea_Float(material, flowEmissionEnabled, "Enabled");

                });
            }

            if (material.HasProperty("_WindEnabled"))
            {
                DrawArea("Wind", () =>
                {
                    ChangeCheckArea_Float(material, wind, "Enabled");
                    materialEditor.ShaderProperty(speed, speed.displayName);
                    materialEditor.ShaderProperty(amount, amount.displayName);
                    materialEditor.ShaderProperty(distance, distance.displayName);
                    materialEditor.TexturePropertySingleLine(positionMask.displayName.ToGUIContent(), positionMask);
                    materialEditor.TextureScaleOffsetProperty(positionMask);                    
                });
            }

            if (EditorGUI.EndChangeCheck())
            {
                foreach (var obj in materialEditor.targets)
                    MaterialChanged((Material)obj);
            }
                        
        }

        public void DrawMode(string text, float fadeSpeed = 3.0f, string style = "ShurikenModuleTitle")
        {
            string key = text;
            bool state = EditorPrefs.GetBool(key, true);           

            GUILayout.BeginHorizontal();
            {
                GUI.changed = false;

                text = "<b><size=11>" + text + "</size></b>";
                if (state) text =  text;
                else text =  text;
                if (GUILayout.Button(text, style))
                {
                    state = !state;
                    EditorPrefs.SetBool(key, state);
                }
            }
            GUILayout.EndHorizontal();
            GUI.backgroundColor = Color.white;
            

        }

    }
}