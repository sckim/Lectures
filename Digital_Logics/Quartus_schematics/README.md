# 🟦 Quartus를 이용한 논리회로 시뮬레이션

이 폴더는 Intel (Altera) Quartus Prime의 Schematic Editor (Block Diagram File, `.bdf`)를 사용하여 설계된 디지털 논리 회로 예제들을 포함하고 있습니다.

This folder contains digital logic circuit examples designed using Intel (Altera) Quartus Prime's Schematic Editor.

---

## 📂 프로젝트 목록 (Project List)

| 폴더 (Folder) | 주요 내용 (Description) |
| :--- | :--- |
| **0_Basic** | 기본적인 논리 게이트(AND, OR, NOT 등) 실습, DE2 스위치 입력 기초 |
| **1_Combinational** | 반가산기, 전가산기, 디코더 등 조합논리회로 설계, 누산기 전가산기, 해저드(글리치) 관찰 |
| **4_Flipflop** | SR, JK, D, T 플립플롭의 동작 시뮬레이션 |
| **5_Ripplecounter** | 리플 카운터(비동기식 카운터) 설계 예제 |
| **5_Shift registers** | SISO, SIPO, PISO, PIPO 등 다양한 쉬프트 레지스터, 74LS74 시프트 레지스터 |
| **6_Counter** | 동기식 카운터 및 Modulo-N 카운터 설계, 존슨 카운터, DE1-SoC 첫 FPGA 카운터 |
| **7.State machine** | 상태도(State Diagram)를 이용한 순차회로 설계, 101 검출기, JK/D/SR-FF 순차회로 해석·설계 |
| **8_IO_Display** | 50 MHz 클록 분주기, 7세그먼트 디코더·표시(DE2/DE1-SoC), UART 송수신 |
| **10_Verilog** | Verilog 예제: 반·전가산기(VHDL/Verilog), Hello World, 첫 카운터, PS/2 키보드 |
| **11_SoC_NIOS_DE1** | Nios II 실습(HelloNios·PIO·인터럽트·7세그먼트), HPS(ARM) 덧셈기, DE1-SoC 골든 톱 |
| **Clock** | 디지털 시계 구성 블록: 1Hz 클럭 분주기·10진 카운터(VHDL)와 상위 스키매틱 |
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

## 🗂️ 통합 이력 (2026-10-10)

`H:\My Drive\20_Teaching\20_Digital_Engineering\1_강의자료\2_실습가이드\03_FPGA\Examples`에 흩어져 있던 회로도(`.bdf`/`.gdf`) 포함 프로젝트 39개(파일 404개, `desktop.ini` 제외)를 이 폴더로 옮겼다. 이 중 구버전 MAX+plus 예제(교재 예제 회로도 18개, `고급예제\LPM`, `maxplus_seq_examples`)는 다시 삭제 대상으로 뺐다. 프로젝트 폴더 안은 건드리지 않았고, 전 파일 SHA256 대조로 동일함을 확인했다. 원경로↔새 경로 대응표는 Drive의 `03_FPGA\_to_delete\_merge_20261010\copy_manifest.tsv`에 있다. 순수 VHDL·Verilog·NIOS·Simulink 예제는 Drive `Examples`에 그대로 남겼다.

| 원래 위치 (`Examples\…`) | 새 위치 |
| :--- | :--- |
| `01_기본게이트_조합회로\Test`, `switch_input_de2` | `0_Basic\Test_and_gate_de1soc`, `0_Basic\switch_input_de2` |
| `01_기본게이트_조합회로\adder_full_with_accumulator`, `hazard_glitch` | `1_Combinational\` |
| `02_카운터_레지스터\counter_de1soc_my_first_fpga`, `counter_johnson_bdf` | `6_Counter\` |
| `02_카운터_레지스터\shiftreg_74ls74_bdf` | `5_Shift registers\` |
| `03_순차회로_FSM\` 9개 | `7.State machine\` |
| `04_입출력_표시_통신\` clock_divider_50mhz·seg7_de1soc·seg7_decoder·uart_tx_rx | `8_IO_Display\` |

같은 날 2차로 Verilog·NIOS·Simulink 예제(`01\adder_half_full`, `01\hello_world_verilog`, `02\counter_verilog_first`, `04\ps2_keyboard`, `05_SoC_NIOS_DE1` 전체, `06_Simulink_HDL` 전체, 파일 2,691개)도 `10_Verilog`, `11_SoC_NIOS_DE1`, `12_Simulink_HDL`로 옮겼다. 이 중 `12_Simulink_HDL`은 Simulink 자료를 한곳에 두기 위해 `..\Simulink\12_Simulink_HDL`로 다시 옮겼다. 역시 전 파일 SHA256이 일치했고, 대응표는 `copy_manifest_map2.tsv`이다. `11_SoC_NIOS_DE1\de1soc_examples_git`(`Altera_DE2` 포함)은 내용 없는 git 저장소 사본이라 삭제 대상으로 뺐다.

구버전 MAX+plus 예제와 `de1soc_examples_git`은 Drive `03_FPGA\_to_delete\from_D\`로, Drive에 남아 있던 `90_구버전_MAXplus_교재예제`는 `03_FPGA\_to_delete\Examples\`로 옮겼다.

폴더 내부 중복(동일 `.bdf`) 목록은 `DUPLICATES.md`에 있다. 아직 정리하지 않았다.

---

## 📚 관련 자료
*   [Quartus 강의 자료](https://docs.google.com/document/d/18SPKDoWC6wiWRv3qgELFiMcgOY7u5xflKEo1A7NmJGI/edit)
*   [메인 README.md로 돌아가기](../README.md)
