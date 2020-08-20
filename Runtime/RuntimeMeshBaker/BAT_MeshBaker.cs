using UnityEngine;
using System.Collections.Generic;
using bat.util;
using bat.opt.bake.util;
using UnityEngine.Rendering;

namespace bat.opt.bake
{
    /// <summary>
    /// </summary>
	public class BAT_MeshBaker : BAT_BakerBase
	{

        /// <summary>
        /// Bake all game objects under current GameObject,including meshes and materials.
        /// By default, baking will group the meshes by diffrent material(ShareMaterial).
        /// </summary>
        protected override GameObject Bake()
		{
            //create the target game object of merging to
            var allBakedTo = BAT_NodeUtil.RecreateChild(m_transform, "__AllBaked");
		    ReleaseRuntimeAssets();
            //collect all groups
		    BAT_Collecor BakeTable = new BAT_Collecor();
            BakeTable.Collect(this, m_regionSize);

            int BakedID = 0;
            List<BAT_BakeGroup> groups = BakeTable.Groups;
		    List<CombineInstance> _combinedObjs = new List<CombineInstance>();
            bool _hasSkinned = false;
            foreach (BAT_BakeGroup group in groups)
            {
                if (group.IsSkinned)
                {
                    _hasSkinned = true;
                }
            }
            bool _seprateShadow = !_hasSkinned && m_seprateShadow;
            //baking by groups
            foreach (BAT_BakeGroup group in groups)
			{
				if(group.Count <= 0)
				{
					continue;
				}
                var childNode = BAT_NodeUtil.CreateChild(allBakedTo, "__mt_" + BakedID);
			    var _combineList = group.ToCombineInstances();
                CombineList(childNode, _combineList, group.m_sharedMaterial,group.IsSkinned, group.m_bindPoses, group.m_bones);
			    _combinedObjs.AddRange(_combineList);

                BakedID++;
			}
            //disable renderers
            foreach (BAT_BakeGroup group in groups)
            {
                DisableMeshRenderers(group);
            }

		    //start baking shadow object
            if (_seprateShadow)
		    {
                try
		        {
                    //disable baked renderer's shadow mode
                    var _allBakedRenderers = allBakedTo.GetComponentsInChildren<Renderer>();
                    foreach (var _renderer in _allBakedRenderers)
                    {
                        _renderer.shadowCastingMode = ShadowCastingMode.Off;
                    }
                    //create new child node for casting shadow
                    var shadowObj = BAT_NodeUtil.CreateChild(allBakedTo, "shadowOnly");
		            var shadowMaterial = Resources.Load<Material>("ShadowOnly");
                    CombineList(shadowObj, _combinedObjs, shadowMaterial,false, null,null);
		            var _shadowRenderers = shadowObj.GetComponentsInChildren<MeshRenderer>();
		            foreach (var _render in _shadowRenderers)
		            {
                        _render.shadowCastingMode = ShadowCastingMode.ShadowsOnly;
                    }

		        }
                catch (System.Exception e)
		        {
		            Debug.LogError("Error occured in baking shadow object \n " + e.Message);
		        }

            }

		    //clear resource not needed
			BakeTable.Clear();
			Resources.UnloadUnusedAssets();
            //Baked event
			if(OnBaked != null)
			{
				OnBaked();
			}
			return allBakedTo.gameObject;
		}

        protected static void CombineList(Transform _root, List<CombineInstance> _toCombineList,
            Material _sharedMaterial, bool _isSkinned,Matrix4x4[] _binedPoses, Transform[] bones)
        {
            //Bake mesh of current group,if mesh vertexCount>=64k,
            //it would be seperated into several children
            int beginID = 0;
            int vertexCount = 0;
            int meshBakeID = 0;
            int currentID = 0;
            while (currentID < _toCombineList.Count)
            {
                Mesh mesh_i = (_toCombineList[currentID]).mesh;
                //                int subMeshCount = mesh_i.subMeshCount;
                int vertexCountI = mesh_i.vertexCount;
                //whether exceed the vertextCount

                bool exceedVC = (vertexCount + vertexCountI >= MaxBakingVertex);
                //the end of group
                bool endOfGroup = currentID >= _toCombineList.Count - 1;
                //need Bake now? 
                bool needBake = false;
                if (exceedVC)
                {
                    needBake = true;
                }
                else if (endOfGroup)
                {
                    needBake = true;
                }
                //need baking now
                if (needBake)
                {
                    //create new child node
                    var childNode = BAT_NodeUtil.CreateChild(_root, _root.name + "__Baked_" + meshBakeID).gameObject;
                    int count;
                    int beginIDNext;
                    //one mesh's vertexCount exceed the max,Bake one
                    if (currentID == beginID)
                    {
                        count = 1;
                        beginIDNext = currentID + 1;
                        vertexCount = 0;
                    }
                    else
                    {
                        //exceed ,Bake [beginID,currentID)
                        if (exceedVC)
                        {
                            count = currentID - beginID;
                            beginIDNext = currentID;
                            vertexCount = vertexCountI;
                        }
                        else //end of group ,and not exceed,Bake [beginID,currentID]
                        {
                            count = _toCombineList.Count - beginID;
                            beginIDNext = currentID + 1;
                            vertexCount = 0;
                        }
                    }
                    //start baking
                    Mesh BakedMesh = new Mesh();
                    BakedMesh.name = "Baked_Mesh_" + _root.name;
                    MarkRuntimeAsset(BakedMesh);
                    //combine all submeshes
                    CombineInstance[] combineInsts = _toCombineList.GetRange(beginID,count).ToArray();
                    try
                    {
                        BakedMesh.CombineMeshes(combineInsts, true, true);
                        //优化过程应该设置可选
                        //  var _simpled = MeshUti.SimpleMesh(BakedMesh);
                        //  Object.DestroyImmediate(BakedMesh);
                        //  BakedMesh = _simpled;
                    }
                    catch (System.Exception e)
                    {
                        Debug.LogError("Error occured in baking " + count + " items \n " + e.Message);
                    }

                    if (_isSkinned)
                    {
                        //add SkinnedMeshRenderer to Baked child
                        SkinnedMeshRenderer mr_Baked = childNode.AddComponent<SkinnedMeshRenderer>();
                        BakedMesh.RecalculateBounds();
                        mr_Baked.sharedMesh = BakedMesh;
                        mr_Baked.sharedMaterial = _sharedMaterial;
                        BakedMesh.bindposes = _binedPoses;
                        mr_Baked.bones=bones;
                    }
                    else
                    {
                        //add MeshFilter to Baked child
                        MeshFilter mf_Baked = childNode.AddComponent<MeshFilter>();
                        mf_Baked.sharedMesh = BakedMesh;

                        //add MeshRenderer to Baked child
                        Renderer mr_Baked = childNode.AddComponent<MeshRenderer>();
                        mr_Baked.sharedMaterial = _sharedMaterial;
                    }

                    //set same layer with root 
                    childNode.layer = _root.gameObject.layer;

                    //ready for next
                    beginID = beginIDNext;

                    meshBakeID++;
                }
                else //not need Bake, add the vertexCount
                {
                    vertexCount += vertexCountI;
                }
                currentID++;
            }

        }

    }
}