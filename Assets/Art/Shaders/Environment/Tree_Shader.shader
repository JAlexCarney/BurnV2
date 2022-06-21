Shader "Unlit/NEW FUCK SHADER"
{
    Properties
    {
        _Gradient ("Color", 2D) = "white" {}
        _StartHeight ("Lowest height", float) = 5
        _EndHeight ("Tallest height", float) = 20 
    }
    SubShader
    {
        LOD 100

        Pass
        {   
            Tags {  "LightMode"="ForwardBase"  }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc" 


            // take over shadow processing yourself
           #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight


            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL; 
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed4 col : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 wPos : TEXCOORD2;
                fixed3 ambient : COLOR;
                half diff : TEXCOORD3;
                SHADOW_COORDS(4) // calculate coords for shadows on objects
            };

            sampler2D _Gradient; 
            float _StartHeight; 
            float _EndHeight; 
            
            //TODO: Change to something smaller than float? 
            float ilerp(float start, float end, float val) 
            {
                val = clamp(val, start, end); 
                return (val - start)/(end - start); 
            }

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float originHeight = mul(unity_ObjectToWorld, float4(0,0,0,1)).y; 
                float val = ilerp(_StartHeight, _EndHeight, originHeight);
                o.col = tex2Dlod(_Gradient, float4(val,0,0,0)); // use tex2Dlod in a vert shader

                o.normal = UnityObjectToWorldNormal( v.normal ); 
                o.wPos = mul(unity_ObjectToWorld, v.vertex);

                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half nl = dot(worldNormal, _WorldSpaceLightPos0.xyz);
                o.diff = nl;

                o.ambient = ShadeSH9(half4(o.normal,1));

                // populate shadow coords
                TRANSFER_SHADOW(o);



                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float N = normalize(i.normal); 
                float L = normalize(UnityWorldSpaceLightDir(i.wPos));
                float diffuse = saturate(dot(N,L));

                float attenuation = SHADOW_ATTENUATION(i); 

                // sample the texture ZZ
                fixed3 lighting = i.diff * _LightColor0 * attenuation+ i.ambient; 
                fixed4 col = i.col;
                col.rgb *= lighting;            
                // up smoothness for more contrast? 
                
                return (col);
            }
            ENDCG
        }   

        Pass // SHADOW PASS
        {
            Tags { "LightMode"="ShadowCaster" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            // ^ tell compiler that we wanna do shadows
            #include "UnityCG.cginc"
            // dont need lighting cginc

            // get geometry from model to calculate shadow...
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL; 
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                V2F_SHADOW_CASTER; // ALL this pass is doing is taking geometry from model and casting shadow
                // so all u need is shadow
            };

            v2f vert (appdata v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o); // ty macros lmao 
                // a shadow basically squashes 3D space into plane (projects flat shadow) 
                // basically casting it backwards and making it flat on whatever it lands on
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i); // spit out pixel color for shadow
            }
            ENDCG
        }

    }
}
