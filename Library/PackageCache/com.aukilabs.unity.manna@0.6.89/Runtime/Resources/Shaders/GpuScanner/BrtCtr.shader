Shader "Auki/GpuScanner/BrtCtr"
{
    Properties 
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Brightness  ("_Brightness", Range(0.0, 20.0)) = 1.0
        _Contrast  ("_Contrast", Range(0.0, 10.0)) = 1.0
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
            uniform float _Contrast;
            uniform float _Brightness;
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
                const float mult[10] = {1.4, 1.3, 1.2, 1.1, 1.0, 0.9, 0.8, 0.7, 0.6, 0.5};
            
                float2 uv = i.texcoord;

                float4 col = float4(0.,0.,0.,1.);
                float3 baseRgb = tex2D(_MainTex, uv.xy).rgb;
                float3 lowFreqColor3 = tex2Dlod(_MainTex, float4(uv.xy, 0, 3)).rgb;
                float3 lowFreqColor2 = tex2Dlod(_MainTex, float4(uv.xy, 0, 4)).rgb;
                float3 lowFreqColor1 = tex2Dlod(_MainTex, float4(uv.xy, 0, 5)).rgb;
                const float lowFreqGray3 = (0.5 - (lowFreqColor3.r + lowFreqColor1.g + lowFreqColor3.b) * 0.33333f) * 0.25;
                const float lowFreqGray2 = (0.5 - (lowFreqColor2.r + lowFreqColor1.g + lowFreqColor2.b) * 0.33333f) * 0.5;
                const float lowFreqGray1 = (0.5 - (lowFreqColor1.r + lowFreqColor2.g + lowFreqColor1.b) * 0.33333f) * 1.0;
                const float lowFreqGray = (lowFreqGray1 + lowFreqGray2 + lowFreqGray3) * 0.33333f;
                float gray = saturate((baseRgb.r + baseRgb.g + baseRgb.b) * 0.33333f + lowFreqGray);
                gray = lerp(0.5, gray, 2);
//                gray = gray * gray * 6;
                
                col.rgb	= float3(gray, gray, gray);
                return col;
            }

            ENDCG
        }
    }
}