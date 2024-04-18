Shader "Auki/GpuScanner/EdgeDetector"
{
    Properties 
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _ScreenResolution ("_ScreenResolution", Vector) = (0.,0.,0.,0.)
        _Threshold ("_Threshold", Range(0.,1.)) = 0.5
    }
    
    SubShader 
    {
        Pass
        {
            Cull Off ZWrite Off ZTest Always
            CGPROGRAM
            #pragma exclude_renderers d3d11 gles
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma target 3.0
            #pragma glsl
            #include "UnityCG.cginc"


            uniform sampler2D _MainTex;
            uniform float4 _ScreenResolution;
            uniform float _Threshold;

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
            
            #define tex2D(sampler,uvs)  tex2Dlod( sampler , float4( ( uvs ) , 0.0f , 0.0f) )

            half4 _MainTex_ST;

            float intensity(in float4 color)
            {
                return sqrt((color.x*color.x)+(color.y*color.y)+(color.z*color.z));
            }

            float4 frag(v2f i) : COLOR
            {
                const float2 uv = i.texcoord.xy;

                const float2 p = 1.0 / _ScreenResolution.xy;

                float gray_sum = 0.0;
                for(int a = -1; a <= 1; a ++)
                {
                    for(int b = -1; b <= 1; b ++)
                    {
                        const float c = step(_Threshold, intensity(tex2D(_MainTex, uv + p * float2(b, a))));
                        if(b == 0 && a == 0) gray_sum += c * 8.0;
                        else gray_sum -= c;
                    }
                }
                float v = step(0.5, gray_sum);
                return float4(v,v,v,v);
            }
            ENDCG
        }
    }
}