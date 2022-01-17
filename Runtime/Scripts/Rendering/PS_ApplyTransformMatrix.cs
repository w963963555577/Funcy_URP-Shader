using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(ParticleSystem))]
public class PS_ApplyTransformMatrix : MonoBehaviour
{
    ParticleSystem ps;
    ParticleSystemRenderer ren;
    MaterialPropertyBlock block;
    private void OnEnable()
    {
        ps = GetComponent<ParticleSystem>();
        ren = GetComponent<ParticleSystemRenderer>();
        block = new MaterialPropertyBlock();
        block.Clear();
        ren.GetPropertyBlock(block);
        List<ParticleSystemVertexStream> streams = new List<ParticleSystemVertexStream>();
        streams.AddRange(new ParticleSystemVertexStream[] {
         ParticleSystemVertexStream.Position,
         ParticleSystemVertexStream.Color,
         ParticleSystemVertexStream.Center,
         ParticleSystemVertexStream.Custom1X,
         ParticleSystemVertexStream.Rotation3D,
         ParticleSystemVertexStream.Custom2X,
         ParticleSystemVertexStream.SizeXYZ,
        });
        ren.SetActiveVertexStreams(streams);

        var main = ps.main;
        if (!main.startRotation3D)
        {
            main.startRotation3D = true;            
        }

        if (main.startRotationZ.constant > 0 || main.startRotationZ.constantMin > 0 || main.startRotationZ.constantMax > 0)
        {
            main.startRotationY = main.startRotationZ;
        }
        var minmax = main.startRotationX;
        minmax.constant = minmax.constantMax = minmax.constantMin = 0;
        main.startRotationX = main.startRotationZ = minmax;

        var rol = ps.rotationOverLifetime;
        rol.separateAxes = true;
        if (rol.z.constant > 0 || rol.z.constantMin > 0 || rol.z.constantMax > 0)
        {
            rol.y = rol.z;
        }

        minmax = rol.x;
        minmax.constant = minmax.constantMax = minmax.constantMin = 0;
        rol.x = rol.z = minmax;


        transform.localEulerAngles = new Vector3(0.0f, transform.localEulerAngles.y, transform.localEulerAngles.z);
        transform.localScale = new Vector3(1.0f, transform.localEulerAngles.z > 1.0f ? transform.localEulerAngles.z : 10.0f, 1.0f);
    }

    void Update()
    {
        block.SetMatrix("_w2o", ren.worldToLocalMatrix);        
        ren.SetPropertyBlock(block);
    }

    private void OnDisable()
    {
        ren.SetPropertyBlock(null);
        block.Clear();
        block = null;
    }
}
