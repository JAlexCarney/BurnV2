// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/FlameParticle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _PlayerHeight ("Player height", float) = 1
        _PlayerBase ("Player Base", float) = 1
        _GradientMask ("Player Gradient", float) = 1
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
                fixed3 wPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _PlayerHeight;
            float _PlayerBase;
            float _GradientMask;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                o.wPos = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            float iLerp( float a, float b, float v ) {
                return min(max((v - a) / (b - a), 0), 1);
            }

            // TODO: looks like all particles have an origin of (0,0,0,0) 
            // maybe pass in gradient y pos and calculate that w particle???? idkkkk
            fixed4 frag (v2f i) : SV_Target
            {
                // float gradientMask = saturate(i.uv.y * _GradientHeight);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col-.95);

                float y = iLerp(_PlayerBase, _PlayerHeight + _PlayerBase, i.wPos.y);
                float gradientMask = saturate(y * _GradientMask);
                // return float4(gradientMask, gradientMask, gradientMask,1);

                float4 color = i.color * gradientMask + _Color * (1-gradientMask);
                // return 
                return color;
            }
            ENDCG
        }

    }
}
