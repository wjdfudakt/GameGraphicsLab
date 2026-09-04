// Inspector에서 보일 Shader 메뉴 이름입니다.
Shader "GameGraphics/Day07 Unlit Color"
{
    // Material Inspector에 노출할 값을 선언합니다.
    Properties
    {
        // _BaseColor라는 색 값을 만들고, 기본값을 하늘색으로 설정합니다.
        _BaseColor ("Base Color", Color) = (0.2, 0.7, 1.0, 1.0)
    }

    // 렌더링에 사용할 Shader 설정 묶음입니다.
    SubShader
    {
        // 이 Shader가 URP용이며, 불투명 물체를 그린다고 표시합니다.
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
        }

        // 한 번의 그리기 작업을 정의합니다.
        Pass
        {
            // 이 Pass의 이름입니다.
            Name "ForwardUnlit"

            // URP의 일반적인 전방 렌더링 단계에서 실행한다고 표시합니다.
            Tags { "LightMode" = "UniversalForward" }

            // 여기부터 HLSL 셰이더 코드입니다.
            HLSLPROGRAM

            // 정점마다 vert 함수를 실행하도록 지정합니다.
            #pragma vertex vert

            // 화면의 픽셀마다 frag 함수를 실행하도록 지정합니다.
            #pragma fragment frag

            // TransformObjectToHClip 같은 URP 제공 함수를 가져옵니다.
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Material마다 다른 값을 SRP Batcher 호환 방식으로 묶습니다.
            CBUFFER_START(UnityPerMaterial)

                // Properties의 _BaseColor와 연결되는 실제 HLSL 변수입니다.
                half4 _BaseColor;

            // Material 값 묶음을 끝냅니다.
            CBUFFER_END

            // 메시에서 정점 데이터를 받는 입력 구조체입니다.
            struct Attributes
            {
                // 메시의 정점 위치를 positionOS에 넣습니다.
                // POSITION은 "정점 위치 데이터"를 뜻하는 시맨틱입니다.
                // OS는 Object Space, 즉 오브젝트 기준 좌표입니다.
                float4 positionOS : POSITION;
            };

            // vert 함수가 계산한 값을 frag 함수로 보내는 구조체입니다.
            struct Varyings
            {
                // 화면에 그릴 최종 정점 위치를 담습니다.
                // SV_POSITION은 GPU가 삼각형을 화면에 배치할 때 쓰는 시맨틱입니다.
                // CS는 Clip Space, 즉 투영까지 끝난 화면 배치용 좌표입니다.
                float4 positionCS : SV_POSITION;
            };

            // 정점마다 한 번 실행되는 정점 셰이더 함수입니다.
            // GPU가 POSITION 데이터를 input.positionOS에 채워서 전달합니다.
            Varyings vert(Attributes input)
            {
                // frag 단계로 보낼 빈 출력 구조체를 만듭니다.
                Varyings output;

                // 오브젝트 기준 정점 위치를 Clip Space 위치로 변환합니다.
                // 오브젝트 변환, 카메라 변환, 투영 변환이 반영됩니다.
                output.positionCS =
                    TransformObjectToHClip(input.positionOS.xyz);

                // 채운 출력 구조체를 GPU에 반환합니다.
                return output;
            }

            // 화면에서 삼각형으로 덮인 픽셀마다 한 번 실행되는 함수입니다.
            // SV_Target은 반환값을 최종 픽셀 색으로 사용하라는 시맨틱입니다.
            half4 frag(Varyings input) : SV_Target
            {
                // Material Inspector의 Base Color를 그대로 픽셀 색으로 반환합니다.
                return _BaseColor;
            }

            // HLSL 코드 블록을 끝냅니다.
            ENDHLSL
        }
    }
}