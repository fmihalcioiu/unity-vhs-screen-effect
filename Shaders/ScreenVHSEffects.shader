Shader "com.vhs_screen_effect/ScreenVHSEffects"
{
    Properties
    {
        _SplitAmount("Split Amount", Range(0, 0.01)) = 0.0015
        _Direction("Direction", Vector) = (1, 0, 0, 0)
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Name "ScreenVHSEffects"
            ZTest Always
            ZWrite Off
            Cull Off
            Blend One Zero

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                uint vertexID : SV_VertexID;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            TEXTURE2D(_BlitTexture);
            SAMPLER(sampler_BlitTexture);

            CBUFFER_START(UnityPerMaterial)
                float _SplitAmount;
                float4 _Direction;
            CBUFFER_END

            Varyings Vert(Attributes input)
            {
                Varyings output;
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float2 uv = float2((input.vertexID << 1) & 2, input.vertexID & 2);
                output.positionCS = float4(uv * 2.0 - 1.0, 0.0, 1.0);
                output.uv = uv;

                return output;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;

                #if UNITY_UV_STARTS_AT_TOP
                if (_ProjectionParams.x < 0.0)
                    uv.y = 1.0 - uv.y;
                #endif

                float2 dir = _Direction.xy;
                float dirLen = max(length(dir), 1e-5);
                dir /= dirLen;

                float2 offset = dir * _SplitAmount;
                float2 uvR = saturate(uv + offset);
                float2 uvB = saturate(uv - offset);

                half4 baseCol = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, uv);
                half r = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, uvR).r;
                half b = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, uvB).b;
                half3 col = half3(r, baseCol.g, b);

                return half4(saturate(col), baseCol.a);
            }
            ENDHLSL
        }
    }
}