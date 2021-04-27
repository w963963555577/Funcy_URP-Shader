using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Linq;

[InitializeOnLoad]
public class LatchEditorUpdate 
{
    /*
    static LatchEditorUpdate()
    {

        EditorApplication.delayCall += () => {
            EditorApplication.update += () => { };
            
            FileModificationWarning.onSavedProject += () =>
            {
                bool reimport = false;
                foreach (var file in Directory.GetFiles(Application.dataPath, "*", SearchOption.AllDirectories).ToList().FindAll(f => Path.GetExtension(f) == ".fbx" || Path.GetExtension(f) == ".FBX"))
                {
                    string localPath = file.Replace(Application.dataPath, "Assets");
                    ModelImporter modelImporter = (ModelImporter)AssetImporter.GetAtPath(localPath);
                    if (!modelImporter.isReadable)
                    {
                        modelImporter.isReadable = true;
                        modelImporter.SaveAndReimport();
                        reimport = true;
                    }
                }

            };            
        };

    }    
*/
}
public class FileModificationWarning : AssetModificationProcessor
{
    public static System.Action onSavedProject;
    static string[] OnWillSaveAssets(string[] paths)
    {
        onSavedProject?.Invoke();
        return paths;
    }
}