Shader "Auki/GpuScanner/PlaneMerge"
{
    Properties 
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _OverlayTex ("Base (RGB)", 2D) = "white" {}
        _GradientTex ("Base (RGB)", 2D) = "white" {}
        _Brightness  ("_Brightness", Range(0.0, 1.0)) = 1.0
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
            uniform sampler2D _OverlayTex;
            uniform sampler2D _GradientTex;
            half _Brightness;
            half4 _MainTex_ST;

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

            float4 frag(v2f i) : COLOR
            {
                float2 uv = i.texcoord;

                half3 color = saturate(tex2D(_MainTex, uv.xy).rgb * _Brightness);
                const half overlay = tex2D(_OverlayTex, uv.xy).r;
                const half3 gradient = tex2D(_GradientTex, float2(overlay, 0.5));
                const half alpha = step(0.1, overlay);
                color = lerp(color, gradient, alpha);
                return half4(color, 1); 
            }

            ENDCG
        }
    }
}