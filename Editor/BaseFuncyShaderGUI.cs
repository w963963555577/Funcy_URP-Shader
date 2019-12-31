using System;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEditor.Rendering;
using System.Collections.Generic;
using UnityEditor.AnimatedValues;
using System.Linq;

namespace UnityEditor
{
    public abstract class BaseFuncyShaderGUI : ShaderGUI
    {
        private bool isEnable = false;
        public MaterialEditor materialEditor;
        public MaterialProperty[] props;
        public MaterialProperty FindProperty(string name)
        {
            return props.ToList().Find(p => p.name == name);
        }

        public virtual void OnEnable()
        {

        }
        public abstract void MaterialChanged(Material material);

        public override void OnGUI(MaterialEditor materialEditorIn, MaterialProperty[] properties)
        {
            materialEditor = materialEditorIn;
            props = properties;

            if (!isEnable)
            {
                isEnable = true;
                OnEnable();
            }

            OnMaterialGUI();
        }

        public virtual void OnMaterialGUI()
        {
            base.OnGUI(materialEditor, props);
        }
        public void MaterialChangeCheck()
        {
            foreach (var obj in materialEditor.targets)
            {
                ((Material)obj).enableInstancing = true;             
            }
            if (EditorGUI.EndChangeCheck())
            {
                foreach (var obj in materialEditor.targets)
                {
                    ((Material)obj).enableInstancing = true;
                    MaterialChanged((Material)obj);
                }

            }
        }
        [Serializable]
        public class AnimBoolNameId
        {
            public string name = "";
            public AnimBool animBool;

            public AnimBoolNameId(string name, bool defaultVale)
            {
                this.name = name;
                this.animBool = new AnimBool(defaultVale);
            }
        }
        [SerializeField] List<AnimBoolNameId> animBools = new List<AnimBoolNameId>();
        public void DrawArea(string text, Action onGUI, float fadeSpeed = 3.0f, string style = "ShurikenModuleTitle")
        {
            string key = text;
            bool state = EditorPrefs.GetBool(key, true);

            if (animBools.Find(a => a.name == text) == null)
            {
                if (animBools.Count == 0)
                {
                    EditorApplication.update += () => {
                        materialEditor.Repaint();
                    };
                }
                var newAnimBool = new AnimBoolNameId(text, state);
                newAnimBool.animBool.speed = fadeSpeed;
                animBools.Add(newAnimBool);
            }

            var currentAnimBool = animBools.Find(a => a.name == text);

            GUILayout.BeginHorizontal();
            {
                GUI.changed = false;

                text = "<b><size=11>" + text + "</size></b>";
                if (state) text = "\u25BC " + text;
                else text = "\u25BA " + text;
                if (GUILayout.Button(text, style))
                {
                    state = !state;
                    currentAnimBool.animBool.target = state;
                    EditorPrefs.SetBool(key, state);
                }
            }
            GUILayout.EndHorizontal();
            GUI.backgroundColor = Color.white;

            if (currentAnimBool == null) return;

            if (EditorGUILayout.BeginFadeGroup(currentAnimBool.animBool.faded))
            {
                GUILayout.BeginHorizontal("ShurikenModuleBg", GUILayout.Height(10));
                GUILayout.Space(10);
                GUILayout.BeginVertical(GUILayout.Height(10));
                onGUI();
                GUILayout.EndVertical();
                GUILayout.EndHorizontal();
            }
            EditorGUILayout.EndFadeGroup();

        }

    }
    public static class Extension
    {
        public static GUIContent ToGUIContent(this string name)
        {
            return new GUIContent(name);
        }
    }
}