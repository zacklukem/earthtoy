Shader "Hidden/OceanShore" {

Properties {
    _MainTex ("Texture", 2D) = "white" {}
} // Properties

SubShader {
Cull Off ZWrite Off ZTest Always

Pass {

CGPROGRAM //////////////////////////////////////////////////////////////////////

#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"
#include "./Includes/Math.cginc"

struct appdata {
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

struct v2f {
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float3 cameraViewDir: TEXCOORD1;
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

float planetRadius;
float3 planetOrigin;
float threshold;
float depthScalar;
float shoreScalar;
float4 oceanColorShallow;
float4 oceanColorDeep;
float specular;
sampler2D specularTex;

float4 frag(v2f i) : SV_Target {
    float4 col = tex2D(_MainTex, i.uv);

    float3 cameraViewDir = normalize(i.cameraViewDir);

    float planetDist = raySphere(planetOrigin, planetRadius, _WorldSpaceCameraPos, cameraViewDir).x;

    float sceneDistE = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
    float sceneDist = LinearEyeDepth(sceneDistE) * length(i.cameraViewDir);

    if (planetDist > sceneDist) return col;

    float4 spec = tex2D(specularTex, i.uv);

    float diff = sceneDist - planetDist;

    // float3 normal = normalize((_WorldSpaceCameraPos + cameraViewDir * planetDist) - planetOrigin);
    // float angle = acos(dot(normalize(_WorldSpaceLightPos0 - cameraViewDir), normal));
    // float specularExp = angle / specular;
    // float specularLight = exp(-specularExp * specularExp);

    // float diffuse = saturate(dot(normal, _WorldSpaceLightPos0));

    float depth = 1 - exp(-diff * depthScalar);
    float shore = 1 - exp(-diff * shoreScalar);

    float4 ocean = lerp(oceanColorShallow, oceanColorDeep, depth) * spec;

    return lerp(col, ocean, shore);
}

ENDCG //////////////////////////////////////////////////////////////////////////

} // Pass

} // SubShader

} // Shader
