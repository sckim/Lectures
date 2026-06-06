# 🟦 Quartus를 이용한 논리회로 시뮬레이션

이 폴더는 Intel (Altera) Quartus Prime의 Schematic Editor (Block Diagram File, `.bdf`)를 사용하여 설계된 디지털 논리 회로 예제들을 포함하고 있습니다.

This folder contains digital logic circuit examples designed using Intel (Altera) Quartus Prime's Schematic Editor.

---

## 📂 프로젝트 목록 (Project List)

| 폴더 (Folder) | 주요 내용 (Description) |
| :--- | :--- |
| **0_Basic** | 기본적인 논리 게이트(AND, OR, NOT 등) 실습 |
| **1_Combinational** | 반가산기, 전가산기, 디코더 등 조합논리회로 설계 |
| **4_Flipflop** | SR, JK, D, T 플립플롭의 동작 시뮬레이션 |
| **5_Ripplecounter** | 리플 카운터(비동기식 카운터) 설계 예제 |
| **5_Shift registers** | SISO, SIPO, PISO, PIPO 등 다양한 쉬프트 레지스터 |
| **6_Counter** | 동기식 카운터 및 Modulo-N 카운터 설계 |
| **7.State machine** | 상태도(State Diagram)를 이용한 순차회로 설계 |
| **DigitalClock** | 디지털 시계 시스템 전체 설계 예제 |
| **Digital_StrongBox** | 비밀번호 입력 기반의 디지털 금고 제어 회로 |
| **Tutorial** | Quartus Prime 사용법을 위한 튜토리얼 프로젝트 |

---

## 🔍 학습 목표 (Learning Objectives)

1.  **그래픽 기반 회로 설계**: 스키매틱 에디터를 통해 논리 소자를 배치하고 연결하는 실무 역량을 키웁니다.
2.  **FPGA 개발 흐름 이해**: 설계, 컴파일(Synthesis & Fitter), 핀 할당, 프로그래밍으로 이어지는 FPGA 개발 프로세스를 학습합니다.
3.  **타이밍 분석 및 검증**: 시뮬레이션을 통해 신호의 지연과 전파 특성을 분석합니다.

---

## 🛠️ 개발 환경 및 실행 방법 (Environment & How to Run)

1.  **개발 도구**: Intel Quartus Prime (Standard 또는 Lite Edition)
2.  **실행 방법**:
    *   해당 폴더 내의 `.qpf` (Quartus Project File) 파일을 엽니다.
    *   `Compile Design`을 눌러 전체 프로젝트를 빌드합니다.
    *   `ModelSim` 또는 `University Program VWF`를 통해 시뮬레이션을 수행합니다.

---

## 📚 관련 자료
*   [Quartus 강의 자료](https://docs.google.com/document/d/18SPKDoWC6wiWRv3qgELFiMcgOY7u5xflKEo1A7NmJGI/edit)
*   [메인 README.md로 돌아가기](../README.md)
