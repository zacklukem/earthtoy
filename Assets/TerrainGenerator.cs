using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TerrainGenerator : MonoBehaviour {

    public bool gen = false;
    public int divisions = 6;
    public int meshDivide = 3;
    public float lowVal = 0.9f;
    public GameObject meshSectionPrefab;
    public Vector2[] stages;

    bool oldGen = false;

    void Start() {
        oldGen = gen;
        updateMesh();
    }

    void Update() {
        if (oldGen != gen) {
            oldGen = gen;
            updateMesh();
        }
    }

    static float PerlinNoise3D(Vector3 v) { return (Noise.Generate(v.x, v.y, v.z) + 1.0f) / 2.0f; }

    float heightAtPoint(Vector3 point) {
        var o = 0.0f;
        foreach (var stage in stages) {
            o += PerlinNoise3D(point * stage.x) * stage.y;
        }
        return o + lowVal;
    }

    void updateMesh() {
        if (divisions % meshDivide != 0 || !meshSectionPrefab)
            return;
        foreach (Transform c in transform)
            Destroy(c.gameObject);
        for (int i = 0; i < meshDivide; i++) {
            for (int j = 0; j < meshDivide; j++) {
                for (int x = 0; x < 6; x++) {
                    var child = Instantiate(meshSectionPrefab, transform);
                    child.GetComponent<MeshFilter>().mesh = genMesh(i, j, x);
                }
            }
        }
    }

    Mesh genMesh(int a, int b, int axis) {
        var mesh = new Mesh();
        var vertices = new List<Vector3>((divisions + 1) * (divisions + 1));
        var indices = new List<int>(divisions * divisions * 2);
        generatePlane(axis, a, b, ref indices, ref vertices);
        for (var i = 0; i < vertices.Count; i++) {
            var vec = vertices[i];
            var v2 = Vector3.Scale(vec, vec);
            vertices[i] = new Vector3(
                vec.x * Mathf.Sqrt(1 - 0.5f * v2.y - 0.5f * v2.z + v2.y * v2.z / 3f),
                vec.y * Mathf.Sqrt(1 - 0.5f * v2.x - 0.5f * v2.z + v2.x * v2.z / 3f),
                vec.z * Mathf.Sqrt(1 - 0.5f * v2.x - 0.5f * v2.y + v2.x * v2.y / 3f));
            vertices[i] *= heightAtPoint(vertices[i]);
        }
        mesh.vertices = vertices.ToArray();
        mesh.triangles = indices.ToArray();
        mesh.RecalculateNormals();
        mesh.Optimize();
        return mesh;
    }

    void generatePlane(int axis, int a, int b, ref List<int> indices, ref List<Vector3> vertices) {
        var divisionDim = 2.0f / (float)divisions;
        var sectionDiv = divisions / meshDivide;
        for (var i = a * sectionDiv; i < (a + 1) * sectionDiv; i++) {
            for (var j = b * sectionDiv; j < (b + 1) * sectionDiv; j++) {
                var a0 = (divisionDim * i) - 1.0f;
                var b0 = (divisionDim * j) - 1.0f;
                var a1 = a0 + divisionDim;
                var b1 = b0 + divisionDim;
                // 00[0]-10[1]
                //  | \    |
                //  |  \   |
                //  |   \  |
                //  |    \ |
                // 01[3]-11[2]
                var idx = vertices.Count;
                vertices.Add(v3Axis(a0, b0, 1, axis));
                vertices.Add(v3Axis(a1, b0, 1, axis));
                vertices.Add(v3Axis(a1, b1, 1, axis));
                vertices.Add(v3Axis(a0, b1, 1, axis));
                indices.Add(idx + 0);
                indices.Add(idx + 1);
                indices.Add(idx + 2);
                indices.Add(idx + 0);
                indices.Add(idx + 2);
                indices.Add(idx + 3);
            }
        }
    }

    Vector3 v3Axis(float x, float y, float v, int axis) {
        if (axis == 0) {
            return new Vector3(v, x, y);
        } else if (axis == 1) {
            return new Vector3(y, v, x);
        } else if (axis == 2) {
            return new Vector3(x, y, v);
        } else if (axis == 3) {
            return new Vector3(-v, y, x);
        } else if (axis == 4) {
            return new Vector3(x, -v, y);
        } else if (axis == 5) {
            return new Vector3(y, x, -v);
        }
        throw new System.Exception("Axis must be in range [0, 5]");
    }
}
