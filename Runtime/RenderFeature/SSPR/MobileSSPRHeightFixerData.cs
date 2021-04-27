using System.Collections;
using System.Collections.Generic;
using UnityEngine;


#if UNITY_EDITOR
[CreateAssetMenu(menuName = "RenderFeature/SSPR/Height Fixer Data")]
#endif
public class MobileSSPRHeightFixerData : ScriptableObject
{
    public Texture2D horizontalHeightFixerMap;
    public Vector4 worldSize_Offest_HeightIntensity = Vector4.zero;
}
