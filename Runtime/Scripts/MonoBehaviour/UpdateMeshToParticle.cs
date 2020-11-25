using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class UpdateMeshToParticle : MonoBehaviour
{
    [SerializeField] ParticleSystem ps;
    [HideInInspector][SerializeField]Mesh mesh = null;
    private void OnEnable()
    {
        if (mesh != null)
            mesh.Clear();
        else
            mesh = new Mesh();

        GetComponent<SkinnedMeshRenderer>().BakeMesh(mesh);

        var shape = ps.shape;
        shape.mesh = mesh;
    }

    void Update()
    {
        
    }
}
