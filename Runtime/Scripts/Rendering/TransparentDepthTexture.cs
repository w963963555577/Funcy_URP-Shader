using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
#if UNITY_EDITOR
using UnityEditor;
#endif
[ExecuteAlways]
[RequireComponent(typeof(Camera))]
public class TransparentDepthTexture : MonoBehaviour
{
    public RenderTexture m_target1 = null;
    public RenderTexture m_target2 = null;

    private RenderBuffer[] m_buffers = null;
    Camera cam;
    Camera origCamera;
    RenderTargetIdentifier[] MRT2 = new RenderTargetIdentifier[2];
    private void OnEnable()
    {
        cam = GetComponent<Camera>();
        if (m_target1 != null)
        {
            m_target1.Release();
            m_target1 = null;
        }

        if (m_target2 != null)
        {
            m_target2.Release();
            m_target2 = null;
        }
        // Screen.width and Screen.height can change from outside this function between the creation of the 2 RenderTexture.
        // Memorize them to be sure both buffers are the same size.
        int witdh = cam.pixelWidth;
        int height = cam.pixelHeight;

        //m_target1 = new RenderTexture(witdh, height, 32, UnityEngine.Experimental.Rendering.DefaultFormat.HDR);
        //m_target2 = new RenderTexture(witdh, height, 32, UnityEngine.Experimental.Rendering.DefaultFormat.HDR);


        m_buffers = new RenderBuffer[2] { m_target1.colorBuffer, m_target2.colorBuffer };

        //RenderPipelineManager.beginCameraRendering += OnBeginCameraRendering;
    }

    void OnBeginCameraRendering(ScriptableRenderContext ctx, Camera c)
    {        
        c.SetTargetBuffers(m_buffers, m_target2.depthBuffer);
    }
    private void OnDisable()
    {
        //RenderPipelineManager.beginCameraRendering -= OnBeginCameraRendering;
        DestroyImmediate(m_target1);
        DestroyImmediate(m_target2);
    }    
}
#if UNITY_EDITOR
[CustomEditor(typeof(TransparentDepthTexture))]
public class TransparentDepthTexture_Editor : Editor
{
    private void OnEnable()
    {
        
    }
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
    }
}
#endif