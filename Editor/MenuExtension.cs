using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;
using System;
using UnityEngine.Networking;
using System.IO;
using UnityEngine.U2D;
using System.Reflection;

public class MenuExtension
{
    public class CreateGameObjectMenu
    {
        [MenuItem("Edit/ZD/Convert Selection Material To CartoonShader")]
        public static void ConvertToCartoonMaterial()
        {
            foreach (var o in Selection.objects.ToList().FindAll(x => x.GetType() == typeof(Material)))
            {
                Material m = o as Material;
                var tex = m.GetTexture("_BaseMap") as Texture2D;
                m.shader = Shader.Find("ZDShader/LWRP/Character");
                m.SetTexture("_diffuse", tex);
            }
        }

        [MenuItem("ZD/Developer/Release Memory", false, 48)]
        static void ReleaseMemory()
        {
            Resources.UnloadUnusedAssets();
            GC.Collect();
        }

        [MenuItem("ZD/Partacles/Update Project Materials", false, 60)]
        static void Particles_UpdateProjectMaterials()
        {
            var mats = Resources.FindObjectsOfTypeAll<Material>();
            foreach (var m in mats)
            {
                string shader = m.shader.name;
                //Debug.Log(shader);
                string path = AssetDatabase.GetAssetPath(m);
                bool isParticle = shader.Contains("Mobile/Particles/");
                if (!isParticle) continue;
                Debug.Log(System.IO.Path.GetFileName(shader));
                m.shader = Shader.Find("ZDShader/LWRP/Particles/" + System.IO.Path.GetFileName(shader));

            }
        }

        static List<Material> SelectionMaterials
        {
            get
            {
                List<Material> mats = new List<Material>();
                foreach (var go in Selection.gameObjects)
                {
                    foreach (var r in go.GetComponentsInChildren<Renderer>())
                    {
                        foreach (var m in r.sharedMaterials)
                        {
                            if (!mats.Contains(m)) mats.Add(m);
                        }
                    }
                }
                return mats;
            }
        }
        [MenuItem("GameObject/Select Dependencies Materials", false, 47)]
        public static void SelectDependenciesMaterials()
        {
            Selection.objects = SelectionMaterials.ToArray();
            foreach (var o in Selection.objects)
            {
                EditorGUIUtility.PingObject(o);
            }
        }
        [MenuItem("GameObject/Select Dependencies Textures", false, 48)]
        public static void SelectDependenciesTextures()
        {
            List<Texture> texes = new List<Texture>();

            foreach (var m in SelectionMaterials)
            {
                for (int i = 0; i < ShaderUtil.GetPropertyCount(m.shader); i++)
                {
                    if (ShaderUtil.GetPropertyType(m.shader, i) == ShaderUtil.ShaderPropertyType.TexEnv)
                    {
                        string name = ShaderUtil.GetPropertyName(m.shader, i);
                        var tex = m.GetTexture(name);
                        if (!texes.Contains(tex)) texes.Add(tex);
                    }
                }
            }
            Selection.objects = texes.ToArray();
            foreach (var o in Selection.objects)
            {
                EditorGUIUtility.PingObject(o);
            }
        }


        [MenuItem("GameObject/Funcy/FPS Display UI", false, 46)]
        static void FPSDisplayUI()
        {
            var p = AssetDatabase.LoadAssetAtPath<GameObject>("Packages/com.zd.lwrp.funcy/Runtime/Prefab/FPSDisplayUI.prefab");
            var g = PrefabUtility.InstantiatePrefab(p) as GameObject;
            g.transform.SetAsLastSibling();

        }

        [MenuItem("GameObject/Volumetric Rendering/Directional Lighting", false, 49)]
        static void VolumetricRenderingLightingBox()
        {
            GameObject vl = GameObject.CreatePrimitive(PrimitiveType.Cube);
            vl.gameObject.name = "New Volumetic Directional Lighting Box";
            GameObject.DestroyImmediate(vl.GetComponent<Collider>());
            MeshFilter filter = vl.GetComponent<MeshFilter>();
            MeshRenderer renderer = vl.GetComponent<MeshRenderer>();
            vl.transform.position = Vector3.zero;
            vl.transform.rotation = Quaternion.identity;
            vl.transform.localScale = Vector3.one * 1000;
            renderer.sharedMaterial = new Material(Shader.Find("ZDShader/LWRP/Volume/Directional Lighting"));
            renderer.sharedMaterial.SetTextureScale("_ShadowRamp", Vector2.one * 16f);
            Selection.activeGameObject = vl;
        }

        [MenuItem("GameObject/Volumetric Rendering/Point Lighting", false, 50)]
        static void VolumetricRenderingPointLighting()
        {
            GameObject vl = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            vl.gameObject.name = "New Volumetic Point Lighting";
            GameObject.DestroyImmediate(vl.GetComponent<Collider>());
            MeshFilter filter = vl.GetComponent<MeshFilter>();
            MeshRenderer renderer = vl.GetComponent<MeshRenderer>();
            vl.transform.position = Vector3.zero;
            vl.transform.rotation = Quaternion.identity;
            vl.transform.localScale = Vector3.one * 50;
            renderer.sharedMaterial = new Material(Shader.Find("ZDShader/LWRP/Volume/Point Lighting"));
            renderer.sharedMaterial.SetTextureScale("_ShadowRamp", Vector2.one * 32f);
            Selection.activeGameObject = vl;
        }

        [MenuItem("GameObject/Volumetric Rendering/Lens Flare", false, 51)]
        static void VolumetricRenderingLensFlare()
        {
            GameObject vl = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            vl.gameObject.name = "New Flare";
            GameObject.DestroyImmediate(vl.GetComponent<Collider>());
            MeshFilter filter = vl.GetComponent<MeshFilter>();
            MeshRenderer renderer = vl.GetComponent<MeshRenderer>();
            vl.transform.position = Vector3.zero;
            vl.transform.rotation = Quaternion.identity;
            vl.transform.localScale = Vector3.one * 50;
            renderer.sharedMaterial = new Material(Shader.Find("ZDShader/LWRP/Volume/Lens Flare"));
            Selection.activeGameObject = vl;
        }
    }
    public class CreateAssetMenu
    {
        [MenuItem("Assets/ZD/複製變色RGB", true)]
        public static bool CopyDiscolorationInfo_Validator()
        {           
            return Selection.activeObject is Material && ((Material)Selection.activeObject).shader.name == "ZDShader/LWRP/Character";
        }
        [MenuItem("Assets/ZD/複製變色RGB", false, 1001)]
        public static void CopyDiscolorationInfo()
        {
            Material referenceMaterial = Selection.activeObject as Material;
            Color skinColor, eyesColor, hairColor, headressColor1, headressColor2, color1, color2, color3, color4;
            Color emissionColor, specularColor;
            Color shadowColor1, shadowColor2, shadowColor3;
            skinColor      = referenceMaterial.GetColor("_DiscolorationColor_1");
            eyesColor      = referenceMaterial.GetColor("_DiscolorationColor_2");
            hairColor      = referenceMaterial.GetColor("_DiscolorationColor_7");
            headressColor1 = referenceMaterial.GetColor("_DiscolorationColor_8");
            headressColor2 = referenceMaterial.GetColor("_DiscolorationColor_9");
            color1         = referenceMaterial.GetColor("_DiscolorationColor_3");
            color2         = referenceMaterial.GetColor("_DiscolorationColor_4");
            color3         = referenceMaterial.GetColor("_DiscolorationColor_5");
            color4         = referenceMaterial.GetColor("_DiscolorationColor_6");
            emissionColor  = referenceMaterial.GetColor("_EmissionColor");
            specularColor  = referenceMaterial.GetColor("_SpecularColor");
            shadowColor1   = referenceMaterial.GetColor("_ShadowColor0");
            shadowColor2   = referenceMaterial.GetColor("_ShadowColor1");
            shadowColor3   = referenceMaterial.GetColor("_ShadowColorElse");
            char tab = '	';

            GUIUtility.systemCopyBuffer = string.Format("{1}{0}{2}{0}{3}{0}{4}{0}{5}{0}{6}{0}{7}{0}{8}{0}{9}{0}{10}{0}{11}{0}{12}{0}{13}{0}{14}", tab,
                 ColorToSheetString(skinColor),
                 ColorToSheetString(eyesColor),
                 ColorToSheetString(hairColor),
                 ColorToSheetString(headressColor1),
                 ColorToSheetString(headressColor2),
                 ColorToSheetString(color1),
                 ColorToSheetString(color2),
                 ColorToSheetString(color3),
                 ColorToSheetString(color4),
                 ColorToSheetString(emissionColor),
                 ColorToSheetString(specularColor),
                 ColorToSheetString(shadowColor1),
                 ColorToSheetString(shadowColor2),
                 ColorToSheetString(shadowColor3)
                );
        }

        static string ColorToSheetString(Color c)
        {
            char tab = '	';
            return string.Format("{1}{0}{2}{0}{3}", tab, c.r.ToString("0.00"), c.g.ToString("0.00"), c.b.ToString("0.00"));
        }


        [MenuItem("Tools/Export atlases as PNG")]
        static void ExportAtlases()
        {
            string exportPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop) + "/Atlases";
            foreach (UnityEngine.Object obj in Selection.objects)
            {
                SpriteAtlas atlas = (SpriteAtlas)obj;
                if (atlas == null) continue;
                Debug.Log("Exporting selected atlas: " + atlas);

                // use reflection to run this internal editor method
                // UnityEditor.U2D.SpriteAtlasExtensions.GetPreviewTextures
                // internal static extern Texture2D[] GetPreviewTextures(this SpriteAtlas spriteAtlas);
                Type type = typeof(UnityEditor.U2D.SpriteAtlasExtensions);
                MethodInfo methodInfo = type.GetMethod("GetPreviewTextures", BindingFlags.Static | BindingFlags.NonPublic);
                if (methodInfo == null)
                {
                    Debug.LogWarning("Failed to get UnityEditor.U2D.SpriteAtlasExtensions");
                    return;
                }
                Texture2D[] textures = (Texture2D[])methodInfo.Invoke(null, new object[] { atlas });
                if (textures == null)
                {
                    Debug.LogWarning("Failed to get texture results");
                    continue;
                }

                foreach (Texture2D texture in textures)
                {
                    // these textures in memory are not saveable so copy them to a RenderTexture first
                    Texture2D textureCopy = DuplicateTexture(texture);
                    if (!Directory.Exists(exportPath)) Directory.CreateDirectory(exportPath);
                    string filename = exportPath + "/" + texture.name + ".png";
                    FileStream fs = new FileStream(filename, FileMode.Create);
                    BinaryWriter bw = new BinaryWriter(fs);
                    bw.Write(textureCopy.EncodeToPNG());
                    bw.Close();
                    fs.Close();
                    Debug.Log("Saved texture to " + filename);
                }
            }
        }


        private static Texture2D DuplicateTexture(Texture2D source)
        {
            RenderTexture renderTex = RenderTexture.GetTemporary(
                source.width,
                source.height,
                0,
                RenderTextureFormat.Default,
                RenderTextureReadWrite.Linear);

            Graphics.Blit(source, renderTex);
            RenderTexture previous = RenderTexture.active;
            RenderTexture.active = renderTex;
            Texture2D readableText = new Texture2D(source.width, source.height);
            readableText.ReadPixels(new Rect(0, 0, renderTex.width, renderTex.height), 0, 0);
            readableText.Apply();
            RenderTexture.active = previous;
            RenderTexture.ReleaseTemporary(renderTex);
            return readableText;
        }
    }

    public class SendData : IMultipartFormSection
    {
        public string sectionName => throw new NotImplementedException();

        public byte[] sectionData => throw new NotImplementedException();

        public string fileName => throw new NotImplementedException();

        public string contentType => throw new NotImplementedException();
    }
}
