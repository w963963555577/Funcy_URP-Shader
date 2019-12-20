using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
[InitializeOnLoad]
public class LatchEditorUpdate 
{
    static LatchEditorUpdate()
    {
        EditorApplication.delayCall += () => {
            EditorApplication.update += () => { EditorApplication.ExecuteMenuItem("Edit/Graphics Tier/Shader Hardware Tier 3"); };
        };
    }    
}
