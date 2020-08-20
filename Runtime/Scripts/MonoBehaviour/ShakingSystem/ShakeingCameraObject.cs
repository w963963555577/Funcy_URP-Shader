using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Mathematics;
#if UNITY_EDITOR
using UnityEditor;
#endif
namespace UnityEngine.Funcy.LWRP.Runtime
{
    [ExecuteInEditMode]
    public class ShakeingCameraObject : MonoBehaviour
    {
        [Range(0, 1)] public float intansity = 0.0f;
        public float3 intensityXYZ = Vector3.one;
        public float time = 0.0f;

        private void OnEnable()
        {
            ShakeCameraLayer.shakeingCameraObjects.Add(this);
        }

        private void OnDisable()
        {
            ShakeCameraLayer.shakeingCameraObjects.Remove(this);
        }
    }
}