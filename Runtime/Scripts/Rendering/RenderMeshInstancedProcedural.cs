using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.AnimatedValues;
#endif
[ExecuteInEditMode]
public class RenderMeshInstancedProcedural : MonoBehaviour
{
    public List<RenderGroup> renderGroups = new List<RenderGroup>();
    [System.Serializable]
    public class RenderGroup
    {
        private ComputeBuffer ObjectToWorldBuffer;
        private ComputeBuffer WorldToObjectBuffer;
        private ComputeBuffer argsBuffer;
        public void UpdateBuffer()
        {            
            if (ObjectToWorldBuffer != null) ObjectToWorldBuffer.Release();
            if (WorldToObjectBuffer != null) WorldToObjectBuffer.Release();

            ObjectToWorldBuffer = new ComputeBuffer(objs.Count, sizeof(float) * 4 * 4, ComputeBufferType.Default);
            WorldToObjectBuffer = new ComputeBuffer(objs.Count, sizeof(float) * 4 * 4, ComputeBufferType.Default);

            List<Matrix4x4> o2w = new List<Matrix4x4>();
            List<Matrix4x4> w2o = new List<Matrix4x4>();

            foreach (var o in objs)
            {
                o2w.Add(o.localToWorldMatrix);
                w2o.Add(o.worldToLocalMatrix);
            }
            ObjectToWorldBuffer.SetData(o2w);
            WorldToObjectBuffer.SetData(w2o);

            var mat = reference.GetComponent<MeshRenderer>().sharedMaterial;
            mat.SetBuffer("ObjectToWorldBuffer", ObjectToWorldBuffer);
            mat.SetBuffer("WorldToObjectBuffer", WorldToObjectBuffer);            


            ///////////////////////////
            // Indirect args buffer
            ///////////////////////////
            if (argsBuffer != null)
                argsBuffer.Release();
            uint[] args = new uint[5] { 0, 0, 0, 0, 0 };
            argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);

            args[0] = (uint)reference.sharedMesh.GetIndexCount(0);
            args[1] = (uint)objs.Count;
            args[2] = (uint)reference.sharedMesh.GetIndexStart(0);
            args[3] = (uint)reference.sharedMesh.GetBaseVertex(0);
            args[4] = 0;

            argsBuffer.SetData(args);

        }

        public void Draw()
        {
            var mat = reference.GetComponent<MeshRenderer>().sharedMaterial;
            mat.SetFloat("_DrawMeshInstancedProcedural", 1);
            mat.EnableKeyword("_DrawMeshInstancedProcedural");
            Graphics.DrawMeshInstancedIndirect(reference.sharedMesh, 0, mat, new Bounds(new Vector3(0, 0, 0), new Vector3(1000, 1000, 1000)), argsBuffer);
        }

        public MeshFilter reference;
        public bool activeGroup = true;

        [SerializeField] List<MeshRenderer> objs = new List<MeshRenderer>();

        public int objectCount { get { return objs.Count; } }
        public void SetObjects(List<MeshRenderer> objects)
        {
            objs = objects;
        }
        public List<MeshRenderer> GetObjects()
        {
            return objs;
        }

        public void Dispose()
        {            
            if (ObjectToWorldBuffer != null) ObjectToWorldBuffer.Dispose(); ObjectToWorldBuffer = null;
            if (WorldToObjectBuffer != null) WorldToObjectBuffer.Dispose(); WorldToObjectBuffer = null;
            if (argsBuffer != null) argsBuffer.Release(); argsBuffer = null;


            var mat = reference.GetComponent<MeshRenderer>().sharedMaterial;
            mat.SetFloat("_DrawMeshInstancedProcedural", 0);
            mat.DisableKeyword("_DrawMeshInstancedProcedural");
        }
#if UNITY_EDITOR
        public bool hasMesh = false;
#endif
    }
    
    private void OnEnable()
    {
        foreach (var rg in renderGroups)
        {
            if (!rg.activeGroup) rg.UpdateBuffer();
        }
    }
    void LateUpdate()
    {
        foreach (var rg in renderGroups)
        {
            if (!rg.activeGroup) rg.Draw();
        }
    }

    public void UpdateAllBuffer()
    {
        foreach (var rg in renderGroups)
        {
            rg.UpdateBuffer();            
        }
    }

    void Start()
    {
        
    }

    private void Update()
    {
 
    }
    

    public void DisposeAllBuffer()
    {
        foreach (var rg in renderGroups)
        {
            rg.Dispose();            
        }
    }
    private void OnDisable()
    {
        DisposeAllBuffer();
    }
}
#if UNITY_EDITOR


[InitializeOnLoad,CustomEditor(typeof(RenderMeshInstancedProcedural))]
public class RenderMeshInstancedProcedural_Editor : Editor
{
    static RenderMeshInstancedProcedural_Editor()
    {
        EditorApplication.delayCall += () =>
         {
             foreach (var data in FindObjectsOfType<RenderMeshInstancedProcedural>())
             {
                 if (data.enabled) data.UpdateAllBuffer();
             }
         };
        
    }
    RenderMeshInstancedProcedural data;
    private void OnEnable()
    {
        data = target as RenderMeshInstancedProcedural;

    }

    public override void OnInspectorGUI()
    {
        if (GUILayout.Button("Find Reference Mesh Gameobject"))
        {
            foreach (var rg in data.renderGroups)
            {
                if (rg.reference == null)
                {
                    Debug.Log("You must be add reference in property");
                    return;
                }
                List<GameObject> rootGameObjects = new List<GameObject>();
                data.gameObject.scene.GetRootGameObjects(rootGameObjects);

                List<MeshRenderer> result = new List<MeshRenderer>();
                foreach (var g in rootGameObjects)
                {
                    result.AddRange(g.GetComponentsInChildren<MeshRenderer>(true).ToList().FindAll(r => r.GetComponent<MeshFilter>() && r.GetComponent<MeshFilter>().sharedMesh == rg.reference.sharedMesh));
                }
                rg.SetObjects(result);
            }
            EditorUtility.SetDirty(target);
            UnityEditor.SceneManagement.EditorSceneManager.MarkSceneDirty(data.gameObject.scene);
        }

        GUILayout.Space(10);

        if (GUILayout.Button("Add Reference", EditorStyles.miniButton)) 
        {
            data.renderGroups.Add(new RenderMeshInstancedProcedural.RenderGroup());
            EditorUtility.SetDirty(target);
            UnityEditor.SceneManagement.EditorSceneManager.MarkSceneDirty(data.gameObject.scene);
        }
        
        GUILayout.Space(5);

        bool isRootChange = false;

        int removeIndex = -1;
        foreach (var rg in data.renderGroups)
        {
            var rect = GUILayoutUtility.GetLastRect();

            DrawArea(rg.reference != null ? rg.reference.sharedMesh.name : "Reference is null!!", () =>
            {                
                GUILayout.BeginHorizontal();
                rg.reference = (MeshFilter)EditorGUILayout.ObjectField("Reference", rg.reference, typeof(MeshFilter), true);
                if (rg.hasMesh != (rg.reference != null))
                {                    
                    rg.hasMesh = rg.reference != null;
                    if(rg.hasMesh && data.renderGroups.Find(g => g.reference.sharedMesh == rg.reference.sharedMesh) != rg)
                    {
                        rg.reference = null;
                        rg.hasMesh = false;
                        Debug.Log("mesh cannot repeat in list!!");
                    }
                }

                GUILayout.EndHorizontal();
                GUILayout.Label("Object Count = " + rg.objectCount);
            },
            () => 
            {
                rg.activeGroup = GUILayout.Toggle(rg.activeGroup, "", GUILayout.Width(15));
                if (GUI.changed || isRootChange)
                {
                    if (rg.activeGroup)
                    {
                        rg.Dispose();                        
                    }
                    else
                    {
                        rg.UpdateBuffer();
                    }
                    foreach (var o in rg.GetObjects())
                    {
                        o.gameObject.SetActive(rg.activeGroup);
                    }
                    EditorUtility.SetDirty(target);
                    UnityEditor.SceneManagement.EditorSceneManager.MarkSceneDirty(data.gameObject.scene);
                }
            },
            () => 
            {
                if (GUILayout.Button("-", EditorStyles.miniButton, GUILayout.Height(30), GUILayout.MaxWidth(30))) 
                {
                    removeIndex = data.renderGroups.IndexOf(rg);
                }
            }
            );
        }

        if (removeIndex >= 0) 
        {
            data.renderGroups.RemoveAt(removeIndex);
        }

        if(GUI.changed)
        {
            EditorUtility.SetDirty(target);
            UnityEditor.SceneManagement.EditorSceneManager.MarkSceneDirty(data.gameObject.scene);
        }
    }

    [System.Serializable]
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
    public void DrawArea(string text, System.Action onGUI, System.Action onLabelBegin = null, System.Action onLabelEnd = null, float fadeSpeed = 3.0f, string style = "ShurikenModuleTitle")
    {
        string key = text;
        bool state = EditorPrefs.GetBool(key, true);

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
            if (state) text = "\u25BC " + text;
            else text = "\u25BA " + text;
            GUILayout.BeginHorizontal();
            onLabelBegin?.Invoke();
            if (GUILayout.Button(text, style))
            {
                state = !state;
                currentAnimBool.animBool.target = state;
                EditorPrefs.SetBool(key, state);
            }
            onLabelEnd?.Invoke();
            GUILayout.EndHorizontal();
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
#endif