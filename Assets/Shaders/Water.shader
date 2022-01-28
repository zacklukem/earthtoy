Shader "Custom/Water" {

Properties {
    _Color ("Color", Color) = (1,1,1,1)
    _MainTex ("Albedo (RGB)", 2D) = "white" {}
    _WaveA ("Wave A", 2D) = "white" {}
    _WaveB ("Wave B", 2D) = "white" {}
    _WaveAScale ("Wave A Scale", float) = 1.0
    _WaveBScale ("Wave B Scale", float) = 1.0
    _Glossiness ("Smoothness", Range(0,1)) = 0.5
    _Metallic ("Metallic", Range(0,1)) = 0.0
} // Properties

SubShader {

Tags { "RenderType"="Opaque" }
LOD 200

CGPROGRAM //////////////////////////////////////////////////////////////////////

// Physically based Standard lighting model, and enable shadows on all light types
#pragma surface surf Standard fullforwardshadows

// Use shader model 3.0 target, to get nicer looking lighting
#pragma target 3.0

sampler2D _MainTex;
sampler2D _WaveA;
sampler2D _WaveB;
float _WaveAScale;
float _WaveBScale;

struct Input {
    float2 uv_MainTex;
    float3 worldPosition;
    float3 worldNormal;
    INTERNAL_DATA
};

half _Glossiness;
half _Metallic;
fixed4 _Color;

UNITY_INSTANCING_BUFFER_START(Props)
UNITY_INSTANCING_BUFFER_END(Props)

float4 triplanar(in float3 normal, in float3 pos, in sampler2D tex, in float2 offset, float scale) {
    float4 x = tex2D(tex, (normal.yz + offset) * scale);
    float4 y = tex2D(tex, (normal.xz + offset) * scale);
    float4 z = tex2D(tex, (normal.xy + offset) * scale);

    float3 blend = normal * normal;
    blend /= dot(blend, 1);

    return x * blend.x + y * blend.y + z * blend.z;
}

void surf(Input i, inout SurfaceOutputStandard o) {
    float3 worldNormal = WorldNormalVector(i, o.Normal);

    float4 waveA = triplanar(worldNormal, i.worldPosition, _WaveA, float2(0.03, 0.02) * _Time, _WaveAScale);
    float4 waveB = triplanar(worldNormal, i.worldPosition, _WaveB, float2(0.03, 0.0) * _Time, _WaveBScale);

    float4 c = _Color;

    o.Albedo = c;
    o.Normal = (waveA.rgb + waveB.rgb) / 2;

    // Metallic and smoothness come from slider variables
    o.Metallic = _Metallic;
    o.Smoothness = _Glossiness;
    o.Alpha = c.a;
}

ENDCG //////////////////////////////////////////////////////////////////////////

} // SubShader

FallBack "Diffuse"

} // Shader
