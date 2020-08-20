using System;
using System.Collections.Generic;
using bat.util;
using UnityEngine;

namespace bat.opt.bake.util
{
    public class BAT_Collecor
    {
        public bool m_isSkinnedMesh=false;
        /// <summary>
        /// all groups
        /// </summary>
        protected Dictionary<GroupKey, BAT_BakeGroup> m_groupTables = new Dictionary<GroupKey, BAT_BakeGroup>();
        /// <summary>
        /// group MeshFilters by main material(sharedMaterial).
        /// if exsit two MeshFilter,using the same main meterial(sharedMaterial),
        /// but the diffrent sharedMaterials,it would be recognized as the same meterials ,
        /// use the first marked sharedMaterials.
        /// </summary>
        /// <param name="baker"></param>
        /// <param name="regionSize"></param>
        public  void Collect(BAT_BakerBase baker, int regionSize)
        {
            List<Renderer> _renderers=new List<Renderer>();
            List<SkinnedMeshRenderer> _skinnedMeshRenderers = BAT_NodeUtil.ListAllInChildren<SkinnedMeshRenderer>(baker.transform);
            if (_skinnedMeshRenderers.Count > 0)
            {
                _renderers.AddRange(_skinnedMeshRenderers.ToArray());
            }
            else
            {
                List<MeshFilter> meshFilters = BAT_NodeUtil.ListAllInChildren<MeshFilter>(baker.transform);
                for (int i = 0; i < meshFilters.Count; i++)
                {
                    MeshFilter meshFilterI = meshFilters[i];
                    if (meshFilterI == null || meshFilterI.mesh == null)
                    {
                        continue;
                    }
                    //check if exist MeshRenderer on the MeshFilter
                    MeshRenderer meshRendererI = meshFilterI.GetComponent<MeshRenderer>();
                    if (meshRendererI == null)
                    {
                        continue;
                    }
                    _renderers.Add(meshRendererI);
                }
            }

            for (int i = 0; i < _renderers.Count; i++)
            {
                var _rendererI = _renderers[i];
                var materials = _rendererI.sharedMaterials;
                if (materials == null)
                {
                    continue;
                }

                var _meshFilter = _rendererI.GetComponent<MeshFilter>();
                if (_meshFilter == null)
                {
	                continue;
                }
                Mesh _sharedMesh = _meshFilter.sharedMesh;
                int subMeshCount = _sharedMesh==null?0:_sharedMesh.subMeshCount;
                for (int j = 0; j < subMeshCount; j++)
                {
                    if (j >= materials.Length)
                    {
                        continue;
                    }
                    var _key = new GroupKey();
                    _key.material = materials[j];
                    var _subMeshCenter = MeshUtil.GetSubMeshCenter(_sharedMesh, j);
                    var _subMeshCenterWorld = _rendererI.transform.TransformPoint(_subMeshCenter);
                    _key.setValue(_subMeshCenterWorld, regionSize);
                    //grop by main material
                    BAT_BakeGroup group = null;
                    if (m_groupTables.ContainsKey(_key))
                    {
                        group = m_groupTables[_key];
                    }
                    else
                    {
                        group = new BAT_BakeGroup();
                        group.m_sharedMaterial = materials[j];
                        m_groupTables.Add(_key, group);
                    }
                    var bakeUnit = new BAT_BakeUnit();
                    bakeUnit.SetValue(_sharedMesh, _rendererI, j);
                    //place into the group
                    group.m_BakeUnits.Add(bakeUnit);
                }

            }

        }
        public List<BAT_BakeGroup> Groups
        {
            get
            {
                List<BAT_BakeGroup> groups = new List<BAT_BakeGroup>();
                foreach (var g in m_groupTables.Values)
                {
                    groups.Add(g);
                }
                return groups;
            }
        }
        public void Clear()
        {
            m_groupTables.Clear();
        }
    }


    public struct GroupKey:IEquatable<GroupKey>
    {
        public Material material;
        public Vector3Int region;

        public void setValue(Vector3 position, int regionSize)
        {
	        regionSize = Math.Abs(regionSize);
            if (regionSize == 0)
            {
                regionSize = 65536;
            }
            region.x = getRegionID(position.x,regionSize);
            region.y = getRegionID(position.y,regionSize);
            region.z = getRegionID(position.z,regionSize);
        }

        private int getRegionID(float _value, int regionSize)
        {
	        int _id = (int) ((Mathf.Abs(_value) + regionSize * 0.5f) / regionSize);
	        return _id * Math.Sign(_value);
        }

        public bool Equals(GroupKey other)
        {
	        return Equals(material, other.material)&& region.Equals(other.region);

        }

        public override bool Equals(object obj)
        {
	        return obj is GroupKey other && Equals(other);
        }

        public override int GetHashCode()
        {
	        unchecked
	        {
		        var hashCode = (material != null ? material.GetHashCode() : 0);
		        hashCode = (hashCode * 397) ^ region.GetHashCode();
		        return hashCode;
	        }
        }
    }
}
