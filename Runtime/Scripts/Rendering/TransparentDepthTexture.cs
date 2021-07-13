using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(Camera))]
public class TransparentDepthTexture : MonoBehaviour
{
    [HideInInspector] [SerializeField] Camera depthCamera;
    [SerializeField] Camera currentCamera;
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
        DestroyImmediate(currentCamera.gameObject);
    }
}
