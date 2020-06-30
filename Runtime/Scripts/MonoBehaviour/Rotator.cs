using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace UnityEngine.Funcy.LWRP.Runtime
{
    [ExecuteInEditMode]
    public class Rotator : MonoBehaviour
    {
        [HideInInspector] [SerializeField] Matrix4x4 origMatrix;
        [HideInInspector] [SerializeField] Vector3 origPos;

        public enum RotateAxis { X, Y, Z }
        public RotateAxis rotateAxis = RotateAxis.Y;
        public Space rotationSpace = Space.Self;
        public float angularVelocity = 5.0f;

        private void Reset()
        {
            origMatrix = transform.localToWorldMatrix;
            origPos = transform.position;
        }
        // Start is called before the first frame update
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {
            Vector3 axis;
            axis = new Vector3(
                rotateAxis == RotateAxis.X ? 1 : 0,
                rotateAxis == RotateAxis.Y ? 1 : 0,
                rotateAxis == RotateAxis.Z ? 1 : 0
                );
            transform.Rotate(axis, angularVelocity, rotationSpace);
        }

        private void OnDisable()
        {
            transform.right = -origMatrix.GetColumn(0);
            transform.up = origMatrix.GetColumn(1);
            transform.forward = origMatrix.GetColumn(2);
            transform.position = origMatrix.GetColumn(3);
        }
    }
}