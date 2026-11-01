# Quartus 예제 — 강의 슬라이드별 정리

디지털논리회로 강의08~11 Google Slides에 대응하는 Quartus 예제를 강의별로 모은 폴더이다. 폴더 이름은 `슬라이드 제목_페이지번호`이고, 폴더 안 파일 이름은 원본 그대로이다. 원본은 `Quartus_schematics`에 있으며, db·incremental_db·simulation 폴더는 재생성되므로 제외했다.

이 문서는 폴더 구성과 함께, 예제마다 회로 구성·동작 원리·시뮬레이션에서 확인할 점을 정리한 것이다.

| 강의 | 주제 | 예제 수 | 핵심 소자 |
|---|---|---|---|
| 강의08 | 플립플롭 | 5 | NOR/NAND 래치, 주종형 S-R, JK·D·T FF |
| 강의09 | 레지스터 | 5 | DFF, DFFE, 7491, 74164 |
| 강의10 | 비동기식 카운터 | 6 | JKFF, 74112, 7400 |
| 강의11 | 동기 순서논리회로 | 5 | DFF, JKFF, 74112, 74138 |
| 슬라이드 미대응 | 동기식 카운터 | 5 | JKFF, AND/OR 게이트 |

자료 구분:
- **슬라이드 화면**: 슬라이드에 실린 Quartus 화면과 창 제목·핀 이름으로 대조해 찾은 프로젝트이다.
- **회로도·시뮬레이션**: 회로도 이미지(`*schematic*`)와 시뮬레이션 결과 이미지가 모두 있는 예제를 슬라이드 주제에 맞춰 배정한 것이다.
- `*_schematic.png` 가운데 원본 캡처가 없던 것은 .bdf를 직접 읽어 그린 그림이다(Quartus 화면 캡처 아님).
- 일부 예제는 프로젝트가 .zip으로만 들어 있다. 압축을 풀고 .qpf를 열면 된다.
- 시뮬레이션 설명의 시각(예: "약 3 µs")은 캡처 화면에서 읽은 대략값이다.

---

## 강의08_플립플롭

| 폴더 | 내용 | 구분 | 원본 (Quartus_schematics) |
|---|---|---|---|
| `01. 기본적인 플립플롭_22` | NOR S-R 래치 | 회로도·시뮬레이션 | `4_Flipflop/SR_Latch` |
| `Switch Debouncing with an S-R Latch_34` | NAND 래치 디바운스 회로 | 회로도·시뮬레이션 | `4_Flipflop/4_1_7_debouncing_circuit` |
| `3. 주종형 S-R 플립플롭_59` | NAND 게이트 주종형 S-R FF | 회로도·시뮬레이션 | `4_Flipflop/4_1_3_master_slave_ff` |
| `3. 주종형 S-R 플립플롭_60` | SR_FF 블록 2개로 만든 주종형 FF | 회로도·시뮬레이션 | `4_Flipflop/4_1_3_1_master_slave_ff_subblock` |
| `11.9 Summary_135` | SR·JK·D·T 플립플롭 모음 | 회로도·시뮬레이션 | `4_Flipflop/4_1_2_basic_flipflops` |

두 게이트의 출력을 서로의 입력으로 되먹임하면 1비트를 기억하는 래치가 되고, 여기에 클럭 제어를 더하면 플립플롭이 된다. 강의08 예제 5개는 이 과정을 래치 → 디바운스 응용 → 주종형 FF → FF 4종 순서로 보여 준다.

### NOR S-R 래치 (`01. 기본적인 플립플롭_22`, SR_Latch.bdf)

![NOR S-R 래치](<강의08_플립플롭/01. 기본적인 플립플롭_22/4_1_1_sr_latch_schematic.png>)

![NOR S-R 래치 시뮬레이션](<강의08_플립플롭/01. 기본적인 플립플롭_22/4_1_1_sr_latch_vwf_sim.png>)

회로: NOR2 2개를 교차 결합했다. S는 위쪽 NOR(출력 /Q), R은 아래쪽 NOR(출력 Q)에 들어가고, 각 NOR의 나머지 입력은 상대 게이트의 출력이다.

동작: NOR는 입력에 1이 하나라도 있으면 0을 내므로, S=1이면 /Q=0이 되고 이것이 아래 NOR로 돌아가 Q=1이 된다. 입력이 모두 0으로 돌아와도 되먹임 때문에 Q=1이 유지된다.

| S | R | Q(다음) | 의미 |
|---|---|---|---|
| 0 | 0 | Q | 유지 |
| 0 | 1 | 0 | 리셋 |
| 1 | 0 | 1 | 셋 |
| 1 | 1 | 0 (Q=/Q=0) | 금지 |

시뮬레이션: R=1로 Q=0에서 시작하고, R이 0이 된 뒤에도 Q=0을 유지한다. 약 2.2 µs에 S=1이 되면 Q=1로 바뀌고, S가 다시 0이 되어도 Q=1이 남는 것을 확인한다.

### NAND 래치 스위치 디바운스 (`Switch Debouncing with an S-R Latch_34`, Debouce.bdf)

![NAND 래치 디바운스](<강의08_플립플롭/Switch Debouncing with an S-R Latch_34/4_1_7_debouncing_circuit_schematic.png>)

![NAND 래치 디바운스 시뮬레이션](<강의08_플립플롭/Switch Debouncing with an S-R Latch_34/4_1_7_debouncing_circuit_vwf_sim.png>)

회로: NAND2 2개를 교차 결합한 /S-/R 래치다. 입력은 S_bar, R_bar(액티브 로우), 출력은 Q, Q_bar이다.

동작: NAND 래치는 0이 들어오는 순간 셋·리셋되고, 두 입력이 1이면 상태를 유지한다. 기계식 스위치는 접점이 붙는 순간 수 ms 동안 튀지만(바운스), 첫 0에서 이미 상태가 바뀌고 이후의 0↔1 반복은 '유지' 또는 같은 '셋'이라 출력이 한 번만 바뀐다.

| S_bar | R_bar | Q | 의미 |
|---|---|---|---|
| 1 | 1 | Q | 유지 |
| 0 | 1 | 1 | 셋 |
| 1 | 0 | 0 | 리셋 |
| 0 | 0 | 1 (Q=Q_bar=1) | 금지 |

시뮬레이션: S_bar와 R_bar에 튀는 펄스 묶음을 넣었다. 약 10 µs의 S_bar 바운스 구간에서 Q는 첫 하강 에지에 한 번만 1로 올라가고, 약 34 µs의 R_bar 바운스에서 한 번만 0으로 내려간다. 이미 셋된 상태에서 들어온 약 23 µs의 S_bar 바운스는 Q를 바꾸지 않는다.

### NAND 게이트 주종형 S-R 플립플롭 (`3. 주종형 S-R 플립플롭_59`, MasterSlave_SR_FF.bdf)

![주종형 S-R FF](<강의08_플립플롭/3. 주종형 S-R 플립플롭_59/4_1_3_master_slave_ff_schematic.png>)

![주종형 S-R FF 시뮬레이션](<강의08_플립플롭/3. 주종형 S-R 플립플롭_59/4_1_3_master_slave_ff_vwf_sim.png>)

회로: NAND2 8개와 NOT 1개로 만든 두 단 구조다.

1. 마스터: inst·inst3가 S·R을 Cp로 게이트하고, inst4·inst5가 NAND 래치를 이룬다. 마스터 출력은 Y, Y_Bar로 따로 내보냈다.
2. 슬레이브: inst6·inst7이 Y·Y_Bar를 NOT Cp(inst10)로 게이트하고, inst8·inst9가 출력 래치(Q, Q_Bar)다.

동작: Cp=1이면 마스터가 S·R을 받아들이고 슬레이브는 닫혀 있다. Cp가 0으로 떨어지면 마스터가 닫히고 슬레이브가 열려 Y가 Q로 전달된다. 따라서 Q는 Cp의 하강 에지에서만 바뀌며, Y와 Q를 함께 보면 '마스터가 먼저, 슬레이브가 반 주기 뒤'에 바뀌는 것을 볼 수 있다.

### SR_FF 블록으로 만든 주종형 FF (`3. 주종형 S-R 플립플롭_60`, zip)

![SR_FF 블록 주종형 FF](<강의08_플립플롭/3. 주종형 S-R 플립플롭_60/4_1_3_1_master_slave_ff_subblock_schematic.png>)

![SR_FF 블록 주종형 FF 시뮬레이션](<강의08_플립플롭/3. 주종형 S-R 플립플롭_60/4_1_3_1_master_slave_ff_subblock_vwf_sim.png>)

앞 회로의 게이트 래치 부분을 `SR_FF` 심볼(.bsf)로 묶어 두 번 쓴 계층형 설계다. 첫 블록(inst)은 CP, 두 번째 블록(inst3)은 NOT CP를 받고, 첫 블록의 Q·/Q가 두 번째 블록의 S·R로 들어간다. 동작은 앞 예제와 같고, 하위 블록을 만들어 재사용하는 Quartus 작업 방법을 익히는 예제다.

### SR·JK·D·T 플립플롭 모음 (`11.9 Summary_135`, ExampleCollection.bdf)

![플립플롭 4종](<강의08_플립플롭/11.9 Summary_135/4_1_2_basic_flipflops_schematic.png>)

![플립플롭 4종 시뮬레이션](<강의08_플립플롭/11.9 Summary_135/4_1_2_basic_flipflops_vwf_sim.png>)

한 파일에 네 회로가 독립적으로 그려져 있다.

| 회로 | 구성 | 트리거 | 동작 |
|---|---|---|---|
| SR | AND2 2개로 S·R을 CP_sr 게이트 + NOR 래치 | 레벨(CP=1) | CP=1일 때만 S-R 래치처럼 동작 |
| JK | JKFF 기본소자, PRN=VCC, CLRN=ClrN_j | 상승 에지 | J=K=0 유지, 10 셋, 01 리셋, J=K=1 토글 |
| D | NAND2 4개 + NOT(D→/D), CP_d 게이트 | 레벨(CP=1) | CP=1이면 Q=D, CP=0이면 유지 |
| T | TFF 기본소자, PRN=VCC, CLRN=ClrN_t | 상승 에지 | T=1이면 토글, T=0이면 유지 |

시뮬레이션에서 확인할 점:
- SR·D는 CP=0인 구간(약 32 µs까지) Q가 X(미정)다. 초기값을 정해 주는 입력이 없기 때문이다. CP=1이 된 뒤에는 Q가 S·R 또는 D를 그대로 따라간다.
- JK·T는 ClrN=0으로 시작해 Q=0이 확정되고, 이후 CP 상승 에지에서만 바뀐다.
- 여기서 SR·D는 엄밀히 게이트형 래치(레벨 트리거)이므로, 에지 트리거인 JK·T와 파형을 비교해 보면 차이가 드러난다.

---

## 강의09_레지스터

| 폴더 | 내용 | 구분 | 원본 (Quartus_schematics) |
|---|---|---|---|
| `1. 4비트 직렬입력-직렬출력 레지스터 구조_18` | 4비트 SISO(DFFE), 8비트 7491 | 회로도·시뮬레이션 | `5_Shift registers/4_2_1_siso_reg` |
| `Right-Shift Register_23` | 4비트 우측 시프트 레지스터(DFFE) | 슬라이드 화면 (창 제목 `rightshift.sim.vwf`) | `5_Shift registers/RightShift` |
| `74LS164(8-Bit Parallel Output Serial Shift Registers)_31` | 74164 SIPO | 회로도·시뮬레이션 | `5_Shift registers/4_2_2_sipo_reg` |
| `1. 디지털 금고_76` | 디지털 금고 | 회로도·시뮬레이션 | `5_Shift registers/4_2_6_digital_locker_reg` |
| `3. 난수발생회로_79` | 난수 발생 회로 | 회로도·시뮬레이션 | `5_Shift registers/4_2_7_random_num_gen_reg` |

레지스터는 같은 클럭을 받는 플립플롭을 줄지어 놓은 것이다. 앞 단 Q를 뒤 단 D에 이으면 클럭마다 데이터가 한 칸씩 이동하는 시프트 레지스터가 되고, 금고와 난수 발생기는 이 구조를 응용한 것이다.

### 4비트 직렬입력-직렬출력(SISO) 레지스터 (`1. 4비트 직렬입력-직렬출력 레지스터 구조_18`, SISO_Register.bdf)

![4비트 SISO](<강의09_레지스터/1. 4비트 직렬입력-직렬출력 레지스터 구조_18/4_2_1_siso_reg_schematic.png>)

![4비트 SISO 시뮬레이션](<강의09_레지스터/1. 4비트 직렬입력-직렬출력 레지스터 구조_18/4_2_1_siso_reg_vwf_simulation.png>)

회로: DFFE(인에이블 붙은 D FF) 4개를 직렬로 잇고, SI → Q3 → Q2 → Q1 → Q0 순서로 데이터가 흐른다. Clock은 4개 FF에 공통, Shift는 모든 ENA에, ClrN은 모든 CLRN에 들어가고 PRN은 VCC다.

동작: Shift=1이면 Clock 상승 에지마다 SI가 Q3에 들어가고 기존 값은 오른쪽(Q0 방향)으로 한 칸 밀린다. Shift=0이면 클럭이 들어와도 값을 유지한다. 직렬 출력은 Q0이며, 입력한 비트는 4클럭 뒤에 Q0에 나타난다.

시뮬레이션: SI=1, 0, 1, 0 순서의 입력이 Q3 → Q2 → Q1 → Q0으로 한 클럭(약 5 µs)씩 늦어져 계단처럼 나타난다.

같은 폴더의 8비트 예제는 **7491**(8비트 SISO 시프트 레지스터) 매크로 하나를 쓴다. 직렬 입력은 A·B의 AND이므로 SI를 A, 쓰기 허용 WR을 B에 넣었다. WR=1인 동안 들어온 SI 비트가 8클럭 뒤 SO(QH)에 그대로 나오고, WR=0이면 0이 채워진다. 시뮬레이션에서 약 3~10 µs에 넣은 패턴이 약 17~27 µs에 SO로 나오는 것을 볼 수 있다.

![8비트 SISO(7491)](<강의09_레지스터/1. 4비트 직렬입력-직렬출력 레지스터 구조_18/4_2_1_1_8bit_siso_reg_schematic.png>)

![8비트 SISO(7491) 시뮬레이션](<강의09_레지스터/1. 4비트 직렬입력-직렬출력 레지스터 구조_18/4_2_1_1_8bit_siso_reg_vwf_simulation.png>)

### 4비트 우측 시프트 레지스터 (`Right-Shift Register_23`, rightshift.bdf)

![우측 시프트 레지스터](<강의09_레지스터/Right-Shift Register_23/rightshift_schematic.png>)

슬라이드 p.23 화면에 나오는 프로젝트다. 회로는 위 SISO와 같은 DFFE 4개 구조(SI, Shift, Clock, ClrN → Q3~Q0)이고, 각 단의 Q를 모두 출력으로 내보내 병렬로도 읽을 수 있다. 데이터가 Q3(왼쪽)에서 Q0(오른쪽)으로 이동하므로 우측 시프트라 부른다.

### 74164 직렬입력-병렬출력(SIPO) 레지스터 (`74LS164(8-Bit Parallel Output Serial Shift Registers)_31`)

![74164 SIPO](<강의09_레지스터/74LS164(8-Bit Parallel Output Serial Shift Registers)_31/4_2_2_sipo_reg_schematic.png>)

![74164 SIPO 시뮬레이션](<강의09_레지스터/74LS164(8-Bit Parallel Output Serial Shift Registers)_31/4_2_2_sipo_reg_vwf_simulation.png>)

회로: **74164** 매크로 하나에 SI→A, WR→B, ClrN→CLRN, Clk→CLK을 물리고, 8개 출력 QA~QH를 모두 핀으로 내보냈다.

동작: 클럭 상승 에지마다 (A AND B)가 QA에 들어가고 QA→QB→…→QH로 밀린다. 8클럭 뒤에는 직렬로 넣은 8비트를 QA~QH에서 한 번에 읽을 수 있다. CLRN=0이면 클럭과 무관하게 모두 0이 된다.

시뮬레이션: 약 15 µs까지는 WR=0이라 SI=1이어도 0만 들어간다. WR=1이 된 뒤 들어온 1 펄스가 QA→QH로 한 클럭씩 내려가고, 약 56 µs에 ClrN=0이 되자 모든 출력이 0이 된다.

### 디지털 금고 (`1. 디지털 금고_76`, Digital_StrongBox.zip)

![디지털 금고](<강의09_레지스터/1. 디지털 금고_76/4_2_6_digital_locker_reg_schematic.png>)

![디지털 금고 시뮬레이션](<강의09_레지스터/1. 디지털 금고_76/4_2_6_digital_locker_reg_vwf_simulation.png>)

회로: DFF 4개를 직렬로 잇고 첫 단 D를 VCC(1)에 물렸다. 각 FF의 클럭은 숫자 버튼 하나씩이다.

| 단 | 클럭 입력 | 역할 |
|---|---|---|
| inst | Three | 1번째 숫자 |
| inst1 | One | 2번째 숫자 |
| inst2 | Nine | 3번째 숫자 |
| inst3 | Zero | 4번째 숫자, Q = Unlock |

나머지 6개 버튼(Two, Four, Five, Six, Seven, Eight)은 NOR6에 들어가고, NOR6 출력이 4개 FF의 CLRN에 공통으로 물린다.

동작: 비밀번호는 **3-1-9-0**이다. Three를 누르면 첫 FF에 1이 저장되고, One을 누르면 그 1이 두 번째 FF로 옮겨지는 식으로 올바른 순서일 때만 1이 끝까지 전달되어 Unlock=1이 된다. 순서가 틀리면 앞 단에 1이 없어 0이 옮겨지고, 비밀번호에 없는 숫자를 누르면 NOR6 출력이 0이 되어 모두 초기화된다.

시뮬레이션: Three(약 3.3 µs) → One(4.1 µs) → Nine(5.1 µs) → Zero(5.9 µs) 순서로 누르자 Zero의 상승 에지에서 Unlock=1이 된다.

### 난수 발생 회로 (`3. 난수발생회로_79`, RandomNumber_Generator.zip)

![난수 발생 회로](<강의09_레지스터/3. 난수발생회로_79/4_2_7_random_num_gen_reg_schematic.png>)

![난수 발생 회로 시뮬레이션](<강의09_레지스터/3. 난수발생회로_79/4_2_7_random_num_gen_reg_vwf_simulation.png>)

회로: DFF 4개를 Qa→Qb→Qc→Qd로 잇고, Qc와 Qd의 XNOR를 첫 단 D로 되돌린 4비트 LFSR(선형 귀환 시프트 레지스터)이다. St는 첫 FF의 PRN에 들어가 시작 값을 정하고, 나머지 PRN·CLRN은 VCC다.

동작: St=0이면 Qa=1이 되어 상태 1000에서 출발한다. 이후 Cp 상승 에지마다 다음과 같이 15개 상태를 돈 뒤 다시 1000으로 돌아온다(QaQbQcQd).

```
1000 → 1100 → 1110 → 0111 → 1011 → 1101 → 0110 → 0011
     → 1001 → 0100 → 1010 → 0101 → 0010 → 0001 → 0000 → 1000
```

XNOR 귀환에서는 1111이 빠지는데, 1111에 들어가면 XNOR(1,1)=1이 되어 빠져나오지 못하는 잠김 상태이기 때문이다. 시뮬레이션 초반의 Qa·Qb·Qc·Qd 파형이 위 순서(1000, 1100, 1110, 0111 …)와 일치한다.

---

## 강의10_비동기식_카운터

| 폴더 | 내용 | 구분 | 원본 (Quartus_schematics) |
|---|---|---|---|
| `12.3 Design of Binary Counters_7` | 3비트 리플 상향 카운터 | 회로도·시뮬레이션 | `5_Ripplecounter/RippleCounter/4_3_1_ripple_up_counter` |
| `12.3 Design of Binary Counters_7_14` | 3비트 리플 상향(`3bit_ripple.bdf`, p.7)·MOD-8 하향(`3bit_ripple_down.bdf`, p.14) | 슬라이드 화면 (핀 n_cp, ClrN, Q[2..0]) | `5_Ripplecounter/RippleCounter/3bit ripple` |
| `MOD-8 리플 다운 카운터_14` | 리플 하향 카운터 | 회로도·시뮬레이션 | `5_Ripplecounter/RippleCounter/4_3_2_ripple_down_counter` |
| `3. 비동기 상향-하향 카운터_24` | 리플 상향/하향 카운터 | 회로도·시뮬레이션 | `5_Ripplecounter/RippleCounter/4_3_3_ripple_up_down_counter` |
| `4. modulo-m 비동기 카운터_26` | modulo-m 리플 카운터 | 회로도·시뮬레이션 | `5_Ripplecounter/RippleCounter/4_3_4_modulom_ripple_counter` |
| `0, 1, 2, …,8,9, 0, 1, 2, … 카운터_29` | 0~9 카운터(74112×4, 7400) | 슬라이드 화면 (창 제목 `eightcounter.sim.vwf`) | `6_Counter/eightcounter` |

비동기식(리플) 카운터는 첫 FF만 외부 클럭을 받고, 나머지는 앞 단 출력을 클럭으로 쓴다. 모든 FF는 J=K=1(토글)이라 클럭 에지마다 반전하고, 각 단은 앞 단의 주파수를 2로 나눈다. 상향·하향은 '어느 에지에서 다음 단을 트리거하느냐'와 'Q와 /Q 중 무엇을 출력으로 보느냐'로 정해진다.

| 하강 에지 FF에서 | 다음 단 클럭 = Q | 다음 단 클럭 = /Q |
|---|---|---|
| 출력 Q | 상향 | 하향 |
| 출력 /Q | 하향 | 상향 |

Quartus의 JKFF 기본소자는 상승 에지 트리거이므로, 예제들은 클럭 앞에 NOT을 넣어 하강 에지 FF처럼 쓴다. 74112는 원래 하강 에지 FF라 NOT이 필요 없다.

### 3비트 리플 상향 카운터 (`12.3 Design of Binary Counters_7`, `_7_14`의 3bit_ripple.bdf)

![3비트 리플 상향 카운터](<강의10_비동기식_카운터/12.3 Design of Binary Counters_7/4_3_1_ripple_up_counter_schematic.png>)

![3비트 리플 상향 카운터 시뮬레이션](<강의10_비동기식_카운터/12.3 Design of Binary Counters_7/4_3_1_ripple_up_counter_vwf_simulation.png>)

회로: JKFF 3개(J=K=PRN=VCC), CLRN은 ClrN 공통. Clk(또는 n_cp) → NOT → inst, Q[0] → NOT → inst1, Q[1] → NOT → inst2 순서로 클럭이 이어진다. 출력은 버스 Q[2..0]이다.

동작: Q[0]은 Clk 하강 에지마다, Q[1]은 Q[0]이 1→0이 될 때마다, Q[2]는 Q[1]이 1→0이 될 때마다 반전한다. 그 결과 000 → 001 → … → 111 → 000을 반복하는 MOD-8 상향 카운터가 된다. 시뮬레이션에서도 Clk 하강 에지마다 Q가 000부터 111까지 1씩 증가한다.

### MOD-8 리플 하향 카운터 (`MOD-8 리플 다운 카운터_14`, `_7_14`의 3bit_ripple_down.bdf)

![MOD-8 리플 하향 카운터](<강의10_비동기식_카운터/MOD-8 리플 다운 카운터_14/4_3_2_ripple_down_counter_schematic.png>)

![MOD-8 리플 하향 카운터 시뮬레이션](<강의10_비동기식_카운터/MOD-8 리플 다운 카운터_14/4_3_2_ripple_down_counter_vwf_simulation.png>)

두 프로젝트 모두 FF 연결은 상향 카운터와 같고, **출력을 /Q로 바꾼** 것만 다르다.
- `3bit_ripple_down.bdf`: 각 FF Q에 NOT(inst9~11)을 달아 Q[2..0]으로 내보냈다.
- `4_3_2_ripple_down_counter`: 다음 단 클럭용 NOT(inst5, inst6)의 출력을 Q[0], Q[1]로 꺼내고, 마지막 단은 NOT(inst9)을 달았다.

동작: 내부 FF는 0→7로 올라가지만 출력은 보수(7−n)이므로 111 → 110 → … → 000 → 111로 내려간다. 시뮬레이션에서 ClrN=0으로 FF를 지우면 출력은 111에서 시작하는 것을 확인한다.

### 비동기 상향/하향 카운터 (`3. 비동기 상향-하향 카운터_24`, zip)

![리플 상향/하향 카운터](<강의10_비동기식_카운터/3. 비동기 상향-하향 카운터_24/4_3_3_ripple_up_down_counter_schematic.png>)

![리플 상향/하향 카운터 시뮬레이션 1](<강의10_비동기식_카운터/3. 비동기 상향-하향 카운터_24/4_3_3_ripple_up_down_counter_vwf_simulation_0.png>)

![리플 상향/하향 카운터 시뮬레이션 2](<강의10_비동기식_카운터/3. 비동기 상향-하향 카운터_24/4_3_3_ripple_up_down_counter_vwf_simulation_1.png>)

회로: JKFF 4개(J=K=VCC)로 만든 4비트 리플 카운터다. 단 사이마다 `2to1mux`가 있어 input0=Q, input1=/Q(NOT) 중 하나를 선택 입력 S로 고르고, 그 출력을 NOT을 거쳐 다음 단 클럭에 넣는다. 출력은 Q[3..0]이다.

동작:
- S=0: 다음 단이 Q의 하강 에지에서 토글 → 상향(0 → 15).
- S=1: 다음 단이 Q의 상승 에지(=/Q의 하강 에지)에서 토글 → 하향(15 → 0).

시뮬레이션 파일은 두 장이다. `_0`은 S=0 상향 동작, `_1`은 S=1 하향 동작을 보여 준다. S를 도중에 바꾸면 멀티플렉서 출력이 변하면서 클럭 에지가 생겨 값이 튈 수 있으므로, S는 동작 전에 정해 두는 것이 좋다.

### modulo-m 비동기 카운터 (`4. modulo-m 비동기 카운터_26`, zip)

![modulo-m 리플 카운터](<강의10_비동기식_카운터/4. modulo-m 비동기 카운터_26/4_3_4_modulom_ripple_counter_schematic.png>)

![modulo-m 리플 카운터 시뮬레이션](<강의10_비동기식_카운터/4. modulo-m 비동기 카운터_26/4_3_4_modulom_ripple_counter_vwf_simulation.png>)

회로: 4비트 리플 상향 카운터(JKFF 4개 + NOT)에 NAND2 하나를 더했다. NAND2 입력은 Q[1]과 Q[3], 출력은 4개 FF의 CLRN에 공통으로 물린다.

동작: 0부터 세다가 1010(10)이 되는 순간 Q3=Q1=1이라 NAND 출력이 0이 되고, 모든 FF가 즉시 0000으로 지워진다. 따라서 0~9를 반복하는 MOD-10 카운터가 된다. 일반적으로 MOD-m은 m의 2진수에서 1인 비트들을 NAND로 묶어 CLRN에 넣으면 된다.

시뮬레이션에서 볼 점: 약 20.5 µs에 Q1에 짧은 스파이크(글리치)가 보인다. 1010 상태가 아주 짧게 나타났다가 클리어되기 때문이며, 비동기 리셋 방식의 특징이다.

### 0~9 카운터, 74112 사용 (`0, 1, 2, …,8,9, 0, 1, 2, … 카운터_29`, eightcounter.bdf)

![0~9 카운터](<강의10_비동기식_카운터/0, 1, 2, …,8,9, 0, 1, 2, … 카운터_29/eightcounter_schematic.png>)

회로는 세 부분으로 나뉜다.
1. 클럭 분주: `Mod50MHz.vhd`는 n_cp 하강 에지마다 q를 0~49,999,999로 세는 카운터다. 보드의 CP_50MHz를 넣고 비트 q[25]를 클럭으로 쓰면 주기 1초(약 1 Hz)의 느린 클럭이 나와, LED로 숫자가 바뀌는 것을 눈으로 볼 수 있다. n_rd는 VCC다.
2. 카운터: 74112(하강 에지 JK FF) 4개의 1번 FF만 쓴다. 1PRN·1J·1K는 VCC, 첫 단 1CLK은 q[25], 다음 단 1CLK은 앞 단 1Q다. 출력은 Qa_LSB, Qb, Qc, Qd_MSB다.
3. 리셋: 7400(NAND) 5개를 직렬로 잇는다. 첫 NAND(inst11)가 Qb·Qd를 받고, 나머지 4개는 입력을 묶어 인버터로 쓴다. 최종 출력은 NAND(Qb, Qd)와 같은 논리이고, 4개 FF의 1CLRN에 들어간다.

동작: 74112는 하강 에지 FF이므로 NOT 없이 Q를 다음 단 클럭에 이어도 상향 카운터가 된다. 1010(10)이 되면 Qd=Qb=1이라 클리어되어 0~9를 반복한다. 인버터 4단은 논리를 바꾸지 않고 리셋 신호에 지연을 더해, 모든 FF가 확실히 지워질 만큼 리셋 펄스를 길게 하는 역할로 볼 수 있다.

---

## 강의11_동기순서논리회로

| 폴더 | 내용 | 구분 | 원본 (Quartus_schematics) |
|---|---|---|---|
| `Quartus II 사용법 및 DE2 보드 (docs)_10` | 순차회로 해석(DFF 2개) | 슬라이드 화면 (창 제목 `Seq_Analysis1`) | `7.State machine/seq_analysis_dff` |
| `Example 1 (Quartus II)_14` | Example 1/2 (74112, SetN·Cp·A) | 슬라이드 화면·회로도·시뮬레이션 | `7.State machine/5_sequential_circuit_analysis` |
| `Example 1 (Quartus II)_15` | 같은 회로의 JKFF 기본소자판 (p.15·17 창 제목 `Example1.sim.vwf`) | 슬라이드 화면 | `7.State machine/seq_jkff_exam` |
| `7. 논리 회로의 구현_60` | J-K FF 동기 순차회로 설계(x, A, B) | 회로도·시뮬레이션 | `7.State machine/6_sequential_circuit_design` |
| `예제 9-4. 그레이 코드 카운터 회로도_120` | 74138+JKFF 그레이 코드 카운터 | 슬라이드 화면 (핀 clk, q[2..0]) | `7.State machine/seq_jkff_decoder_74138` |

순서회로 해석은 '회로도 → FF 입력식 → 상태표 → 상태도', 설계는 그 반대 순서다. 아래 예제들은 회로도에서 입력식을 읽고, 그 식으로 상태 변화를 예측한 뒤 시뮬레이션으로 확인하는 흐름으로 보면 된다. JK FF의 다음 상태는 Q⁺ = J·Q′ + K′·Q, D FF는 Q⁺ = D다.

### 순차회로 해석, DFF 2개 (`Quartus II 사용법 및 DE2 보드 (docs)_10`, Seq_Analysis1.bdf)

![순차회로 해석 DFF](<강의11_동기순서논리회로/Quartus II 사용법 및 DE2 보드 (docs)_10/Seq_Analysis1_schematic.png>)

Quartus 사용법과 DE2 보드 다운로드를 설명할 때 쓰는 예제로, 컴파일 보고서(.rpt)와 핀 파일(.pin)까지 들어 있다.

회로: DFF 2개, 두 FF 모두 D = 자기 /Q(NOT inst2, inst4)다. inst는 NOT Clock(inst5)을, inst3은 Clock을 그대로 클럭으로 받고, ClrN은 두 CLRN에 공통이다.

동작: D=/Q인 DFF는 클럭마다 반전하는 2분주기다. Q1은 Clock 하강 에지, Q2는 상승 에지에서 반전하므로, 둘 다 Clock의 1/2 주파수이면서 서로 반 클럭(90°)씩 어긋난 파형이 된다. 상승·하강 에지 트리거의 차이를 파형으로 비교하기 좋은 회로다.

### Example 1, 74112 버전 (`Example 1 (Quartus II)_14`, Seq_exam.bdf)

![Example 1 74112](<강의11_동기순서논리회로/Example 1 (Quartus II)_14/5_sequential_circuit_analysis_schematic.png>)

![Example 1 74112 시뮬레이션](<강의11_동기순서논리회로/Example 1 (Quartus II)_14/5_sequential_circuit_analysis_vwf_simulation.png>)

회로: 74112 두 개의 1번 FF와 AND2 2개를 쓴다.

| FF | 클럭 | J | K | PRN / CLRN |
|---|---|---|---|---|
| Q0 (inst) | Cp 하강 에지 | 1 | 1 | SetN / 1 |
| Q1 (inst1) | Q0 하강 에지 | J1 = A·Q1 | K1 = A·Q0 | SetN / 1 |

동작:
- SetN=0이면 Q0=Q1=1로 프리셋된다.
- Q0는 J=K=1이라 Cp 하강 에지마다 토글한다.
- Q1은 Q0가 1→0이 되는 순간에만 바뀐다. 그때 Q0=1이므로 K1=A다. A=0이면 J1=K1=0이라 유지하고, A=1이면 Q1=1일 때는 토글(J=K=1), Q1=0일 때는 리셋(J=0, K=1)이라 어느 쪽이든 Q1=0이 된다.
- 한 번 Q1=0이 되면 J1=0이라 다시 SetN을 넣기 전까지 0에 머문다.

시뮬레이션: SetN=0으로 Q0=Q1=1에서 시작한다. 약 3 µs에 A=1이 되면 J1=1이 되고, 약 6 µs에 Q0가 1→0으로 떨어지는 순간 Q1=0이 된 뒤 계속 0을 유지한다. J1·K1을 출력 핀으로 내보내 입력식을 파형으로 직접 확인할 수 있다.

### Example 1, JKFF 기본소자 버전 (`Example 1 (Quartus II)_15`, Example1.bdf)

![Example 1 JKFF](<강의11_동기순서논리회로/Example 1 (Quartus II)_15/Example1_schematic.png>)

같은 회로를 74112 대신 JKFF 기본소자로 다시 그렸다. JKFF는 상승 에지 트리거이므로 클럭 앞에 NOT(inst1: Cp, inst3: Q0)을 넣어 하강 에지 동작을 맞추었다. 입력식(J1 = A·Q1, K1 = A·Q0)과 SetN→PRN 연결은 74112 버전과 같아, 시뮬레이션 결과도 같아야 한다. 두 버전을 비교하면 74 시리즈 매크로와 기본소자의 에지 극성 차이를 익힐 수 있다.

### J-K FF 동기 순차회로 설계 (`7. 논리 회로의 구현_60`, Design_Sequential_Circuit.zip)

![J-K FF 순차회로 설계](<강의11_동기순서논리회로/7. 논리 회로의 구현_60/6_sequential_circuit_design_schematic.png>)

![J-K FF 순차회로 설계 시뮬레이션](<강의11_동기순서논리회로/7. 논리 회로의 구현_60/6_sequential_circuit_design_vwf_simulation.JPG>)

회로: JKFF 2개(A, B)가 Cp 상승 에지를 공통으로 받는 동기식 회로다. 입력은 x, ClrN은 두 CLRN에 공통이다. FF 입력식은 회로도에서 다음과 같이 읽힌다.
- J_A = x′·B (NOT inst4 + AND inst2), K_A = x·B (AND inst3)
- J_B = x, K_B = (A ⊕ x)′ (XNOR inst5)

상태표(현재 AB → 다음 AB):

| 현재 AB | x = 0 | x = 1 |
|---|---|---|
| 00 | 00 | 01 |
| 01 | 10 | 01 |
| 10 | 10 | 11 |
| 11 | 11 | 00 |

동작: x=1이 계속 들어오면 00→01에서 멈추고, x=0이면 01→10으로 넘어간 뒤 10에서 머문다. 다시 x=1이면 10→11, 그다음 x=1이면 11→00으로 돌아온다. 즉 '입력이 바뀌는 패턴'에 따라 00→01→10→11→00을 한 단계씩 진행하는 회로다.

시뮬레이션: Cp 상승 에지마다 그 순간의 x로 위 표를 따라가면 A·B 파형을 그대로 재현할 수 있다. ClrN=0으로 00에서 시작하므로, x=1이 처음 들어온 뒤의 에지에서 B가 먼저 1이 되는 것(00→01)부터 확인하면 된다.

### 74138 + JKFF 그레이 코드 카운터 (`예제 9-4. 그레이 코드 카운터 회로도_120`, seq_decoder.bdf)

![그레이 코드 카운터](<강의11_동기순서논리회로/예제 9-4. 그레이 코드 카운터 회로도_120/seq_decoder_schematic.png>)

회로: 현재 상태 q[2..0]을 74138(3×8 디코더)의 C·B·A에 넣고(G1=VCC, G2AN·G2BN=GND로 항상 동작), 액티브 로우 출력 Y0N~Y7N을 NOT 8개로 뒤집어 최소항 m0~m7을 만든다. 각 JKFF의 J·K는 이 최소항(또는 두 최소항의 OR)이다. clk는 세 FF에 공통이다.

| FF | J | K |
|---|---|---|
| q[2] (inst) | m2 | m4 |
| q[1] (inst2) | m1 | m7 |
| q[0] (inst3) | m0 + m6 (OR inst4) | m3 + m5 (OR inst5) |

동작: 디코더가 현재 상태 하나만 1로 만들고, 그 상태에서 바뀌어야 할 비트 하나의 J(0→1) 또는 K(1→0)만 1이 된다. 따라서 clk 상승 에지마다 한 비트씩만 바뀌는 3비트 그레이 코드를 반복한다(q2 q1 q0).

```
000 → 001 → 011 → 010 → 110 → 111 → 101 → 100 → 000
```

예를 들어 상태 011(m3)에서는 K0 = m3 + m5 = 1이라 q0만 0이 되어 010으로, 상태 010(m2)에서는 J2 = m2 = 1이라 q2만 1이 되어 110으로 간다. 리셋 입력이 없으므로 시뮬레이션은 전원 투입 시의 000에서 시작한다고 보면 된다.

---

## 슬라이드_미대응

동기식 카운터 예제로, 강의08~11 슬라이드에 대응하는 페이지가 없다.

| 폴더 | 원본 (Quartus_schematics) |
|---|---|
| `6_1_2bit_counter` | `5_Ripplecounter/3.Counter/6_1_2bit_counter` |
| `6_2_3bit_counter` | `5_Ripplecounter/3.Counter/6_2_3bit_counter` |
| `4bits_Counter` | `6_Counter/4bits_Counter` |
| `6_4_syn_bcd_counter` | `6_Counter/6_4_syn_bcd_counter` |
| `6_5_syn_3bit_updown_counter` | `6_Counter/6_5_syn_3bit_updown_counter` |

모두 JKFF(상승 에지, PRN=VCC)가 Cp를 공통으로 받고 ClrN이 모든 CLRN에 들어간다. 각 FF를 J=K로 묶어 T FF처럼 쓰고, '아래 비트가 모두 1일 때 토글'하도록 AND로 토글 조건을 만든다. 모든 FF가 동시에 바뀌므로 리플 카운터와 달리 출력이 단계적으로 흐트러지지 않는다.

| 예제 | 토글 조건 (J = K) | 순서 |
|---|---|---|
| `6_1_2bit_counter` | Qa: 1, Qb: Qa | 0 → 3 반복 (MOD-4) |
| `6_2_3bit_counter` | Qa: 1, Qb: Qa, Qc: Qa·Qb | 0 → 7 반복 (MOD-8) |
| `4bits_Counter` | Qa: 1, Qb: Qa, Qc: Qa·Qb, Qd: Qa·Qb·Qc | 0 → 15 반복 (MOD-16) |

![2비트 동기 카운터](<슬라이드_미대응/6_1_2bit_counter/6_1_2bit_counter_schematic.png>)

![2비트 동기 카운터 시뮬레이션](<슬라이드_미대응/6_1_2bit_counter/6_1_2bit_counter_vwf_simulation.png>)

![3비트 동기 카운터](<슬라이드_미대응/6_2_3bit_counter/6_2_3bit_counter_schematic.png>)

![3비트 동기 카운터 시뮬레이션](<슬라이드_미대응/6_2_3bit_counter/6_2_3bit_counter_vwf_simulation.png>)

![4비트 동기 카운터](<슬라이드_미대응/4bits_Counter/4bits_counter_schematic.png>)

![4비트 동기 카운터 시뮬레이션](<슬라이드_미대응/4bits_Counter/4bits_counter_SimulationCaptured.JPG>)

4비트 카운터는 Qa·Qb(inst5) 출력을 다시 Qc와 AND(inst9)해 쓰는 직렬 캐리 구조다. 비트 수가 늘어도 게이트는 AND2 하나씩만 늘어난다.

### 동기식 BCD 카운터 (`6_4_syn_bcd_counter`, BCD_counter.zip)

![동기식 BCD 카운터](<슬라이드_미대응/6_4_syn_bcd_counter/6_4_syn_bcd_counter_schematic.png>)

![동기식 BCD 카운터 시뮬레이션](<슬라이드_미대응/6_4_syn_bcd_counter/6_4_syn_bcd_counter_vwf_simulation.png>)

회로: 4비트 동기 카운터에 9 다음 0으로 돌아가는 조건을 더했다.

| FF | J | K |
|---|---|---|
| Qa | 1 | 1 |
| Qb | Qa·Qd′ (AND inst6 + NOT inst7) | 같음 |
| Qc | Qa·Qb (AND inst10) | 같음 |
| Qd | Qa·Qb·Qc (AND3 inst11) | Qa |

동작: 0~7에서는 일반 상향 카운터와 같고, 0111→1000에서 Qd가 1이 된다. 1001(9)에서는 Qd=1이라 Qb가 토글하지 않고, Qa=1이라 Qd는 리셋(K=1)되며 Qa도 0이 되어 0000으로 돌아간다. 캐리 출력 C = Qa·Qd(AND inst12)는 9일 때만 1이어서 다음 자리 카운터를 올리는 데 쓴다. modulo-m 리플 카운터와 달리 비동기 클리어를 쓰지 않아 1010 글리치가 생기지 않는다.

### 동기식 3비트 상향/하향 카운터 (`6_5_syn_3bit_updown_counter`, 3bits_updown_counter.zip)

![동기식 3비트 상향/하향 카운터](<슬라이드_미대응/6_5_syn_3bit_updown_counter/6_5_syn_3bit_updown_counter_schematic.png>)

![동기식 3비트 상향/하향 카운터 시뮬레이션](<슬라이드_미대응/6_5_syn_3bit_updown_counter/6_5_syn_3bit_updown_counter_vwf_simulation.png>)

회로: 방향 입력 X에 따라 토글 조건을 두 가지로 만들고 OR로 합쳤다.
- Qa: J = K = 1
- Qb: J = K = X′·Qa + X·Qa′ (AND inst4, inst5 → OR inst8)
- Qc: J = K = X′·Qa·Qb + X·Qa′·Qb′ (AND inst11, inst12 → OR inst14)

동작: X=0이면 아래 비트가 모두 1일 때 토글하므로 상향(0→7), X=1이면 아래 비트가 모두 0일 때 토글하므로 하향(7→0)이다. 모든 FF가 같은 클럭을 쓰므로, 비동기 상하향 카운터와 달리 X를 바꿔도 클럭에 가짜 에지가 생기지 않고, 다음 클럭부터 방향만 바뀐다.

---

## 실습 시 유의사항

- **에지 극성**: Quartus 기본소자 DFF·JKFF·TFF는 상승 에지, 74112는 하강 에지다. 같은 회로라도 기본소자로 옮길 때는 클럭에 NOT을 넣어야 한다(강의11 Example 1 두 버전 비교).
- **래치와 플립플롭**: 강의08의 SR·D 회로는 CP=1 동안 입력을 따라가는 게이트형 래치다. 에지에서만 바뀌는 플립플롭과 파형을 비교해 보자.
- **초기화**: 리셋·프리셋 입력이 없거나 넣지 않으면 시뮬레이션 출력이 X로 나온다. .vwf를 만들 때 처음에 ClrN(또는 SetN, St)을 잠깐 0으로 두는 것이 좋다.
- **비동기 리셋의 글리치**: modulo-m·0~9 리플 카운터는 금지 상태(1010)가 아주 짧게 나타났다가 지워진다. Timing 시뮬레이션에서 보이는 스파이크는 이 때문이며, 동기식 BCD 카운터는 이 문제가 없다.
- **비동기 방식의 한계**: 리플 카운터는 단마다 지연이 쌓여 상위 비트가 늦게 바뀌고, 상하향 전환 시 가짜 클럭 에지가 생길 수 있다. 같은 기능의 동기식 예제(슬라이드_미대응 폴더)와 비교하면 차이가 분명하다.
- **보드 실습**: 0~9 카운터처럼 50 MHz 클럭을 바로 쓰면 LED 변화가 너무 빨라 보이지 않는다. Mod50MHz 같은 분주기로 1 Hz 안팎으로 낮춰 쓴다.
- **zip 프로젝트**: 압축을 푼 뒤 .qpf를 열고, 컴파일 후 .vwf로 시뮬레이션한다. db·simulation 폴더는 다시 만들어진다.

---

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
