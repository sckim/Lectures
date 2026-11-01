# 🟦 Quartus를 이용한 논리회로 시뮬레이션

이 폴더는 Intel (Altera) Quartus Prime의 Schematic Editor (Block Diagram File, `.bdf`)를 사용하여 설계된 디지털 논리 회로 예제들을 포함하고 있습니다.

This folder contains digital logic circuit examples designed using Intel (Altera) Quartus Prime's Schematic Editor.

---

## 📂 프로젝트 목록 (Project List)

| 폴더 (Folder) | 주요 내용 (Description) |
| :--- | :--- |
| **00_Basic** | 첫 프로젝트(AND 게이트, VHDL 테스트벤치 포함), 헤드라이트 조합회로 설계 |
| **01_Combinational** | 반가산기·전가산기·4비트 가산기(7483, 7세그먼트 표시), BCD-7세그먼트 디코더(7447), 해저드(글리치) 관찰 |
| **04_Flipflop** | SR 래치, 게이트형 SR·D 래치, 게이트로 만든 D·JK·T FF, 기본 FF 4종(교재 4.1.2), 주종형 FF, 디바운스 회로 |
| **05_ShiftRegister** | SISO·SIPO(교재 4.2절), 우측 시프트, 74194 범용·74165 PISO·74195 PIPO, 디지털 금고, 난수 발생기 |
| **06_RippleCounter** | 리플 카운터(교재 4.3절 업·다운·업다운·Modulo-m), 4비트 리플, 74112 0~9 카운터 |
| **07_Counter** | 동기식 카운터(교재 6.1~6.5절), D·T FF 동기 카운터 설계, 그레이 카운터(74138 디코더), 존슨 카운터, 2자리 7447 표시 카운터 |
| **08_StateMachine** | 순차회로 해석(예제 1: 74112판·JKFF판)·설계, 101 검출기(`detector_101_*` 3판), JK/D/SR-FF 순차회로, 74138 디코더 카운터 |
| **09_IO_Display** | 50 MHz 클록 분주기, 7세그먼트 표시(`BCD_Counter_7Seg`: 7490 카운터+7447) |
| **10_DigitalClock** | 디지털 시계: 구성 블록(`Clock`), `Basic_Clock`, 시각 설정 시계(`Set_Clock_90`/`_92`) |
| **11_VHDL** | VHDL 예제: `basic_gates`, `full_adder`, `adder_4bit`, `bcd_to_7seg`(·`_case`), 카운터(`counter_process_basic`, `counter_mod16_up_7seg`, `counter_lpm_bcd_7seg`, `counter_structural_bcd_7seg`), `clock_divider_120hz`, `seg7_decoder`, `seg7_de1soc`, `uart_tx_rx` |
| **13_SoC_NIOS_DE1** | Nios II 실습(HelloNios·PIO·인터럽트·7세그먼트), HPS(ARM) 덧셈기, DE1-SoC 골든 톱 |
| **14_보충** | 학습 핵심에서 뺀 변형·중복·보드 입문 예제. 원래 폴더 구조(`00_Basic` … `07_Counter`)를 그대로 유지한다 |

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
| `01_기본게이트_조합회로\Test`, `switch_input_de2` | `00_Basic\Test_and_gate_de1soc`, `00_Basic\switch_input_de2` |
| `01_기본게이트_조합회로\adder_full_with_accumulator`, `hazard_glitch` | `01_Combinational\` |
| `02_카운터_레지스터\counter_de1soc_my_first_fpga`, `counter_johnson_bdf` | `07_Counter\` |
| `02_카운터_레지스터\shiftreg_74ls74_bdf` | `05_Shift registers\` |
| `03_순차회로_FSM\` 9개 | `08_State machine\` |
| `04_입출력_표시_통신\` clock_divider_50mhz·seg7_de1soc·seg7_decoder·uart_tx_rx | `09_IO_Display\` |

같은 날 2차로 Verilog·NIOS·Simulink 예제(`01\adder_half_full`, `01\hello_world_verilog`, `02\counter_verilog_first`, `04\ps2_keyboard`, `05_SoC_NIOS_DE1` 전체, `06_Simulink_HDL` 전체, 파일 2,691개)도 `10_Verilog`, `11_SoC_NIOS_DE1`, `12_Simulink_HDL`로 옮겼다(현재 이름은 `11_Verilog`, `12_SoC_NIOS_DE1`). 이 중 `12_Simulink_HDL`은 Simulink 자료를 한곳에 두기 위해 `..\Simulink\12_Simulink_HDL`로 다시 옮겼다. 역시 전 파일 SHA256이 일치했고, 대응표는 `copy_manifest_map2.tsv`이다. `11_SoC_NIOS_DE1\de1soc_examples_git`(`Altera_DE2` 포함)은 내용 없는 git 저장소 사본이라 삭제 대상으로 뺐다.

구버전 MAX+plus 예제와 `de1soc_examples_git`은 Drive `03_FPGA\_to_delete\from_D\`로, Drive에 남아 있던 `90_구버전_MAXplus_교재예제`는 `03_FPGA\_to_delete\Examples\`로 옮겼다.

폴더 내부 중복(동일 `.bdf`) 목록은 `DUPLICATES.md`에 있다.

## 🧹 중복 정리·재배치 (2026-10-30)

설계 소스의 MD5를 다시 대조하여 프로젝트 단위 중복 15개(약 20 MB)를 `_to_delete_중복\`으로 격리하고, 잘못 놓인 프로젝트 15건을 주제 폴더로 옮겼다. 프로젝트 폴더 내부는 건드리지 않았다. 전체 이동 기록은 `_ops\move_log.tsv`에 있다.

| 구분 | 내용 |
| :--- | :--- |
| 동기식 카운터 | `06_Ripplecounter\3.Counter` → `07_Counter\3.Counter`, 그 안의 `6_1_2bit_counter`·`6_2_3bit_counter`는 `07_Counter\` 바로 아래로, `4bits_Counter`는 `07_Counter\6_3_syn_4bit_counter\` 안으로 |
| 리플 카운터 | `07_Counter`의 `0.3bit ripple up cnt`, `3bits_ripple down`, `3bits_ripple falling edge`, `4bit ripple counter` → `06_Ripplecounter\` |
| 7세그먼트 표시 | `06_Ripplecounter\BCD2SEG`, 최상위 `Demo3` → `09_IO_Display\BCD2SEG`(현재 이름 `BCD_Counter_7Seg`), `09_IO_Display\Demo3_BCD2SEG`(현재 이름 `Demo3_BCD_Counter_7Seg`) |
| 최상위 Demo | `Demo2` → `07_Counter\Demo2_Graycode`, `Demo4` → `08_State machine\Demo4_Seq_detector` |
| 디지털 시계 | `07_Counter\Projects`, 최상위 `Clock`, `DigitalClock` → `10_DigitalClock\` |
| 중복 격리 | 교재 절 번호 폴더(`4_x_x`, `6_x_x`)와 같은 사본, `07_Counter`의 리플 카운터 사본, `01_Combinational\Graycode`(= `07_Counter\Gray_counter`), 최상위 `Digital_StrongBox` 등 15개 |



---

## 🎓 강의 슬라이드 ↔ 예제 폴더 (2026-10-30)

디지털논리회로 강의08~11 Google Slides에 실린 Quartus 예제의 위치이다. 슬라이드별 회로 해설은 `..\Quartus_Examples\README.md`에 있다. 쪽수는 슬라이드 번호이다.

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
| 10 비동기식 카운터 | 12.3 Design of Binary Counters (7, 14) | `06_RippleCounter\ripple_counter_3bit_up_down` (원래 연결된 4_3_1·3bit ripple은 제외됨) |
| 10 비동기식 카운터 | MOD-8 리플 다운 카운터 (14) | `06_RippleCounter\ripple_counter_3bit_down` |
| 10 비동기식 카운터 | 비동기 상향-하향 카운터 (24) | `06_RippleCounter\ripple_counter_3bit_up_down_sel` |
| 10 비동기식 카운터 | modulo-m 비동기 카운터 (26) | `06_RippleCounter\ripple_counter_modulo_m` |
| 10 비동기식 카운터 | 0~9 카운터 (29) | `06_RippleCounter\ripple_counter_mod10_74112` |
| 11 동기 순서논리회로 | Quartus II 사용법 및 DE2 보드 (10) | `08_StateMachine\seq_analysis_dff` |
| 11 동기 순서논리회로 | Example 1 (14, 15) | `08_StateMachine\seq_analysis_jk_74112`, `seq_analysis_jk_jkff` |
| 11 동기 순서논리회로 | 논리 회로의 구현 (60) | `08_StateMachine\seq_design_jkff` |
| 11 동기 순서논리회로 | 예제 9-4 그레이 코드 카운터 (120) | `08_StateMachine\gray_counter_74138_or_design` |
| (슬라이드 없음) | 동기식 카운터 | `07_Counter\sync_counter_*_jk` (2bit·3bit·4bit·bcd·3bit_updown) |

`Quartus_Examples`에만 있던 회로도 그림 7장(`*_schematic.png`, `.bdf`를 읽어 그린 것)을 위 예제 폴더에 복사했다. 원본 Quartus 캡처가 이미 있는 `4bits_counter_schematic.png`는 복사하지 않았다. 강의10 예제인 `eightcounter`(74112 리플 0~9 카운터)는 `07_Counter`에서 `06_Ripplecounter`로 옮겼다.

---

## 🖼️ 회로도 그림 (2026-10-30)

각 예제의 `.bdf`를 그림으로 그려 같은 폴더에 `<bdf이름>_schematic.png`로 넣었다(113장). `.bdf`에 저장된 소자 기호·배선·핀 이름을 그대로 그린 것이며 Quartus 화면 캡처는 아니다.

- 원본 Quartus 캡처(`4_x_x_…_schematic.png` 등)가 이미 있는 교재 절 번호 폴더 6곳은 새로 그리지 않았다.
- `07_Counter\8진 up counter\Quartus II\tff(a-b-c).bdf`는 크기 0인 빈 파일이라 그림이 없다.
- MAX+plus 이진 형식 `.gdf`만 있는 `07_Counter\2bit UD counter`(`count.gdf`), `07_Counter\8진 updown counter`, `07_Counter\8진 up counter`의 `tff(a-b-c).gdf`는 변환하지 못했다.
- 변환 스크립트는 `_ops\bdf2png.py`에 있다.

---

## ✅ 검토 반영 (2026-10-30)

검토 페이지에서 표시한 대로 정리했다. 이동 기록은 `_ops\move_log.tsv`에 있다.

| 구분 | 내용 |
| :--- | :--- |
| 제외(격리) 20개 | `00_Basic\and_gate`, `Test_and_gate_de1soc` / `04_Flipflop\SRLatch` / `05_Shift registers\Register_74194` / `06_Ripplecounter\0.3bit ripple up cnt`, `RippleCnt`, `RippleCounter\3bit ripple`, `RippleCounter\4_3_1_ripple_up_counter` / `07_Counter\0.3digits using 7447`, `1.3digits with VHDL`, `2. 3digits with VHDL`, `1. Async TFF Down`, `1.Async TFF Up`, `3. Async DFF Up`, `2bit UD counter`, `74160`, `Gray_counter\graycode` / `08_State machine\fsm_detector_101_alt` / `09_IO_Display\Demo3_BCD_Counter_7Seg` / `10_DigitalClock\DigitalClock` → `_to_delete_중복\` |
| HDL 예제 이동 | `07_Counter\3.Counter`의 하위 6개, `00_Basic\1_Basic_gates`, `01_Combinational\2_Seven_Segments`, `3_Adder` → `11_Verilog\` |
| 기타 이동 | `00_Basic\0.MyFirstProject` → `04_Flipflop\0.MyFirstProject` |
| 이름 변경 | `01_Combinational\FA4_adder` → `FA4_adder_withSegments`, `07_Counter\Demo` → `Ten_Counter`, `07_Counter\Demo2_Graycode` → `graycounterUsingdecoder`, `04_Flipflop\WithGates` → `JK_FlipFlop_WithGates` |
| 프로젝트 이름 | `04_Flipflop\T_FlipFlop`의 `jkff_test` → `T_ff` (qpf·qsf·bdf·sof·pof, 최상위 엔티티) |

---

## 🔤 VHDL 예제 분리 (2026-10-30)

VHDL로 된 예제를 `11_VHDL`로 모으고, 번호가 겹치지 않도록 `11_Verilog` → `12_Verilog`, `12_SoC_NIOS_DE1` → `13_SoC_NIOS_DE1`로 바꿨다. 위 절들에 적힌 `11_Verilog`, `12_SoC_NIOS_DE1`은 당시 이름이다.

| 옮긴 것 | 이유 |
| :--- | :--- |
| `12_Verilog`(옛 `11_Verilog`)의 `1_Basic_gates`, `2_Seven_Segments`, `3_Adder`, `3.Counter`, `Counter`, `counter2`, `mod16up`, `Clk_Test`, `DisplaySegment` | VHDL 소스만 있는 프로젝트 |
| `01_Combinational\FA4_adder_withSegments\VHDL\adder_4b` → `11_VHDL\adder_4b` | 4비트 가산기의 VHDL판 |
| `09_IO_Display\uart_tx_rx`, `seg7_decoder`, `seg7_de1soc` | 회로도가 있지만 최상위 엔티티가 VHDL인 프로젝트 |

회로도가 최상위이고 VHDL은 분주기 같은 하위 블록으로만 쓰는 프로젝트(`BCD_Counter_7Seg`, `eightcounter`, `Ten_Counter`, `10_DigitalClock` 등)는 제자리에 두었다.

---

## 📦 보충 폴더 분리 (2026-10-30)

`00_Basic`~`07_Counter`에서 교재 절 번호 예제, 강의 슬라이드 예제, 개념마다 대표 예제를 남기고, 나머지를 `14_보충\<원래 폴더>\`로 옮겼다.

| 옮긴 예제 | 이유 |
| :--- | :--- |
| `00_Basic\switch_input_de2` | 스위치를 LED에 잇기만 하는 보드 입출력 확인 |
| `01_Combinational\adder_full_with_accumulator` | 레지스터가 들어간 누산기라 조합회로 범위를 넘음 |
| `04_Flipflop\0.MyFirstProject`, `JK_FlipFlop`, `T_FlipFlop` | FF 소자 하나만 시험, `4_1_2_basic_flipflops`에 모두 포함 |
| `05_Shift registers\SISO_Register` | `4_2_1_siso_reg`와 같은 회로 |
| `05_Shift registers\shiftreg_74ls74_bdf` | 74LS74 내부 게이트 모델 |
| `06_Ripplecounter\3bits_ripple down`, `3bits_ripple falling edge` | `RippleCounter`의 4_3_2·3bit_ripple과 겹침 |
| `07_Counter\1.3digits with decoder`, `4digits using 7447` | 다자리 표시 변형, `2digits using 7447`과 `10_DigitalClock`으로 대표 |
| `07_Counter\3bits counter with t syn` | `3. 동기식 TFF Down`, `6_2_3bit_counter`와 겹침 |
| `07_Counter\4.Digital Safe` | `05\4_2_6_digital_locker_reg`와 같은 주제 |
| `07_Counter\Gray_counter` | `graycounterUsingdecoder`와 같은 설계 |
| `07_Counter\Ten_Counter`, `counter_de1soc_my_first_fpga` | VHDL 블록 조합·Intel 튜토리얼로 게이트·FF 수준 학습이 아님 |
| `07_Counter\Mod50MHz.bsf` | 최상위에 따로 놓인 심볼 파일 |

`05_Shift registers\SIPO_Register`의 프로젝트(zip)는 `4_2_2_sipo_reg\SIPO_Register\`로 옮겨 그림과 짝을 맞췄다.

---

## 🔁 08_State machine 같은 회로 묶기 (2026-10-30)

같은 회로에 시뮬레이션 파형만 다른 예제는 이름 앞부분을 같게 맞췄다.

| 묶음 | 이전 이름 → 새 이름 | 차이 |
| :--- | :--- | :--- |
| 101 검출기 (D_A = X'·Q_B, D_B = X, Z = Q_A·X) | `Design14_1` → `detector_101_ch14_1` | 상승 에지, 클리어 있음 |
| | `Demo4_Seq_detector` → `detector_101_demo4` | ch14_1과 같은 회로, 배치·파형만 다름 |
| | `fsm_detector_101` → `detector_101_negedge` | 클록에 NOT을 넣은 하강 에지판, 클리어 없음 |
| 순차회로 해석 예제 1 | `5_sequential_circuit_analysis` (그대로) | 74112로 구현 |
| | `seq_jkff_exam` → `5_sequential_circuit_analysis_jkff` | JKFF+NOT으로 구현, 파형 2개 |

`Sequential logic circuit example`은 `5_sequential_circuit_analysis`와 회로·파형까지 같은 사본이라 `_to_delete_중복`으로 옮겼다.

---

## 🏷️ 하위 폴더 이름 통일 (2026-10-30)

상위 폴더(00_~14_)는 그대로 두고, 하위 폴더 이름을 영문 소문자 snake_case로 맞추고 교재 절 번호(`4_1_2_` 등)를 뺐다. 형식은 `주제_규모_구현_변형`, 쓰인 74xx 부품 번호는 맨 뒤에 붙였다. 위 절들에 적힌 이름은 당시 이름이며, 전체 대응표는 `_ops\move_log.tsv`의 `rename` 줄에 있다.

| 폴더 | 이름 예 |
| :--- | :--- |
| 04_Flipflop | `4_1_2_basic_flipflops` → `basic_flipflops`, `SR_FlipFlop` → `gated_latch_sr_d`, `JK_FlipFlop_WithGates` → `ff_gate_level_d_jk_t` |
| 05_ShiftRegister | `4_2_1_siso_reg` → `shiftreg_siso`, `74194` → `shiftreg_universal_74194` |
| 06_RippleCounter | `RippleCounter\4_3_x_…`를 한 단계 위로 올려 `ripple_counter_3bit_down` 등, `eightcounter` → `ripple_counter_mod10_74112` |
| 07_Counter | `6_3_syn_4bit_counter` → `sync_counter_4bit_jk`, `2. Sync DFF Up` → `sync_counter_3bit_dff_up` |
| 08_State machine | `detector_101_ch14_1` → `detector_101`, `seq_jkff_decoder_74138` → `gray_counter_74138_or_design` |
| 10_DigitalClock | `Set_Clock_90`/`_92` → `clock_set_7490`/`_7492`(쓰인 카운터 IC 기준) |
| 11_VHDL | `3.Counter` → `counter_lpm_bcd_7seg`, `Counter` → `counter_structural_bcd_7seg`, `counter2` → `counter_process_basic` |

폴더를 옮긴 것: `07_Counter\3bit ripple counter syn` → `06_Ripplecounter\ripple_counter_3bit_nor_reset`(리플 구조), `08_State machine\fsm_jkff_ex10_19` → `04_Flipflop\latch_vs_ff`(D래치·DFFE·JKFF 비교).
`13_SoC_NIOS_DE1`과 `14_보충`의 예제 폴더 이름은 바꾸지 않았다.

최상위 폴더도 공백을 없앴다: `05_Shift registers` → `05_ShiftRegister`, `06_Ripplecounter` → `06_RippleCounter`(`14_보충` 안의 같은 폴더도 함께). `08_State machine` → `08_StateMachine`, `5_sequential_circuit_analysis` → `seq_analysis_jk_74112`도 마쳤다.

---

## 🗑️ 12_Verilog 정리 (2026-10-30)

`12_Verilog`의 Verilog 예제 3개(`hello_world_verilog`, `counter_verilog_first`, `ps2_keyboard`)는 교재 `Digital_Textbook\3_labs\code`로 옮길 만한 것이 없어 `_to_delete_불필요\`로 옮기고, 빈 `12_Verilog` 폴더를 지웠다. Hello World와 4비트 카운터는 교재 부록 C·G와 Lab 09(`sync4.v`)가 이미 다루고, PS/2 키보드는 DE1-SoC가 아닌 4자리 애노드 구동 보드용이라 실습 범위 밖이다.

---

## 🧾 격리 폴더 삭제 (2026-10-30)

정리 과정에서 모아 둔 `_to_delete_중복`(중복 사본)과 `_to_delete_불필요`(검토에서 뺀 예제)를 삭제했다. 지운 항목 목록은 `_ops\deleted_list.txt`, 전체 이동·이름 변경 기록은 `_ops\move_log.tsv`, 회로도 그림 변환 스크립트는 `_ops\bdf2png.py`에 있다. 위 절들에서 `_to_delete_…`로 옮겼다고 적힌 항목은 모두 삭제되었다.

---

## 📚 관련 자료
*   [Quartus 강의 자료](https://docs.google.com/document/d/18SPKDoWC6wiWRv3qgELFiMcgOY7u5xflKEo1A7NmJGI/edit)
*   [메인 README.md로 돌아가기](../README.md)
