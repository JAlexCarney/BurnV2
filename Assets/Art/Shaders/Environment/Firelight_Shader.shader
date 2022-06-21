Shader "Unlit/Firelight_Shader"
{
    Properties
    {
        _Color ("Fire Color", Color) = (1,1,1,1)
        _LightPos ("Light pos", Vector) = (1,1,1)
        _Range ("Range", float) = 5
        _NormalCutoff ("Normal Cutoff", Range(0,1)) = 0

        _WigglyRange("Wiggly Range", Range(0,1)) = 0.5
        _WigglySpeed("Wiggly  Speed", float) = 1 
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100

        Pass
        {
            Blend One One  

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL; 
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 wPos : TEXCOORD1; 
                float3 normal : TEXCOORD2; 
            };

            float4 _Color;
            float4 _LightPos;
            float _Range;
            float _NormalCutoff;

            float _WigglyRange; 
            float _WigglySpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float sdf_sphere (float3 p, float3 center, float radius)
            {
                return distance(p, center) - radius;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float wigglyRange = _Range + sin(_Time.a * _WigglySpeed)*_WigglyRange;
                clip(-1 * sdf_sphere(i.wPos, _LightPos, wigglyRange)); // remove if not inside of light's range

                float3 L = normalize(_LightPos - i.wPos);
                float3 N = normalize(i.normal); 

                clip(dot(L,N) - _NormalCutoff); // remove if fragment is not facing light source 
    
                return _Color;
            }
            ENDCG
        }
    }
}
