using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using Unity.Rendering;
using UnityEngine.Rendering;
using Unity.Transforms;
using Unity.Jobs;
using Unity.Burst;
using Unity.Entities;
using Unity.Mathematics;
using Unity.Collections;
using System.Linq;


public class DOTSInstancingRenderer : MonoBehaviour
{
    World world;
    private void Awake()
    {
        world = World.DefaultGameObjectInjectionWorld;
        var entityManager = world.EntityManager;
        foreach (var ren in GetComponentsInChildren<MeshRenderer>())
        {
            if (!ren.gameObject.activeInHierarchy) continue;
            EntityArchetype archetype = entityManager.CreateArchetype(
            typeof(RenderMesh),
            typeof(RenderBounds),
            typeof(LocalToWorld));

            // 2
            Entity entity = entityManager.CreateEntity(archetype);

            entityManager.AddComponentData(entity, new RenderBounds { Value = new AABB { Center = Vector3.zero, Extents = ren.bounds.extents } });
            entityManager.AddComponentData(entity, new LocalToWorld { Value = Matrix4x4.TRS(ren.transform.position, ren.transform.rotation, ren.transform.lossyScale) });

            entityManager.AddSharedComponentData(entity, new RenderMesh
            {
                mesh = ren.GetComponent<MeshFilter>().sharedMesh,
                material = ren.sharedMaterial,
                castShadows = ren.shadowCastingMode,
                layer = ren.gameObject.layer,
                receiveShadows = ren.receiveShadows,
                subMesh = 0
            });
            ren.enabled = false;
        }
    }
    private void OnEnable()
    {
        
    }
    // Start is called before the first frame update
    private void Start()
    {        
        

    }

}
