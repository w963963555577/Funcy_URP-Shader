using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class FollowMainCamera : MonoBehaviour
{
    Camera cam;
    private void OnEnable()
    {
        cam = Camera.main;
    }
    void Update()
    {
        if(cam != null)
        {
            transform.position = cam.transform.position;
            transform.rotation = cam.transform.rotation;
        }
    }
}
