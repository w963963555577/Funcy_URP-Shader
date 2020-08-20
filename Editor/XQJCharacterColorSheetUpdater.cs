using UnityEngine;
using UnityEngine.Networking;
using UnityEditor;
using Unity.Mathematics;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System;


public class XQJCharacterColorSheetUpdater : EditorWindow
{
    [MenuItem("ZD/Google Spread Sheet/Character Color Sheet Updater")]
   
   static void Init()
    {
        var window = Resources.FindObjectsOfTypeAll<XQJCharacterColorSheetUpdater>().FirstOrDefault();
        if(window == null)
        {
            window = GetWindow<XQJCharacterColorSheetUpdater>(true, "Color Sheet Updater");
        }
        window.minSize = new Vector2(500, 300);
        window.skinEyesHair = new SkinEyesHair();
        window.Show(true);
    }
    public Material referenceMaterial;
    public int selectionTabIndex = 0;
    string[] selectionTabList = new string[] { "Skin-Eyes-Hair", "Headdress", "Body" };

    public SkinEyesHair skinEyesHair;
    public static bool isNetworkUpdating = false;

    private void OnEnable()
    {
        isNetworkUpdating = false;
    }

    [System.Serializable]public class SkinEyesHair
    {
        public string currentFieldType = "";
        public Color skinColor, eyesColor, hairColor;
        [SerializeField] Color tmplate = Color.clear;
        public string[] postData = new string[9];

        public void Update()
        {
            isNetworkUpdating = true;

            string url;
            WWWForm form = new WWWForm();
            url = "https://script.google.com/macros/s/AKfycbzO4imjFLeMWQ-e-mYGbt3hXk96_-hBUHRQQiiL6nN4hhvCL5Q/exec";
            
            form.AddField("method", "read");
            form.AddField("sheetName", "Skin-Eyes-Hair");
            form.AddField("fieldType", currentFieldType);
            var getWebRequest = UnityWebRequest.Post(url, form);
            var getRequest = getWebRequest.SendWebRequest();
            
            isNetworkUpdating = true;
            getRequest.completed += (e) =>
            {
                if (getWebRequest.isNetworkError || getWebRequest.isHttpError)
                {
                    Debug.Log("Read - 網路錯誤");
                    isNetworkUpdating = false;
                }
                else
                {
                    var signSplit = getWebRequest.downloadHandler.text.Split('☆');
                    var dataExist = signSplit[0] == "True" ? true : false;
                    var updateRow = int.Parse(signSplit[1]);
                    
                    form = new WWWForm();
                    form.AddField("method", "write");
                    form.AddField("sheetName", "Skin-Eyes-Hair");
                    form.AddField("fieldType", currentFieldType);
                    form.AddField("fieldIndex", updateRow);

                    string colorRGBList = "";
                    for (int iter = 0; iter < postData.Length; iter++)
                    {
                        var data = postData[iter];
                        colorRGBList += data + (iter < postData.Length - 1 ? "," : "");
                    }

                    form.AddField("colorRGBList", colorRGBList);

                    var sendWebRequest = UnityWebRequest.Post(url, form);
                    var sendRequest = sendWebRequest.SendWebRequest();
                    sendRequest.completed += (d) =>
                    {
                        if (sendWebRequest.isNetworkError || sendWebRequest.isHttpError)
                        {
                            Debug.Log("Write - 網路錯誤");
                        }                        
                        isNetworkUpdating = false;
                        Debug.Log(sendWebRequest.downloadHandler.text);
                        sendWebRequest.Dispose();
                    };
                    
                }

                getWebRequest.Dispose();
            };
            
        }
    }
    private void Update()
    {
        if (!referenceMaterial) return;
        skinEyesHair.skinColor = referenceMaterial.GetColor("_DiscolorationColor_1");
        skinEyesHair.eyesColor = referenceMaterial.GetColor("_DiscolorationColor_2");
        skinEyesHair.hairColor = referenceMaterial.GetColor("_DiscolorationColor_7");
    }

    #region SkinEyesHairGUI
    void SkinEyesHairGUI()
    {
        GUILayout.BeginHorizontal("Box");
        {
            GUILayout.BeginVertical();
            {
                GUILayout.Label("", EditorStyles.boldLabel);
                GUILayout.BeginHorizontal("Box", GUILayout.Width(80));
                GUILayout.Label("配色", EditorStyles.boldLabel);
                GUILayout.EndHorizontal();
                GUILayout.BeginHorizontal("Box", GUILayout.Width(80));
                skinEyesHair.currentFieldType = EditorGUILayout.TextField(skinEyesHair.currentFieldType);
                GUILayout.EndHorizontal();

            }
            GUILayout.EndVertical();

            GUILayout.BeginVertical();
            {
                GUILayout.Label("Skin", EditorStyles.boldLabel);
                GUILayout.BeginHorizontal("Box");
                GUILayout.Label("R");
                GUILayout.Label("G");
                GUILayout.Label("B");
                GUILayout.EndHorizontal();
                EditorGUI.BeginDisabledGroup(true);
                {
                    GUILayout.BeginHorizontal("Box");
                    skinEyesHair.postData[0] = GUILayout.TextField(skinEyesHair.skinColor.r.ToString("0.00"));
                    skinEyesHair.postData[1] = GUILayout.TextField(skinEyesHair.skinColor.g.ToString("0.00"));
                    skinEyesHair.postData[2] = GUILayout.TextField(skinEyesHair.skinColor.b.ToString("0.00"));
                    GUILayout.EndHorizontal();
                }
                EditorGUI.EndDisabledGroup();
            }
            GUILayout.EndVertical();

            GUILayout.BeginVertical();
            {
                GUILayout.Label("Eyes", EditorStyles.boldLabel);
                GUILayout.BeginHorizontal("Box");
                GUILayout.Label("R");
                GUILayout.Label("G");
                GUILayout.Label("B");
                GUILayout.EndHorizontal();
                EditorGUI.BeginDisabledGroup(true);
                {
                    GUILayout.BeginHorizontal("Box");
                    skinEyesHair.postData[3] = GUILayout.TextField(skinEyesHair.eyesColor.r.ToString("0.00"));
                    skinEyesHair.postData[4] = GUILayout.TextField(skinEyesHair.eyesColor.g.ToString("0.00"));
                    skinEyesHair.postData[5] = GUILayout.TextField(skinEyesHair.eyesColor.b.ToString("0.00"));
                    GUILayout.EndHorizontal();
                }
                EditorGUI.EndDisabledGroup();
            }
            GUILayout.EndVertical();

            GUILayout.BeginVertical();
            {
                GUILayout.Label("Hair", EditorStyles.boldLabel);
                GUILayout.BeginHorizontal("Box");
                GUILayout.Label("R");
                GUILayout.Label("G");
                GUILayout.Label("B");
                GUILayout.EndHorizontal();
                EditorGUI.BeginDisabledGroup(true);
                {
                    GUILayout.BeginHorizontal("Box");
                    skinEyesHair.postData[6] = GUILayout.TextField(skinEyesHair.hairColor.r.ToString("0.00"));
                    skinEyesHair.postData[7] = GUILayout.TextField(skinEyesHair.hairColor.g.ToString("0.00"));
                    skinEyesHair.postData[8] = GUILayout.TextField(skinEyesHair.hairColor.b.ToString("0.00"));
                    GUILayout.EndHorizontal();
                }
                EditorGUI.EndDisabledGroup();
            }
            GUILayout.EndVertical();
        }
        GUILayout.EndHorizontal();
    }
    #endregion
    private void OnGUI()
    {
        EditorGUI.BeginDisabledGroup(isNetworkUpdating);
        var obj = (Material)EditorGUILayout.ObjectField("Reference", referenceMaterial, typeof(Material), false);
        if (obj)
        {
            if (obj.shader.name == "ZDShader/LWRP/Character")
            { referenceMaterial = obj; }
            else
            {
                Debug.Log("You must assign Material which shader path is 'ZDShader/LWRP/PBR Base'.");
            }
        }
        
        selectionTabIndex = GUILayout.Toolbar(selectionTabIndex, selectionTabList, GUILayout.Height(30));
        EditorGUI.EndDisabledGroup();
        switch (selectionTabList[selectionTabIndex])
        {
            case "Skin-Eyes-Hair":
                SkinEyesHairGUI();
                break;
            case "Headdress":

                break;
            case "Body":

                break;
        }

        GUILayout.FlexibleSpace();
        EditorGUI.BeginDisabledGroup(!referenceMaterial || isNetworkUpdating);
        if(GUILayout.Button("Update"))
        {
            switch (selectionTabList[selectionTabIndex])
            {
                case "Skin-Eyes-Hair":
                    skinEyesHair.Update();
                    break;
                case "Headdress":

                    break;
                case "Body":

                    break;
            }
        }
        EditorGUI.EndDisabledGroup();
        Repaint();
    }
}
