using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
public class VertexRectToShader : BaseMeshEffect
{    
    public RectTransform targetGraphic;

    public Vector2 refBlur = new Vector2(0.9f, 0.1f);
    private Camera uicamera;
    private RectTransform rootCanvas;
    public enum PositionMoode {World,Local }
    public PositionMoode positionMoode = PositionMoode.Local;

    [SerializeField]VertexRectToShaderGroup group;
    protected override void Awake()
    {
        base.Awake();
    }
    protected override void OnEnable()
    {
        if (group && !group.vertexRectToShaders.Contains(this)) group.vertexRectToShaders.Add(this);
    }
    protected override void OnDisable()
    {
        if (group && group.vertexRectToShaders.Contains(this)) group.vertexRectToShaders.Remove(this);
    }
    Vector2 tmp1 = Vector2.one * -99999, tmp2 = Vector2.one * -99999, tmp3 = Vector2.one * -99999;
    Vector2 currentPosition;
    private void Update()
    {
#if UNITY_EDITOR
        if (group && !group.vertexRectToShaders.Contains(this)) group.vertexRectToShaders.Add(this);
#endif
        if (rootCanvas == null)
            rootCanvas = GetComponentInParent<Canvas>().GetComponent<RectTransform>();
        if (uicamera == null)
            uicamera = GetComponentInParent<Canvas>().worldCamera;

        if (targetGraphic)
        {
            switch(positionMoode)
            {
                case PositionMoode.World:
                    currentPosition = uicamera.WorldToScreenPoint(targetGraphic.position, Camera.MonoOrStereoscopicEye.Mono);
                    currentPosition = currentPosition - (rootCanvas.sizeDelta * 0.5f) + (Vector2.one * 0.5f - targetGraphic.pivot) * targetGraphic.rect.size;
                    break;

                case PositionMoode.Local:                    
                    currentPosition = targetGraphic.anchoredPosition + (Vector2.one * 0.5f - targetGraphic.pivot) * targetGraphic.rect.size;
                    break;                
            }
            
            if (tmp1 != currentPosition)
            {
                tmp1 = currentPosition;
                graphic.SetVerticesDirty();
            }
            if (tmp2 != targetGraphic.rect.size)
            { 
                tmp2 = targetGraphic.rect.size;
                graphic.SetVerticesDirty();
            }
            if (tmp3 != refBlur)
            {
                tmp3 = refBlur;
                graphic.SetVerticesDirty();
            }
        }
    }
    public override void ModifyMesh(VertexHelper helper)
    {
        if (!IsActive() || helper.currentVertCount == 0 || !targetGraphic)
            return;                
        
        List<UIVertex> _vertexList = new List<UIVertex>();
        UIVertex vertex = new UIVertex();

        for (int i = 0; i < helper.currentVertCount; i++)
        {
            helper.PopulateUIVertex(ref vertex, i);
            vertex.uv1 = currentPosition;
            vertex.uv2 = targetGraphic.rect.size;
            vertex.uv3 = refBlur;
            helper.SetUIVertex(vertex, i);            
        }        
    }


    [System.Serializable]public class Vector3Event : UnityEvent<Vector3> { }
}
