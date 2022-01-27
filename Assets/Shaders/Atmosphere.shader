Shader "Hidden/Atmosphere" {

Properties {
    _MainTex ("Texture", 2D) = "white" {}
}

SubShader {
Cull Off ZWrite Off ZTest Always

Pass {

CGPROGRAM //////////////////////////////////////////////////////////////////////

#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"
#include "./Includes/Math.cginc"

// Input to vertex shader
struct appdata {
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

// Input to fragment shader
struct v2f {
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float3 cameraViewDir : TEXCOORD1;
};

v2f vert(appdata v) {
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;

    float3 proj = mul(unity_CameraInvProjection, float4(v.uv.xy * 2 - 1, 0, -1));
    o.cameraViewDir = mul(unity_CameraToWorld, float4(proj, 0));

    return o;
}

sampler2D _MainTex;
sampler2D _CameraDepthTexture;
// float4 _WorldSpaceLightPos0;

// Set by c#
int scatteringPoints;
int depthPoints;
float planetRadius;
float falloff;
float atmosphereRadius;
float3 planetOrigin;

float utilNum;

float getDensity(float3 pt) {
    float height = distance(pt, planetOrigin) / atmosphereRadius;
    // height /= (atmosphereRadius - planetRadius);
    return exp(-falloff * height) * (1 - height);
}

float opticalDepth(float3 pt, float3 dir, float dist) {
    // Integral of line pt in dir for dist times density

    float stepLength = dist / (float) (depthPoints - 1);
    float3 step = dir * stepLength;
    float3 currentPoint = pt;

    float depth = 0;

    for (int i = 0; i < depthPoints; i++) {
        depth += getDensity(currentPoint) * stepLength;
        currentPoint += step;
    }

    return depth;
}

float4 scattering(float3 origin, float3 direction, float dist, float4 col) {

    // Vector added to origin for each step
    float stepLength = dist / (float) (scatteringPoints - 1);
    float3 step = direction * stepLength;
    float3 currentPoint = origin;
    float light = 0;

    for (int i = 0; i < scatteringPoints; i++) {
        // Dist from point to atmosphere in light direction
        float sunAtmosphereDist = raySphere(planetOrigin, atmosphereRadius, currentPoint, _WorldSpaceLightPos0).y;
        float sunOpticalDepth = opticalDepth(currentPoint, _WorldSpaceLightPos0, sunAtmosphereDist);
        float viewOpticalDepth = opticalDepth(currentPoint, -direction, stepLength * i);
        float transmittance = exp(-(sunOpticalDepth + viewOpticalDepth));

        float density = getDensity(currentPoint);

        light += density * transmittance * stepLength;
        currentPoint += step;
    }

    return col * (1 - light) + light;
}

float4 frag(v2f i) : SV_Target {
    float4 col = tex2D(_MainTex, i.uv);
    float3 cameraViewDir = normalize(i.cameraViewDir);

    float2 atmosphereHit = raySphere(planetOrigin, atmosphereRadius, _WorldSpaceCameraPos, cameraViewDir);

    if (atmosphereHit.x == FLOAT_MAX) return col;

    float sceneDistE = tex2D(_CameraDepthTexture, i.uv);
    float sceneDist = LinearEyeDepth(sceneDistE) * length(i.cameraViewDir);

    float atmosphereDist = min(atmosphereHit.y, sceneDist - atmosphereHit.x);

    if (atmosphereDist > 0) {
        return scattering(_WorldSpaceCameraPos + cameraViewDir * (atmosphereHit.x + 0.0001), cameraViewDir, atmosphereHit.y - 0.0002, col);
    }

    return col;
}

ENDCG //////////////////////////////////////////////////////////////////////////

} // Pass

} // SubShader

} // Shader
