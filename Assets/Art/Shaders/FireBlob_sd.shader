Shader "Unlit/FireBlob_sd"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _StepWidth ("Step Width", Range(0.05, 1)) = 0.33
        [IntRange]_NumSteps ("Number of Steps", Range(1, 16)) = 2

        [Header(Colors)]
        _Color_Inner ("Inner Color", Color) = (1,1,1,1)
        _Color_Middle ("Middle Color", Color) = (.5,.5,.5,.5)
        _Color_Outer ("Outer Color", Color) = (0,0,0,0)

        [Header(Blorbness)]
        _Bottom ("Bottom clamp", Range(0, 1)) = 0.1
        _Top ("Top clamp", Range (0,1)) = 0.5

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent-1"}
        LOD 100

        Stencil
        {
            Ref 1 
            Comp always // comparison - ALWAYS write 1 into stencil buffer 
            Pass replace // replace anything in frame buffer w this pixel pass
        }


        // Pass {
        //     ZWrite On
        //     ColorMask 0

        //     CGPROGRAM
        //     #pragma vertex vert
        //     #pragma fragment frag


        //     #include "UnityCG.cginc"
            

        //     #define PI 3.14159265359

        //     struct appdata
        //     {
        //         float4 vertex : POSITION;
        //         float2 uv : TEXCOORD0;
        //         float2 uv1 : TEXCOORD1;
        //         float3 normal : NORMAL;
        //     };

        //     struct v2f
        //     {
        //         float2 uv : TEXCOORD0;
        //         float2 uv1 : TEXCOORD2;
        //         float4 vertex : SV_POSITION;
        //         float3 normal : TEXCOORD3; 
        //         float3 wPos : TEXCOORD4; 
        //     };

        //     v2f vert (appdata v)
        //     {
        //         v2f o;

        //         // UVs are second set of UVs (contain height/width of model)
        //         o.uv = v.uv1;

        //         // calculate wigglies 
        //         float wiggleX = sin(_Time.y * o.uv.y * 5) * .0005;
        //         float wiggleY = ((sin(PI * _Time.y)+1)/2) * .002 * sin(o.uv.x * PI);
        //         v.vertex.x = v.vertex.x + wiggleX;
        //         // v.vertex.z = v.vertex.z + wiggleY * (o.uv.y>.5);
        //         o.vertex = UnityObjectToClipPos(v.vertex);

        //         // other vars
        //         o.normal = UnityObjectToWorldNormal( v.normal ); 
        //         o.wPos = mul(unity_ObjectToWorld, v.vertex);
        //         return o;
        //     }

        //     fixed4 frag (v2f i) : SV_Target
        //     {
        //         // sample the texture
        //         return float4(0,0,0,0);
        //     }

        //     ENDCG
        // }


        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            

            #define PI 3.14159265359

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD2;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD3; 
                float3 wPos : TEXCOORD4; 
                float3 color : TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _StepWidth;
            int _NumSteps;

            fixed4 _Color_Inner;
            fixed4 _Color_Middle;
            fixed4 _Color_Outer;

            float _Bottom;
            float _Top;

            float iLerp( float a, float b, float v ) {
                return (v - a) / (b - a);
            }

            v2f vert (appdata v)
            {
                v2f o;

                // UVs are second set of UVs (contain height/width of model)
                o.uv = v.uv1;

                // calculate wigglies 
                float wiggleX = sin((o.uv.y -_Time.y * .2f)  * 10) * .0005;
                float clamped = saturate(iLerp(_Bottom, _Top, o.uv.y)); 
                v.vertex.x = v.vertex.x + (wiggleX * clamped);

                float wiggleY = ((sin(PI * _Time.y)+1)/2) * .002 * sin(o.uv.x * PI);
                // v.vertex.z = v.vertex.z + wiggleY * (o.uv.y>.5);
                
                o.vertex = UnityObjectToClipPos(v.vertex);

                // other vars
                o.normal = UnityObjectToWorldNormal( v.normal ); 
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.normal); 
                float3 L = _WorldSpaceLightPos0.xyz; // actually a direction (first pass)
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos); 

                float alpha = 1; 
                // inverse
                half dp = dot(V, N);
                
                alpha = saturate((dp * 2)-.8);

                dp = saturate((1 - dp) * 4);
                float4 color = dp * _Color_Middle;

                dp = 1 - dp;
                color = color + (dp * _Color_Inner);


                return color;
                // sample the texture
                return float4(color.rgb, alpha);
            }
            ENDCG
        }

    }
}
