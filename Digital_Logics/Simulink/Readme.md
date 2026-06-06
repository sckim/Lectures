# 📊 Simulink를 이용한 논리회로 시뮬레이션

이 폴더는 MATLAB/Simulink를 사용하여 논리 회로를 모델링하고 동작을 분석하기 위한 실습 예제들을 포함하고 있습니다.

This folder contains Simulink models for simulating and analyzing digital logic circuits.

---

## 📂 주요 모델 목록 (Main Models)

| 모델 파일 (Model File) | 주요 내용 (Description) |
| :--- | :--- |
| **BasicGates.slx** | AND, OR, NOT 등 기본적인 논리 게이트 시뮬레이션 |
| **FullAdder.slx / HalfAdder.slx** | 1비트 반가산기 및 전가산기 모델 |
| **FourBitsAdder.slx** | 4비트 전가산기 시뮬레이션 |
| **JKFF.slx / SRFlipflop.slx** | 다양한 방식(Gate-level, MS)으로 구현된 플립플롭 |
| **UpCounter.slx / DownCounter.slx** | 3비트 비동기식/동기식 카운터 예제 |
| **StateDiagram1.slx~5.slx** | 상태 머신(FSM) 설계 및 검증 모델 |
| **VendingMachine.slx** | 자동판매기 제어 로직 시뮬레이션 |
| **ADC.slx** | Sampling rate에 따른 아날로그-디지털 변환 시뮬레이션 |

---

## 🔍 학습 목표 (Learning Objectives)

1.  **모델 기반 설계 (MBD)**: 블록 다이어그램 방식으로 복잡한 시스템을 추상화하여 설계하는 방법을 익힙니다.
2.  **동적 시뮬레이션**: 시간의 흐름에 따른 신호의 변화를 시각적으로 확인하고 검증합니다.
3.  **HDL 코드 생성 기초**: Simulink 모델로부터 VHDL 또는 Verilog 코드를 자동 생성하는 기술을 이해합니다.

---

## 🛠️ 개발 환경 및 실행 방법 (Environment & How to Run)

1.  **개발 도구**: MATLAB / Simulink
2.  **실행 방법**:
    *   MATLAB을 실행하고 해당 폴더로 이동합니다.
    *   원하는 `.slx` 파일을 엽니다.
    *   `Run` 버튼을 클릭하여 시뮬레이션을 수행하고, `Scope` 또는 `Display` 블록을 통해 결과를 확인합니다.

---

## 📚 관련 자료
*   [MATLAB/Simulink 공식 가이드](https://kr.mathworks.com/help/simulink/getting-started-with-simulink.html)
*   [메인 README.md로 돌아가기](../README.md)
