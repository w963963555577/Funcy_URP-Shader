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
    [RequireComponent(typeof(Camera))]
    public class ShakeCameraLayer : MonoBehaviour
    {
        public static List<ShakeingCameraObject> shakeingCameraObjects = new List<ShakeingCameraObject>();
        private float4x4 origMatrix;
        private float3 origPos;
#if UNITY_EDITOR
        private float4x4 origPreviewMatrix;
        private float3 origPreviewPos;
#endif

        private float intansity = 0.0f;
        private float3 intensityXYZ = Vector3.one;
        private float time = 0.0f;

        private float intansity_tmp = 0.0f;
        private bool shaking = false;

        

        private float3 startTime;

#if UNITY_EDITOR
        SceneView sceneView;
#endif

        private void OnEnable()
        {
#if UNITY_EDITOR
            SceneView.duringSceneGui += s =>
            {
                sceneView = s;
            };
#endif
        }


        void Update()
        {
            intansity = 0.0f;
            intensityXYZ = Vector3.one;
            time = 0.0f;
            
            foreach (var shaking in shakeingCameraObjects)
            {
                intansity += shaking.intansity;
                intensityXYZ = new float3(math.max(intensityXYZ.x, shaking.intensityXYZ.x), math.max(intensityXYZ.y, shaking.intensityXYZ.y), math.max(intensityXYZ.z, shaking.intensityXYZ.z));
                time = math.max(time, shaking.time);
            }

            if (intansity_tmp != intansity)
            {
                intansity_tmp = intansity;
                if (intansity <= 0)
                {
                    transform.right = -origMatrix.c0.xyz;
                    transform.up = origMatrix.c1.xyz;
                    transform.forward = origMatrix.c2.xyz;
                    transform.position = origMatrix.c3.xyz;
#if UNITY_EDITOR
                    if (sceneView)
                    {
                        sceneView.rotation = Quaternion.LookRotation(origPreviewMatrix.c2.xyz, origPreviewMatrix.c1.xyz);
                        sceneView.pivot = origPreviewPos;
                    }
#endif
                    shaking = false;
                    UnityEngine.Random.InitState(UnityEngine.Random.Range(-100, 100));
                    startTime.x = UnityEngine.Random.Range(-100.0f, 100.0f);
                    startTime.y = UnityEngine.Random.Range(-100.0f, 100.0f);
                    startTime.z = UnityEngine.Random.Range(-100.0f, 100.0f);
                }

            }

            if (intansity <= 0)
            {
                origMatrix = transform.localToWorldMatrix;
                origPos = transform.position;
#if UNITY_EDITOR

                if (sceneView)
                {
                    origPreviewMatrix.c0.xyz = sceneView.rotation * Vector3.right;
                    origPreviewMatrix.c1.xyz = sceneView.rotation * Vector3.up;
                    origPreviewMatrix.c2.xyz = sceneView.rotation * Vector3.forward;
                    origPreviewPos = sceneView.pivot;
                }
#endif
                return;
            }

            if (intansity > 0 && !shaking)
            {
#if UNITY_EDITOR

                if (sceneView)
                {
                    origPreviewMatrix.c0.xyz = sceneView.rotation * Vector3.right;
                    origPreviewMatrix.c1.xyz = sceneView.rotation * Vector3.up;
                    origPreviewMatrix.c2.xyz = sceneView.rotation * Vector3.forward;
                    origPreviewPos = sceneView.pivot;
                }
#endif
                shaking = true;
            }

            float currentIntansity = intansity / 10f;
            float3 runtime = startTime + new float3(time, time, time);
            float3 shakeDirection = new float3((Mathf.PerlinNoise(runtime.x, 0) - 0.5f) * 2.0f, (Mathf.PerlinNoise(0, runtime.y) - 0.5f) * 2.0f, (Mathf.PerlinNoise(runtime.z, runtime.z) - 0.5f) * 2.0f) * currentIntansity;
            shakeDirection *= intensityXYZ;

            transform.right = -origMatrix.c0.xyz + new float3(0, shakeDirection.yz);
            transform.up = origMatrix.c1.xyz + new float3(shakeDirection.x, 0, shakeDirection.z);
            transform.forward = origMatrix.c2.xyz + new float3(shakeDirection.xy, 0);
            transform.position = origPos + (float3)transform.TransformDirection(shakeDirection);

#if UNITY_EDITOR
            if (sceneView)
            {
                sceneView.rotation = Quaternion.LookRotation(origPreviewMatrix.c2.xyz + new float3(shakeDirection.xy, 0), origPreviewMatrix.c1.xyz + new float3(shakeDirection.x, 0, shakeDirection.z));
                sceneView.pivot = origPreviewPos;
            }
#endif

        }
    }
}