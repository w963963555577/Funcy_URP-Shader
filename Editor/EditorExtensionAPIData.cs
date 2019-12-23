using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
using UnityEngine.Events;
using UnityEditor;

using System;
using System.Linq.Expressions;
using UnityEditor.AnimatedValues;

public class EditorExtensionAPIData : ScriptableObject
{
    public static Action<string> OnAddFile, OnDeleteFile;
    public static Action OnAddFiles, OnDeleteFiles;
    public static EditorExtensionAPIData data;

    public List<string> AllAssetPath = new List<string>();

    public void onAddFiles(List<string> addFileList)
    {
        try { OnAddFiles(); } catch { };
        foreach (var file in addFileList) try { OnAddFile(file.toAssetsPath()); } catch { };

    }
    public void onDeleteFiles(List<string> deleteFileList)
    {
        try { OnDeleteFiles(); } catch { };
        foreach (var file in deleteFileList) try { OnDeleteFile(file.toAssetsPath()); } catch { }
    }
}

namespace UnityEditor
{
    [CustomEditor(typeof(EditorExtensionAPIData))]
    public class EditorExtensionAPIData_Editor : Editor
    {
        public override void OnInspectorGUI()
        {
            var data = target as EditorExtensionAPIData;
            GUILayout.Label("FileCount: " + data.AllAssetPath.Count.ToString());
        }
    }


    [InitializeOnLoad]
    public class EditorWindows
    {
        static EditorWindows()
        {
            Create("EditorExtensionAPIData");
            Project.Awake(); Hierarchy.Awake();
        }
        public static T Open<T>(string title = "", bool utility = false) where T : EditorWindow
        {
            var windows = AllWindows.FindAll(x => x.GetType() == typeof(T));
            title = title == "" ? typeof(T).Name : title;
            var window = windows.Count > 0 ? windows[0] : EditorWindow.GetWindow<T>(utility, title);

            return (T)window;
        }

        public static List<T> Open<T>(int maxCount, string title = "", bool utility = false) where T : EditorWindow
        {
            var currentWindows = AllWindows.FindAll(x => x.GetType() == typeof(T));
            title = title == "" ? typeof(T).Name : title;
            List<T> windows = new List<T>();
            foreach (var w in currentWindows) windows.Add((T)w);
            return windows;
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
        [SerializeField] static List<AnimBoolNameId> animBools = new List<AnimBoolNameId>();
        public static void DrawArea(string text, Action onGUI, bool defaultValue = true, float fadeSpeed = 3.0f, string style = "ShurikenModuleTitle", bool hasArrow = true)
        {
            string key = text;
            bool state = EditorPrefs.GetBool(key, defaultValue);

            if (animBools.Find(a => a.name == text) == null)
            {
                var newAnimBool = new AnimBoolNameId(text, state);
                newAnimBool.animBool.speed = fadeSpeed;
                animBools.Add(newAnimBool);
            }

            var currentAnimBool = animBools.Find(a => a.name == text);

            GUILayout.BeginHorizontal();
            {
                GUI.changed = false;

                text = "<b><size=11>" + text + "</size></b>";
                if (state) text = (hasArrow ? "\u25BC " : "") + text;
                else text = (hasArrow ? "\u25BA " : "") + text;
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


        #region    Properties      
        static List<EditorWindow> AllWindows
        {
            get
            {
                return Resources.FindObjectsOfTypeAll<EditorWindow>().ToList();
            }
        }

        static void Create(string fileName, string assetPath = "Assets")
        {
            if (!EditorExtensionAPIData.data)
                EditorExtensionAPIData.data = Project.CreateCannotBeDeleteObject<EditorExtensionAPIData>("EditorExtensionAPIData");
            EditorApplication.projectWindowChanged += delegate
            {
                if (!EditorExtensionAPIData.data)
                    EditorExtensionAPIData.data = Project.CreateCannotBeDeleteObject<EditorExtensionAPIData>("EditorExtensionAPIData");
            };

        }

        #endregion  Properties      

    }

    public class Project
    {

        public static void Awake()
        {
            var all = allAssetPath;

            if (EditorExtensionAPIData.data == null) return;

            if (EditorExtensionAPIData.data.AllAssetPath.Count != all.Count)
            {
                EditorExtensionAPIData.data.AllAssetPath = all;
            }

            EditorApplication.projectChanged += delegate
            {
                if (EditorExtensionAPIData.data == null) return;
                all = allAssetPath;
                if (EditorExtensionAPIData.data.AllAssetPath.Count != all.Count)
                {
                    if (EditorExtensionAPIData.data.AllAssetPath.Count < all.Count)
                        EditorExtensionAPIData.data.onAddFiles(all.FindAll(x => !EditorExtensionAPIData.data.AllAssetPath.Contains(x)));
                    if (EditorExtensionAPIData.data.AllAssetPath.Count > all.Count)
                        EditorExtensionAPIData.data.onDeleteFiles(EditorExtensionAPIData.data.AllAssetPath.FindAll(x => !all.Contains(x)));
                    EditorExtensionAPIData.data.AllAssetPath = all;

                }
            };
        }

        public static T CreateCannotBeDeleteObject<T>(string fileName, string assetPath = "Assets") where T : ScriptableObject
        {
            try
            {
                if (Resources.FindObjectsOfTypeAll<T>().Length == 0 || Resources.FindObjectsOfTypeAll<T>().ToList().Find(x => x.name == fileName) == null)
                {
                    ScriptableObject asset = ScriptableObject.CreateInstance<T>();
                    if (!Directory.Exists(Application.dataPath + "/Editor"))
                        Directory.CreateDirectory(Application.dataPath + "/Editor");
                    AssetDatabase.CreateAsset(asset, assetPath + "/Editor/" + fileName + ".asset");

                }
                EditorApplication.projectChanged += delegate
                {
                    if (Resources.FindObjectsOfTypeAll<T>().Length == 0 || Resources.FindObjectsOfTypeAll<T>().ToList().Find(x => x.name == fileName) == null)
                    {
                        ScriptableObject asset = ScriptableObject.CreateInstance<T>();
                        if(!Directory.Exists(Application.dataPath+ "/Editor"))
                            Directory.CreateDirectory(Application.dataPath + "/Editor");
                        AssetDatabase.CreateAsset(asset, assetPath + "/Editor/" + fileName + ".asset");
                        //Debug.Log(fileName + "曰 : " + "你刪不掉  (́◉◞౪◟◉‵). ヽ(́◕◞౪◟◕‵)ﾉ.");
                    }
                };

                return Resources.FindObjectsOfTypeAll<T>().ToList().Find(x => x.name == fileName);
            }
            catch
            {
                return null;
            }
        }

        public static bool Exist(string childPah)
        {
            return Directory.Exists(Application.dataPath + "/" + childPah);
        }

        public static bool AssetExistOfType<T>() where T : UnityEngine.Object
        {
            return EditorExtensionAPIData.data.AllAssetPath.Find(x => AssetDatabase.LoadAssetAtPath<T>(x.toAssetsPath()) != null) != null;
        }
        /*
                public static List<T> FindAssetsOfType<T>() where T : UnityEngine.Object
                {
                    var resultFiles = EditorExtensionAPIData.data.AllAssetPath.FindAll(x => AssetDatabase.LoadAssetAtPath<T>(x.toAssetsPath()) != null);
                    List<T> resultAssets = new List<T>();
                    foreach (var s in resultFiles) resultAssets.Add((T)AssetDatabase.LoadAssetAtPath(s.toAssetsPath(), typeof(T)));
                    return resultAssets;
                }
        */
        #region    Properties

        public List<string> AllAssetPath { get { return EditorExtensionAPIData.data.AllAssetPath; } }

        static List<string> allAssetPath
        {
            get
            {
                List<string> allFiles = Directory.GetFiles(Application.dataPath, "*.*", SearchOption.AllDirectories).Where(s => !s.EndsWith(".meta")).ToList();
                return allFiles;
            }
        }

        #endregion  Properties
    }


    public class Hierarchy
    {
        public static void Awake()
        {
            EditorApplication.hierarchyWindowItemOnGUI += DrawIconOnWindowItem;
        }
        static List<GameObject> drawingObject = new List<GameObject>();
        static List<Texture2D> drawingIcon = new List<Texture2D>();

        static List<Color> drawingColor = new List<Color>();
        #region DrawIcon        
        public static void DrawIconInHierarchy(UnityEngine.Object @object, GameObject go, Color textColor)
        {
            if (!drawingObject.Contains(go))
            {
                drawingObject.Add(go);
                var icon = (Texture2D)EditorGUIUtility.ObjectContent(@object, @object.GetType()).image;
                drawingIcon.Add(icon);
                drawingColor.Add(textColor);
            }
        }

        private static void DrawIconOnWindowItem(int instanceID, Rect rect)
        {
            GameObject gameObject = EditorUtility.InstanceIDToObject(instanceID) as GameObject;
            if (!drawingObject.Contains(gameObject)) return;
            int index = drawingObject.IndexOf(gameObject);

            float iconWidth = 15;
            EditorGUIUtility.SetIconSize(new Vector2(iconWidth, iconWidth));
            var padding = new Vector2(5, 0);
            var iconDrawRect = new Rect(
                                   rect.xMax - (iconWidth + padding.x),
                                   rect.yMin,
                                   rect.width,
                                   rect.height);
            var iconGUIContent = new GUIContent(drawingIcon[index]);
            EditorGUI.LabelField(iconDrawRect, iconGUIContent);

            var fixRect = rect;
            fixRect.x -= 2;
            fixRect.y += 1;
            var contentColorTmp = GUI.contentColor;
            var backGdColorTmp = GUI.backgroundColor;
            GUI.contentColor = drawingColor[index];
            GUI.backgroundColor = Color.clear;
            EditorGUI.LabelField(fixRect, gameObject.name);
            GUI.contentColor = contentColorTmp;
            GUI.backgroundColor = backGdColorTmp;

            EditorGUIUtility.SetIconSize(Vector2.zero);
        }
        #endregion

        #region  Operation
        public static void ApplyPrefab(GameObject target)
        {
            var instanceRoot = PrefabUtility.FindRootGameObjectWithSameParentPrefab(target.gameObject);
            var targetPrefab = PrefabUtility.GetPrefabParent(instanceRoot);

            PrefabUtility.ReplacePrefab(
                    instanceRoot,
                    targetPrefab,
                    ReplacePrefabOptions.ConnectToPrefab
                    );
        }

        #endregion
    }

    public static class ExtensionData
    {
        #region    EditorWindows
        #endregion EditorWindows

        #region    Project
        public static string toAssetsPath(this string path)
        {
            return path.Replace(Application.dataPath, "Assets").Replace(@"\", "/");
        }
        #endregion Project
    }
    [System.Serializable] public class StringListEvent : UnityEngine.Events.UnityEvent<List<string>> { }
}

