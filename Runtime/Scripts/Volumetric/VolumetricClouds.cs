using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class VolumetricClouds : MonoBehaviour
{
    public int verticalSize = 20;
    MeshFilter filter;
    MeshRenderer ren;
    // Start is called before the first frame update
    private void OnEnable()
    {
        filter = GetComponent<MeshFilter>();
        ren = GetComponent<MeshRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        List<Matrix4x4> matrix4X4s = new List<Matrix4x4>();        
        for (int i=0;i< verticalSize;i++)
        {
            matrix4X4s.Add(Matrix4x4.TRS(transform.position + Vector3.up * (i - verticalSize * 0.5f) * 0.01f, transform.rotation, transform.localScale));
        }
        Graphics.DrawMeshInstanced(filter.sharedMesh, 0,  ren.sharedMaterial, matrix4X4s.ToArray(), verticalSize);        
    }
}
