using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationMapData : StateMachineBehaviour
{    
    public int index;
    public AnimatorStateInfo stateInfo;
    AnimationInstancingElement e;
    override public void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        if (!e) e = animator.GetComponent<AnimationInstancingElement>();
        this.stateInfo = stateInfo;
        e.StartCoroutine(AutoNext(animator));
    }

    IEnumerator AutoNext(Animator animator)
    {
        float randomTime = Random.Range(2.0f, 3.0f);
        yield return new WaitForSecondsRealtime(randomTime);
        animator.SetTrigger("Next");
    }
}
