Shader "Auki/GpuScanner/DrawEdges"
{
    Properties 
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Color ("Color", float) = 0.5
    }
    
    SubShader 
    {
        Pass
        {
            Cull Off ZWrite Off ZTest Always
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma target 3.0
            #include "UnityCG.cginc"

            uniform sampler2D _MainTex;
            uniform half4 _Color;

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 texcoord  : TEXCOORD0;
                float4 vertex   : SV_POSITION;
                float4 color    : COLOR;
            };   

            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color;
                return OUT;
            }

            half4 _MainTex_ST;
            float4 frag(v2f i) : COLOR
            {
                const float2 uv = UnityStereoScreenSpaceUVAdjust(i.texcoord, _MainTex_ST);
                return half4(1, 1, 1, 1) * tex2D(_MainTex, uv).r;
            }
            ENDCG
        }
    }
}