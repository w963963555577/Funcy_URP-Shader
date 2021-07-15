using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(ParticleSystem))]
public class PS_ApplyTransformMatrix : MonoBehaviour
{
    Material mat;
    ParticleSystemRenderer ren;
    private void OnEnable()
    {
        ren = GetComponent<ParticleSystemRenderer>();
        mat = ren.sharedMaterial;
    }

    void Update()
    {
        mat.SetMatrix("_o2w", ren.localToWorldMatrix);
        mat.SetMatrix("_w2o", ren.worldToLocalMatrix);
    }
}
