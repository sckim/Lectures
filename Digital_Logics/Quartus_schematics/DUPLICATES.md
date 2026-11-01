# Quartus_schematics 중복 목록

> **2026-10-30 처리 완료.** 아래 A표의 정리 후보와 B표의 `1.3bit ripple down cnt`, 교재 번호 폴더 사본(`6_Counter\3bits_Counter`, `BCD_Counter`, `3bits_UpDown_Counter`, `7.State machine\Design_Sequential_Circuit`)을 `_to_delete_중복\`으로 옮겼다. 1번은 `Gray_counter`가 JK-FF 카운터이므로 `6_Counter` 쪽을 남기고 `1_Combinational/Graycode`를 격리했다. 7번은 `6_Counter` 쪽을 남겨 `6_3_syn_4bit_counter` 안으로 옮겼다. 9·10·12번의 `0_Basic` 사본은 이미 없었다. 같은 날 사용자 지시로 `6_Counter/GrayCounter_NOT`(NAND판과 회로도 동일), `6_Counter/4digits using 7447.txt`(2012년판 zip), `4_Flipflop/T_FlipFlop/tff.bdf`(`jkff_test.bdf` 사본, qsf 등록 줄도 삭제)를 삭제했다. 재조사 결과 격리 폴더 밖에는 프로젝트 단위 중복이 남아 있지 않다. 아래 표의 경로는 정리 전 기준이다. 같은 날 최상위 폴더 번호를 두 자리로 바꿨다(`0_Basic` → `00_Basic`, `7.State machine` → `07_State machine` 등). 이어서 05 중복을 없애려고 `05_Shift registers`를 두고 리플카운터부터 번호를 하나씩 미뤘다(`06_Ripplecounter` … `12_SoC_NIOS_DE1`).

## A. 폴더 단위 중복 (2026-10-29 재조사)

설계 소스(.bdf/.v/.vhd/.vwf/.bsf 등)를 MD5로 비교한 결과다. db·output_files·desktop.ini는 비교에서 뺐다. 아직 아무것도 지우거나 옮기지 않았다.

| # | 남길 폴더 (권장) | 정리 후보 | 차이 | 크기 |
|---|---|---|---|---|
| 1 | `1_Combinational/Graycode` | `6_Counter/Gray_counter` | 완전히 같다 | 13.5 MB |
| 2 | `5_Ripplecounter/RippleCounter/4_3_1_ripple_up_counter/Ripple up counter` | `6_Counter/Ripple up counter` | desktop.ini만 다르다 | 0.3 MB |
| 3 | `5_Ripplecounter/RippleCounter/4_3_2_ripple_down_counter/Ripple down counter` | `6_Counter/Ripple down counter` | desktop.ini만 다르다 | 0.3 MB |
| 4 | `5_Ripplecounter/RippleCounter/4_3_3_ripple_up_down_counter/Ripple up down counter` | `6_Counter/Ripple up down counter` | desktop.ini만 다르다 | 0.3 MB |
| 5 | `5_Ripplecounter/RippleCounter/4_3_4_modulom_ripple_counter/Modulo-m ripple counter` | `6_Counter/Modulo-m ripple counter` | desktop.ini만 다르다 | 0.3 MB |
| 6 | `5_Ripplecounter/RippleCounter/3bit ripple` | `6_Counter/3bit ripple` | 완전히 같다 | 3.0 MB |
| 7 | `5_Ripplecounter/3.Counter/4bits_Counter` | `6_Counter/4bits_Counter` | 완전히 같다 | 0.4 MB |
| 8 | `5_Ripplecounter/3.Counter/2bits_Counter` (Quartus 18.1) | `6_Counter/2bits_Counter` (Quartus 9.1) | qsf의 버전 줄만 다르다 | 3.0 MB |
| 9 | `4_Flipflop/4_1_7_debouncing_circuit` | `0_Basic/Debounce_Circuit` | ※ | 2.9 MB |
| 10 | `4_Flipflop/4_1_3_master_slave_ff` | `0_Basic/MasterSlave_SR_FF` | ※ | 2.9 MB |
| 11 | `4_Flipflop/4_1_3_1_master_slave_ff_subblock` | `0_Basic/MasterSlave_SR_FF(Ver.Subblock)` | ※ | 36 KB |
| 12 | `4_Flipflop/4_1_2_basic_flipflops` | `0_Basic/Total_FF_ExampleCollection(SR,JK,D,T)` | ※ | 3.0 MB |
| 13 | `5_Shift registers/4_2_6_digital_locker_reg` | 최상위 `Digital_StrongBox` (zip만 있음) | 압축본이다 | 0.4 MB |
| 14 | `5_Shift registers/4_2_7_random_num_gen_reg` | `7.State machine/RandomNumber_Generator` (zip만 있음) | 압축본이다 | 0.3 MB |

※ `4_x_x` 번호 폴더는 교재 절 번호로 다시 만든 사본이다. 회로도·파형 캡처 `.png`가 있지만 `.qsf`(핀 할당)와 `.sof`/`.pof`가 없다. 정리하기 전에 `0_Basic` 쪽 `.qsf`/`.sof`를 번호 폴더로 옮겨야 한다.

표의 정리 후보를 모두 치우면 약 30 MB가 줄어든다.

## B. 확인이 필요한 항목 (자동 정리 대상 아님)

| 항목 | 상태 | 판단 |
|---|---|---|
| `6_Counter/0.3bit ripple up cnt` ↔ `6_Counter/1.3bit ripple down cnt` | 두 폴더가 완전히 같다 | down 폴더에 up 회로가 복사된 것으로 보인다. 다운 카운터 원본을 잃었을 수 있다 |
| `5_Ripplecounter/RippleCounter/3bit ripple` ↔ `3bit_ripple` | 주 회로도만 같다. vwf·qsf가 다르고 `3bit_ripple`에는 `ripple_counter.bdf`가 더 있다 | 별개 판이므로 둘 다 남긴다 |
| `6_Counter/GrayCounter_NAND` ↔ `6_Counter/GrayCounter_NOT` | 회로도가 같다 | NOT판에 NAND 회로가 들어간 것으로 보인다 |
| `4_Flipflop/T_FlipFlop`의 `jkff_test.bdf` = `tff.bdf` | 한 프로젝트 안의 사본이다 | 파일 하나만 정리하면 된다 |
| `1_Combinational/FA4_adder` ↔ 그 안의 `Schematics/` | 반가산기·전가산기 bdf가 겹친다 | 프로젝트 구조상 필요할 수 있다 |
| `SixCnt.bdf`(5곳), `Counter.bdf`(3곳) | 여러 프로젝트가 같은 하위 블록을 쓴다 | 각 프로젝트에 필요하므로 그대로 둔다 |
| Nios II `*_bsp/HAL`(7곳), `drivers` | 자동 생성 BSP이다 | 프로젝트마다 필요하므로 그대로 둔다 |

## C. 파일 단위 중복 .bdf 목록 (2026-10-10 조사)

내용(MD5)이 완전히 같은 `.bdf` 묶음 16개다. 프로젝트 단위 중복(0_Basic↔4_Flipflop, 5_Ripplecounter↔6_Counter, 1_Combinational/Graycode↔6_Counter/Gray_counter)과 한 프로젝트 안의 사본이 섞여 있다. 아직 아무것도 지우지 않았다.

- **2개 동일**
  - `1_Combinational/Graycode/graycode.bdf`
  - `6_Counter/Gray_counter/graycode.bdf`
- **2개 동일**
  - `4_Flipflop/T_FlipFlop/jkff_test.bdf`
  - `4_Flipflop/T_FlipFlop/tff.bdf`
- **2개 동일**
  - `1_Combinational/FA4_adder/Schematics/fulladder.bdf`
  - `1_Combinational/FA4_adder/fulladder.bdf`
- **2개 동일**
  - `5_Ripplecounter/3.Counter/2bits_Counter/2bits_counter/2bits_counter.bdf`
  - `6_Counter/2bits_Counter/2bits_counter/2bits_counter.bdf`
- **2개 동일**
  - `6_Counter/3bits counter with t syn/3bit counter.bdf`
  - `6_Counter/3bits counter with t syn/3bit_counter.bdf`
- **2개 동일**
  - `0_Basic/MasterSlave_SR_FF/MasterSlave_SRFF/MasterSlave_SR_FF.bdf`
  - `4_Flipflop/4_1_3_master_slave_ff/MasterSlave_SR_FF/MasterSlave_SRFF/MasterSlave_SR_FF.bdf`
- **2개 동일**
  - `0_Basic/Debounce_Circuit/Debounce_Circuit/Debouce.bdf`
  - `4_Flipflop/4_1_7_debouncing_circuit/Debounce_Circuit/Debouce.bdf`
- **2개 동일**
  - `6_Counter/GrayCounter_NAND/GrayCounter.bdf`
  - `6_Counter/GrayCounter_NOT/GreyCounter.bdf`
- **2개 동일**
  - `1_Combinational/Graycode/graycode/graycode.bdf`
  - `6_Counter/Gray_counter/graycode/graycode.bdf`
- **2개 동일**
  - `1_Combinational/FA4_adder/Schematics/halfadder.bdf`
  - `1_Combinational/FA4_adder/halfadder.bdf`
- **6개 동일**
  - `5_Ripplecounter/RippleCounter/3bit ripple/3bit_ripple.bdf`
  - `5_Ripplecounter/RippleCounter/3bit_ripple/3bit_ripple.bdf`
  - `6_Counter/0.3bit ripple up cnt/3bit_ripple.bdf`
  - `6_Counter/1.3bit ripple down cnt/3bit_ripple.bdf`
  - `6_Counter/3bit ripple/3bit_ripple.bdf`
  - `Tutorial/Tutorial.bdf`
- **2개 동일**
  - `5_Shift registers/74194/piso.bdf`
  - `5_Shift registers/PISO_74165/piso.bdf`
- **5개 동일**
  - `6_Counter/0.3digits using 7447/SixCnt.bdf`
  - `6_Counter/1.3digits with VHDL/SixCnt.bdf`
  - `6_Counter/1.3digits with decoder/SixCnt.bdf`
  - `6_Counter/2. 3digits with VHDL/SixCnt.bdf`
  - `6_Counter/4digits using 7447/SixCnt.bdf`
- **2개 동일**
  - `0_Basic/Total_FF_ExampleCollection(SR,JK,D,T)/Total_FF_ExampleCollection/ExampleCollection.bdf`
  - `4_Flipflop/4_1_2_basic_flipflops/Total_FF_ExampleCollection(SR,JK,D,T)/Total_FF_ExampleCollection/ExampleCollection.bdf`
- **3개 동일**
  - `6_Counter/2. 3digits with VHDL/Counter.bdf`
  - `6_Counter/4digits using 7447/Counter.bdf`
  - `DigitalClock/Counter.bdf`
- **3개 동일**
  - `5_Ripplecounter/RippleCounter/3bit ripple/3bit_ripple_down.bdf`
  - `5_Ripplecounter/RippleCounter/3bit_ripple/3bit_ripple_down.bdf`
  - `6_Counter/3bit ripple/3bit_ripple_down.bdf`
