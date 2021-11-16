using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.InteropServices;
using System;
using System.Linq;
using System.IO;
using UnityEngine.Rendering.Universal;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Rendering;
using uWintab;
#endif
namespace UnityEngine.Funcy.URP.Runtime
{
#if UNITY_EDITOR
    [ExecuteInEditMode]
    public class Painter : Tablet
    {
        [SerializeField] Collider co;
        private void Reset()
        {
            currentRenderer = GetComponent<Renderer>();
            ClearTexture();
            co = GetComponent<Collider>() ? GetComponent<Collider>() : gameObject.AddComponent<MeshCollider>();
            if(currentRenderer.GetType()==typeof(SkinnedMeshRenderer) && co.GetType()==typeof(MeshCollider))
            {
                var MCO = ((MeshCollider)co);
                Mesh mc = new Mesh();
                ((SkinnedMeshRenderer)currentRenderer).BakeMesh(mc);
                MCO.sharedMesh = mc;                
            }
#if UNITY_EDITOR
            SceneView.duringSceneGui += UpdateSceneView;
#endif
        }
        public override void OnEnable()
        {
            base.OnEnable();
            if (!currentRenderer) return;

            ClearTexture();
#if UNITY_EDITOR
            SceneView.duringSceneGui += UpdateSceneView;            
#endif
        }
        public void ClearTexture()
        {
            runtimeTex.Release();
            paintedTex.Release();
            RenderTexture.active = paintedTex;
            GL.Clear(true, true, Color.white);
            RenderTexture.active = null;

        }
        public void ClearTextureAsBrushColor()
        {
            runtimeTex.Release();
            paintedTex.Release();
            RenderTexture.active = paintedTex;
            GL.Clear(true, true, brushMask.GetColor("_BrushColor"));
            RenderTexture.active = null;

        }
        public override void OnDisable()
        {
            base.OnDisable();
            currentRenderer.sharedMaterial.SetTexture(selectProperty, null);
            runtimeTex.Release();
            paintedTex.Release();
#if UNITY_EDITOR
            SceneView.duringSceneGui -= UpdateSceneView;
#endif
        }

        private void GetOrCreateIsolateCamera()
        {            
            if (!isolateCamera)
            {
                GameObject go = new GameObject("Brush isolate camera" + GetInstanceID(), typeof(Camera));
                isolateCamera = go.GetComponent<Camera>();
                isolateCamera.gameObject.hideFlags = HideFlags.HideAndDontSave;
            }
            else
            {
                isolateCamera.transform.position = currentRenderer.bounds.center;                
                isolateCamera.transform.rotation = Quaternion.identity;                
                isolateCamera.clearFlags = CameraClearFlags.SolidColor;
                isolateCamera.backgroundColor = Color.black;
                isolateCamera.orthographic = true;
                isolateCamera.orthographicSize = currentRenderer.bounds.size.magnitude / 2.0f;
                isolateCamera.nearClipPlane = -isolateCamera.orthographicSize;
                isolateCamera.farClipPlane = isolateCamera.orthographicSize;
                isolateCamera.targetTexture = runtimeTex;
                var camData = isolateCamera.GetComponent<UniversalAdditionalCameraData>() ? isolateCamera.GetComponent<UniversalAdditionalCameraData>() : isolateCamera.gameObject.AddComponent<UniversalAdditionalCameraData>();                
                camData.SetRenderer(1);                                
            }
        }


        Ray ray;
#if UNITY_EDITOR
        // Update is called once per frame
        void UpdateSceneView(SceneView sceneView)
        {
            Event e = Event.current;
            ray = this.proximity ?
                Camera.current.ViewportPointToRay(new Vector3(this.x , this.y  ))
                :
             Camera.current.ScreenPointToRay(new Vector3(e.mousePosition.x, -e.mousePosition.y + Camera.current.pixelHeight));
            HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));
        }
#endif
        void DrawBrushMesh(Mesh sharedMesh)
        {
            
            //Draw UV Texture
            isolateCamera.cullingMask = (int)Mathf.Pow(2, 30);
            Graphics.DrawMesh(sharedMesh, transform.localToWorldMatrix, worldToUVPoint, 30, isolateCamera);

            //Draw Brush Priview
            Graphics.DrawMesh(sharedMesh, transform.localToWorldMatrix, brushMask, 0);

            worldToUVPoint.SetMatrix("mesh_Object2World", transform.localToWorldMatrix);
        }
        void Paint(Vector3 drawPoint, Mesh sharedMesh)
        {
            worldToUVPoint.SetVector("_Point", drawPoint);
            //DrawBrushMesh(sharedMesh);
            
            Graphics.Blit(null, paintedTex, brushMask);
        }
        private void Update()
        {
            if (!currentRenderer) return;
            currentRenderer.sharedMaterial.SetTexture(selectProperty, paintedTex);

            GetOrCreateIsolateCamera();

            Mesh sharedMesh = GetComponent<MeshFilter>() ? GetComponent<MeshFilter>().sharedMesh : GetComponent<SkinnedMeshRenderer>() ? GetComponent<SkinnedMeshRenderer>().sharedMesh : null;
            if (!sharedMesh)
            {
                Debug.Log("There are no meshs in Object");
                return;
            }

            DrawBrushMesh(sharedMesh);

            if (Physics.Raycast(ray, out RaycastHit hit, Mathf.Infinity))
            {                
                bool isMousePress = false;
#if UNITY_EDITOR
                isMousePress = !Input.GetLeftAltPress() && (Input.GetMouseLeftPress() || this.isPenDrawing);
#else
                isMousePress = UnityEngine.Input.GetMouseButton(0) && UnityEngine.Input.GetKey(KeyCode.LeftAlt);
#endif

                if (isMousePress)
                {                    
                    if(this.isPenDrawing)
                    {
                        brushMask.EnableKeyword("_Tablet");
                        brushMask.SetFloat("_BrushAlpha", this.pressure);
                    }
                    else
                    {
                        brushMask.DisableKeyword("_Tablet");
                    }
                    
                    
                    if (currentPoint != hit.point && Vector3.Distance(currentPoint, hit.point) > worldToUVPoint.GetFloat("_BrushSize") / 3000.0f ) 
                    {
                        currentPoint = Vector3.Lerp(currentPoint, hit.point, 0.5f);
                        Paint(currentPoint, sharedMesh);
                    } 
                }
                else
                {
                    currentPoint = hit.point;
                    worldToUVPoint.SetVector("_Point", hit.point);
                    brushMask.DisableKeyword("_Tablet");
                }
                Debug.DrawLine(hit.point, hit.point + hit.normal, Color.red);
            }
            else
            {
                //Debug.DrawLine(ray.origin, ray.origin + ray.direction * 1000f, Color.red);
                brushMask.DisableKeyword("_Tablet");
            }
        }

        private void OnDestroy()
        {
#if UNITY_EDITOR
            if(co)
            {
                DestroyImmediate(co);
            }
#endif
        }
        [HideInInspector] [SerializeField] private Vector3 currentPoint;
#if UNITY_EDITOR
        public class Input
        {
            public static bool GetMouseLeftPress() { return GetAsyncKeyState(0x01) != 0; }
            public static bool GetLeftAltPress() { return GetAsyncKeyState(18) != 0; }
        }
        [HideInInspector] public Texture texTemplate;
#endif
        #region Properties
#if UNITY_EDITOR
        [DllImport("user32.dll")]
        public static extern short GetAsyncKeyState(UInt16 virtualKeyCode);
#endif

        public Material worldToUVPoint;
        public Material brushMask;
        public RenderTexture runtimeTex;
        public RenderTexture paintedTex;

        [HideInInspector] [SerializeField] private Camera isolateCamera;

        public Renderer currentRenderer;
        public string selectProperty = "";

#endregion
    }
#endif
    #region Editor
#if UNITY_EDITOR
    [InitializeOnLoad]
    [CustomEditor(typeof(Painter))]
    public class Painter_Editor : Editor
    {
        Painter data;
        MaterialEditor worldToUVPoint, brushMask;
        private void OnEnable()
        {
            data = target as Painter;
            worldToUVPoint = CreateEditor(data.worldToUVPoint) as MaterialEditor;
            brushMask = CreateEditor(data.brushMask) as MaterialEditor;
        }
        public override void OnInspectorGUI()
        {
            //base.OnInspectorGUI();
            EditorGUI.BeginDisabledGroup(true);
            var rect = new Rect();

            rect.y += rect.size.y + 5;
            rect.x += 15;
            rect.size = new Vector2(EditorGUIUtility.currentViewWidth * 0.8f, EditorGUIUtility.currentViewWidth * 0.8f);
            GUI.DrawTexture(rect, data.paintedTex);
            GUILayout.Box("", GUILayout.Width(rect.width), GUILayout.Height(rect.height));
            EditorGUI.EndDisabledGroup();
            if (GUILayout.Button("Clear Texture as white")) data.ClearTexture();
            if (GUILayout.Button("Clear Texture as brush color")) data.ClearTextureAsBrushColor();
            data.selectProperty = SelectPopupShaderProperties("Select Property", data.currentRenderer.sharedMaterial.shader, data.selectProperty, ShaderUtil.ShaderPropertyType.TexEnv);

            GUILayout.BeginVertical("Box");
            
            worldToUVPoint.ShaderProperty(data.worldToUVPoint.shader, 0);
            worldToUVPoint.ShaderProperty(data.worldToUVPoint.shader, 1);
            brushMask.ShaderProperty(data.brushMask.shader, 0);

            GUILayout.EndVertical();

            if (GUILayout.Button("Save to Texture")) 
                SaveRenderTextureToPNG("painter_texture", data.paintedTex);

            Repaint();
        }

        private void OnDisable()
        {
            DestroyImmediate(worldToUVPoint);
            DestroyImmediate(brushMask);
        }


        public string SelectPopupShaderProperties(string title,Shader shader, string nowSelection, params ShaderUtil.ShaderPropertyType[] includeTypes)
        {
            List<string> props = new List<string>();
            int count = ShaderUtil.GetPropertyCount(shader);
            for (int i = 0; i < count; i++)
            {
                if (includeTypes != null)
                {                    
                    var types = includeTypes.ToList();
                    if (types.Contains(ShaderUtil.GetPropertyType(shader, i)))
                    {
                        props.Add(ShaderUtil.GetPropertyName(shader, i));
                    }
                }
                else
                {
                    props.Add(ShaderUtil.GetPropertyName(shader, i));
                }                
            }

            if (!props.Contains(nowSelection))
            {
                nowSelection = props[0];
                data.texTemplate = data.currentRenderer.sharedMaterial.GetTexture(nowSelection);
            }
            

            int currentIndex = props.IndexOf(nowSelection);
            int lastIndex = EditorGUILayout.Popup(title, currentIndex, props.ToArray());

            if (nowSelection != props[lastIndex])
            {
                data.currentRenderer.sharedMaterial.SetTexture(nowSelection, data.texTemplate);
                nowSelection = props[lastIndex];
                data.texTemplate = data.currentRenderer.sharedMaterial.GetTexture(nowSelection);
            }
            return nowSelection;
        }

        private void SaveRenderTextureToPNG(string textureName, RenderTexture renderTexture, Action<TextureImporter> importAction = null)
        {
            string path = EditorUtility.SaveFilePanel("Save to png", Application.dataPath, textureName + "_painted.png", "png");
            if (path.Length != 0)
            {
                var newTex = new Texture2D(renderTexture.width, renderTexture.height);
                RenderTexture.active = renderTexture;
                newTex.ReadPixels(new Rect(0, 0, renderTexture.width, renderTexture.height), 0, 0);
                newTex.Apply();

                byte[] pngData = newTex.EncodeToPNG();
                if (pngData != null)
                {
                    File.WriteAllBytes(path, pngData);
                    AssetDatabase.Refresh();
                    var importer = AssetImporter.GetAtPath(path) as TextureImporter;
                    if (importAction != null)
                        importAction(importer);
                }

                Debug.Log(path);
            }
        }
    }
#endif
#endregion Editor
}
