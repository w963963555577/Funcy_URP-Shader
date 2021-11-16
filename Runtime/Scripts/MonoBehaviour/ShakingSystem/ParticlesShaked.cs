using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Mathematics;
#if UNITY_EDITOR
using UnityEditor;
#endif
namespace UnityEngine.Funcy.URP.Runtime
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(ParticleSystem))]
    public class ParticlesShaked : ShakeingCameraObject
    {
        [Range(0, 60)] public int frequency = 2;
        ParticleSystem pS;
        private void Update()
        {
            if (!pS) pS = GetComponent<ParticleSystem>();
            if (pS.isPlaying)
            {
                time = pS.time * frequency;
            }            
        }
    }
}