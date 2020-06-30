using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace UnityEngine.Funcy.LWRP.Runtime
{
    [ExecuteInEditMode]
    public class WindAnimation : MonoBehaviour
    {
        public Texture2D maskTex;
        Renderer ren;

        string[] propertiesNames;
        float[] values;

        [Range(0.1f, 10f)] public float speed = 2.0f;
        [Range(0.1f, 10f)] public float amount = 1.0f;
        [Range(0.0f, 0.5f)] public float distance = 0.1f;
        [Range(0.0f, 1f)] public float zMotion = 0.5f;
        [Range(0.0f, 10f)] public float zMotionSpeed = 10.0f;
        [Range(0.1f, 1f)] public float originWeight = 1.0f;
        public bool debugMask = false;

        MaterialPropertyBlock prop = null;
        private void OnEnable()
        {
            ren = GetComponent<Renderer>();
            prop = new MaterialPropertyBlock();
            propertiesNames = new string[] {

        "_Speed",
        "_Amount",
        "_Distance",
        "_ZMotion",
        "_ZMotionSpeed",
        "_OriginWeight",
        "_DebugMask",
        "_PositionMask"
    };

        }

        // Update is called once per frame
        void Update()
        {
            values = new float[] {
        speed,
        amount,
        distance,
        zMotion,
        zMotionSpeed,
        originWeight,
        debugMask?1.0f:0.0f
    };
            ren.GetPropertyBlock(prop);

            for (int i = 0; i < values.Length; i++)
            {
                prop.SetFloat(propertiesNames[i], values[i]);
            }
            if (maskTex)
                prop.SetTexture(propertiesNames[7], maskTex);

            ren.SetPropertyBlock(prop);
        }
    }
}