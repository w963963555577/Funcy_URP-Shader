using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
#if UNITY_EDITOR
using UnityEditor;
[InitializeOnLoad]
public class GameObjectReplacer : EditorWindow
{
    private void OnEnable()
    {
        EditorApplication.update += Repaint;
    }
    private void OnDisable()
    {
        EditorApplication.update -= Repaint;
    }
    static GameObjectReplacer window = null;
    [MenuItem("ZD/Editor/GameObject Replacer")]
    public static void Open()
    {
        window = EditorWindows.Open<GameObjectReplacer>("GameObject Replacer");
        window.Focus();
    }

    [SerializeField] GameObject targetPrefab;
    public bool copyRotaton = true;
    public bool copyScale = false;
    string errMes = "Error: ";

    List<System.Action> undoAction = new List<System.Action>();
    List<System.Action> redoAction = new List<System.Action>();
    private void OnGUI()
    {
        targetPrefab = EditorGUILayout.ObjectField("Target Prefab", targetPrefab, typeof(GameObject), false) as GameObject;
        

        GUILayout.FlexibleSpace();
        GUIButton("Replace", () => {
            if(targetPrefab == null)
            {
                return;
            }
            redoAction.Add(() => {
                List<GameObject> origGameObjects = new List<GameObject>();
                origGameObjects = Selection.gameObjects.ToList() ;
                List<GameObject> newsGameObjects = new List<GameObject>();
                foreach (var selection in origGameObjects)
                {
                    if (selection.scene.name == null) continue;
                    GameObject i = PrefabUtility.InstantiatePrefab(targetPrefab, selection.transform.parent) as GameObject;
                    newsGameObjects.Add(i);
                    i.transform.position = selection.transform.position;
                    if (copyRotaton)
                        i.transform.rotation = selection.transform.rotation;
                    if (copyScale)
                        i.transform.localScale = selection.transform.localScale;

                    DestroyImmediate(selection);
                }
                Selection.objects = newsGameObjects.ToArray();
            });

            redoAction[redoAction.Count - 1]?.Invoke();

        });
        copyRotaton = EditorGUILayout.Toggle("Copy Rotation", copyRotaton);
        copyScale   = EditorGUILayout.Toggle("Copy Scale", copyScale);

        EditorGUILayout.BeginHorizontal();
        GUIButton("Undo", () => {

        });
        GUIButton("Redo", () => { });
        EditorGUILayout.EndHorizontal();


    }

    bool GUIButton(string buttonName,System.Action action)
    {
        bool isClick = false;
        isClick = GUILayout.Button(buttonName);
        if (isClick) action?.Invoke();
        return isClick;
    }
}
#endif