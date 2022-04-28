
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine.UIElements;
#endif

public class ZDUniversalRenderFeature : ScriptableRendererFeature
{
    public static ForwardRendererData rootRenderer;
    public static List<RadialBlurControl> radialBlurControls = new List<RadialBlurControl>();
    public MobileBloomPass.Settings settings = new MobileBloomPass.Settings();
    public PassCatchDatas passCatchDatas = new PassCatchDatas();
    public RadiusBlurSettings radiusBlurSettings = new RadiusBlurSettings();
    MobileBloomPass bloomPass;
    
    public override void Create()
    {
        bloomPass = new MobileBloomPass(settings, radiusBlurSettings);
        UniversalRenderPipelineAsset pipelineAsset = QualitySettings.GetRenderPipelineAssetAt(QualitySettings.GetQualityLevel()) as UniversalRenderPipelineAsset;
        FieldInfo fieldInfo = pipelineAsset.GetType().GetField("m_RendererDataList", BindingFlags.Instance | BindingFlags.NonPublic);
        ScriptableRendererData[] rendererDatas = fieldInfo.GetValue(pipelineAsset) as UnityEngine.Rendering.Universal.ScriptableRendererData[];
        rootRenderer = rendererDatas.ToList().Find(x => x.name == "BloomRenderer") as ForwardRendererData;
        passCatchDatas.m_MRTOpaque.SetActive(false);
        passCatchDatas.m_MRTTerrain.SetActive(false);
#if (UNITY_EDITOR && (UNITY_ANDROID || UNITY_STANDALONE_WIN)) || (UNITY_ANDROID || UNITY_STANDALONE_WIN)
        DefaultSetting();
#elif (UNITY_EDITOR && (UNITY_IPHONE || UNITY_STANDALONE_OSX)) || (UNITY_IPHONE || UNITY_STANDALONE_OSX)
        iOSSetting();
#endif
        passCatchDatas.m_MRTOpaque.SetActive(true);
        passCatchDatas.m_MRTTerrain.SetActive(true);
    }

    void DefaultSetting()
    {
        rootRenderer.opaqueLayerMask = -1;
        rootRenderer.transparentLayerMask = -1;
        passCatchDatas.m_MRTOpaque.settings.eventIndexOffset = 0;
        passCatchDatas.m_MRTTerrain.settings.eventIndexOffset = 0;
        passCatchDatas.m_UniversalForwardOpaque.settings.active = false;
    }
    void iOSSetting()
    {
        rootRenderer.opaqueLayerMask = 0;
        rootRenderer.transparentLayerMask = 0;
        passCatchDatas.m_MRTOpaque.settings.eventIndexOffset = 50;
        passCatchDatas.m_MRTTerrain.settings.eventIndexOffset = 50;
        passCatchDatas.m_UniversalForwardOpaque.settings.active = true;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        bloomPass.Setup(renderer.cameraColorTarget);
        renderer.EnqueuePass(bloomPass);
    }

    [System.Serializable]
    public class RadiusBlurSettings
    {
        [System.NonSerialized] public float blurStrength = 0;
        [System.NonSerialized] public float blurWidth = 0f;
        [System.NonSerialized] public Vector3 worldPosition;
    }

    static RadiusBlurSettings m_RadiusBlurSettings;
    public static RadiusBlurSettings GetRadiusBlurSettings()
    {
        if (m_RadiusBlurSettings != null)
        {
            return m_RadiusBlurSettings;
        }
        
        ZDUniversalRenderFeature urf = rootRenderer.rendererFeatures.Find(x => x.GetType() == typeof(ZDUniversalRenderFeature)) as ZDUniversalRenderFeature;
        m_RadiusBlurSettings= urf.radiusBlurSettings;
        return m_RadiusBlurSettings;
    }
    [System.Serializable]
    public class PassCatchDatas
    {
        public bool test = false;
        public MRTPass m_MRTOpaque;
        public MRTPass m_MRTTerrain;
        public MRTPass m_UniversalForwardOpaque;
    }
}
#if UNITY_EDITOR
// IngredientDrawerUIE
[CustomPropertyDrawer(typeof(ZDUniversalRenderFeature.RadiusBlurSettings))]
public class RadiusBlurSettings_Editor : PropertyDrawer
{
    const string toggleKeyword = "ZDUniversalRenderFeature.RadiusBlurSettings";
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        var data = ZDUniversalRenderFeature.GetRadiusBlurSettings();

        bool isExpanded = EditorGUILayout.Foldout(EditorPrefs.GetBool(toggleKeyword), "Radius Blur Settings(NonSerialized)");
        if (isExpanded != EditorPrefs.GetBool(toggleKeyword))
        {
            EditorPrefs.SetBool(toggleKeyword, isExpanded);
        }
        if(isExpanded)
        {
            EditorGUI.indentLevel = 1;
            data.blurStrength = EditorGUILayout.FloatField("Strength", data.blurStrength);
            data.blurWidth = EditorGUILayout.FloatField("Width", data.blurWidth);
            EditorGUI.indentLevel = 0;
        }
    }
}
#endif