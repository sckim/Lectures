# 🟦 Quartus를 이용한 논리회로 시뮬레이션

이 폴더는 Intel (Altera) Quartus Prime의 Schematic Editor (Block Diagram File, `.bdf`)를 사용하여 설계된 디지털 논리 회로 예제들을 포함하고 있습니다.

This folder contains digital logic circuit examples designed using Intel (Altera) Quartus Prime's Schematic Editor.

---

## 📂 프로젝트 목록 (Project List)

| 폴더 (Folder) | 주요 내용 (Description) |
| :--- | :--- |
| **00_Basic** | 첫 프로젝트(`and_gate`, VHDL 테스트벤치 포함), 헤드라이트 조합회로(`headlight_logic`) |
| **01_Combinational** | 4비트 가산기(7483, 7세그먼트 표시), BCD-7세그먼트 디코더(7447), 해저드(글리치) 관찰 |
| **04_Flipflop** | SR 래치, 게이트형 SR·D 래치, 게이트로 만든 D·JK·T FF, 기본 FF 4종, 주종형 FF, 래치와 FF 비교, 디바운스 회로 |
| **05_ShiftRegister** | SISO·SIPO(74164), 우측 시프트, 74194 범용·74165 PISO·74195 PIPO, 디지털 금고, 난수 발생기 |
| **06_RippleCounter** | 3비트 리플 카운터(업·다운·업다운·NOR 리셋), 4비트 리플, Modulo-m, 74112 0~9 카운터 |
| **07_Counter** | JK·D·T FF 동기 카운터(2·3·4비트, BCD, 업다운), 그레이 카운터(74138 디코더), 존슨 카운터, 2자리 7490+7447 표시 카운터 |
| **08_StateMachine** | 순차회로 해석(예제 1: 74112판·JKFF판, DFF판)·설계, 101 검출기 3판, D·SR FF 순차회로, 74138 그레이 코드 카운터 |
| **09_IO_Display** | 50 MHz 클록 분주기, 7세그먼트 표시(7490 카운터+7447) |
| **10_DigitalClock** | 디지털 시계: 기본 시계(`clock_basic`), 시각 설정 시계(`clock_set_7490`/`_7492`) |
| **11_VHDL** | VHDL 예제: 기본 게이트, 전가산기, 4비트 가산기, BCD-7세그먼트 디코더, 카운터 4종, 120 Hz 분주기, 7세그먼트 표시, 디지털 시계 블록, UART 송수신 |
| **13_SoC_NIOS_DE1** | Nios II 실습(HelloNios·PIO·인터럽트·7세그먼트), HPS(ARM) 덧셈기, DE1-SoC 골든 톱 |
| **14_보충** | 핵심 예제와 겹치는 변형·보드 입문 예제. 안의 폴더 구조는 `00_Basic` … `07_Counter`와 같다 |

폴더 이름은 `주제_규모_구현_변형` 형식의 영문 소문자이고, 쓰인 74xx 부품 번호를 맨 뒤에 붙였다(예: `shiftreg_sipo_74164`, `sync_counter_4bit_jk`).

각 예제 폴더의 `<bdf이름>_schematic.png`는 `.bdf`에 저장된 소자 기호·배선·핀 이름을 그대로 그린 회로도 그림이다. Quartus 화면 캡처가 있는 예제는 캡처를 그대로 두었다.

---

## 🎓 강의 슬라이드 ↔ 예제 폴더

디지털논리회로 강의08~11 Google Slides에 실린 Quartus 예제의 위치이다. 슬라이드별 회로 해설과 시뮬레이션 결과는 [`../Quartus_Examples/README.md`](../Quartus_Examples/README.md)에 있다. 쪽수는 슬라이드 번호이다.

| 강의 | 슬라이드 (쪽) | 예제 폴더 |
| :--- | :--- | :--- |
| 08 플립플롭 | 기본적인 플립플롭 (22) | `04_Flipflop\sr_latch` |
| 08 플립플롭 | Switch Debouncing with an S-R Latch (34) | `04_Flipflop\debouncing_circuit` |
| 08 플립플롭 | 주종형 S-R 플립플롭 (59, 60) | `04_Flipflop\master_slave_ff`, `master_slave_ff_subblock` |
| 08 플립플롭 | 11.9 Summary (135) | `04_Flipflop\basic_flipflops` |
| 09 레지스터 | 4비트 직렬입력-직렬출력 레지스터 (18) | `05_ShiftRegister\shiftreg_siso` |
| 09 레지스터 | Right-Shift Register (23) | `05_ShiftRegister\shiftreg_right_4bit` |
| 09 레지스터 | 74LS164 SIPO (31) | `05_ShiftRegister\shiftreg_sipo_74164` |
| 09 레지스터 | 디지털 금고 (76), 난수발생회로 (79) | `05_ShiftRegister\shiftreg_digital_locker`, `shiftreg_random_number` |
| 10 비동기식 카운터 | 12.3 Design of Binary Counters (7, 14) | `06_RippleCounter\ripple_counter_3bit_up_down` |
| 10 비동기식 카운터 | MOD-8 리플 다운 카운터 (14) | `06_RippleCounter\ripple_counter_3bit_down` |
| 10 비동기식 카운터 | 비동기 상향-하향 카운터 (24) | `06_RippleCounter\ripple_counter_3bit_up_down_sel` |
| 10 비동기식 카운터 | modulo-m 비동기 카운터 (26) | `06_RippleCounter\ripple_counter_modulo_m` |
| 10 비동기식 카운터 | 0~9 카운터 (29) | `06_RippleCounter\ripple_counter_mod10_74112` |
| 11 동기 순서논리회로 | Quartus II 사용법 및 DE2 보드 (10) | `08_StateMachine\seq_analysis_dff` |
| 11 동기 순서논리회로 | Example 1 (14, 15) | `08_StateMachine\seq_analysis_jk_74112`, `seq_analysis_jk_jkff` |
| 11 동기 순서논리회로 | 논리 회로의 구현 (60) | `08_StateMachine\seq_design_jkff` |
| 11 동기 순서논리회로 | 예제 9-4 그레이 코드 카운터 (120) | `08_StateMachine\gray_counter_74138_or_design` |
| (슬라이드 없음) | 동기식 카운터 | `07_Counter\sync_counter_*_jk` (2bit·3bit·4bit·bcd·3bit_updown) |

---

## 🔍 학습 목표 (Learning Objectives)

1.  **그래픽 기반 회로 설계**: 스키매틱 에디터를 통해 논리 소자를 배치하고 연결하는 실무 역량을 키웁니다.
2.  **FPGA 개발 흐름 이해**: 설계, 컴파일(Synthesis & Fitter), 핀 할당, 프로그래밍으로 이어지는 FPGA 개발 프로세스를 학습합니다.
3.  **타이밍 분석 및 검증**: 시뮬레이션을 통해 신호의 지연과 전파 특성을 분석합니다.

---

## 🛠️ 개발 환경 및 실행 방법 (Environment & How to Run)

1.  **개발 도구**: Intel Quartus Prime (Standard 또는 Lite Edition)
2.  **실행 방법**:
    *   해당 폴더 내의 `.qpf` (Quartus Project File) 파일을 엽니다. 프로젝트가 `.zip`으로만 있는 예제는 먼저 압축을 풉니다.
    *   `Compile Design`을 눌러 전체 프로젝트를 빌드합니다.
    *   `ModelSim` 또는 `University Program VWF`를 통해 시뮬레이션을 수행합니다.

---

## 📚 관련 자료
*   [Quartus 강의 자료](https://docs.google.com/document/d/18SPKDoWC6wiWRv3qgELFiMcgOY7u5xflKEo1A7NmJGI/edit)
*   [메인 README.md로 돌아가기](../README.md)
