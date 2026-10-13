Shader "com.vhs_screen_effect/ScreenVHSEffects"
{
    Properties
    {
        _SplitAmount("Split Amount", Range(0, 0.01)) = 0.0015
        _Direction("Direction", Vector) = (1, 0, 0, 0)

        _ScanlineIntensity("Scanline Intensity", Range(0, 1)) = 0.22
        _ScanlineCount("Scanline Density", Range(120, 1200)) = 480
        _ScanlineSpeed("Scanline Drift Speed", Range(0, 8)) = 1.1

        _GlitchJitter("Glitch Jitter", Range(0, 0.02)) = 0.0018
        _GlitchSpeed("Glitch Speed", Range(0, 30)) = 8

        _PosterizeLevels("Posterize Levels", Range(2, 64)) = 8
        _PosterizeBlend("Posterize Blend", Range(0, 1)) = 1
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

                float _ScanlineIntensity;
                float _ScanlineCount;
                float _ScanlineSpeed;

                float _GlitchJitter;
                float _GlitchSpeed;

                float _PosterizeLevels;
                float _PosterizeBlend;
            CBUFFER_END

            // Set globally from script (Time.unscaledTime based).
            float4 _UnscaledTimeParams;

            float Hash21(float2 p)
            {
                p = frac(p * float2(123.34, 345.45));
                p += dot(p, p + 34.345);
                return frac(p.x * p.y);
            }

            half3 Posterize(half3 c, float levels)
            {
                float l = max(2.0, levels);
                float steps = l - 1.0;
                return round(c * steps) / steps;
            }

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

                float t = _UnscaledTimeParams.y;

                float bandCenter = frac(t * (_GlitchSpeed * 0.06));
                float bandWidth = 0.10;
                float bandDist = abs(uv.y - bandCenter);
                float bandMask = 1.0 - smoothstep(0.0, bandWidth, bandDist);

                float lineNoise = Hash21(float2(uv.y * (_ScanlineCount * 0.6), t * 0.7));
                float lineDrift = (lineNoise - 0.5) * 2.0;
                float sineDrift = sin((t * _GlitchSpeed + uv.y * 180.0)) * 0.35;
                float jitter = (lineDrift + sineDrift) * _GlitchJitter * bandMask;

                float2 uvGlitch = saturate(uv + float2(jitter, 0));

                float2 dir = _Direction.xy;
                float dirLen = max(length(dir), 1e-5);
                dir /= dirLen;

                float2 offset = dir * _SplitAmount;
                float2 uvR = saturate(uvGlitch + offset);
                float2 uvB = saturate(uvGlitch - offset);

                half4 baseCol = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, uvGlitch);
                half r = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, uvR).r;
                half b = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, uvB).b;
                half3 col = half3(r, baseCol.g, b);

                float scanWave = sin((uv.y * _ScanlineCount + t * _ScanlineSpeed) * 6.2831853);
                float scanMask = 1.0 - ((scanWave * 0.5 + 0.5) * _ScanlineIntensity);
                col *= scanMask;

                half3 posterized = Posterize(col, _PosterizeLevels);
                col = lerp(col, posterized, _PosterizeBlend);

                return half4(saturate(col), baseCol.a);
            }
            ENDHLSL
        }
    }
}