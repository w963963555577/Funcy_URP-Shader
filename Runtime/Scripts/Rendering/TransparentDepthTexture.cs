using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
[ExecuteAlways]
[RequireComponent(typeof(Camera))]
public class TransparentDepthTexture : MonoBehaviour
{
    [HideInInspector] [SerializeField] Camera depthCamera;
    [HideInInspector][SerializeField] Camera currentCamera;
    Camera origCamera;
    private void OnEnable()
    {
        origCamera = GetComponent<Camera>();
    }
    
    void Update()
    { 
        if(currentCamera == null)
        {
            currentCamera = Instantiate(depthCamera, transform);            
            currentCamera.gameObject.hideFlags = HideFlags.HideAndDontSave;
            return;
        }

        currentCamera.fieldOfView = origCamera.fieldOfView;
        currentCamera.nearClipPlane = origCamera.nearClipPlane; 
        currentCamera.farClipPlane = origCamera.farClipPlane;
    }
    private void OnDisable()
    {
        if (currentCamera != null)
            DestroyImmediate(currentCamera.gameObject);
    }
}
#if UNITY_EDITOR
[CustomEditor(typeof(TransparentDepthTexture))]
public class TransparentDepthTexture_Editor : Editor
{
    private void OnEnable()
    {
        
    }
    public override void OnInspectorGUI()
    {
        
    }
}
#endif