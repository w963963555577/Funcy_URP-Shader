using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace UnityEngine.Funcy.LWRP.Runtime
{
    [ExecuteInEditMode]
    public class TransformAnimation : MonoBehaviour
    {
        public Vector3 offset = Vector3.zero;
        public float animationIntensity = 0.05f;
        private Transform myTr;
        private void OnEnable()
        {
            myTr = transform;
        }

        // Update is called once per frame
        void Update()
        {
            myTr.localPosition = offset + new Vector3(0, Mathf.Sin(Timer.NowTime), 0) * animationIntensity;
        }
    }
}