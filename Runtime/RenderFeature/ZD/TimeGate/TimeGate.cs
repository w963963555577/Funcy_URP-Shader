using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[ExecuteInEditMode]
public class TimeGate : MonoBehaviour
{    
    [Range(0.0f, 1.0f)] public float blend = 0.0f;
    [Range(0.0f, 1.0f)] public float whiteAdd = 0.0f;
    public float speedAdd = 0.0f;
    [SerializeField]CustomScreenTexture timeGate;
    private void OnEnable()
    {
        if (timeGate == null) return;
        timeGate.SetActive(true);
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalFloat("_TimeGateBlend", blend);
        Shader.SetGlobalFloat("_TimeGateWhiteAdd", whiteAdd);
        Shader.SetGlobalFloat("_TimeGateSpeedAdd", speedAdd);        
    }

    private void OnDisable()
    {
        if (timeGate == null) return;
        timeGate.SetActive(false);
    }

}
