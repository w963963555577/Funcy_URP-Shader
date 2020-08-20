using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;
using System;
using UnityEngine.Networking;
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
        [MenuItem("Assets/ZD/Update Material Property to Google Sheets",true)]
        public static bool UpdateMaterialPropertyToGoogleSheets_Validator()
        {           
            return Selection.activeObject is Material && ((Material)Selection.activeObject).shader.name == "ZDShader/LWRP/Character";
        }
        [MenuItem("Assets/ZD/Update Material Property to Google Sheets", false, 1001)]
        public static void UpdateMaterialPropertyToGoogleSheets()
        {
            string url = "https://script.google.com/macros/s/AKfycbzO4imjFLeMWQ-e-mYGbt3hXk96_-hBUHRQQiiL6nN4hhvCL5Q/exec";
            WWWForm form = new WWWForm();
            form.AddField("sheetName", "Skin-Eyes-Hair");
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
