using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SyncMaterialProperty : MonoBehaviour
{
    [Header("A Properties sync to B")]
    public Material a;
    public Material b;

    private void Start()
    {
        a = GetComponent<MeshRenderer>().sharedMaterial;
    }

    private void Update()
    {
        if (!a) return;
        b.CopyPropertiesFromMaterial(a);
    }
}
