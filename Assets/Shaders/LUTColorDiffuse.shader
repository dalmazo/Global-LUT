Shader "LUT/LUTColorDiffuse" 
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
        [KeywordEnum(Default,Character,Props,Scenario,VFX)] _Rule("Rule", Float) = 1 // 0, 1, 2, 3, 4
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 150

        CGPROGRAM
        #pragma surface surf Lambert noforwardadd

        //Start here
        sampler2D _MainTex;

        #define COLORS 32.0
        uniform float _LUTAtoB;
        uniform sampler2D _LUTA;
        float4 _LUTA_TexelSize;
        uniform sampler2D _LUTB;
        float4 _LUTB_TexelSize;
        uniform float _Contribution;

        struct Input
        {
            float2 uv_MainTex;
        };

        float4 LUT(Input i)
        {
            float maxColor = COLORS - 1.0;
            float halfColX = 0.5 / _LUTA_TexelSize.z;
            float halfColY = 0.5 / _LUTA_TexelSize.w;
            float threshold = maxColor / COLORS;

            fixed4 col = saturate(tex2D(_MainTex, i.uv_MainTex));
            float xOffset = halfColX + col.r * threshold / COLORS;
            float yOffset = halfColY + col.g * threshold;
            float cell = floor(col.b * maxColor);

            float2 lutPos = float2(cell / COLORS + xOffset, yOffset);

            float4 mix = (tex2D(_LUTA, lutPos) * (1 - _LUTAtoB)) + (tex2D(_LUTB, lutPos) * (_LUTAtoB)); 

            return mix;
        }
        //end here


        void surf(Input i, inout SurfaceOutput o) 
        {
            fixed4 c = tex2D(_MainTex, i.uv_MainTex);
            //o.Albedo = c.rgb;
            float4 finalcol = lerp(c, LUT(i), _Contribution);

            o.Albedo = finalcol.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    Fallback "Mobile/VertexLit"
}