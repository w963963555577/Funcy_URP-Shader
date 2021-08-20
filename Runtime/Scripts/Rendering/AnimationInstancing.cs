using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using System.Linq;
using Unity.Mathematics;
using Funcy.Graphics;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.AnimatedValues;
#endif
[ExecuteInEditMode]
public class AnimationInstancing : MonoBehaviour
{    
    public ComputeShader cullingComputeShader;
    public List<RenderGroup> renderGroups = new List<RenderGroup>();
    public bool viewCulling = true;

    public UnityEngine.UI.Text objectCount, currentCount;    

    private void OnEnable()
    {
        foreach (var rg in renderGroups)
        {
            rg.InitBuffers();
            rg.UpdateBuffer();
        }
    }

    public void UpdateObject(int rgIndex, int index)
    {
        var rg = renderGroups[rgIndex];
        var ren = rg.GetObjects()[index];
        rg.UpdateTransform(index);
    }

    bool instanced_tmp = false;
    bool _instanced = true;
    public bool instanced { get { return _instanced; } set { _instanced = value; } }
    float _distance = 8;
    public float distance { get { return _distance; } set { _distance = value; } }
    [System.Serializable]
    public class RenderGroup
    {
        Renderer ren;

        public int currentCount = 0;

        private Buffer _ObjectToWorldBuffer;
        private Buffer _WorldToObjectBuffer;

        private Buffer boundsBuffer;
        private Buffer visibleInstanceOnlyTransformBuffer;
        private Buffer visibleTransformIDBuffer;
        uint[] visibleTransformID;
        private Buffer argsBuffer;
        float4x4[] o2w;
        float4x4[] w2o;
        float3x2[] bounds;
        uint[] args = new uint[5] { 0, 0, 0, 0, 0 };


        //Animation Instancing
        private Buffer _TimeBuffer;Vector4[] timeData;

        //Probes
        MaterialPropertyBlock properties = null;

        public void InitBuffers()
        {
            ren = reference.GetComponent<Renderer>();
            properties = new MaterialPropertyBlock();
            ren.GetPropertyBlock(properties);

            _ObjectToWorldBuffer = new Buffer(objs.Count, typeof(Matrix4x4));
            _WorldToObjectBuffer = new Buffer(objs.Count, typeof(Matrix4x4), ComputeBufferType.Default);
            
            boundsBuffer = new Buffer(objs.Count, typeof(Bounds));

            int idBufferCount = Mathf.NextPowerOfTwo(objs.Count);//Because AppendStructuredBuffer<> must be a power of 2
            visibleInstanceOnlyTransformBuffer = new Buffer(idBufferCount, typeof(uint), ComputeBufferType.Append); //uint only, per visible grass
            visibleTransformIDBuffer = new Buffer(objs.Count, typeof(uint)); //uint only, per visible grass
            visibleTransformID = new uint[objs.Count];
            argsBuffer = new Buffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);

            o2w = new float4x4[objs.Count];
            w2o = new float4x4[objs.Count];
            bounds = new float3x2[objs.Count];


            //Animation Instancing
            _TimeBuffer = new Buffer(objs.Count, typeof(Vector4));
            timeData = new Vector4[objs.Count];
        }

        public void DispBuffers()
        {
            if (_ObjectToWorldBuffer != null) _ObjectToWorldBuffer.Dispose();
            if (_WorldToObjectBuffer != null) _WorldToObjectBuffer.Dispose();
            if (boundsBuffer != null) boundsBuffer.Dispose();
            if (visibleInstanceOnlyTransformBuffer != null) visibleInstanceOnlyTransformBuffer.Dispose();
            if (visibleTransformIDBuffer != null) visibleTransformIDBuffer.Dispose();
        }

        private Material instancedMaterial;
        public void UpdateTransform(int index)
        {
            var o = objs[index];
            o2w[index] = o.localToWorldMatrix;
            w2o[index] = o.worldToLocalMatrix;
            bounds[index] = new float3x2(o.bounds.center, o.bounds.extents);
            UpdateBuffer(false, false);
        }

        public void UpdateTime(int index, Vector4 timedata)
        {
            this.timeData[index] = timedata;
        }

        public void UpdateBuffer(bool updateAllObjects = true, bool updateArgs = true)
        {                        
            int index = 0;
            if (updateAllObjects)
            {
                foreach (var o in objs)
                {
                    o2w[index] = o.localToWorldMatrix;
                    w2o[index] = o.worldToLocalMatrix;
                    bounds[index] = new float3x2(o.bounds.center, o.bounds.extents);
                    var e = o.GetComponent<AnimationInstancingElement>();
                    elements.Add(e);
                    if (!e)
                    {
                        e = o.gameObject.AddComponent<AnimationInstancingElement>();
                    }
                    e.index = index;

                    index++;
                }
            }

            _ObjectToWorldBuffer.SetData(o2w);
            _WorldToObjectBuffer.SetData(w2o);
            
            var mat = ren.sharedMaterial;
            mat.SetBuffer("_ObjectToWorldBuffer", _ObjectToWorldBuffer.target);
            mat.SetBuffer("_WorldToObjectBuffer", _WorldToObjectBuffer.target);

            boundsBuffer.SetData(bounds);
            mat.SetBuffer("_VisibleInstanceOnlyTransformIDBuffer", visibleInstanceOnlyTransformBuffer.target);
            mat.SetBuffer("_VisibleTransformIDBuffer", visibleTransformIDBuffer.target);
            
            if(updateArgs)
            {
                args[0] = (uint)reference.sharedMesh.GetIndexCount(0);
                args[1] = (uint)objs.Count;
                args[2] = (uint)reference.sharedMesh.GetIndexStart(0);
                args[3] = (uint)reference.sharedMesh.GetBaseVertex(0);
                args[4] = 0;

                argsBuffer.SetData(args);
            }            
        }

        public void Draw(ComputeShader cullingComputeShader, int kernel, Matrix4x4 ViewMatrix, Matrix4x4 ProjectionMatrix, bool viewCulling, LightProbeUsage lightProbeUsage = LightProbeUsage.BlendProbes, LightProbeProxyVolume volume = null)
        {
            if (instancedMaterial == null)
                instancedMaterial =  reference.GetComponent<MeshRenderer>().sharedMaterial;

            if (activeGroup)
            { instancedMaterial.DisableKeyword("_DrawMeshInstancedProcedural"); }
            else
            { instancedMaterial.EnableKeyword("_DrawMeshInstancedProcedural"); }
            

            visibleInstanceOnlyTransformBuffer.SetCounterValue(0);
            cullingComputeShader.SetMatrix("_VMatrix", ViewMatrix);
            cullingComputeShader.SetMatrix("_PMatrix", ProjectionMatrix);
            cullingComputeShader.SetFloat("_MaxDrawDistance", farClipDistance);
            cullingComputeShader.SetBuffer(kernel, "_BoundsBuffer", boundsBuffer.target);
            cullingComputeShader.SetBuffer(kernel, "_VisibleInstanceOnlyTransformIDBuffer", visibleInstanceOnlyTransformBuffer.target);
            cullingComputeShader.SetBuffer(kernel, "_VisibleTransformIDBuffer", visibleTransformIDBuffer.target);
            cullingComputeShader.Dispatch(kernel, Mathf.CeilToInt(objs.Count / 64f), 1, 1);
            

            if (!activeGroup)
            {
                //Animation Instancing Data            
                _TimeBuffer.SetData(this.timeData);
                instancedMaterial.SetBuffer("_TimeBuffer", _TimeBuffer.target);
                //Animation Instancing Data

                ComputeBuffer.CopyCount(visibleInstanceOnlyTransformBuffer.target, argsBuffer.target, 4);
                Graphics.DrawMeshInstancedIndirect(reference.sharedMesh, 0, instancedMaterial, new Bounds(new Vector3(0, 0, 0), new Vector3(10000, 10000, 10000)), argsBuffer.target, 0,
                    null, shadowCastingMode, true, reference.gameObject.layer, null, lightProbeUsage, volume);

                if (viewCulling)
                {
                    AsyncGPUReadback.Request(visibleTransformIDBuffer.target, r =>
                    {
                        if (r.hasError) return;

                        var d = r.GetData<uint>();
                        d.CopyTo(visibleTransformID);
                        currentCount = visibleTransformID.ToList().FindAll(x => x == 1).Count;
                    });

                    for (int i = 0; i < objs.Count; i++)
                    {
                        bool enabled = visibleTransformID[i] == 1;
                        elements[i].enabled = enabled;
                        elements[i].animator.enabled = enabled;
                    }
                }
                else
                {
                    for (int i = 0; i < objs.Count; i++)
                    {
                        objs[i].enabled = true;
                    }
                }
            }
            else
            {
                if (viewCulling)
                {
                    AsyncGPUReadback.Request(visibleTransformIDBuffer.target, r =>
                    {
                        if (r.hasError) return;
                        
                        var d = r.GetData<uint>();                        
                        d.CopyTo(visibleTransformID);
                        currentCount = visibleTransformID.ToList().FindAll(x => x == 1).Count;
                    });
                    
                    for (int i = 0; i < objs.Count; i++)
                    {
                        bool enabled = visibleTransformID[i] == 1;
                        objs[i].enabled = enabled;
                        elements[i].enabled = enabled;
                        elements[i].animator.enabled = enabled;
                    }
                }
                else
                {
                    for (int i = 0; i < objs.Count; i++)
                    {
                        objs[i].enabled = true;
                    }
                }
            }


        }

        public MeshFilter reference;
        public bool activeGroup = true;
        public float farClipDistance = 150f;
        public ShadowCastingMode shadowCastingMode = ShadowCastingMode.On;

        [SerializeField] List<MeshRenderer> objs = new List<MeshRenderer>();
        [SerializeField] List<AnimationInstancingElement> elements = new List<AnimationInstancingElement>();

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
            if (visibleTransformIDBuffer != null) visibleTransformIDBuffer.Dispose(); visibleTransformIDBuffer = null;
            if (argsBuffer != null) argsBuffer.Dispose(); argsBuffer = null;
            var mat = reference.GetComponent<MeshRenderer>().sharedMaterial;            
            mat.DisableKeyword("_DrawMeshInstancedProcedural");
        }
#if UNITY_EDITOR
        public bool hasMesh = false;
#endif
    }    

    public void UpdateBufferWherToggle(RenderGroup rg)
    {
        foreach (var o in rg.GetObjects())
        {
            o.enabled = rg.activeGroup;
        }

        rg.InitBuffers();
        rg.UpdateBuffer();
    }

    Camera mainCamera;
    void LateUpdate()
    {
        if (mainCamera == null)
        {
            mainCamera = Camera.main;
            return;
        }
        
        Matrix4x4 v = mainCamera.worldToCameraMatrix;
        Matrix4x4 p = mainCamera.projectionMatrix;
        
        var kernel = viewCulling ? cullingComputeShader.FindKernel("ViewCulling") : cullingComputeShader.FindKernel("Default");
        
        foreach (var rg in renderGroups)
        {
            rg.Draw(cullingComputeShader, kernel, v, p, viewCulling, LightProbeUsage.BlendProbes);
        }
        renderGroups[0].farClipDistance = distance;
        renderGroups[0].activeGroup = !instanced;
        if(instanced_tmp != instanced)
        {
            instanced_tmp = instanced;
            UpdateBufferWherToggle(renderGroups[0]);
        }
        objectCount.text = string.Format("Object Count: {0}", renderGroups[0].objectCount);
        currentCount.text = string.Format("Current Count: {0}", renderGroups[0].currentCount);
    }

    public void UpdateAllBuffer()
    {
        foreach (var rg in renderGroups)
        {
            rg.UpdateBuffer();
        }
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


[InitializeOnLoad,CustomEditor(typeof(AnimationInstancing))]
public class AnimationInstancing_Editor : Editor
{
    

    static AnimationInstancing_Editor()
    {
        System.Action updateBuffer = null;
        updateBuffer = () => {
            foreach (var data in FindObjectsOfType<AnimationInstancing>())
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
                    foreach (var data in FindObjectsOfType<AnimationInstancing>())
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
    AnimationInstancing data;
    void Dirty()
    {
        EditorUtility.SetDirty(data);
    }
    private void OnEnable()
    {
        data = target as AnimationInstancing;
        EditorApplication.update += Dirty;
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
                if (result.Count > 0)
                    rg.UpdateBuffer();
            }
            EditorUtility.SetDirty(target);
            UnityEditor.SceneManagement.EditorSceneManager.MarkSceneDirty(data.gameObject.scene);
        }

        GUILayout.Space(10);

        if (GUILayout.Button("Add Reference", EditorStyles.miniButton)) 
        {
            data.renderGroups.Add(new AnimationInstancing.RenderGroup());
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
            },
            () => 
            {
                rg.activeGroup = GUILayout.Toggle(rg.activeGroup, "", GUILayout.Width(15));
                if (GUI.changed || isRootChange)
                {                    
                    var mat = rg.reference.GetComponent<MeshRenderer>().sharedMaterial;

                    data.UpdateBufferWherToggle(rg);

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

    private void OnDisable()
    {
        EditorApplication.update -= Dirty;
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