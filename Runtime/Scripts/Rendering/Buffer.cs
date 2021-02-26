using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;

namespace Funcy.Graphics
{
    #region Buffer    
    [System.Serializable]
    public class Buffer
    {
        static List<Buffer> buffers = new List<Buffer>();

        public ComputeBuffer target { get { return buffer; } }
        ComputeBuffer buffer;

        public int Count { get { return count; } }
        public int Stride { get { return stride; } }

        [SerializeField] int count, stride;
        public Buffer(int count, System.Type type, ComputeBufferType bufferType = ComputeBufferType.Default)
        {
            this.count = count;
            if (type == typeof(uint)) stride = sizeof(uint);
            if (type == typeof(int)) stride = sizeof(int);
            if (type == typeof(float)) stride = sizeof(float);
            if (type == typeof(Vector2)) stride = 2 * sizeof(float);
            if (type == typeof(Vector3)) stride = 3 * sizeof(float);
            if (type == typeof(Vector4)) stride = 4 * sizeof(float);
            if (type == typeof(Matrix4x4)) stride = 16 * sizeof(float);
            if (type == typeof(Bounds)) stride = 6 * sizeof(float);

            if (buffer == null) buffer = new ComputeBuffer(this.count, stride, bufferType);

            buffers.Add(this);
        }

        public Buffer(int count, int stride, ComputeBufferType bufferType = ComputeBufferType.Default)
        {
            this.count = count;
            if (buffer == null) buffer = new ComputeBuffer(this.count, stride, bufferType);
            buffers.Add(this);
        }

        public void Dispose()
        {
            if (buffer != null)
            {
                buffer.Dispose();
                buffer = null;
            }
        }
        public static void DisposeAll()
        {
            foreach (var b in buffers) b.Dispose();
        }

        public void GetData(System.Array data) { buffer.GetData(data); }

        public void GetData(System.Array data, int managedBufferStartIndex, int computeBufferStartIndex, int count)
        {
            buffer.SetData(data, managedBufferStartIndex, computeBufferStartIndex, count);
        }

        public void SetData(System.Array data) { buffer.SetData(data); }

        public void SetData<T>(List<T> data) where T : struct { buffer.SetData(data); }

        public void SetData<T>(NativeArray<T> data) where T : struct { buffer.SetData(data); }

        public void SetData<T>(List<T> data, int managedBufferStartIndex, int computeBufferStartIndex, int count) where T : struct
        {
            buffer.SetData(data, managedBufferStartIndex, computeBufferStartIndex, count);
        }

        public void SetData<T>(NativeArray<T> data, int nativeBufferStartIndex, int computeBufferStartIndex, int count) where T : struct
        {
            buffer.SetData(data, nativeBufferStartIndex, computeBufferStartIndex, count);
        }

        public void SetData(System.Array data, int managedBufferStartIndex, int computeBufferStartIndex, int count)
        {
            buffer.SetData(data, managedBufferStartIndex, computeBufferStartIndex, count);
        }

        public void SetCounterValue(uint counterValue)
        {
            buffer.SetCounterValue(counterValue);
        }
    }
    #endregion Buffer
}