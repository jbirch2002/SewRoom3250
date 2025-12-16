Shader "Custom/ClassShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Color2 ("Color 2", Color) = (1,1,1,1)
        _ColorAlt ("Color alt", Color ) = (1,1,1,1)
        _Color2Alt ("Color 2 alt", Color ) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MainTex2 ("Other Albedo", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _LerpAlpha ("Transition Value", Range(0,1)) = 0
        _Mask1 ("Mask 1", 2D) = "white" {}
        _Mask2 ("Mask 2", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _MainTex2;
        sampler2D _Mask1;
        sampler2D _Mask2;
        sampler2D _BumpMap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv2_Mask1;

        };

        half _Glossiness;
        half _Metallic;
        half _LerpAlpha; 
        fixed4 _Color;
        fixed4 _Color2;
        fixed4 _ColorAlt;
        fixed4 _Color2Alt;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {   
            fixed4 cResult1 = lerp(_Color,_Color2, _LerpAlpha);
            fixed4 cResult2 = lerp(_ColorAlt,_Color2Alt, _LerpAlpha);

            fixed4 c1 = tex2D (_MainTex, IN.uv_MainTex) * cResult1;
            fixed4 c2 = tex2D (_MainTex2, IN.uv_MainTex) * cResult2;
            fixed4 m1 = tex2D (_Mask1, IN.uv2_Mask1);
            fixed4 m2 = tex2D (_Mask2, IN.uv2_Mask1);

            o.Albedo = (c1.rgb + m1.rgb) * (c2.rgb + m2.rgb);
            //o.Normal = UnpackNormal(tex2D (_BumpMap, IN.uv_MainTex));

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            //o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
