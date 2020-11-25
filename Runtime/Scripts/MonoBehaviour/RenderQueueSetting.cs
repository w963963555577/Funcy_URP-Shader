using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RenderQueueSetting : MonoBehaviour
{
    [HideInInspector][SerializeField] int srcQueue = -9999;    
    [HideInInspector] [SerializeField] Renderer ren;
    [SerializeField] UnityEngine.Rendering.BlendMode srcBlend = UnityEngine.Rendering.BlendMode.One, dstBlend = UnityEngine.Rendering.BlendMode.Zero;
    public int queue;
    private void OnEnable()
    {

    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
#if UNITY_EDITOR
        if(!ren)
        {
            srcQueue = -9999;
        }
        if (GetComponent<Renderer>() && srcQueue <= -9999)
        {
            ren = GetComponent<Renderer>();
            srcQueue = queue = ren.sharedMaterial.renderQueue;            
        }
#endif
        if (!ren) return;
        if (ren.sharedMaterial.renderQueue != queue)
        {
            ren.sharedMaterial.renderQueue = queue;
            if (queue > 2450)
                ren.sharedMaterial.EnableKeyword("_AlphaClip");
            else
                ren.sharedMaterial.DisableKeyword("_AlphaClip");

            ren.sharedMaterial.SetFloat("_SrcBlend", (int)srcBlend);
            ren.sharedMaterial.SetFloat("_DstBlend", (int)dstBlend);
        }
    }
}
