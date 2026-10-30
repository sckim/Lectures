# Quartus 예제 — 강의 슬라이드별 정리

디지털논리회로 강의08~11 Google Slides에 대응하는 Quartus 예제를 강의별로 모은 폴더이다. 폴더 이름은 `슬라이드 제목_페이지번호`이고, 폴더 안 파일 이름은 원본 그대로이다. 원본은 `Quartus_schematics`에 있으며, db·incremental_db·simulation 폴더는 재생성되므로 제외했다.

자료 구분:
- **슬라이드 화면**: 슬라이드에 실린 Quartus 화면과 창 제목·핀 이름으로 대조해 찾은 프로젝트이다.
- **회로도·시뮬레이션**: 회로도 이미지(`*schematic*`)와 시뮬레이션 결과 이미지가 모두 있는 예제를 슬라이드 주제에 맞춰 배정한 것이다.
- `*_schematic.png` 가운데 원본 캡처가 없던 것은 .bdf를 직접 읽어 그린 그림이다(Quartus 화면 캡처 아님).

## 강의08_플립플롭

| 폴더 | 내용 | 구분 | 원본 (Quartus_schematics) |
|---|---|---|---|
| `01. 기본적인 플립플롭_22` | NOR S-R 래치 | 회로도·시뮬레이션 | `4_Flipflop/SR_Latch` |
| `Switch Debouncing with an S-R Latch_34` | NAND 래치 디바운스 회로 | 회로도·시뮬레이션 | `4_Flipflop/4_1_7_debouncing_circuit` |
| `3. 주종형 S-R 플립플롭_59` | NAND 게이트 주종형 S-R FF | 회로도·시뮬레이션 | `4_Flipflop/4_1_3_master_slave_ff` |
| `3. 주종형 S-R 플립플롭_60` | SR_FF 블록 2개로 만든 주종형 FF | 회로도·시뮬레이션 | `4_Flipflop/4_1_3_1_master_slave_ff_subblock` |
| `11.9 Summary_135` | SR·JK·D·T 플립플롭 모음 | 회로도·시뮬레이션 | `4_Flipflop/4_1_2_basic_flipflops` |

## 강의09_레지스터

| 폴더 | 내용 | 구분 | 원본 (Quartus_schematics) |
|---|---|---|---|
| `1. 4비트 직렬입력-직렬출력 레지스터 구조_18` | 4비트 SISO(DFF), 8비트 7491 | 회로도·시뮬레이션 | `5_Shift registers/4_2_1_siso_reg` |
| `Right-Shift Register_23` | 4비트 우측 시프트 레지스터(DFFE) | 슬라이드 화면 (창 제목 `rightshift.sim.vwf`) | `5_Shift registers/RightShift` |
| `74LS164(8-Bit Parallel Output Serial Shift Registers)_31` | 74164 SIPO | 회로도·시뮬레이션 | `5_Shift registers/4_2_2_sipo_reg` |
| `1. 디지털 금고_76` | 디지털 금고 | 회로도·시뮬레이션 | `5_Shift registers/4_2_6_digital_locker_reg` |
| `3. 난수발생회로_79` | 난수 발생 회로 | 회로도·시뮬레이션 | `5_Shift registers/4_2_7_random_num_gen_reg` |

## 강의10_비동기식_카운터

| 폴더 | 내용 | 구분 | 원본 (Quartus_schematics) |
|---|---|---|---|
| `12.3 Design of Binary Counters_7` | 3비트 리플 상향 카운터 | 회로도·시뮬레이션 | `5_Ripplecounter/RippleCounter/4_3_1_ripple_up_counter` |
| `12.3 Design of Binary Counters_7_14` | 3비트 리플 상향(`3bit_ripple.bdf`, p.7)·MOD-8 하향(`3bit_ripple_down.bdf`, p.14) | 슬라이드 화면 (핀 n_cp, ClrN, Q[2..0]) | `5_Ripplecounter/RippleCounter/3bit ripple` |
| `MOD-8 리플 다운 카운터_14` | 리플 하향 카운터 | 회로도·시뮬레이션 | `5_Ripplecounter/RippleCounter/4_3_2_ripple_down_counter` |
| `3. 비동기 상향-하향 카운터_24` | 리플 상향/하향 카운터 | 회로도·시뮬레이션 | `5_Ripplecounter/RippleCounter/4_3_3_ripple_up_down_counter` |
| `4. modulo-m 비동기 카운터_26` | modulo-m 리플 카운터 | 회로도·시뮬레이션 | `5_Ripplecounter/RippleCounter/4_3_4_modulom_ripple_counter` |
| `0, 1, 2, …,8,9, 0, 1, 2, … 카운터_29` | 0~9 카운터(74112×4, 7400) | 슬라이드 화면 (창 제목 `eightcounter.sim.vwf`) | `6_Counter/eightcounter` |

## 강의11_동기순서논리회로

| 폴더 | 내용 | 구분 | 원본 (Quartus_schematics) |
|---|---|---|---|
| `Quartus II 사용법 및 DE2 보드 (docs)_10` | 순차회로 해석(DFF 2개) | 슬라이드 화면 (창 제목 `Seq_Analysis1`) | `7.State machine/seq_analysis_dff` |
| `Example 1 (Quartus II)_14` | Example 1/2 (74112, SetN·Cp·A) | 슬라이드 화면·회로도·시뮬레이션 | `7.State machine/5_sequential_circuit_analysis` |
| `Example 1 (Quartus II)_15` | 같은 회로의 JKFF 기본소자판 (p.15·17 창 제목 `Example1.sim.vwf`) | 슬라이드 화면 | `7.State machine/seq_jkff_exam` |
| `7. 논리 회로의 구현_60` | J-K FF 동기 순차회로 설계(x, A, B) | 회로도·시뮬레이션 | `7.State machine/6_sequential_circuit_design` |
| `예제 9-4. 그레이 코드 카운터 회로도_120` | 74138+JKFF 그레이 코드 카운터 | 슬라이드 화면 (핀 clk, q[2..0]) | `7.State machine/seq_jkff_decoder_74138` |

## 슬라이드_미대응

동기식 카운터 예제로, 강의08~11 슬라이드에 대응하는 페이지가 없다.

| 폴더 | 원본 (Quartus_schematics) |
|---|---|
| `6_1_2bit_counter` | `5_Ripplecounter/3.Counter/6_1_2bit_counter` |
| `6_2_3bit_counter` | `5_Ripplecounter/3.Counter/6_2_3bit_counter` |
| `4bits_Counter` | `6_Counter/4bits_Counter` |
| `6_4_syn_bcd_counter` | `6_Counter/6_4_syn_bcd_counter` |
| `6_5_syn_3bit_updown_counter` | `6_Counter/6_5_syn_3bit_updown_counter` |

## 이름 규칙 메모
- 강의10 p.24 원래 제목 "3. 비동기 상향/하향 카운터"의 `/`는 폴더 이름에 쓸 수 없어 `-`로 바꾸었다.
- 제목이 없는 페이지(강의09 p.23, 강의11 p.120)는 앞 페이지의 제목을 썼다.
- `_7_14`는 강의10 p.7과 p.14의 회로가 한 프로젝트에 있어 두 페이지를 함께 적은 것이다.
- 강의09 p.18 폴더의 8비트 7491 예제는 강의09 p.24 "74LS91(8-Bit Shift Register)"에 해당한다.
- 강의08 p.135(11.9 Summary)는 플립플롭 4종 모음 예제를 배정한 것이다.

## 찾지 못한 것
- 강의08 p.95: NAND3로 만든 주종형 J-K 플립플롭(PreN·ClrN·CP·J·K → Q·notQ)은 `Quartus_schematics`에 해당 프로젝트가 없다.

## 같은 회로라 넣지 않은 것 (같은 .bdf)
- `6_Counter/3bits_Counter` = `5_Ripplecounter/3.Counter/6_2_3bit_counter`
- `6_Counter/6_3_syn_4bit_counter`, `5_Ripplecounter/3.Counter/4bits_Counter` = `6_Counter/4bits_Counter` (6_3은 프로젝트가 없어 프로젝트가 있는 4bits_Counter를 남김)
- `6_Counter/BCD_Counter` = `6_Counter/6_4_syn_bcd_counter`
- `6_Counter/3bits_UpDown_Counter` = `6_Counter/6_5_syn_3bit_updown_counter`
- `7.State machine/Design_Sequential_Circuit` = `7.State machine/6_sequential_circuit_design`
- `6_Counter/3bit ripple` = `5_Ripplecounter/RippleCounter/3bit ripple`
- `1_Combinational/Graycode`, `Demo2/Graycode.bdf`도 74138+JKFF+OR2 그레이 코드 카운터 구성이다.
