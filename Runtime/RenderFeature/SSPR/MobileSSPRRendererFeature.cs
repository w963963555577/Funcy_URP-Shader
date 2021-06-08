//see README here: https://github.com/ColinLeung-NiloCat/UnityURP-MobileScreenSpacePlanarReflection

using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.SceneManagement;
#endif
public class MobileSSPRRendererFeature : ScriptableRendererFeature
{
    public static MobileSSPRRendererFeature instance; //for example scene to call, user should add 1 and not more than 1 MobileSSPRRendererFeature anyway so it is safe to use static ref
     

    [System.Serializable]
    public class PassSettings
    {
        [Header("Settings")]
        public bool ShouldRenderSSPR = true;
        public float horizontalReflectionPlaneHeightWS = 0.01f; //default higher than ground a bit, to avoid ZFighting if user placed a ground plane at y=0

        [System.NonSerialized] public MobileSSPRHeightFixerData selectedHeightFixerData;
        public List<MobileSSPRHeightFixerData> heightFixerData = new List<MobileSSPRHeightFixerData>();
        [Range(0.01f, 1f)]
        public float fadeOutScreenBorderWidthVerticle = 0.25f;
        [Range(0.01f, 1f)]
        public float fadeOutScreenBorderWidthHorizontal = 0.35f;
        [Range(0,8f)]
        public float screenLRStretchIntensity = 4;
        [Range(-1f,1f)]
        public float screenLRStretchThreshold = 0.7f;
        [ColorUsage(true,true)]
        public Color tintColor = Color.white;

        //////////////////////////////////////////////////////////////////////////////////
        [Header("Performance Settings")]
        [Range(128, 1024)]
        [Tooltip("set to 512 or below for better performance, if visual quality lost is acceptable")]
        public int RT_height = 512;
        [Tooltip("can set to false for better performance, if visual quality lost is acceptable")]
        public bool UseHDR = true;
        [Tooltip("can set to false for better performance, if visual quality lost is acceptable")]
        public bool ApplyFillHoleFix = true;
        [Tooltip("can set to false for better performance, if flickering is acceptable")]
        public bool ShouldRemoveFlickerFinalControl = true;

        //////////////////////////////////////////////////////////////////////////////////
        [Header("Danger Zone")]
        [Tooltip("You should always turn this on, unless you want to debug")]
        public bool EnablePerPlatformAutoSafeGuard = true;

        public ComputeShader SSPR_computeShader;
    }
    public PassSettings Settings = new PassSettings();

    public class CustomRenderPass : ScriptableRenderPass
    {
        static readonly int _SSPR_ColorRT_pid = Shader.PropertyToID("_MobileSSPR_ColorRT");
        static readonly int _SSPR_PackedDataRT_pid = Shader.PropertyToID("_MobileSSPR_PackedDataRT");
        static readonly int _SSPR_PosWSyRT_pid = Shader.PropertyToID("_MobileSSPR_PosWSyRT");
        RenderTargetIdentifier _SSPR_ColorRT_rti = new RenderTargetIdentifier(_SSPR_ColorRT_pid);
        RenderTargetIdentifier _SSPR_PackedDataRT_rti = new RenderTargetIdentifier(_SSPR_PackedDataRT_pid);
        RenderTargetIdentifier _SSPR_PosWSyRT_rti = new RenderTargetIdentifier(_SSPR_PosWSyRT_pid);
        

        const int SHADER_NUMTHREAD_X = 8; //must match compute shader's [numthread(x)]
        const int SHADER_NUMTHREAD_Y = 8; //must match compute shader's [numthread(y)]

        public bool shouldUseSinglePassUnsafeAllowFlickeringDirectResolve = false;

        PassSettings settings;
        ComputeShader cs;
        public CustomRenderPass(PassSettings settings)
        {
            this.settings = settings;
            cs = settings.SSPR_computeShader;
        }

        int GetRTHeight()
        {
            return Mathf.CeilToInt(settings.RT_height / (float)SHADER_NUMTHREAD_Y) * SHADER_NUMTHREAD_Y;
        }
        int GetRTWidth()
        {
            float aspect = (float)Screen.width / Screen.height;
            return Mathf.CeilToInt(GetRTHeight() * aspect / (float)SHADER_NUMTHREAD_X) * SHADER_NUMTHREAD_X;
        }


        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in an performance manner.
        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {    
            RenderTextureDescriptor rtd = new RenderTextureDescriptor(GetRTWidth(), GetRTHeight(),RenderTextureFormat.Default, 0, 0);

            rtd.sRGB = false; //don't need gamma correction when sampling these RTs, it is linear data already because it will be filled by screen's linear data
            rtd.enableRandomWrite = true; //using RWTexture2D in compute shader need to turn on this

            //color RT
            bool shouldUseHDRColorRT = settings.UseHDR;
            if (cameraTextureDescriptor.colorFormat == RenderTextureFormat.ARGB32)
                shouldUseHDRColorRT = false;// if there are no HDR info to reflect anyway, no need a HDR colorRT
            rtd.colorFormat = shouldUseHDRColorRT ? RenderTextureFormat.ARGBHalf : RenderTextureFormat.ARGB32; //we need alpha! (usually LDR is enough, ignore HDR is acceptable for reflection)
            cmd.GetTemporaryRT(_SSPR_ColorRT_pid, rtd);

            //PackedData RT
            if (shouldUseSinglePassUnsafeAllowFlickeringDirectResolve)
            {
                //use unsafe method if mobile
                //posWSy RT (will use this RT for posWSy compare test, just like the concept of regular depth buffer)
                rtd.colorFormat = RenderTextureFormat.RFloat;
                cmd.GetTemporaryRT(_SSPR_PosWSyRT_pid, rtd);
            }
            else
            {
                //use 100% correct method if console/PC
                rtd.colorFormat = RenderTextureFormat.RInt;
                cmd.GetTemporaryRT(_SSPR_PackedDataRT_pid, rtd);
            }
        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cb = CommandBufferPool.Get("SSPR");

            int dispatchThreadGroupXCount = GetRTWidth() / SHADER_NUMTHREAD_X; //divide by shader's numthreads.x
            int dispatchThreadGroupYCount = GetRTHeight() / SHADER_NUMTHREAD_Y; //divide by shader's numthreads.y
            int dispatchThreadGroupZCount = 1; //divide by shader's numthreads.z

            if (settings.ShouldRenderSSPR)
            {
                cb.SetComputeVectorParam(cs, Shader.PropertyToID("_RTSize"), new Vector2(GetRTWidth(), GetRTHeight()));
                cb.SetComputeFloatParam(cs, Shader.PropertyToID("_HorizontalPlaneHeightWS"), settings.horizontalReflectionPlaneHeightWS);

                var heightFixerData = settings.selectedHeightFixerData;
                cb.SetComputeVectorParam(cs, Shader.PropertyToID("_WorldSize_Offest_HeightIntensity"), heightFixerData.worldSize_Offest_HeightIntensity);

                cb.SetComputeFloatParam(cs, Shader.PropertyToID("_FadeOutScreenBorderWidthVerticle"), settings.fadeOutScreenBorderWidthVerticle);
                cb.SetComputeFloatParam(cs, Shader.PropertyToID("_FadeOutScreenBorderWidthHorizontal"), settings.fadeOutScreenBorderWidthHorizontal);
                cb.SetComputeVectorParam(cs, Shader.PropertyToID("_CameraDirection"), renderingData.cameraData.camera.transform.forward);
                cb.SetComputeFloatParam(cs, Shader.PropertyToID("_ScreenLRStretchIntensity"), settings.screenLRStretchIntensity);
                cb.SetComputeFloatParam(cs, Shader.PropertyToID("_ScreenLRStretchThreshold"), settings.screenLRStretchThreshold);
                cb.SetComputeVectorParam(cs, Shader.PropertyToID("_FinalTintColor"), settings.tintColor);

                //we found that on metal, UNITY_MATRIX_VP is not correct, so we will pass our own VP matrix to compute shader
                Camera camera = renderingData.cameraData.camera;
                Matrix4x4 VP = GL.GetGPUProjectionMatrix(camera.projectionMatrix, true) * camera.worldToCameraMatrix;
                cb.SetComputeMatrixParam(cs, "_VPMatrix", VP);

                if (shouldUseSinglePassUnsafeAllowFlickeringDirectResolve)
                {
                    ////////////////////////////////////////////////
                    //Mobile Path (Android GLES / Metal)
                    ////////////////////////////////////////////////

                    //kernel MobilePathsinglePassColorRTDirectResolve
                    int kernel_MobilePathSinglePassColorRTDirectResolve = cs.FindKernel("MobilePathSinglePassColorRTDirectResolve");
                    cb.SetComputeTextureParam(cs, kernel_MobilePathSinglePassColorRTDirectResolve, "ColorRT", _SSPR_ColorRT_rti);
                    cb.SetComputeTextureParam(cs, kernel_MobilePathSinglePassColorRTDirectResolve, "PosWSyRT", _SSPR_PosWSyRT_rti);
                    cb.SetComputeTextureParam(cs, kernel_MobilePathSinglePassColorRTDirectResolve, "_CameraOpaqueTexture", new RenderTargetIdentifier("_CameraOpaqueTexture"));
                    cb.SetComputeTextureParam(cs, kernel_MobilePathSinglePassColorRTDirectResolve, "_CameraDepthTexture", new RenderTargetIdentifier("_CameraDepthTexture"));
                    cs.SetTexture(kernel_MobilePathSinglePassColorRTDirectResolve, "_HorizontalHeightFixerMap", heightFixerData.horizontalHeightFixerMap);
                    cb.DispatchCompute(cs, kernel_MobilePathSinglePassColorRTDirectResolve, dispatchThreadGroupXCount, dispatchThreadGroupYCount, dispatchThreadGroupZCount);

                }
                else
                {
                    ////////////////////////////////////////////////
                    //Non-Mobile Path (PC/console)
                    ////////////////////////////////////////////////

                    //kernel NonMobilePathClear
                    int kernel_NonMobilePathClear = cs.FindKernel("NonMobilePathClear");
                    cb.SetComputeTextureParam(cs, kernel_NonMobilePathClear, "HashRT", _SSPR_PackedDataRT_rti);
                    cb.SetComputeTextureParam(cs, kernel_NonMobilePathClear, "ColorRT", _SSPR_ColorRT_rti);
                    cb.DispatchCompute(cs, kernel_NonMobilePathClear, dispatchThreadGroupXCount, dispatchThreadGroupYCount, dispatchThreadGroupZCount);

                    //kernel NonMobilePathRenderHashRT
                    int kernel_NonMobilePathRenderHashRT = cs.FindKernel("NonMobilePathRenderHashRT");
                    cb.SetComputeTextureParam(cs, kernel_NonMobilePathRenderHashRT, "HashRT", _SSPR_PackedDataRT_rti);
                    cb.SetComputeTextureParam(cs, kernel_NonMobilePathRenderHashRT, "_CameraDepthTexture", new RenderTargetIdentifier("_CameraDepthTexture"));
                    cs.SetTexture(kernel_NonMobilePathRenderHashRT, "_HorizontalHeightFixerMap", heightFixerData.horizontalHeightFixerMap);
                    cb.DispatchCompute(cs, kernel_NonMobilePathRenderHashRT, dispatchThreadGroupXCount, dispatchThreadGroupYCount, dispatchThreadGroupZCount);

                    //resolve to ColorRT
                    int kernel_NonMobilePathResolveColorRT = cs.FindKernel("NonMobilePathResolveColorRT");
                    cb.SetComputeTextureParam(cs, kernel_NonMobilePathResolveColorRT, "_CameraOpaqueTexture", new RenderTargetIdentifier("_CameraOpaqueTexture"));
                    cb.SetComputeTextureParam(cs, kernel_NonMobilePathResolveColorRT, "ColorRT", _SSPR_ColorRT_rti);
                    cb.SetComputeTextureParam(cs, kernel_NonMobilePathResolveColorRT, "HashRT", _SSPR_PackedDataRT_rti);
                    cs.SetTexture(kernel_NonMobilePathResolveColorRT, "_HorizontalHeightFixerMap", heightFixerData.horizontalHeightFixerMap);
                    cb.DispatchCompute(cs, kernel_NonMobilePathResolveColorRT, dispatchThreadGroupXCount, dispatchThreadGroupYCount, dispatchThreadGroupZCount);
                }

                //optional shared pass to improve result only: fill RT hole
                if(settings.ApplyFillHoleFix)
                {
                    int kernel_FillHoles = cs.FindKernel("FillHoles");
                    cb.SetComputeTextureParam(cs, kernel_FillHoles, "ColorRT", _SSPR_ColorRT_rti);                    
                    cb.DispatchCompute(cs, kernel_FillHoles, Mathf.CeilToInt(dispatchThreadGroupXCount / 2f), Mathf.CeilToInt(dispatchThreadGroupYCount / 2f), dispatchThreadGroupZCount);
                }

                //send out to global, for user's shader to sample reflection result RT (_MobileSSPR_ColorRT)
                //where _MobileSSPR_ColorRT's rgb is reflection color, a is reflection usage 0~1 for user's shader to lerp with fallback reflection probe's rgb
                cb.SetGlobalTexture(_SSPR_ColorRT_pid, _SSPR_ColorRT_rti);
                cb.EnableShaderKeyword("_MobileSSPR");
            }
            else
            {
                //allow user to skip SSPR related code if disabled
                cb.DisableShaderKeyword("_MobileSSPR");
            }

            context.ExecuteCommandBuffer(cb);
            CommandBufferPool.Release(cb);

        }

        /// Cleanup any allocated resources that were created during the execution of this render pass.
        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(_SSPR_ColorRT_pid);

            if(shouldUseSinglePassUnsafeAllowFlickeringDirectResolve)
                cmd.ReleaseTemporaryRT(_SSPR_PosWSyRT_pid);
            else
                cmd.ReleaseTemporaryRT(_SSPR_PackedDataRT_pid);
        }
    }

    CustomRenderPass m_ScriptablePass;

    void IndexHeightFixerData(Scene scene, LoadSceneMode mode)
    {
        var currentScene = SceneManager.GetActiveScene();
        Settings.selectedHeightFixerData = Settings.heightFixerData.Find(x => x.name == currentScene.name);

        if (Settings.selectedHeightFixerData == null)
        {
            Settings.selectedHeightFixerData = Settings.heightFixerData.Find(x => x.name == "Default");
        }

#if UNITY_EDITOR

        UnityEditor.EditorUtility.SetDirty(this);
#endif
    }

    /// <summary>
    /// If user enabled PerPlatformAutoSafeGuard, this function will return true if we should use mobile path
    /// </summary>
    bool ShouldUseSinglePassUnsafeAllowFlickeringDirectResolve()
    {
        if (Settings.EnablePerPlatformAutoSafeGuard)
        {
            //if RInt RT is not supported, use mobile path
            if (!SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.RInt))
                return true;

            //tested Metal(even on a Mac) can't use InterlockedMin().
            //so if metal, use mobile path
            if (SystemInfo.graphicsDeviceType == GraphicsDeviceType.Metal)
                return true;
#if UNITY_EDITOR
            //PC(DirectX) can use RenderTextureFormat.RInt + InterlockedMin() without any problem, use Non-Mobile path.
            //Non-Mobile path will NOT produce any flickering
            if (SystemInfo.graphicsDeviceType == GraphicsDeviceType.Direct3D11 || SystemInfo.graphicsDeviceType == GraphicsDeviceType.Direct3D12)
                return false;
#elif UNITY_ANDROID
                //- samsung galaxy A70(Adreno612) will fail if use RenderTextureFormat.RInt + InterlockedMin() in compute shader
                //- but Lenovo S5(Adreno506) is correct, WTF???
                //because behavior is different between android devices, we assume all android are not safe to use RenderTextureFormat.RInt + InterlockedMin() in compute shader
                //so android always go mobile path
                return true;
#endif
        }

        //let user decide if we still don't know the correct answer
        return !Settings.ShouldRemoveFlickerFinalControl;
    }

    public override void Create()
    {
        instance = this;

#if UNITY_EDITOR

        if (Settings.heightFixerData == null || Settings.heightFixerData.Count < 1)
        {
            Settings.heightFixerData = new List<MobileSSPRHeightFixerData>();
            Settings.heightFixerData.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<MobileSSPRHeightFixerData>("Packages/com.zd.lwrp.funcy/Runtime/_URPAsset/SSRHeightFixerDatas/Default.asset"));
            UnityEditor.EditorUtility.SetDirty(this);
        }

        EditorSceneManager.SceneOpenedCallback editorAction = (s, m) => { IndexHeightFixerData(s, LoadSceneMode.Single); };
#endif
        if (isActive)
        {
            IndexHeightFixerData(new Scene(), LoadSceneMode.Single);

            if (Application.isPlaying)
            {
                SceneManager.sceneLoaded += IndexHeightFixerData;
            }
            else
            {
#if UNITY_EDITOR
                EditorSceneManager.sceneOpened += editorAction;
                EditorApplication.update += Dirty;
#endif
            }
        }
        else
        {
            if (Application.isPlaying)
            {
                SceneManager.sceneLoaded -= IndexHeightFixerData;
            }
            else
            {
#if UNITY_EDITOR
                EditorSceneManager.sceneOpened -= editorAction;
                EditorApplication.update -= Dirty;
#endif
            }
        }

        if (Settings.selectedHeightFixerData == null)
            Settings.selectedHeightFixerData = Settings.heightFixerData[0];

        if (!Settings.SSPR_computeShader)
        {
            Debug.LogWarning("You must assign MobileSSPRComputeShader to SSPR_computeShader slot! Abort SSPR rendering.");
            return;
        }


        m_ScriptablePass = new CustomRenderPass(Settings);

        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;//we must wait _CameraOpaqueTexture & _CameraDepthTexture is usable

        m_ScriptablePass.shouldUseSinglePassUnsafeAllowFlickeringDirectResolve = ShouldUseSinglePassUnsafeAllowFlickeringDirectResolve();
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }

#if UNITY_EDITOR
    void Dirty()
    {
        EditorUtility.SetDirty(this);
    }
#endif
}


