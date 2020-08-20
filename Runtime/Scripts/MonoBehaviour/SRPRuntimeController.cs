using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class SRPRuntimeController : MonoBehaviour
{
    [HideInInspector] [SerializeField] bool srbBatcher = true;
    public bool srpBatcherEnabled { get { return srbBatcher;}set {
            QualitySettings.SetQualityLevel(value ? 1 : 0);
            srbBatcher = value; } }

}
