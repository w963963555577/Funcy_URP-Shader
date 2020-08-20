using System.Collections.Generic;
using Unity.Collections.LowLevel.Unsafe;
using UnityEngine;

namespace bat.util
{
    public class MeshUtil
    {
        public static Mesh SimpleMesh(Mesh _mesh)
        {
            InternalMesh _clone = new InternalMesh();
            _clone.InitFrom(_mesh);
            _clone.Simplify();
            return _clone.MakeMesh();
        }
        public static Vector3 GetSubMeshCenter(Mesh _mesh, int _subMeshID)
        {
	        List<int> _indeices=new List<int>();
	        _mesh.GetIndices(_indeices,_subMeshID);
	        List<Vector3> _vertices=new List<Vector3>();
	        _mesh.GetVertices(_vertices);

	        Vector3 _max=new Vector3(-float.MaxValue,-float.MaxValue,-float.MaxValue);
	        Vector3 _min=new Vector3(float.MaxValue,float.MaxValue,float.MaxValue);
	        for (int i = 0; i < _indeices.Count; i++)
	        {
		        var _point = _vertices[_indeices[i]];
		        if (_point.x > _max.x)
		        {
			        _max.x = _point.x;
		        }
		        if (_point.x < _min.x)
		        {
			        _min.x = _point.x;
		        }
		        if (_point.y > _max.y)
		        {
			        _max.y = _point.y;
		        }
		        if (_point.y < _min.y)
		        {
			        _min.y = _point.y;
		        }
		        if (_point.z > _max.z)
		        {
			        _max.z = _point.z;
		        }
		        if (_point.z < _min.z)
		        {
			        _min.z = _point.z;
		        }
	        }
	        return (_max+_min)*0.5f;
			
        }
    }

    class InternalMesh
    {
        List<List<int>> subMeshes=new List<List<int>>();
        private Vector3[] vertices;
        private Vector3[] normals;
        private Vector2[] uv;
        private Vector2[] uv2;
        private Vector2[] uv3;
        private Vector2[] uv4;
        public void InitFrom(Mesh _mesh)
        {
            int _subMesh = _mesh.subMeshCount;
            subMeshes.Clear();
            for (int i = 0; i < _subMesh; i++)
            {
                subMeshes.Add(new List<int>());
                _mesh.GetIndices(subMeshes[i], i);
            }

            vertices = _mesh.vertices;
            normals = _mesh.normals;
            if (_mesh.uv != null)
            {
                uv = new Vector2[_mesh.uv.Length];
                _mesh.uv.CopyTo(uv, 0);
            }
            if (_mesh.uv2 != null)
            {
                uv2 = new Vector2[_mesh.uv2.Length];
                _mesh.uv2.CopyTo(uv2, 0);
            }
            if (_mesh.uv3 != null)
            {
                uv3 = new Vector2[_mesh.uv3.Length];
                _mesh.uv3.CopyTo(uv3, 0);
            }
            if (_mesh.uv4 != null)
            {
                uv4 = new Vector2[_mesh.uv4.Length];
                _mesh.uv4.CopyTo(uv4, 0);
            }
        }

        public void  Simplify()
        {
            Dictionary<VertexNormalUV, int> _uniqueTable=new Dictionary<VertexNormalUV, int>();
            Dictionary<int, int> _vertexReplace = new Dictionary<int, int>();
            var uvExist = uv != null && uv.Length == vertices.Length;
            var uv2Exist = uv2 != null && uv2.Length == vertices.Length;
            var uv3Exist = uv3 != null && uv3.Length == vertices.Length;
            var uv4Exist = uv4 != null && uv4.Length == vertices.Length;
            List<VertexNormalUV> _newPoints=new List<VertexNormalUV>();
            for (int i = 0; i < vertices.Length; i++)
            {
                VertexNormalUV _unique = new VertexNormalUV();
                _unique.vertex = vertices[i];
                _unique.normal = normals[i];
                if (uvExist)
                {
                    _unique.uv = uv[i];
                }
                if (uv2Exist)
                {
                    _unique.uv2 = uv2[i];
                }
                if (uv3Exist)
                {
                    _unique.uv3 = uv3[i];
                }
                if (uv4Exist)
                {
                    _unique.uv4 = uv4[i];
                }
                if (_uniqueTable.ContainsKey(_unique))
                {
                    _vertexReplace[i] = _uniqueTable[_unique];
                }
                else
                {
                    int _transferTo= _newPoints.Count;
                    _vertexReplace[i] = _transferTo;
                    _uniqueTable[_unique] = _transferTo;
                    _newPoints.Add(_unique);

                }
            }
            //重新生成SubMesh
            int _subMesh = subMeshes.Count;
            Dictionary<Triangle, Triangle> _triangleReplace = new Dictionary<Triangle, Triangle>();
            for (int i = 0; i < _subMesh; i++)
            {
                var _subMeshI = subMeshes[i];
                int _indicesCount = _subMeshI.Count;
                List<Triangle> _triangles=new List<Triangle>();
                for (int j = 0; j < _indicesCount; j+=3)
                {
                    int _xi = _vertexReplace[_subMeshI[j]];
                    int _yi = _vertexReplace[_subMeshI[j + 1]];
                    int _zi = _vertexReplace[_subMeshI[j + 2]];
                    Triangle _codeJ = new Triangle(_xi, _yi, _zi);
                    if (!_triangleReplace.ContainsKey(_codeJ))
                    {
                        _triangles.Add(_codeJ);
                        _triangleReplace[_codeJ] = _codeJ;
                    }
                }
                var _subMeshNew=new List<int>(_triangles.Count*3);
                int _tCount = _triangles.Count;
                for (int j = 0; j < _tCount; j++)
                {
                    _subMeshNew.Add(_triangles[j].x);
                    _subMeshNew.Add(_triangles[j].y);
                    _subMeshNew.Add(_triangles[j].z);
                }
                subMeshes[i] = _subMeshNew;
            }
            //重新生成Vertext、Normal、UV
            vertices=new Vector3[_newPoints.Count];
            for (int i = 0; i < vertices.Length; i++)
            {
                vertices[i] = _newPoints[i].vertex;
            }

            if (normals != null && normals.Length>0)
            {
                normals = new Vector3[_newPoints.Count];
                for (int i = 0; i < vertices.Length; i++)
                {
                    normals[i] = _newPoints[i].normal;
                }
            }

            if (uv != null && uv.Length > 0)
            {
                uv = new Vector2[_newPoints.Count];
                for (int i = 0; i < vertices.Length; i++)
                {
                    uv[i] = _newPoints[i].uv;
                }
            }

            if (uv2 != null && uv2.Length > 0)
            {
                uv2 = new Vector2[_newPoints.Count];
                for (int i = 0; i < vertices.Length; i++)
                {
                    uv2[i] = _newPoints[i].uv2;
                }
            }
            if (uv3 != null && uv3.Length > 0)
            {
                uv3 = new Vector2[_newPoints.Count];
                for (int i = 0; i < vertices.Length; i++)
                {
                    uv3[i] = _newPoints[i].uv3;
                }
            }
            if (uv4 != null && uv4.Length > 0)
            {
                uv4 = new Vector2[_newPoints.Count];
                for (int i = 0; i < vertices.Length; i++)
                {
                    uv4[i] = _newPoints[i].uv4;
                }
            }
        }
        public Mesh MakeMesh()
        {
            Mesh _newMesh=new Mesh();
            _newMesh.vertices = vertices;
            _newMesh.normals = normals;
            _newMesh.uv = uv;
            _newMesh.uv2 = uv2;
            _newMesh.uv3 = uv3;
            _newMesh.uv4 = uv4;
            for (int i = 0; i < subMeshes.Count; i++)
            {
                var _subI = subMeshes[i];
                _newMesh.SetTriangles(_subI, i);
            }
            _newMesh.RecalculateBounds();
            return _newMesh;
        }
    }

    struct Triangle
    {
        public int x, y, z;
        public Triangle(int _x,int _y,int _z)
        {
            x = _x;
            y = _y;
            z = _z;
        }

    }
   
    public struct VertexNormalUV
    {
        public Vector3 vertex;
        public Vector3 normal;
        public Vector2 uv;
        public Vector2 uv2;
        public Vector2 uv3;
        public Vector2 uv4;
    }


}