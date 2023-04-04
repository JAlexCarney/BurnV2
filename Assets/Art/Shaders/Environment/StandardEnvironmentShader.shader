Shader "Custom/StandardEnvironmentShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _TexMask ("Texture Mask", 2D) = "white" {}
        [NoScaleOffset] _Glossiness ("Smoothness", 2D) = "white" {}
        _GlossinessMult ("Smoothness multiplier", Range(0,1)) = 1
        [NoScaleOffset]_Normals ("Normal Map", 2D) = "bump" {}
        _Metallic ("Metallic", Range(0,1)) = 0.0
        //add sliders for normal and smoothness levels ok 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" } // removed "RenderType"="Opaque" tag so ground does not render to depth/normal texture
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _TexMask;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_TexMask;
        };

        sampler2D _Glossiness;
        sampler2D _Normals;

        half _GlossinessMult;
        half _NormalsMult;

        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            fixed4 mask = tex2D(_TexMask, IN.uv_TexMask);
            o.Albedo = c.rgb * mask.r + _Color * (1-mask.r);
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = tex2D (_Glossiness, IN.uv_MainTex).r * _GlossinessMult;
            o.Normal = UnpackNormal(tex2D(_Normals, IN.uv_MainTex));
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
