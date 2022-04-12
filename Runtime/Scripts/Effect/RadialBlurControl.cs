using UnityEngine;
using System.Collections;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;


#if UNITY_EDITOR
using UnityEditor;
using System.Reflection;
#endif
[ExecuteInEditMode]
public class RadialBlurControl : MonoBehaviour
{
    public bool playOnAwake = true;
    public AnimationCurve strengthCurve;
    public AnimationCurve widthCurve;

    public RadiusBlurSettings settings;
    [System.Serializable]
    public class RadiusBlurSettings
    {
        public float blurStrength = 2;
        public float blurWidth = 0.5f;
    }

    public float duration = 1.0f;

    [System.NonSerialized] public bool pause = false;
    [System.NonSerialized] public float playbackTime = 0.0f;
    ZDUniversalRenderFeature.RadiusBlurSettings radiusblurSettings;

    private void Reset()
    {
        strengthCurve.AddKey(0, 0);
        strengthCurve.AddKey(1.0f, 0.0f);
        widthCurve.AddKey(0, 0);
        widthCurve.AddKey(1.0f, 0.0f);
        Keyframe mid = new Keyframe(0.2f, 1.0f, 0.0f, 0.0f, 1.0f / 3.0f, 1.0f / 3.0f);
        strengthCurve.AddKey(mid);
        widthCurve.AddKey(mid);
    }
    private void Awake()
    {
        if(playOnAwake)
        {
            Play();
        }
    }
    // Use this for initialization
    void OnEnable ()
    {
        radiusblurSettings = ZDUniversalRenderFeature.GetRadiusBlurSettings();
        ZDUniversalRenderFeature.radialBlurControls.Add(this);
        if (radiusblurSettings != null)
        {
            radiusblurSettings.worldPosition = transform.position;
        }
        
    }
    public void Play()
    {
        pause = false;
        RadialBlur(duration, settings.blurWidth, settings.blurStrength);
    }

    public void Apply(float normalizeTime)
    {
        radiusblurSettings.blurWidth = widthCurve.Evaluate(normalizeTime) * settings.blurWidth;
        radiusblurSettings.blurStrength = strengthCurve.Evaluate(normalizeTime) * settings.blurStrength;
    }
    private void Update()
    {
        if (pause)
        {
            float normalizeTime = Mathf.Min(playbackTime / duration, 1.0f);
            Apply(normalizeTime);
        }
    }

    private void LateUpdate()
    {
        if (transform.hasChanged)
        {
            if (radiusblurSettings != null)
            {
                radiusblurSettings.worldPosition = transform.position;
            }
            transform.hasChanged = false;
        }

        
    }
    async void RadialBlur(float duration, float width, float strength)
    {
        float currenTime = GetNowTime();
        float initTime = playbackTime;
        while (true)
        {
            if (pause) return;
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                EditorUtility.SetDirty(this);
            }
#endif
            playbackTime = initTime + (GetNowTime() - currenTime);
            float normalizeTime = Mathf.Min(playbackTime / duration, 1.0f);
            Apply(normalizeTime);
            if (normalizeTime >= 1.0f)
            {
                break;
            }
            await Task.Yield();
        }
        playbackTime = 0.0f;
    }

    float GetNowTime()
    {
        float result = 0;
#if UNITY_EDITOR
        if(Application.isPlaying)
        {
            result = Time.realtimeSinceStartup;
        }
        else
        {
            result = (float)EditorApplication.timeSinceStartup;
        }
#else
        result = Time.realtimeSinceStartup;
#endif
        return result;
    }

	private void OnDisable()
	{
        ZDUniversalRenderFeature.radialBlurControls.Remove(this);
    }
}

#if UNITY_EDITOR
[InitializeOnLoad]
[CustomEditor(typeof(RadialBlurControl))]
public class RadialBlurControl_Editor : Editor
{
    protected static MethodInfo Resimulation;
    protected static FieldInfo PlaybackTimeField;
    static RadialBlurControl_Editor()
    {
        RadialBlurControl control = null;
        ParticleSystem selectPS = null;
        List<ParticleSystem> psList = new List<ParticleSystem>();
        Selection.selectionChanged += () => {
            control = null;
            selectPS = null;
            if (Selection.activeGameObject)
            {
                selectPS = Selection.activeGameObject.GetComponent<ParticleSystem>();
                psList = new List<ParticleSystem>();
                psList.AddRange(Selection.activeGameObject.GetComponentsInChildren<ParticleSystem>().ToList().FindAll(p => p.gameObject != Selection.activeGameObject));
                psList.AddRange(Selection.activeGameObject.GetComponentsInParent<ParticleSystem>());

                if (selectPS)
                {    
                    foreach (var p in psList)
                    {
                        control = p.GetComponentInChildren<RadialBlurControl>();
                        if (!control) control = p.GetComponentInParent<RadialBlurControl>();
                        if (control) break;
                    }
                }
                
                if(!control)
                {
                    control = Selection.activeGameObject.GetComponent<RadialBlurControl>();
                } 
            }
        };
        EditorApplication.update += () => {
            if (PlaybackTimeField == null || Resimulation == null)
            {
                var PsUtils = typeof(UnityEditor.EditorUtility).Assembly.GetType("UnityEditor.ParticleSystemEditorUtils", true);
                PlaybackTimeField = PsUtils.GetField("playbackTime", BindingFlags.Static | BindingFlags.NonPublic);
                Resimulation = PsUtils.GetMethod("PerformCompleteResimulation", (BindingFlags.Static | BindingFlags.NonPublic));
            }

            if (control && selectPS)
            {
                float normalizeTime = Mathf.Min(control.playbackTime / control.duration, 1.0f);

                if (selectPS.time < Mathf.Max(control.duration, selectPS.main.duration) && selectPS.time > 0.0f)
                {
                    control.playbackTime = selectPS.time;
                    control.Apply(normalizeTime);
                }
                else
                {
                    control.Apply(0);
                }
            }
            if (control && !selectPS && psList.Count > 0)
            {
                foreach(var p in psList)
                {
                    p.Simulate(control.playbackTime, true, true);
                }
                if (PlaybackTimeField != null && Resimulation != null)
                {
                    PlaybackTimeField.SetValue(null, control.playbackTime);
                    Resimulation.Invoke(null, null);
                }
            }
        };
    }

    RadialBlurControl data;
    private void OnEnable()
    {
        data = target as RadialBlurControl;
        if (data.playbackTime > data.duration || data.playbackTime < 0)
        {
            data.playbackTime = 0;
            data.Apply(0);
            data.pause = false;
        }

        EditorApplication.update += Dirty;
    }

    void Dirty()
    {
        EditorUtility.SetDirty(target);
    }
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        
        EditorGUI.BeginChangeCheck();
        data.playbackTime = EditorGUILayout.Slider("Playback Time", data.playbackTime, 0.0f, data.duration);
        
        EditorGUI.BeginDisabledGroup(true);
        EditorGUILayout.Toggle("Pause", data.pause);
        EditorGUI.EndDisabledGroup();
        
        if(EditorGUI.EndChangeCheck())
        {
            data.playbackTime = Mathf.Clamp(data.playbackTime, 0.0f, data.duration);
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                EditorUtility.SetDirty(target);
            }
#endif
            data.pause = data.playbackTime != 0.0f;
        }
        bool playing = data.playbackTime > 0.0f && !data.pause;
        if (GUILayout.Button(playing ? "Pause" : "Play"))
        {
            if(playing)
            {
                data.pause = true;
            }
            else
            {
                data.Play();
            }
        }
    }
    private void OnDisable()
    {
        EditorApplication.update -= Dirty;
    }
}
#endif