using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
[ExecuteInEditMode]
public class VertexRectToShaderGroup : MonoBehaviour
{    
    public Vector2 refBlur = new Vector2(0.9f, 0.1f);
    public List<VertexRectToShader> vertexRectToShaders = new List<VertexRectToShader>();
    
    protected void OnEnable()
    {        
        
    }
    
    private void Update()
    {
        foreach(var vs in vertexRectToShaders)
        {
            vs.refBlur = refBlur;
        }
    }   

    
}
