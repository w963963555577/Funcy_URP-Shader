using System.Collections.Generic;
using UnityEngine;

namespace bat.opt.bake.util
{
    public class BAT_BakeGroup
    {
        //main meterial
        public Material m_sharedMaterial;
        //MeshFilters using the same main material
        public List<BAT_BakeUnit> m_BakeUnits = new List<BAT_BakeUnit>();

        public Matrix4x4[] m_bindPoses;
        public Transform[] m_bones;
        public int Count
        {
            get
            {
                return m_BakeUnits.Count;
            }
        }
        public BAT_BakeUnit this[int id]
        {
            get
            {
                if (id >= 0 && id < m_BakeUnits.Count)
                {
                    return m_BakeUnits[id];
                }
                return null;
            }
        }

        public List<CombineInstance> ToCombineInstances()
        {
            List<CombineInstance> _toCombineList = new List<CombineInstance>();
            //collect all submeshes of this group
            for (int i = 0; i < m_BakeUnits.Count; i++)
            {
                var BakeUnitI = m_BakeUnits[i];
                var mfCI = BakeUnitI.Renderer;
                var _transform = mfCI.transform;
                var mesh = BakeUnitI.SharedMesh;
                var matrix = _transform.localToWorldMatrix;
                CombineInstance _ci = new CombineInstance();
                _ci.mesh = mesh;
                _ci.subMeshIndex = BakeUnitI.SubMeshID;
                _ci.transform = matrix;
                _toCombineList.Add(_ci);
            }
            return _toCombineList;
        }

        public bool IsSkinned
        {
            get { return m_BakeUnits.Count > 0 && m_BakeUnits[0].Renderer is SkinnedMeshRenderer; }
        }
    }
}