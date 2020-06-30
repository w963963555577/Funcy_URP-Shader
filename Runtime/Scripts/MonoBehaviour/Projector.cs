using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace UnityEngine.Funcy.LWRP.Runtime
{
    [ExecuteInEditMode]
    public class Projector : MonoBehaviour
    {
        public float radius = 5.0f;
        [SerializeField] Collider[] inRangeColliders = new Collider[0];
        private void OnEnable()
        {
            
        }
        private void Update()
        {
            inRangeColliders = Physics.OverlapSphere(transform.position, radius);
        }

        private void OnDrawGizmos()
        {
            Gizmos.DrawWireSphere(transform.position, radius);
        }
    }
}