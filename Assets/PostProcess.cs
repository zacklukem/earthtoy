using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcess : MonoBehaviour {
    public Material material;
    public Vector3 planetOrigin = Vector3.zero;
    public float planetRadius = 100.0f;
    public float atmosphereRadius = 110.0f;
    public Vector3 wavelengths = new Vector3(700, 530, 460);
    public float falloff = 500.0f;
    public int scatteringPoints = 10;
    public int depthPoints = 10;
    public float intensity = 1.0f;
    public float scatterStrength = 1.0f;
    public float ditherScale = 1.0f;
    public float ditherStrength = 1.0f;

    [ImageEffectOpaque]
    void OnRenderImage(RenderTexture source, RenderTexture dest) {
        if (material != null) {
            float scatterX = Mathf.Pow(400 / wavelengths.x, 4);
            float scatterY = Mathf.Pow(400 / wavelengths.y, 4);
            float scatterZ = Mathf.Pow(400 / wavelengths.z, 4);

            material.SetVector("planetOrigin", planetOrigin);
            material.SetInteger("scatteringPoints", scatteringPoints);
            material.SetInteger("depthPoints", depthPoints);
            material.SetFloat("planetRadius", planetRadius);
            material.SetFloat("falloff", falloff);
            material.SetFloat("atmosphereRadius", atmosphereRadius);
            material.SetFloat("intensity", intensity);
            material.SetFloat("ditherScale", ditherScale);
            material.SetFloat("ditherStrength", ditherStrength);
            material.SetVector(
                "scatterColor", new Vector3(scatterX, scatterY, scatterZ) * scatterStrength);
            Graphics.Blit(source, dest, material);
        } else {
            Graphics.Blit(source, dest);
        }
    }
}
