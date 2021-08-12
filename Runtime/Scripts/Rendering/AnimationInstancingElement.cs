using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
[ExecuteInEditMode]
public class AnimationInstancingElement : MonoBehaviour
{
    [Range(0, 1)] public float time; float time_tmp = -1;
    
    public int index = 0;
    public int currentAnimation, nextAnimation;
    [Range(0, 1)]public float blend = 0.0f;
    AnimationInstancing root;

    [HideInInspector]public Animator animator;

    List<AnimationMapData> allBehaviours;

    Renderer ren;
    MaterialPropertyBlock propertyBlock;
    private void OnEnable()
    {
        root = GetComponentInParent<AnimationInstancing>();
        animator = GetComponent<Animator>();
        allBehaviours = animator.GetBehaviours<AnimationMapData>().ToList();
        ren = GetComponent<Renderer>();

        propertyBlock = new MaterialPropertyBlock();
        propertyBlock.Clear();
        ren.GetPropertyBlock(propertyBlock);
    }

    // Update is called once per frame
    void Update()
    {
        if (!root) return;
        var rg = root.renderGroups[0];
        if (transform.hasChanged)
        {
            rg.UpdateTransform(index);
            transform.hasChanged = false;
        }
        
        if (animator && Application.isPlaying)
        {
            blend = 0.0f;
            var currStateInfo = animator.GetCurrentAnimatorStateInfo(0);
            var nextStateInfo = animator.GetNextAnimatorStateInfo(0);
            
            if (Application.isPlaying)
            {
                var currData = allBehaviours.Find(b => b.stateInfo.fullPathHash == currStateInfo.fullPathHash);
                if (currData)
                    currentAnimation = currData.index;
                 
                time = currStateInfo.normalizedTime % 1.0f;

                if (nextStateInfo.fullPathHash != 0)
                {                    
                    var nextData = allBehaviours.Find(b => b.stateInfo.fullPathHash == nextStateInfo.fullPathHash);
                    nextAnimation = nextData.index;

                    var transInfo = animator.GetAnimatorTransitionInfo(0);
                    
                    blend = transInfo.normalizedTime;
                    time = nextStateInfo.normalizedTime;
                }
            }                        
        }

        var timeData = new Vector4(time, blend, currentAnimation, nextAnimation);
        if (rg.activeGroup)
        {
            propertyBlock.SetVector("_TimeData", timeData);
            ren.SetPropertyBlock(propertyBlock);
        }
        else
        {
            rg.UpdateTime(index, timeData);            
        }        
    }
}