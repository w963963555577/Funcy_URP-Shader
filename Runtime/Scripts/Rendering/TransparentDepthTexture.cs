using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(Camera))]
public class TransparentDepthTexture : MonoBehaviour
{
    [HideInInspector] [SerializeField] Camera depthCamera;
    [SerializeField] Camera currentCamera;

    private void OnEnable()
    {
        
    }
    
    void Update()
    { 
        if(currentCamera == null)
        {
            currentCamera = Instantiate(depthCamera, transform);            
            currentCamera.gameObject.hideFlags = HideFlags.HideAndDontSave;             
        }

    }
    private void OnDisable()
    {
        DestroyImmediate(currentCamera.gameObject);
    }
}
