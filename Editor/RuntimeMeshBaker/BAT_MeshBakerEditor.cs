using UnityEngine;
using bat.util;
using UnityEditor;
using bat.opt.bake;



[CustomEditor(typeof(BAT_MeshBaker))]
public class BAT_MeshBakerEditor : Editor
{
    private BAT_MeshBaker m_meshBaker;
    void OnEnable()
    {
        if (Application.isPlaying)
        {
            return;
        }
    }
    public override void OnInspectorGUI()
    {
        m_meshBaker = (BAT_MeshBaker)target;
        BAT_UIUtil.RememberColor();

        EditorGUILayout.Separator();

        //【begin of all settings
        GUI.backgroundColor = Color.white;
        EditorGUILayout.BeginVertical("ProgressBarBack");

        //【begin of head region

        EditorGUILayout.BeginVertical("ProgressBarBack");

        //logo
        GUI.backgroundColor = BAT_UIUtil.Color_LogoBg;
        EditorGUILayout.BeginHorizontal("HelpBox");
        GUILayout.FlexibleSpace();
        GUILayout.Label(new GUIContent("Runtime Mesh Baker v1.2.0"));
        GUILayout.FlexibleSpace();
        EditorGUILayout.EndHorizontal();

        //end of logo

        GUI.backgroundColor = BAT_UIUtil.Color_LightGray;
        EditorGUILayout.Space();
        //【begin of setting title
        EditorGUILayout.BeginHorizontal();
        GUI.contentColor = BAT_UIUtil.Color_LightGray;
        GUILayout.Label("Settings", "GUIEditor.BreadcrumbLeft");

        EditorGUILayout.Space();

        EditorGUILayout.EndHorizontal();
        //endof of setting title】

        //set global definition
        BAT_UIUtil.ResetColor();
        EditorGUILayout.BeginVertical();
        var autoBake = EditorGUILayout.Toggle("Auto Bake", m_meshBaker.m_autoBake);
        if (autoBake != m_meshBaker.m_autoBake)
        {
            Undo();
            m_meshBaker.m_autoBake = autoBake;
        }
        var _seperateShadow = EditorGUILayout.Toggle("Seperate Shadow", m_meshBaker.m_seprateShadow);
        if (_seperateShadow != m_meshBaker.m_seprateShadow)
        {
            Undo();
            m_meshBaker.m_seprateShadow = _seperateShadow;
        }
        var _regionSize = EditorGUILayout.IntField("Region Size", m_meshBaker.m_regionSize);
        if (_regionSize != m_meshBaker.m_regionSize)
        {
            Undo();
            m_meshBaker.m_regionSize = _regionSize;
        }
        var _showRegionGizmo = EditorGUILayout.Toggle("Show Region Gizmo", m_meshBaker.m_showRegionGizmo);
        if (_showRegionGizmo != m_meshBaker.m_showRegionGizmo)
        {
            Undo();
            m_meshBaker.m_showRegionGizmo = _showRegionGizmo;
            SceneView.lastActiveSceneView.Repaint();
        }

        if (GUILayout.Button("Rebake"))
        {
            m_meshBaker.StartBake();
        }

        EditorGUILayout.EndVertical();

        EditorGUILayout.EndVertical();
        //endof of head region】

        EditorGUILayout.EndVertical();
        //end of all settings】

        BAT_UIUtil.ResetColor();

    }

    [MenuItem("Window/Runtime Mesh Baker/Add MeshBaker")]
    public static void AddMeshBaker()
    {
        var targetGO = UnityEditor.Selection.activeGameObject as GameObject;
        if (targetGO != null)
        {
            BAT_BakerBase childItem = targetGO.GetComponentInChildren<BAT_BakerBase>();
            if (childItem != null)
            {
                BAT_UIUtil.ShowWarning("You don't need two Bakers in the same tree,because it exist in " + childItem.name);
                return;
            }
            BAT_BakerBase parentItem = targetGO.GetComponentInParent<BAT_BakerBase>();
            if (parentItem != null)
            {
                BAT_UIUtil.ShowWarning("You don't need two Bakers in the same tree,because it exist in " + parentItem.name);
                return;
            }
            BAT_EdtUtil.Undo_AddComponent<BAT_MeshBaker>(targetGO);
        }
    }

    private void Undo()
    {
        if (m_meshBaker != null)
        {
            BAT_EdtUtil.Undo_RecordObject(m_meshBaker, "modify property");
        }
    }




}

