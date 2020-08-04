using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using System.Linq;
using Unity.Mathematics;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.AnimatedValues;
#endif
[ExecuteInEditMode]
public class RenderMeshInstancedProcedural : MonoBehaviour
{    
    public ComputeShader cullingComputeShader;
    public List<RenderGroup> renderGroups = new List<RenderGroup>();
    public bool viewCulling = true;
    [System.Serializable]
    public class RenderGroup
    {
        private ComputeBuffer _ObjectToWorldBuffer;
        private ComputeBuffer _WorldToObjectBuffer;

        private ComputeBuffer boundsBuffer;
        private ComputeBuffer visibleInstanceOnlyTransformBuffer;
        private ComputeBuffer argsBuffer;

        private Material instancedMaterial;
        public void UpdateBuffer()
        {            
            if (_ObjectToWorldBuffer != null) _ObjectToWorldBuffer.Release();
            if (_WorldToObjectBuffer != null) _WorldToObjectBuffer.Release();
            if (boundsBuffer != null) boundsBuffer.Release();
            if (visibleInstanceOnlyTransformBuffer != null) visibleInstanceOnlyTransformBuffer.Release();

            _ObjectToWorldBuffer = new ComputeBuffer(objs.Count, sizeof(float) * 4 * 4, ComputeBufferType.Default);
            _WorldToObjectBuffer = new ComputeBuffer(objs.Count, sizeof(float) * 4 * 4, ComputeBufferType.Default);
            boundsBuffer = new ComputeBuffer(objs.Count, sizeof(float) * 3 * 2); //float3 posWS only, per grass
            visibleInstanceOnlyTransformBuffer = new ComputeBuffer(objs.Count, sizeof(uint), ComputeBufferType.Append); //uint only, per visible grass

            float4x4[] o2w =new float4x4[objs.Count];
            float4x4[] w2o =new float4x4[objs.Count];

            List<float3x2> bounds = new List<float3x2>();
            int index = 0;
            foreach (var o in objs)
            {
                o2w[index] = o.localToWorldMatrix;
                w2o[index] = o.worldToLocalMatrix;
                float3x2 _bounds = new float3x2(o.bounds.center, o.bounds.extents);
                bounds.Add(_bounds);
                index++;
            }
            _ObjectToWorldBuffer.SetData(o2w);
            _WorldToObjectBuffer.SetData(w2o);

            var ren = reference.GetComponent<MeshRenderer>();
            var mat = ren.sharedMaterial;
            mat.SetBuffer("_ObjectToWorldBuffer", _ObjectToWorldBuffer);
            mat.SetBuffer("_WorldToObjectBuffer", _WorldToObjectBuffer);

            boundsBuffer.SetData(bounds);
            mat.SetBuffer("_VisibleInstanceOnlyTransformIDBuffer", visibleInstanceOnlyTransformBuffer);


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

        public void Draw(ComputeShader cullingComputeShader, Matrix4x4 ViewMatrix, Matrix4x4 ProjectionMatrix, bool viewCulling)
        {
            if (instancedMaterial == null)
                instancedMaterial =  reference.GetComponent<MeshRenderer>().sharedMaterial;

            if (!instancedMaterial.IsKeywordEnabled("_DrawMeshInstancedProcedural"))
                instancedMaterial.EnableKeyword("_DrawMeshInstancedProcedural");


            //dispatch culling compute, fill visible instance into visibleInstanceOnlyTransformBuffer
            var kernel = cullingComputeShader.FindKernel("ViewCulling");

            visibleInstanceOnlyTransformBuffer.SetCounterValue(0);
            cullingComputeShader.SetBool("_CullingEnabled", viewCulling);
            cullingComputeShader.SetMatrix("_VMatrix", ViewMatrix);
            cullingComputeShader.SetMatrix("_PMatrix", ProjectionMatrix);
            cullingComputeShader.SetFloat("_MaxDrawDistance", farClipDistance);
            cullingComputeShader.SetBuffer(kernel, "_BoundsBuffer", boundsBuffer);
            cullingComputeShader.SetBuffer(kernel, "_VisibleInstanceOnlyTransformIDBuffer", visibleInstanceOnlyTransformBuffer);
            cullingComputeShader.Dispatch(kernel, Mathf.CeilToInt(objs.Count / 64f), 1, 1);
            ComputeBuffer.CopyCount(visibleInstanceOnlyTransformBuffer, argsBuffer, 4);

            Graphics.DrawMeshInstancedIndirect(reference.sharedMesh, 0, instancedMaterial, new Bounds(new Vector3(0, 0, 0), new Vector3(10000, 10000, 10000)), argsBuffer, 0, null, shadowCastingMode);
        }

        public MeshFilter reference;
        public bool activeGroup = true;
        public float farClipDistance = 150f;
        public ShadowCastingMode shadowCastingMode = ShadowCastingMode.On;

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
            if (_ObjectToWorldBuffer != null) _ObjectToWorldBuffer.Dispose(); _ObjectToWorldBuffer = null;
            if (_WorldToObjectBuffer != null) _WorldToObjectBuffer.Dispose(); _WorldToObjectBuffer = null;
            if (boundsBuffer != null) boundsBuffer.Dispose(); boundsBuffer = null;
            if (visibleInstanceOnlyTransformBuffer != null) visibleInstanceOnlyTransformBuffer.Dispose(); visibleInstanceOnlyTransformBuffer = null;
            if (argsBuffer != null) argsBuffer.Release(); argsBuffer = null;

            var mat = reference.GetComponent<MeshRenderer>().sharedMaterial;            
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
        Matrix4x4 v = Camera.main.worldToCameraMatrix;
        Matrix4x4 p = Camera.main.projectionMatrix;
        Matrix4x4 vp = p * v;
        foreach (var rg in renderGroups)
        {
            if (!rg.activeGroup) rg.Draw(cullingComputeShader, v, p, viewCulling);
        }
    }

    public void UpdateAllBuffer()
    {
        foreach (var rg in renderGroups)
        {
            if (!rg.activeGroup) rg.UpdateBuffer();            
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
        System.Action updateBuffer = null;
        updateBuffer = () => {
            foreach (var data in FindObjectsOfType<RenderMeshInstancedProcedural>())
            {
                data.UpdateAllBuffer();
            }
        };

        System.Action updateBufferDelay = () =>
        {
            EditorApplication.CallbackFunction refresh = null;
            float nowTime = (float)EditorApplication.timeSinceStartup;
            refresh = () =>
            {
                if ((float)EditorApplication.timeSinceStartup - nowTime > 0.05f)
                {
                    foreach (var data in FindObjectsOfType<RenderMeshInstancedProcedural>())
                    {
                        if (data.enabled) data.UpdateAllBuffer();
                        AssetDatabase.Refresh();
                    }
                    EditorApplication.update -= refresh;
                }
            };
            EditorApplication.update += refresh;
        };

        EditorApplication.delayCall += () =>
        {
            updateBuffer?.Invoke();
            FileModificationWarning.onSavedProject += updateBufferDelay;
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

        data.viewCulling = EditorGUILayout.Toggle("View Culling", data.viewCulling);


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
                rg.farClipDistance = EditorGUILayout.FloatField("Max Distance", rg.farClipDistance);
                rg.shadowCastingMode = (ShadowCastingMode)EditorGUILayout.EnumPopup("Shadow Mode",rg.shadowCastingMode);
                GUILayout.Label("Object Count = " + rg.objectCount);

                if (GUI.changed)
                {
                    EditorUtility.SetDirty(target);
                    UnityEditor.SceneManagement.EditorSceneManager.MarkSceneDirty(data.gameObject.scene);
                }
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
    public class FileModificationWarning : AssetModificationProcessor
    {
        public static System.Action onSavedProject;
        static string[] OnWillSaveAssets(string[] paths)
        {
            onSavedProject?.Invoke();            
            return paths;
        }
    }
}

#endif