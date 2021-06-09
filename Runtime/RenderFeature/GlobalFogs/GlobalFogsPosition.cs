using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[ExecuteInEditMode]
public class GlobalFogsPosition : MonoBehaviour
{
    public Color color = Color.gray;
    public float distance = 50.0f;
    [SerializeField]GlobalFogs globalFogs;
    private void OnEnable()
    {
        if (globalFogs == null) return;
        globalFogs.Settings.isActive = true;
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        globalFogs.Settings.worldPosition = transform.position;
        globalFogs.Settings.distance = distance;
        globalFogs.Settings.color = color;
    }
    private void OnDisable()
    {
        if (globalFogs == null) return;
        globalFogs.Settings.isActive = false;
    }



}
