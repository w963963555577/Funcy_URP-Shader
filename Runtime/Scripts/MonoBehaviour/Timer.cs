using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace UnityEngine.Funcy.LWRP.Runtime
{
    #region Timer
    public class Timer
    {
        public static float NowTime
        {
            get
            {
                float time = 0.0f;
                if (Application.isPlaying)
                {
                    time = Time.realtimeSinceStartup;
                }
                else
                {
#if UNITY_EDITOR
                    time = (float)UnityEditor.EditorApplication.timeSinceStartup;
#endif
                }
                return time;
            }
        }
    }
    #endregion
}