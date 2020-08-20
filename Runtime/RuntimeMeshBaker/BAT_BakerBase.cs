using UnityEngine;
using System.Collections.Generic;
using System;
using bat.opt.bake.util;

namespace bat.opt.bake
{
    public enum ClearSkinnedMeshSetting
    {
        Nothing,
        SkinnedRenderers,
    }


	public abstract class BAT_BakerBase : MonoBehaviour
	{
		[SerializeField][Tooltip("Auto combine if not Baked.")]
		public bool m_autoBake=true;
        [SerializeField][Tooltip("Seperate the shadow caster by group")]
        public bool m_seprateShadow = false;

        [SerializeField] [Tooltip("Bake Region Size")]
        public int m_regionSize = 1000;
        [SerializeField] [Tooltip("Show Region Gizmos")]
        public bool m_showRegionGizmo = true;

        [NonSerialized][Tooltip("Events on Baked")]
		public Action OnBaked;
        [NonSerialized][Tooltip("has Baked or not.")]
		protected bool m_hasBaked=false;

        protected Transform m_transform;

        protected virtual void Awake()
        {
            m_transform =transform;
        }
        public static int MaxBakingVertex
        {
            get
            {
                return 65535;
            }
        }
        protected virtual void Start()
        {

        }
        protected virtual void OnEnable()
        {
            if (!m_hasBaked && m_autoBake)
            {
                StartBake();
                m_hasBaked = true;
            }
        }

        protected virtual void OnDisable()
        {
	        m_hasBaked = false;
        }


        /// <summary>
        /// Start Bake
        /// </summary>
        public void StartBake()
        {
            Bake();
        }

		/// <summary>
        /// Bake all game objects under current GameObject,including meshes and materials.
        /// By default, baking will group the meshes by diffrent material(ShareMaterial).
		/// </summary>
        protected abstract GameObject Bake();

        /// <summary>
        /// diable meshrenderer in original game objects by diffrent deep
        /// </summary>
        /// <param name="groups">groups holding the old elelemts which have been Baked</param>
        protected virtual void DisableMeshRenderers(List<BAT_BakeGroup> groups)
        {
            foreach (var group in groups)
            {
                if (group.Count == 0)
                {
                    continue;
                }
                DisableMeshRenderers(group);
            }
        }
        protected void DisableMeshRenderers(BAT_BakeGroup group)
        {
            for (int i = 0; i < group.Count; i++)
            {
                if (group[i] == null)
                {
                    continue;
                }

                var mrI = group[i].Renderer;
                if (mrI != null)
                {
                    mrI.enabled = false;
                }

            }
        }
        #region assets releasing
        /// <summary>
        /// m_assetsCreated are those assets created in baking progress,you need to
        /// destroy them directly when you does't need the them,because them may not be
        /// destroyed successfully by destroying the created GameObject.
        /// </summary>
        private static List<UnityEngine.Object> m_assetsCreated = new List<UnityEngine.Object>();

        /// <summary>
        /// mark the asset for releasing
        /// </summary>
        /// <param name="_asset"> asset to release</param>
        public static void MarkRuntimeAsset(UnityEngine.Object _asset)
        {
            m_assetsCreated.Add(_asset);
        }

	    protected void ReleaseRuntimeAssets()
	    {
	        if (m_assetsCreated != null && m_assetsCreated.Count > 0)
	        {
	            for (int i = 0; i < m_assetsCreated.Count; i++)
	            {
	                if (m_assetsCreated[i] != null)
	                {
	                    DestroyImmediate(m_assetsCreated[i]);
	                }
	            }
	            m_assetsCreated.Clear();
	            Resources.UnloadUnusedAssets();
	        }
        }

	    protected void OnDestroy()
	    {
	        ReleaseRuntimeAssets();
	    }

	    protected void OnDrawGizmos()
	    {
		    if (!m_showRegionGizmo)
		    {
			    return;
		    }
		    Color _orgColor = Gizmos.color;
		    Gizmos.color = Color.blue;
		    int lineCount = 10;
		    int span = m_regionSize * lineCount;
		    for (int j = 0; j < 10; j++)
		    {
			    float _d = (j+0.5f) * m_regionSize;
			    Gizmos.DrawLine(new Vector3(_d,0,-span),new Vector3(_d,0,span) );
			    Gizmos.DrawLine(new Vector3(-_d,0,-span),new Vector3(-_d,0,span) );
		    }
		    for (int j = 0; j < 10; j++)
		    {
			    float _d = (j+0.5f) * m_regionSize;
			    Gizmos.DrawLine(new Vector3(-span,0,_d),new Vector3(span,0,_d) );
			    Gizmos.DrawLine(new Vector3(-span,0,-_d),new Vector3(span,0,-_d) );
		    }
		    Gizmos.color=_orgColor;
	    }

	    #endregion

    }


}