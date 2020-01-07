using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
#if UNITY_EDITOR
using UnityEditor;
#endif
[ExecuteInEditMode]
public class FPSCounter : MonoBehaviour
{
    public StringEvent onFPSUpdate;
    [System.Serializable]public class StringEvent: UnityEvent<string> { }
    private float startTime;
    private void Awake()
    {
        
    }
    private void OnEnable()
    {
        startTime = Time.NowTime;
        counter = 0;
    }

    [SerializeField] string frontText, endedText;
    public string addUnderline = "";
    [HideInInspector] [SerializeField] int counter = 0;
    [HideInInspector] [SerializeField] float currentTime = 0;


    void Update()
    {
        UpdateFPSText();
    }

    void UpdateFPSText()
    {
        currentTime = Time.NowTime - startTime;
        counter++;

        onFPSUpdate.Invoke(frontText + ((float)counter / currentTime).ToString("0.0") + endedText + "\n" + addUnderline);

        if (currentTime >= 1.0f)
        {
            startTime = Time.NowTime;
            counter = 0;
        }
    }

    public class Time
    {
        public static float NowTime
        {
            get
            {
                float t = 0.0f;
                if (Application.isPlaying) t = UnityEngine.Time.realtimeSinceStartup;
                else
                {
#if UNITY_EDITOR
                    if (!Application.isPlaying)
                        t = (float)UnityEditor.EditorApplication.timeSinceStartup;
#endif
                }
                return t;
            }
        }
    }    
}
#if UNITY_EDITOR
[CustomEditor (typeof(FPSCounter))]
public class FPSCounter_Editor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
    }
}
#endif