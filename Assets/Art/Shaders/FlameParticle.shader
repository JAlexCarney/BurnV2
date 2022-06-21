Shader "Unlit/FlameParticle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent+1"}
        LOD 100

        // Pass {
        //     ZWrite On
        //     ColorMask 0
        // }

        ZWrite On
        Pass
        {   
            //  Stencil {
            //       Ref 10
            //       ReadMask 10
            //       Comp NotEqual
            //       Pass Replace
            //   }

            Stencil
            {
                Ref 10  // set value of 1...
                Comp notequal // and if stencil value is =/= to what is already in stencil buffer...
                Pass Replace // then keep the pixel that belongs to the wall!
            }

        
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col-.95);

                return col * i.color;
            }
            ENDCG
        }

    }
}
