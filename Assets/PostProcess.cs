using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcess : MonoBehaviour {
    public Material shoreMaterial;
    public Material atmosphereMaterial;

    public Vector3 planetOrigin = Vector3.zero;
    public float planetRadius = 100.0f;
    public Camera waterCamera;

    [Header("Atmosphere")]
    public float atmosphereRadius = 110.0f;
    public Vector3 wavelengths = new Vector3(700, 530, 460);
    public float falloff = 500.0f;
    public int scatteringPoints = 10;
    public int depthPoints = 10;
    public float intensity = 1.0f;
    public float scatterStrength = 1.0f;
    public float ditherScale = 1.0f;
    public float ditherStrength = 1.0f;

    [Header("Shore")]
    public float threshold = 1.0f;
    public float specular = 1.0f;
    public float depthScalar = 1.0f;
    public float shoreScalar = 1.0f;
    public Color oceanColorShallow = Color.blue;
    public Color oceanColorDeep = Color.blue;

    [ImageEffectOpaque]
    void OnRenderImage(RenderTexture source, RenderTexture dest) {
        var temp = RenderTexture.GetTemporary(dest.descriptor);
        renderShore(source, temp);
        renderAtmosphere(temp, dest);
        RenderTexture.ReleaseTemporary(temp);
    }

    void setGlobals(Material material) {
        material.SetVector("planetOrigin", planetOrigin);
        material.SetFloat("planetRadius", planetRadius);
    }

    void renderAtmosphere(RenderTexture source, RenderTexture dest) {
        var material = atmosphereMaterial;
        if (material != null) {
            float scatterX = Mathf.Pow(400 / wavelengths.x, 4);
            float scatterY = Mathf.Pow(400 / wavelengths.y, 4);
            float scatterZ = Mathf.Pow(400 / wavelengths.z, 4);

            setGlobals(material);

            material.SetInteger("scatteringPoints", scatteringPoints);
            material.SetInteger("depthPoints", depthPoints);
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

    void renderShore(RenderTexture source, RenderTexture dest) {
        var material = shoreMaterial;
        if (material != null) {
            var temp = RenderTexture.GetTemporary(dest.descriptor);
            waterCamera.targetTexture = temp;
            waterCamera.Render();

            setGlobals(material);
            material.SetFloat("threshold", threshold);
            material.SetFloat("specular", specular);
            material.SetFloat("depthScalar", depthScalar);
            material.SetFloat("depthScalar", depthScalar);
            material.SetFloat("shoreScalar", shoreScalar);
            material.SetVector("oceanColorShallow", oceanColorShallow);
            material.SetVector("oceanColorDeep", oceanColorDeep);
            material.SetTexture("specularTex", temp);

            Graphics.Blit(source, dest, material);

            RenderTexture.ReleaseTemporary(temp);
        } else {
            Graphics.Blit(source, dest);
        }
    }
}
