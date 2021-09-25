Shader "AAA/LUTColorGrading"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        [KeywordEnum(Default,Character,Props,Scenario,VFX)] _Rule("Rule", Float) = 1 // 0, 1, 2, 3, 4
    }

    SubShader
    {
        // No culling or depth
        Cull Off ZWrite On ZTest LEqual

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            //uniform float4 _LUTGlobal;
            //uniform float _AtoB;

            sampler2D _MainTex;
            
            #define COLORS 32.0
            uniform float _LUTAtoB;
            uniform sampler2D _LUTA;
            float4 _LUTA_TexelSize;
            uniform sampler2D _LUTB;
            float4 _LUTB_TexelSize;
            uniform float _Contribution;
            float _Rule;

            float4 LUT(v2f i)
            {
                float maxColor = COLORS - 1.0;
                float halfColX = 0.5 / _LUTA_TexelSize.z;
                float halfColY = 0.5 / _LUTA_TexelSize.w;
                float threshold = maxColor / COLORS;

                fixed4 col = saturate(tex2D(_MainTex, i.uv));
                float xOffset = halfColX + col.r * threshold / COLORS;
                float yOffset = halfColY + col.g * threshold;
                float cell = floor(col.b * maxColor);
                
                float2 lutPos = float2(cell / COLORS + xOffset, yOffset);

                float4 mix = (tex2D(_LUTA, lutPos) * (1 - _LUTAtoB)) + (tex2D(_LUTB, lutPos) * (_LUTAtoB));

                return mix;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 col = saturate(tex2D(_MainTex, i.uv));

                return lerp(col, LUT(i), _Contribution);
            }
            ENDCG
        }
    }
}