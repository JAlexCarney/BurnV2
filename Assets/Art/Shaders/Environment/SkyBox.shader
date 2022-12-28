Shader "Unlit/SkyBox"
{
    Properties
    {
        _ColorA ("Color A", Color) = (.3,.3,.3,1)
        _ColorB ("Color B", Color) = (.7,.7,.7,1)
        _Start ("Start height", Range(-1,1)) = .5
        _End ("End Height", Range(-1,1)) = 1
        _Texture("Sky Texture", 2D) = "white" {}
        
    }
    SubShader
    {
        Tags { "RenderType"="Background" "Queue"="Background" "PreviewType"="Quad"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.28318530718
            #define PI 3.14159265358979

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 wPos : TEXCOORD1; 
            };

            float iLerp( float a, float b, float v ) {
                return clamp((v - a) / (b - a), 0, 1);
            }

            fixed4 _ColorA;
            fixed4 _ColorB; 
            float _Start;
            float _End;
            sampler2D _Texture;
            float4 _Texture_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);

                //TODO: idk what the fuck this is doing
                // float3 nwPos = normalize(o.wPos);
                // float uCoord = atan2(nwPos.r, nwPos.b)/(PI*2);
                // float vCoord = asin(nwPos.g)/(PI/2);
                // float2 uvCoords = float2(uCoord, vCoord);
                // o.uv = TRANSFORM_TEX(uvCoords, _Texture);
                // o.uv = uvCoords; 
                o.uv = v.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 nwPos = normalize(i.wPos);

                //calculate gradient
                float inverseLerp = iLerp(_Start, _End, nwPos.y); // no need to lerp after remap since we're just remaping to [0,1]
                fixed4 col = lerp(_ColorA, _ColorB, inverseLerp);

                //calculate uvs for no weird stretching
                float uCoord = atan2(nwPos.r, nwPos.b)/(UNITY_TWO_PI);
                float vCoord = asin(nwPos.g)/(UNITY_HALF_PI);
                float2 uv = float2(uCoord, vCoord);
                uv = uv * _Texture_ST.xy + _Texture_ST.zw;

                fixed4 tex = tex2D (_Texture, uv);
                return tex;
                return col * (1-tex.a) + tex * tex.a;
            }
            ENDCG
        }
    }
}

//https://medium.com/@jannik_boysen/procedural-skybox-shader-137f6b0cb77c