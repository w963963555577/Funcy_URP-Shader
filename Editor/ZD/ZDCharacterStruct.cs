using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if ZD_ART_EDITOR
using LitJson;
#endif
namespace UnityEditor.Rendering.Funcy.URP.ShaderGUI
{
    [InitializeOnLoad]
    public class ReleaseEditorPrefs : Editor
    {
        static ReleaseEditorPrefs()
        {
            EditorApplication.quitting += () => {
                EditorPrefs.DeleteKey("ZDCharacter-Effective");
                EditorPrefs.DeleteKey("ZDCharacter-DiscolorationSystem");
                EditorPrefs.DeleteKey("ZDCharacter-ShadowReplacer");
            };
        }
    }
    public class ColorJson
    {
        public float r;
        public float g;
        public float b;
        public float a;        
    }

    #region ShadowReplacer
    [System.Serializable]
    public class Effective
    {
        public float emissionOn, emissionxBase, emissionFlow, gloss, edgeLightWidth, edgeLightIntensity;
        public ColorJson emissionColor, specularColor;
        public static void Copy(Material m)
        {
            Effective effective = new Effective()
            {
                emissionOn = m.GetFloat("_EmissionOn"),
                emissionxBase = m.GetFloat("_EmissionxBase"),
                emissionFlow = m.GetFloat("_EmissionFlow"),
                gloss = m.GetFloat("_Gloss"),
                edgeLightWidth = m.GetFloat("_EdgeLightWidth"),
                edgeLightIntensity = m.GetFloat("_EdgeLightIntensity"),
                emissionColor = m.GetColor("_EmissionColor").ToColorJson(),
                specularColor = m.GetColor("_SpecularColor").ToColorJson(),
            };
            #if ZD_ART_EDITOR
            var json = JsonMapper.ToJson(effective);
            EditorPrefs.SetString("ZDCharacter-Effective", json);
            #endif
        }

        public static bool CanPaste()
        {
            string json = EditorPrefs.GetString("ZDCharacter-Effective");
            return !string.IsNullOrEmpty(json);
        }
        public static void Paste(Material m)
        {
            #if ZD_ART_EDITOR
            string json = EditorPrefs.GetString("ZDCharacter-Effective");
            var effective = JsonMapper.ToObject<Effective>(json);

            m.SetFloat("_EmissionOn", effective.emissionOn);
            m.SetFloat("_EmissionxBase", effective.emissionxBase);
            m.SetFloat("_EmissionFlow", effective.emissionFlow);
            m.SetFloat("_Gloss", effective.gloss);
            m.SetFloat("_EdgeLightWidth", effective.edgeLightWidth);
            m.SetFloat("_EdgeLightIntensity", effective.edgeLightIntensity);
            m.SetColor("_EmissionColor", effective.emissionColor.ToColor());
            m.SetColor("_SpecularColor", effective.specularColor.ToColor());

            AssetDatabase.SaveAssets();
            #endif
        }
    }
#endregion ShadowReplacer

#region DiscolorationSystem
    [System.Serializable]
    public class DiscolorationSystem
    {
        public float enable;
        public float useColorCount ;
        public ColorJson skinColor, eyesColor, hairColor, headressColor1, headressColor2, color1, color2, color3, color4;
        public static void Copy(Material m)
        {
            DiscolorationSystem discolorationSystem = new DiscolorationSystem()
            {
                enable = m.GetFloat("_DiscolorationSystem"),
                useColorCount = m.GetFloat("_DiscolorationColorCount"),
                skinColor = m.GetColor("_DiscolorationColor_1").ToColorJson(),
                eyesColor = m.GetColor("_DiscolorationColor_2").ToColorJson(),
                color1 = m.GetColor("_DiscolorationColor_3").ToColorJson(),
                color2 = m.GetColor("_DiscolorationColor_4").ToColorJson(),
                color3 = m.GetColor("_DiscolorationColor_5").ToColorJson(),
                color4 = m.GetColor("_DiscolorationColor_6").ToColorJson(),
                hairColor = m.GetColor("_DiscolorationColor_7").ToColorJson(),
                headressColor1 = m.GetColor("_DiscolorationColor_8").ToColorJson(),
                headressColor2 = m.GetColor("_DiscolorationColor_9").ToColorJson(),
            };
            #if ZD_ART_EDITOR
            var json = JsonMapper.ToJson(discolorationSystem);
            
            EditorPrefs.SetString("ZDCharacter-DiscolorationSystem", json);
            #endif
        }

        public static bool CanPaste()
        {
            string json = EditorPrefs.GetString("ZDCharacter-DiscolorationSystem");
            return  !string.IsNullOrEmpty(json);            
        }
        public static void Paste(Material m)
        {
            #if ZD_ART_EDITOR
            string json = EditorPrefs.GetString("ZDCharacter-DiscolorationSystem");
            var discolorationSystem = JsonMapper.ToObject<DiscolorationSystem>(json);
            m.SetFloat("_DiscolorationSystem", discolorationSystem.enable);
            m.SetFloat("_DiscolorationColorCount", discolorationSystem.useColorCount);
            m.SetColor("_DiscolorationColor_1", discolorationSystem.skinColor.ToColor());
            m.SetColor("_DiscolorationColor_2", discolorationSystem.eyesColor.ToColor());
            m.SetColor("_DiscolorationColor_3", discolorationSystem.color1.ToColor());
            m.SetColor("_DiscolorationColor_4", discolorationSystem.color2.ToColor());
            m.SetColor("_DiscolorationColor_5", discolorationSystem.color3.ToColor());
            m.SetColor("_DiscolorationColor_6", discolorationSystem.color4.ToColor());
            m.SetColor("_DiscolorationColor_7", discolorationSystem.hairColor.ToColor());
            m.SetColor("_DiscolorationColor_8", discolorationSystem.headressColor1.ToColor());
            m.SetColor("_DiscolorationColor_9", discolorationSystem.headressColor2.ToColor());
            AssetDatabase.SaveAssets();
            #endif
        }
    }
#endregion DiscolorationSystem

#region ShadowReplacer
    [System.Serializable]
    public class ShadowReplacer
    {
        public ColorJson picker0, picker1, picker2, picker3, picker4, picker5, picker6, picker7, picker8, picker9, picker10, picker11;
        public ColorJson shadowColor0, shadowColor1, shadowColor2, shadowColor3, shadowColor4, shadowColor5, shadowColor6, shadowColor7, shadowColor8, shadowColor9, shadowColor10, shadowColor11, shadowColorElse;
        public static void Copy(Material m)
        {
            ShadowReplacer shadowReplacer = new ShadowReplacer()
            {                                
                picker0 = m.GetColor("_Picker_0").ToColorJson(),
                picker1 = m.GetColor("_Picker_1").ToColorJson(),
                picker2 = m.GetColor("_Picker_2").ToColorJson(),
                picker3 = m.GetColor("_Picker_3").ToColorJson(),
                picker4 = m.GetColor("_Picker_4").ToColorJson(),
                picker5 = m.GetColor("_Picker_5").ToColorJson(),
                picker6 = m.GetColor("_Picker_6").ToColorJson(),
                picker7 = m.GetColor("_Picker_7").ToColorJson(),
                picker8 = m.GetColor("_Picker_8").ToColorJson(),
                picker9 = m.GetColor("_Picker_9").ToColorJson(),
                picker10 = m.GetColor("_Picker_10").ToColorJson(),
                picker11 = m.GetColor("_Picker_11").ToColorJson(),
                shadowColor0 = m.GetColor("_ShadowColor0").ToColorJson(),
                shadowColor1 = m.GetColor("_ShadowColor1").ToColorJson(),
                shadowColor2 = m.GetColor("_ShadowColor2").ToColorJson(),
                shadowColor3 = m.GetColor("_ShadowColor3").ToColorJson(),
                shadowColor4 = m.GetColor("_ShadowColor4").ToColorJson(),
                shadowColor5 = m.GetColor("_ShadowColor5").ToColorJson(),
                shadowColor6 = m.GetColor("_ShadowColor6").ToColorJson(),
                shadowColor7 = m.GetColor("_ShadowColor7").ToColorJson(),
                shadowColor8 = m.GetColor("_ShadowColor8").ToColorJson(),
                shadowColor9 = m.GetColor("_ShadowColor9").ToColorJson(),
                shadowColor10 = m.GetColor("_ShadowColor10").ToColorJson(),
                shadowColor11 = m.GetColor("_ShadowColor11").ToColorJson(),
                shadowColorElse = m.GetColor("_ShadowColorElse").ToColorJson(),
            };
#if ZD_ART_EDITOR
            var json = JsonMapper.ToJson(shadowReplacer);

            EditorPrefs.SetString("ZDCharacter-ShadowReplacer", json);
#endif
        }

        public static bool CanPaste()
        {
            string json = EditorPrefs.GetString("ZDCharacter-ShadowReplacer");
            return !string.IsNullOrEmpty(json);
        }
        public static void Paste(Material m)
        {
            #if ZD_ART_EDITOR
            string json = EditorPrefs.GetString("ZDCharacter-ShadowReplacer");
            var shadowReplacer = JsonMapper.ToObject<ShadowReplacer>(json);
            
            m.SetColor("_Picker_0", shadowReplacer.picker0.ToColor());
            m.SetColor("_Picker_1", shadowReplacer.picker1.ToColor());
            m.SetColor("_Picker_2", shadowReplacer.picker2.ToColor());
            m.SetColor("_Picker_3", shadowReplacer.picker3.ToColor());
            m.SetColor("_Picker_4", shadowReplacer.picker4.ToColor());
            m.SetColor("_Picker_5", shadowReplacer.picker5.ToColor());
            m.SetColor("_Picker_6", shadowReplacer.picker6.ToColor());
            m.SetColor("_Picker_7", shadowReplacer.picker7.ToColor());
            m.SetColor("_Picker_8", shadowReplacer.picker8.ToColor());
            m.SetColor("_Picker_9", shadowReplacer.picker9.ToColor());
            m.SetColor("_Picker_10", shadowReplacer.picker10.ToColor());
            m.SetColor("_Picker_11", shadowReplacer.picker11.ToColor());

            m.SetColor("_ShadowColor0", shadowReplacer.shadowColor0.ToColor());
            m.SetColor("_ShadowColor1", shadowReplacer.shadowColor1.ToColor());
            m.SetColor("_ShadowColor2", shadowReplacer.shadowColor2.ToColor());
            m.SetColor("_ShadowColor3", shadowReplacer.shadowColor3.ToColor());
            m.SetColor("_ShadowColor4", shadowReplacer.shadowColor4.ToColor());
            m.SetColor("_ShadowColor5", shadowReplacer.shadowColor5.ToColor());
            m.SetColor("_ShadowColor6", shadowReplacer.shadowColor6.ToColor());
            m.SetColor("_ShadowColor7", shadowReplacer.shadowColor7.ToColor());
            m.SetColor("_ShadowColor8", shadowReplacer.shadowColor8.ToColor());
            m.SetColor("_ShadowColor9", shadowReplacer.shadowColor9.ToColor());
            m.SetColor("_ShadowColor10", shadowReplacer.shadowColor10.ToColor());
            m.SetColor("_ShadowColor11", shadowReplacer.shadowColor11.ToColor());
            m.SetColor("_ShadowColorElse", shadowReplacer.shadowColorElse.ToColor());
            AssetDatabase.SaveAssets();
            #endif
        }
    }
#endregion ShadowReplacer


    public static class Extension
    {
        public static ColorJson ToColorJson(this Color c)
        {
            return new ColorJson() { r = c.r, g = c.g, b = c.b, a = c.a };
        }
        public static Color ToColor(this ColorJson c)
        {
            return new Color() { r = c.r, g = c.g, b = c.b, a = c.a };
        }
    }
}