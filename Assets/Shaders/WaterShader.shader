Shader "Custom/WaterShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _TexScale ("Texture Scale", float) = 1.0
        _Sharpness ("Sharpness", float) = 1.0
        _FractalA ("Fractal A", float) = 1.0
        _FractalB ("Fractal B", float) = 1.0
    }
    SubShader
    {

        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM

        #include "./Includes/Noise.cginc"

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float3 worldNormal;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _TexScale;
        float _Sharpness;
        float _FractalA;
        float _FractalB;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        float4 fnoise(float3 v, float m, float n) {
            return snoise_grad(v + (snoise_grad(v * m).xyz * n));
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // // float4 cx = fnoise(float3(IN.worldPos.xy * _TexScale + float2(1.0, 1.0) * _Time, 1.0), _FractalA, _FractalB);
            // // float4 cy = fnoise(float3(IN.worldPos.xy * _TexScale + float2(1.0, 1.0) * _Time, 1.0), _FractalA, _FractalB);
            // // float4 cz = fnoise(float3(IN.worldPos.xy * _TexScale + float2(1.0, 1.0) * _Time, 1.0), _FractalA, _FractalB);

            fixed4 cx = fnoise(float3(IN.worldPos.yz * _TexScale, 0.0f), _FractalA, _FractalB) * _Color;
            fixed4 cy = fnoise(float3(IN.worldPos.xz * _TexScale, 0.0f), _FractalA, _FractalB) * _Color;
            fixed4 cz = fnoise(float3(IN.worldPos.xy * _TexScale, 0.0f), _FractalA, _FractalB) * _Color;

            fixed3 blend = pow(abs(IN.worldNormal), _Sharpness);

            blend /= blend.x + blend.y + blend.z;

            fixed4 c = cx * blend.x + cy * blend.y + cz * blend.z;

            // // float4 c = fnoise(IN.worldPos * _TexScale + float3(1.0, 1.0, 1.0) * _Time, _FractalA, _FractalB);

            o.Albedo = _Color;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = 1.0;
            // o.Normal = c.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
