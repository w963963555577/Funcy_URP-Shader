using System;
using UnityEngine;

namespace bat.opt.bake.util
{
    public class BAT_BakeUnit
    {
        protected Renderer m_renderer;
        protected Mesh m_sharedMesh;
        protected int m_subMeshID;
        public Mesh SharedMesh
        {
            get
            {
                return m_sharedMesh;
            }
        }
        public Renderer Renderer
        {
            get
            {
                return m_renderer;
            }
        }
        public int SubMeshID
        {
            get
            {
                return m_subMeshID;
            }
        }
        public BAT_BakeUnit SetValue(Mesh _sharedMesh, Renderer _renderer,int _subMeshID)
        {
            m_sharedMesh = _sharedMesh;
            m_renderer = _renderer;
            m_subMeshID = _subMeshID;
            return this;
        }
    }
}
