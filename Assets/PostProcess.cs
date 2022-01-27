using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcess : MonoBehaviour {
    public Material material;
    public Vector3 planetOrigin = Vector3.zero;
    public float planetRadius = 100.0f;
    public float atmosphereRadius = 110.0f;
    public float utilNum = 500.0f;
    public float falloff = 500.0f;
    public int scatteringPoints = 10;
    public int depthPoints = 10;

    [ImageEffectOpaque]
    void OnRenderImage(RenderTexture source, RenderTexture dest) {
        if (material != null) {
            material.SetVector("planetOrigin", planetOrigin);
            material.SetInteger("scatteringPoints", scatteringPoints);
            material.SetInteger("depthPoints", depthPoints);
            material.SetFloat("planetRadius", planetRadius);
            material.SetFloat("falloff", falloff);
            material.SetFloat("atmosphereRadius", atmosphereRadius);
            material.SetFloat("utilNum", utilNum);
            Graphics.Blit(source, dest, material);
        } else {
            Graphics.Blit(source, dest);
        }
    }
}
