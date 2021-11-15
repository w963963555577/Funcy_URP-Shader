
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine.UIElements;
#endif
public class GlobalProperties : ScriptableRendererFeature
{
    [System.Serializable]
    public class Property
    {
        public string name = "";
        [HideInInspector]public ShaderPropertyType type = ShaderPropertyType.Float;

        [HideInInspector] public float floatValue;
        [HideInInspector] public Vector4 vectorValue;
        [HideInInspector][ColorUsage(true,true)] public Color colorValue;

        public enum ShaderPropertyType
        {            
            Color = 0,            
            Vector = 1,            
            Float = 2              
        }
    }

    [System.Serializable]
    public class Settings 
    {        
        public List<Property> properties = new List<Property>();
    }

    public Settings settings = new Settings();

    class Pass : ScriptableRenderPass
    {
        Settings settings;

        string tag;

        public Pass(Settings settings, string tag)
        {
            this.settings = settings;
            this.tag = tag;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(tag);

            foreach (var p in settings.properties)
            {
                switch(p.type)
                {
                    case Property.ShaderPropertyType.Color:
                        cmd.SetGlobalColor(p.name, p.colorValue);
                        break;
                    case Property.ShaderPropertyType.Float:
                        cmd.SetGlobalFloat(p.name, p.floatValue);
                        break;
                    case Property.ShaderPropertyType.Vector:
                        cmd.SetGlobalVector(p.name, p.vectorValue);
                        break;
                }
            }

            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            CommandBufferPool.Release(cmd);
        }
    }

    Pass pass;


    public override void Create()
    {
        pass = new Pass(settings, this.name);
        pass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
       
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {        
        renderer.EnqueuePass(pass);
    }
}
#if UNITY_EDITOR
// IngredientDrawerUIE
[CustomPropertyDrawer(typeof(GlobalProperties.Settings))]
public class GlobalProperties_Settings : PropertyDrawer
{
    string[] typeValueNames = new string[] { "colorValue", "vectorValue", "floatValue"};
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        var m_properties = property.FindPropertyRelative("properties");
        //EditorGUILayout.PropertyField(m_properties, true);
        m_properties.arraySize = EditorGUI.IntField(position,"Prpoerty Count", m_properties.arraySize);
        for (int i = 0; i < m_properties.arraySize; i++)
        {
            var m_p = m_properties.GetArrayElementAtIndex(i);
            GUILayout.BeginVertical("Box");
            EditorGUILayout.PropertyField(m_p, true);
            
            if(m_p.isExpanded)
            {
                var type = m_p.FindPropertyRelative("type");
                var targetProperty = m_p.FindPropertyRelative(typeValueNames[type.enumValueIndex]);
                GUILayout.BeginVertical("Box");
                GUILayout.BeginHorizontal();
                GUILayout.Space(20);
                EditorGUILayout.PropertyField(type);
                EditorGUILayout.EndHorizontal();
                GUILayout.BeginHorizontal();
                GUILayout.Space(20);
                EditorGUILayout.PropertyField(targetProperty);
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.EndVertical();
            }
            EditorGUILayout.EndVertical();
        }
        
        //EditorGUI.LabelField(position, "123");
        //EditorGUI.LabelField(position, "456");
    }
}
#endif