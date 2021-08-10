using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class AnimationInstancingElement : MonoBehaviour
{
    [Range(0, 1)] public float time; float time_tmp = -1;

    public int index = 0;
    AnimationInstancing root;

    Animator animator;
    private void OnEnable()
    {
        root = GetComponentInParent<AnimationInstancing>();
        animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        var rg = root.renderGroups[0];
        if (transform.hasChanged)
        {
            rg.UpdateTransform(index);            
            Debug.Log("The transform has changed!");
            transform.hasChanged = false;
        }        
        if(animator && Application.isPlaying)
        {
            var stateInfo = animator.GetCurrentAnimatorStateInfo(0);
            time = stateInfo.normalizedTime % 1.0f;
        }

        if (time_tmp != time)
        {
            time_tmp = time;
            rg.UpdateTime(index, time);
        }
    }
}
