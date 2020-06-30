using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CullingSceneRenderer : MonoBehaviour
{
    [HideInInspector][SerializeField]List<Renderer> allRenderer = new List<Renderer>();
    private void OnEnable()
    {
        foreach (var g in gameObject.scene.GetRootGameObjects())
            allRenderer.AddRange(g.GetComponentsInChildren<MeshRenderer>(true));
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
