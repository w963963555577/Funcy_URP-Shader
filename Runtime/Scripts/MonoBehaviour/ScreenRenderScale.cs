using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ScreenRenderScale : MonoBehaviour
{
    [Range(0, 1)] public float renderScale = 1.0f;
    private void OnEnable()
    {        
        Screen.SetResolution((int)(Screen.width * renderScale), (int)(Screen.height * renderScale), true);
    }
}
