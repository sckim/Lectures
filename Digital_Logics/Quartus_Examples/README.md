# Quartus 예제 — 강의 슬라이드별 정리

디지털논리회로 강의08~12 Google Slides에 대응하는 Quartus 예제를 강의별로 모은 폴더이다. 폴더 이름 끝의 `_숫자`는 해당 회로가 나오는 슬라이드 페이지 번호이고, Quartus가 한글·공백·특수문자 경로를 처리하지 못하므로 제목은 영문으로 옮기고 공백·기호는 `_`로 바꾸었다. 강의08~11 폴더는 `01_`부터 번호를 앞에 붙였고, 강의12 폴더는 원래 예제 이름(`6_1_` 등)을 그대로 두었다.

예제마다 회로 구성·동작 원리·시뮬레이션에서 확인할 점을 정리했다.

| 강의 | 주제 | 예제 수 | 핵심 소자 |
|---|---|---|---|
| 강의08 | 플립플롭 | 5 | NOR/NAND 래치, 주종형 S-R, JK·D·T FF |
| 강의09 | 레지스터 | 4 | DFF, DFFE |
| 강의10 | 비동기식 카운터 | 5 | JKFF, 74112, 7400 |
| 강의11 | 동기 순서논리회로 | 5 | DFF, JKFF, 74112, 74138 |
| 강의12 | 동기식 카운터 | 5 | JKFF, AND/OR 게이트 |

참고:
- `*_schematic.png` 가운데 일부는 .bdf를 읽어 그린 그림이다(Quartus 화면 캡처 아님). 강의08·09 폴더의 그림은 `<폴더 이름>_schematic.png`(.bdf), `<폴더 이름>_vwf_sim.png`(ModelSim 시뮬레이션 결과 .vwf)로 그렸다. 파형의 파란색은 입력, 빨간색은 출력, 회색 X는 미정 구간이다.
- 강의12 예제는 프로젝트가 .zip으로만 들어 있다. 압축을 풀고 .qpf를 열면 된다. 강의10의 01·04·05 폴더에도 원래 배포용 zip이 함께 들어 있지만, 같은 프로젝트가 이미 풀려 있다.
- 시뮬레이션 설명의 시각(예: "약 3 µs")은 캡처 화면에서 읽은 대략값이다.

## Lec08_FlipFlops

| 폴더 | 내용 |
|---|---|
| `01_Basic_FlipFlops_22` | NOR S-R 래치 |
| `02_Switch_Debouncing_with_SR_Latch_34` | NAND 래치 디바운스 회로 |
| `03_MasterSlave_SR_FlipFlop_59` | NAND 게이트 주종형 S-R FF |
| `04_MasterSlave_SR_FlipFlop_Block_60` | SR_FF 블록 2개로 만든 주종형 FF |
| `05_Summary_135` | SR·JK·D·T 플립플롭 모음 |

두 게이트의 출력을 서로의 입력으로 되먹임하면 1비트를 기억하는 래치가 되고, 여기에 클럭 제어를 더하면 플립플롭이 된다. 강의08 예제 5개는 이 과정을 래치 → 디바운스 응용 → 주종형 FF → FF 4종 순서로 보여 준다.

### NOR S-R 래치 (`01_Basic_FlipFlops_22`, SR_Latch.bdf)

![NOR S-R 래치](<Lec08_FlipFlops/01_Basic_FlipFlops_22/01_Basic_FlipFlops_22_schematic.png>)

![NOR S-R 래치 시뮬레이션](<Lec08_FlipFlops/01_Basic_FlipFlops_22/01_Basic_FlipFlops_22_vwf_sim.png>)

회로: NOR2 2개를 교차 결합했다. S는 위쪽 NOR(출력 notQ), R은 아래쪽 NOR(출력 Q)에 들어가고, 각 NOR의 나머지 입력은 상대 게이트의 출력이다.

동작: NOR는 입력에 1이 하나라도 있으면 0을 내므로, S=1이면 notQ=0이 되고 이것이 아래 NOR로 돌아가 Q=1이 된다. 입력이 모두 0으로 돌아와도 되먹임 때문에 Q=1이 유지된다.

| S | R | Q(다음) | 의미 |
|---|---|---|---|
| 0 | 0 | Q | 유지 |
| 0 | 1 | 0 | 리셋 |
| 1 | 0 | 1 | 셋 |
| 1 | 1 | 0 (Q=notQ=0) | 금지 |

시뮬레이션: 1 µs 간격으로 SR 조합을 바꾼다. 0~1 µs에 R=1로 Q=0이 되고, 1~2 µs(S=R=0)에는 그대로 유지된다. 2~3 µs에는 S=R=1이라 Q와 notQ가 모두 0인 금지 상태가 나타난다. 3 µs에 R만 0이 되면 Q=1로 셋되고, 4 µs에 R=1이 되면 다시 리셋된다. 6~8 µs에서 같은 순서가 반복된다.

### NAND 래치 스위치 디바운스 (`02_Switch_Debouncing_with_SR_Latch_34`, Debouce.bdf)

![NAND 래치 디바운스](<Lec08_FlipFlops/02_Switch_Debouncing_with_SR_Latch_34/02_Switch_Debouncing_with_SR_Latch_34_schematic.png>)

![NAND 래치 디바운스 시뮬레이션](<Lec08_FlipFlops/02_Switch_Debouncing_with_SR_Latch_34/02_Switch_Debouncing_with_SR_Latch_34_vwf_sim.png>)

회로: NAND2 2개를 교차 결합한 /S-/R 래치다. 입력은 notS, notR(액티브 로우), 출력은 Q, notQ이다.

동작: NAND 래치는 0이 들어오는 순간 셋·리셋되고, 두 입력이 1이면 상태를 유지한다. 기계식 스위치는 접점이 붙는 순간 수 ms 동안 튀지만(바운스), 첫 0에서 이미 상태가 바뀌고 이후의 0↔1 반복은 '유지' 또는 같은 '셋'이라 출력이 한 번만 바뀐다.

| notS | notR | Q | 의미 |
|---|---|---|---|
| 1 | 1 | Q | 유지 |
| 0 | 1 | 1 | 셋 |
| 1 | 0 | 0 | 리셋 |
| 0 | 0 | 1 (Q=notQ=1) | 금지 |

시뮬레이션: notS와 notR에 튀는 펄스 묶음(2 µs 동안)을 넣었다. 10 µs의 notS 바운스에서 Q는 첫 하강 에지에 한 번만 1로 올라가고, 34 µs의 notR 바운스에서 한 번만 0으로 내려간다. 이미 리셋된 상태에서 들어온 2 µs의 notR 바운스와, 셋된 상태에서 notS가 1로 돌아가는 23 µs의 바운스는 Q를 바꾸지 않는다.

### NAND 게이트 주종형 S-R 플립플롭 (`03_MasterSlave_SR_FlipFlop_59`, MasterSlave_SR_FF.bdf)

![주종형 S-R FF](<Lec08_FlipFlops/03_MasterSlave_SR_FlipFlop_59/03_MasterSlave_SR_FlipFlop_59_schematic.png>)

![주종형 S-R FF 시뮬레이션](<Lec08_FlipFlops/03_MasterSlave_SR_FlipFlop_59/03_MasterSlave_SR_FlipFlop_59_vwf_sim.png>)

회로: NAND2 8개와 NOT 1개로 만든 두 단 구조다.

1. 마스터: inst·inst3가 S·R을 Cp로 게이트하고, inst4·inst5가 NAND 래치를 이룬다. 마스터 출력은 Y, Y_Bar로 따로 내보냈다.
2. 슬레이브: inst6·inst7이 Y·Y_Bar를 NOT Cp(inst10)로 게이트하고, inst8·inst9가 출력 래치(Q, Q_Bar)다.

동작: Cp=1이면 마스터가 S·R을 받아들이고 슬레이브는 닫혀 있다. Cp가 0으로 떨어지면 마스터가 닫히고 슬레이브가 열려 Y가 Q로 전달된다. 따라서 Q는 Cp의 하강 에지에서만 바뀌며, Y와 Q를 함께 보면 '마스터가 먼저, 슬레이브가 반 주기 뒤'에 바뀌는 것을 볼 수 있다.

### SR_FF 블록으로 만든 주종형 FF (`04_MasterSlave_SR_FlipFlop_Block_60`, MS_SR_FF.bdf)

![SR_FF 블록 주종형 FF](<Lec08_FlipFlops/04_MasterSlave_SR_FlipFlop_Block_60/04_MasterSlave_SR_FlipFlop_Block_60_schematic.png>)

![SR_FF 블록 주종형 FF 시뮬레이션](<Lec08_FlipFlops/04_MasterSlave_SR_FlipFlop_Block_60/04_MasterSlave_SR_FlipFlop_Block_60_vwf_sim.png>)

앞 회로의 게이트 래치 부분을 `SR_FF` 블록(SR_FF.bdf, 심볼 SR_FF.bsf)으로 묶어 두 번 쓴 계층형 설계다. 첫 블록(inst)은 Cp, 두 번째 블록(inst5)은 NOT Cp(inst4)를 받고, 첫 블록의 Q·Q_bar가 두 번째 블록의 S·R로 들어간다. 동작은 앞 예제와 같고, 하위 블록을 만들어 재사용하는 Quartus 작업 방법을 익히는 예제다. 시뮬레이션에서도 앞 예제와 같은 입력에 대해 Q가 Cp 하강 에지(15, 25, 30, 50 µs)에서만 바뀐다.

### SR·JK·D·T 플립플롭 모음 (`05_Summary_135`, ExampleCollection.bdf)

![플립플롭 4종](<Lec08_FlipFlops/05_Summary_135/05_Summary_135_schematic.png>)

![플립플롭 4종 시뮬레이션](<Lec08_FlipFlops/05_Summary_135/05_Summary_135_vwf_sim.png>)

한 파일에 네 회로가 독립적으로 그려져 있다.

| 회로 | 구성 | 트리거 | 동작 |
|---|---|---|---|
| SR | AND2 2개로 S·R을 CP_sr 게이트 + NOR 래치 | 레벨(CP=1) | CP=1일 때만 S-R 래치처럼 동작 |
| JK | JKFF 기본소자, PRN=VCC, CLRN=ClrN_j | 상승 에지 | J=K=0 유지, 10 셋, 01 리셋, J=K=1 토글 |
| D | NAND2 4개 + NOT(D→/D), CP_d 게이트 | 레벨(CP=1) | CP=1이면 Q=D, CP=0이면 유지 |
| T | TFF 기본소자, PRN=VCC, CLRN=ClrN_t | 상승 에지 | T=1이면 토글, T=0이면 유지 |

시뮬레이션에서 확인할 점:
- SR·D는 CP=0인 구간(20 µs까지) Q가 X(미정)다. 초기값을 정해 주는 입력이 없기 때문이다. CP=1이 된 뒤에는 Q가 S·R 또는 D를 그대로 따라간다.
- JK·T는 ClrN을 1로 두어 Q=0(기본소자의 초기값)에서 시작하고, CP 상승 에지에서만 바뀐다. 예를 들어 Q_jk는 2 µs(J=1, K=0)에 셋, 10 µs(J=K=1)에 토글된다.
- 여기서 SR·D는 엄밀히 게이트형 래치(레벨 트리거)이므로, 에지 트리거인 JK·T와 파형을 비교해 보면 차이가 드러난다.

## Lec09_Registers

| 폴더 | 내용 |
|---|---|
| `01_4bit_SISO_Register_18` | 4비트 SISO(DFFE) |
| `02_Right_Shift_Register_23` | 4비트 우측 시프트 레지스터(DFFE) |
| `03_Digital_SafetyBox_76` | 디지털 금고 |
| `04_Random_Number_Generator_79` | 난수 발생 회로 |

레지스터는 같은 클럭을 받는 플립플롭을 줄지어 놓은 것이다. 앞 단 Q를 뒤 단 D에 이으면 클럭마다 데이터가 한 칸씩 이동하는 시프트 레지스터가 되고, 금고와 난수 발생기는 이 구조를 응용한 것이다.

### 4비트 직렬입력-직렬출력(SISO) 레지스터 (`01_4bit_SISO_Register_18`, SISO_Register.bdf)

![4비트 SISO](<Lec09_Registers/01_4bit_SISO_Register_18/01_4bit_SISO_Register_18_schematic.png>)

![4비트 SISO 시뮬레이션](<Lec09_Registers/01_4bit_SISO_Register_18/01_4bit_SISO_Register_18_vwf_sim.png>)

회로: DFFE(인에이블 붙은 D FF) 4개를 직렬로 잇고, SI → Q3 → Q2 → Q1 → Q0 순서로 데이터가 흐른다. Clock은 4개 FF에 공통, Shift는 모든 ENA에, ClrN은 모든 CLRN에 들어가고 PRN은 VCC다.

동작: Shift=1이면 Clock 상승 에지마다 SI가 Q3에 들어가고 기존 값은 오른쪽(Q0 방향)으로 한 칸 밀린다. Shift=0이면 클럭이 들어와도 값을 유지한다. 직렬 출력은 Q0이며, 입력한 비트는 4클럭 뒤에 Q0에 나타난다.

시뮬레이션: ClrN으로 0000에서 시작하고 Shift=1로 둔다. Clock 상승 에지(2.5, 7.5, 12.5, 17.5 µs …)에서 읽힌 SI=1, 1, 0, 1이 Q3에 들어가고, 같은 패턴이 Q2 → Q1 → Q0으로 한 클럭(5 µs)씩 늦어져 계단처럼 나타난다. Q0에는 17.5 µs부터 나온다.

### 4비트 우측 시프트 레지스터 (`02_Right_Shift_Register_23`, rightshift.bdf)

![우측 시프트 레지스터](<Lec09_Registers/02_Right_Shift_Register_23/02_Right_Shift_Register_23_schematic.png>)

![우측 시프트 레지스터 시뮬레이션](<Lec09_Registers/02_Right_Shift_Register_23/02_Right_Shift_Register_23_vwf_sim.png>)

슬라이드 p.23 화면에 나오는 프로젝트다. 회로는 위 SISO와 같은 DFFE 4개 구조(SI, Shift, Clock, ClrN → Q3~Q0)이고, 각 단의 Q를 모두 출력으로 내보내 병렬로도 읽을 수 있다. 데이터가 Q3(왼쪽)에서 Q0(오른쪽)으로 이동하므로 우측 시프트라 부른다. 시뮬레이션은 클럭 주기가 2 µs로 짧을 뿐 위 SISO와 같은 모양이다. 1, 3, 5, 7 µs의 상승 에지에서 읽힌 SI=1, 1, 0, 1이 Q3 → Q0으로 한 클럭씩 밀린다.

### 디지털 금고 (`03_Digital_SafetyBox_76`, Digital_StrongBox.bdf)

![디지털 금고](<Lec09_Registers/03_Digital_SafetyBox_76/03_Digital_SafetyBox_76_schematic.png>)

![디지털 금고 시뮬레이션](<Lec09_Registers/03_Digital_SafetyBox_76/03_Digital_SafetyBox_76_vwf_sim.png>)

회로: DFF 4개를 직렬로 잇고 첫 단 D를 VCC(1)에 물렸다. 각 FF의 클럭은 숫자 버튼 하나씩이다.

| 단 | 클럭 입력 | 역할 |
|---|---|---|
| inst | Three | 1번째 숫자 |
| inst1 | One | 2번째 숫자 |
| inst2 | Nine | 3번째 숫자 |
| inst3 | Zero | 4번째 숫자, Q = Unlock |

나머지 6개 버튼(Two, Four, Five, Six, Seven, Eight)은 NOR6에 들어가고, NOR6 출력이 4개 FF의 CLRN에 공통으로 물린다.

동작: 비밀번호는 **3-1-9-0**이다. Three를 누르면 첫 FF에 1이 저장되고, One을 누르면 그 1이 두 번째 FF로 옮겨지는 식으로 올바른 순서일 때만 1이 끝까지 전달되어 Unlock=1이 된다. 순서가 틀리면 앞 단에 1이 없어 0이 옮겨지고, 비밀번호에 없는 숫자를 누르면 NOR6 출력이 0이 되어 모두 초기화된다.

시뮬레이션: Three(3 µs) → One(4 µs) → Nine(5 µs) → Zero(6 µs) 순서로 누르자 Zero의 상승 에지에서 Unlock=1이 된다. 다른 버튼은 누르지 않았으므로 Unlock=1이 끝까지 유지된다.

### 난수 발생 회로 (`04_Random_Number_Generator_79`, RandomlyNum.bdf)

![난수 발생 회로](<Lec09_Registers/04_Random_Number_Generator_79/04_Random_Number_Generator_79_schematic.png>)

![난수 발생 회로 시뮬레이션](<Lec09_Registers/04_Random_Number_Generator_79/04_Random_Number_Generator_79_vwf_sim.png>)

회로: DFF 4개를 Qa→Qb→Qc→Qd로 잇고, Qc와 Qd의 XNOR를 첫 단 D로 되돌린 4비트 LFSR(선형 귀환 시프트 레지스터)이다. St는 첫 FF의 PRN에 들어가 시작 값을 정하고, 나머지 PRN·CLRN은 VCC다.

동작: St=0이면 Qa=1이 되어 상태 1000에서 출발한다. 이후 Cp 상승 에지마다 다음과 같이 15개 상태를 돈 뒤 다시 1000으로 돌아온다(QaQbQcQd).

```
1000 → 1100 → 1110 → 0111 → 1011 → 1101 → 0110 → 0011
     → 1001 → 0100 → 1010 → 0101 → 0010 → 0001 → 0000 → 1000
```

XNOR 귀환에서는 1111이 빠지는데, 1111에 들어가면 XNOR(1,1)=1이 되어 빠져나오지 못하는 잠김 상태이기 때문이다. 시뮬레이션에서는 4 µs마다(Cp 상승 에지) 상태가 바뀌어, 0 µs의 1000부터 56 µs의 0000까지 위 15개 상태가 순서대로 나타난다.

## Lec10_Async_Counters

| 폴더 | 내용 |
|---|---|
| `01_Ripple_Up_7` | 3비트 리플 상향 카운터 |
| `02_Ripple_Up_TTL_29` | 0~9 카운터(74112×4, 7400), DE1-SoC |
| `03_Ripple_Down_Counter_14` | 리플 하향 카운터 |
| `04_Ripple_Up_Down_24` | 리플 상향/하향 카운터 |
| `05_Ripple_Ten_Counter_28` | modulo-m(MOD-10) 리플 카운터 |

비동기식(리플) 카운터는 첫 FF만 외부 클럭을 받고, 나머지는 앞 단 출력을 클럭으로 쓴다. 모든 FF는 J=K=1(토글)이라 클럭 에지마다 반전하고, 각 단은 앞 단의 주파수를 2로 나눈다. 상향·하향은 '어느 에지에서 다음 단을 트리거하느냐'와 'Q와 /Q 중 무엇을 출력으로 보느냐'로 정해진다.

| 하강 에지 FF에서 | 다음 단 클럭 = Q | 다음 단 클럭 = /Q |
|---|---|---|
| 출력 Q | 상향 | 하향 |
| 출력 /Q | 하향 | 상향 |

Quartus의 JKFF 기본소자는 상승 에지 트리거이므로, 예제들은 클럭 앞에 NOT을 넣어 하강 에지 FF처럼 쓴다. 74112는 원래 하강 에지 FF라 NOT이 필요 없다.

### 3비트 리플 상향 카운터 (`01_Ripple_Up_7`, Ripple_up.bdf)

![3비트 리플 상향 카운터](<Lec10_Async_Counters/01_Ripple_Up_7/4_3_1_ripple_up_counter_schematic.png>)

![3비트 리플 상향 카운터 시뮬레이션](<Lec10_Async_Counters/01_Ripple_Up_7/4_3_1_ripple_up_counter_vwf_simulation.png>)

회로: JKFF 3개(J=K=PRN=VCC), CLRN은 ClrN 공통. Clk → NOT → inst, Q[0] → NOT → inst1, Q[1] → NOT → inst2 순서로 클럭이 이어진다. 출력은 버스 Q[2..0]이다.

동작: Q[0]은 Clk 하강 에지마다, Q[1]은 Q[0]이 1→0이 될 때마다, Q[2]는 Q[1]이 1→0이 될 때마다 반전한다. 그 결과 000 → 001 → … → 111 → 000을 반복하는 MOD-8 상향 카운터가 된다. 시뮬레이션에서도 Clk 하강 에지마다 Q가 000부터 111까지 1씩 증가한다.

### 0~9 카운터, 74112 사용 (`02_Ripple_Up_TTL_29`, eightcounter.bdf)

![0~9 카운터](<Lec10_Async_Counters/02_Ripple_Up_TTL_29/eightcounter_schematic.png>)

회로는 세 부분으로 나뉜다.
1. 클럭 분주: `Mod50MHz.v`(Verilog)는 n_cp 하강 에지마다 q를 0~49,999,999로 세는 카운터다. 입력 핀 CP_50MHz는 DE1-SoC의 50 MHz 클럭 CLOCK_50(PIN_AF14)에 할당되어 있고, 이를 넣고 비트 q[25]를 클럭으로 쓰면 주기 1초(약 1 Hz)의 느린 클럭이 나와, LED로 숫자가 바뀌는 것을 눈으로 볼 수 있다. n_rd는 VCC다.
2. 카운터: 74112(하강 에지 JK FF) 4개의 1번 FF만 쓴다. 1PRN·1J·1K는 VCC, 첫 단 1CLK은 q[25], 다음 단 1CLK은 앞 단 1Q다. 출력은 Qa_LSB, Qb, Qc, Qd_MSB다.
3. 리셋: 7400(NAND) 5개를 직렬로 잇는다. 첫 NAND(inst11)가 Qb·Qd를 받고, 나머지 4개는 입력을 묶어 인버터로 쓴다. 최종 출력은 NAND(Qb, Qd)와 같은 논리이고, 4개 FF의 1CLRN에 들어간다.

동작: 74112는 하강 에지 FF이므로 NOT 없이 Q를 다음 단 클럭에 이어도 상향 카운터가 된다. 1010(10)이 되면 Qd=Qb=1이라 클리어되어 0~9를 반복한다. 인버터 4단은 논리를 바꾸지 않고 리셋 신호에 지연을 더해, 모든 FF가 확실히 지워질 만큼 리셋 펄스를 길게 하는 역할로 볼 수 있다.

### MOD-8 리플 하향 카운터 (`03_Ripple_Down_Counter_14`, Rippledown.bdf)

![MOD-8 리플 하향 카운터](<Lec10_Async_Counters/03_Ripple_Down_Counter_14/4_3_2_ripple_down_counter_schematic.png>)

![MOD-8 리플 하향 카운터 시뮬레이션](<Lec10_Async_Counters/03_Ripple_Down_Counter_14/4_3_2_ripple_down_counter_vwf_simulation.png>)

FF 연결은 상향 카운터와 같고, **출력을 /Q로 바꾼** 것만 다르다. 다음 단 클럭용 NOT(inst5, inst6)의 출력을 Q[0], Q[1]로 꺼내고, 마지막 단은 NOT(inst9)을 달았다.

동작: 내부 FF는 0→7로 올라가지만 출력은 보수(7−n)이므로 111 → 110 → … → 000 → 111로 내려간다. 시뮬레이션에서 ClrN=0으로 FF를 지우면 출력은 111에서 시작하는 것을 확인한다.

### 비동기 상향/하향 카운터 (`04_Ripple_Up_Down_24`, RippleUpdown.bdf)

![리플 상향/하향 카운터](<Lec10_Async_Counters/04_Ripple_Up_Down_24/4_3_3_ripple_up_down_counter_schematic.png>)

![리플 상향/하향 카운터 시뮬레이션 1](<Lec10_Async_Counters/04_Ripple_Up_Down_24/4_3_3_ripple_up_down_counter_vwf_simulation_0.png>)

![리플 상향/하향 카운터 시뮬레이션 2](<Lec10_Async_Counters/04_Ripple_Up_Down_24/4_3_3_ripple_up_down_counter_vwf_simulation_1.png>)

회로: JKFF 4개(J=K=PRN=VCC)로 만든 4비트 리플 카운터이고, ClrN이 4개 FF의 CLRN에 공통으로 들어간다. 첫 단은 NOT Cp를 클럭으로 받는다. 단 사이마다 `2to1mux`(같은 폴더의 2to1mux.bdf: NOT·AND2 2개·OR2, S=0이면 input0, S=1이면 input1)가 있어 input0=Q, input1=/Q(NOT) 중 하나를 선택 입력 S로 고르고, 그 출력을 NOT을 거쳐 다음 단 클럭에 넣는다. 출력은 Q[3..0]이다.

동작:
- S=0: 다음 단이 Q의 하강 에지에서 토글 → 상향(0 → 15).
- S=1: 다음 단이 Q의 상승 에지(=/Q의 하강 에지)에서 토글 → 하향(15 → 0).

시뮬레이션 그림 두 장은 ClrN 입력을 넣기 전 회로의 캡처다. `_0`은 S=0 상향 동작, `_1`은 S=1 하향 동작을 보여 준다. 현재 RippleUpdown.vwf는 ClrN을 처음 0.48 µs 동안 0으로 두어 0000에서 시작하고, S를 0으로 두었다가 14.88 µs에 1로 바꿔 상향과 하향을 한 파형에서 본다. S를 도중에 바꾸면 멀티플렉서 출력이 변하면서 클럭 에지가 생겨 값이 튈 수 있으므로, S는 동작 전에 정해 두는 것이 좋다.

### modulo-m 비동기 카운터 (`05_Ripple_Ten_Counter_28`, RippleUpDown.bdf)

![modulo-m 리플 카운터](<Lec10_Async_Counters/05_Ripple_Ten_Counter_28/4_3_4_modulom_ripple_counter_schematic.png>)

![modulo-m 리플 카운터 시뮬레이션](<Lec10_Async_Counters/05_Ripple_Ten_Counter_28/4_3_4_modulom_ripple_counter_vwf_simulation.png>)

회로: 4비트 리플 상향 카운터(JKFF 4개 + NOT)에 NAND2 하나를 더했다. NAND2 입력은 Q[1]과 Q[3], 출력은 4개 FF의 CLRN에 공통으로 물린다.

동작: 0부터 세다가 1010(10)이 되는 순간 Q3=Q1=1이라 NAND 출력이 0이 되고, 모든 FF가 즉시 0000으로 지워진다. 따라서 0~9를 반복하는 MOD-10 카운터가 된다. 일반적으로 MOD-m은 m의 2진수에서 1인 비트들을 NAND로 묶어 CLRN에 넣으면 된다.

시뮬레이션에서 볼 점: 약 20.5 µs에 Q1에 짧은 스파이크(글리치)가 보인다. 1010 상태가 아주 짧게 나타났다가 클리어되기 때문이며, 비동기 리셋 방식의 특징이다.

## Lec11_Sync_Sequential_Circuits

| 폴더 | 내용 |
|---|---|
| `01_Example2_10` | 순차회로 해석(DFF 2개) |
| `02_Example1_14` | Example 1 (74112, SetN·Cp·A) |
| `03_Example1_15` | 같은 회로의 JKFF 기본소자판 |
| `04_Example3_59` | J-K FF 동기 순차회로 설계(x, A, B) |
| `05_Example_9_4_Gray_Code_Counter_119` | 74138+JKFF 그레이 코드 카운터 |

순서회로 해석은 '회로도 → FF 입력식 → 상태표 → 상태도', 설계는 그 반대 순서다. 아래 예제들은 회로도에서 입력식을 읽고, 그 식으로 상태 변화를 예측한 뒤 시뮬레이션으로 확인하는 흐름으로 보면 된다. JK FF의 다음 상태는 Q⁺ = J·Q′ + K′·Q, D FF는 Q⁺ = D다.

### 순차회로 해석, DFF 2개 (`01_Example2_10`, Seq_Analysis1.bdf)

![순차회로 해석 DFF](<Lec11_Sync_Sequential_Circuits/01_Example2_10/Seq_Analysis1_schematic.png>)

시뮬레이션 파형 파일(Seq_Analysis1.vwf)은 들어 있지만 결과 그림은 없다.

회로: DFF 2개, 두 FF 모두 D = 자기 /Q(NOT inst2, inst4)다. inst는 NOT Clock(inst5)을, inst3은 Clock을 그대로 클럭으로 받고, ClrN은 두 CLRN에 공통이다.

동작: D=/Q인 DFF는 클럭마다 반전하는 2분주기다. Q1은 Clock 하강 에지, Q2는 상승 에지에서 반전하므로, 둘 다 Clock의 1/2 주파수이면서 서로 반 클럭(90°)씩 어긋난 파형이 된다. 상승·하강 에지 트리거의 차이를 파형으로 비교하기 좋은 회로다.

### Example 1, 74112 버전 (`02_Example1_14`, Seq_exam.bdf)

![Example 1 74112](<Lec11_Sync_Sequential_Circuits/02_Example1_14/5_sequential_circuit_analysis_schematic.png>)

![Example 1 74112 시뮬레이션](<Lec11_Sync_Sequential_Circuits/02_Example1_14/5_sequential_circuit_analysis_vwf_simulation.png>)

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

### Example 1, JKFF 기본소자 버전 (`03_Example1_15`, Example1.bdf)

![Example 1 JKFF](<Lec11_Sync_Sequential_Circuits/03_Example1_15/Example1_schematic.png>)

같은 회로를 74112 대신 JKFF 기본소자로 다시 그렸다. JKFF는 상승 에지 트리거이므로 클럭 앞에 NOT(inst1: Cp, inst3: Q0)을 넣어 하강 에지 동작을 맞추었다. 입력식(J1 = A·Q1, K1 = A·Q0)과 SetN→PRN 연결은 74112 버전과 같아, 시뮬레이션 결과도 같아야 한다. 두 버전을 비교하면 74 시리즈 매크로와 기본소자의 에지 극성 차이를 익힐 수 있다. 파형 파일은 Waveform.vwf, Waveform1.vwf 두 개이고 결과 그림은 없다.

### J-K FF 동기 순차회로 설계 (`04_Example3_59`, Design_Sequential_Circuit.bdf)

![J-K FF 순차회로 설계](<Lec11_Sync_Sequential_Circuits/04_Example3_59/6_sequential_circuit_design_schematic.png>)

![J-K FF 순차회로 설계 시뮬레이션](<Lec11_Sync_Sequential_Circuits/04_Example3_59/6_sequential_circuit_design_vwf_simulation.JPG>)

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

### 74138 + JKFF 그레이 코드 카운터 (`05_Example_9_4_Gray_Code_Counter_119`, seq_decoder.bdf)

![그레이 코드 카운터](<Lec11_Sync_Sequential_Circuits/05_Example_9_4_Gray_Code_Counter_119/seq_decoder_schematic.png>)

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

예를 들어 상태 011(m3)에서는 K0 = m3 + m5 = 1이라 q0만 0이 되어 010으로, 상태 010(m2)에서는 J2 = m2 = 1이라 q2만 1이 되어 110으로 간다. 리셋 입력이 없으므로(모든 PRN·CLRN = VCC) 시뮬레이션은 전원 투입 시의 000에서 시작한다고 보면 된다. 파형 파일은 Waveform.vwf이고 결과 그림은 없다.

## Lec12_Counters

강의12 「동기식 카운터」 예제다. 슬라이드에는 Quartus 화면 대신 교재 회로도가 실려 있어, 같은 회로가 나오는 페이지 번호를 붙였다.

| 폴더 | 내용 | 프로젝트 |
|---|---|---|
| `6_1_2bit_counter_5` | 2비트 동기 카운터 | `2bits_Counter/2bits_counter.zip` |
| `6_2_3bit_counter_12` | 3비트 동기 카운터 | `3bits_Counter/3bits_counter.zip` |
| `4bits_Counter_24` | 4비트 동기 카운터 | `4bits_counter.zip` |
| `6_4_syn_bcd_counter_45` | 동기식 BCD 카운터(캐리 C) | `BCD_Counter/BCD_counter.zip` |
| `6_5_syn_3bit_updown_counter_49` | 동기식 3비트 상향/하향 카운터 | `3bits_UpDown_Counter/3bits_updown_counter.zip` |

모두 JKFF(상승 에지, PRN=VCC)가 Cp를 공통으로 받고 ClrN이 모든 CLRN에 들어간다. 각 FF를 J=K로 묶어 T FF처럼 쓰고, '아래 비트가 모두 1일 때 토글'하도록 AND로 토글 조건을 만든다. 모든 FF가 동시에 바뀌므로 리플 카운터와 달리 출력이 단계적으로 흐트러지지 않는다.

| 예제 | 토글 조건 (J = K) | 순서 |
|---|---|---|
| `6_1_2bit_counter_5` | Qa: 1, Qb: Qa | 0 → 3 반복 (MOD-4) |
| `6_2_3bit_counter_12` | Qa: 1, Qb: Qa, Qc: Qa·Qb | 0 → 7 반복 (MOD-8) |
| `4bits_Counter_24` | Qa: 1, Qb: Qa, Qc: Qa·Qb, Qd: Qa·Qb·Qc | 0 → 15 반복 (MOD-16) |

![2비트 동기 카운터](<Lec12_Counters/6_1_2bit_counter_5/6_1_2bit_counter_schematic.png>)

![2비트 동기 카운터 시뮬레이션](<Lec12_Counters/6_1_2bit_counter_5/6_1_2bit_counter_vwf_simulation.png>)

![3비트 동기 카운터](<Lec12_Counters/6_2_3bit_counter_12/6_2_3bit_counter_schematic.png>)

![3비트 동기 카운터 시뮬레이션](<Lec12_Counters/6_2_3bit_counter_12/6_2_3bit_counter_vwf_simulation.png>)

![4비트 동기 카운터](<Lec12_Counters/4bits_Counter_24/4bits_counter_schematic.png>)

![4비트 동기 카운터 시뮬레이션](<Lec12_Counters/4bits_Counter_24/4bits_counter_SimulationCaptured.JPG>)

4비트 카운터는 Qa·Qb(inst5) 출력을 다시 Qc와 AND(inst9)해 쓰는 직렬 캐리 구조다. 비트 수가 늘어도 게이트는 AND2 하나씩만 늘어난다.

### 동기식 BCD 카운터 (`6_4_syn_bcd_counter_45`, BCD_Counter/BCD_counter.zip)

![동기식 BCD 카운터](<Lec12_Counters/6_4_syn_bcd_counter_45/6_4_syn_bcd_counter_schematic.png>)

![동기식 BCD 카운터 시뮬레이션](<Lec12_Counters/6_4_syn_bcd_counter_45/6_4_syn_bcd_counter_vwf_simulation.png>)

회로: 4비트 동기 카운터에 9 다음 0으로 돌아가는 조건을 더했다.

| FF | J | K |
|---|---|---|
| Qa | 1 | 1 |
| Qb | Qa·Qd′ (AND inst6 + NOT inst7) | 같음 |
| Qc | Qa·Qb (AND inst10) | 같음 |
| Qd | Qa·Qb·Qc (AND3 inst11) | Qa |

동작: 0~7에서는 일반 상향 카운터와 같고, 0111→1000에서 Qd가 1이 된다. 1001(9)에서는 Qd=1이라 Qb가 토글하지 않고, Qa=1이라 Qd는 리셋(K=1)되며 Qa도 0이 되어 0000으로 돌아간다. 캐리 출력 C = Qa·Qd(AND inst12)는 9일 때만 1이어서 다음 자리 카운터를 올리는 데 쓴다. modulo-m 리플 카운터와 달리 비동기 클리어를 쓰지 않아 1010 글리치가 생기지 않는다.

### 동기식 3비트 상향/하향 카운터 (`6_5_syn_3bit_updown_counter_49`, 3bits_UpDown_Counter/3bits_updown_counter.zip)

![동기식 3비트 상향/하향 카운터](<Lec12_Counters/6_5_syn_3bit_updown_counter_49/6_5_syn_3bit_updown_counter_schematic.png>)

![동기식 3비트 상향/하향 카운터 시뮬레이션](<Lec12_Counters/6_5_syn_3bit_updown_counter_49/6_5_syn_3bit_updown_counter_vwf_simulation.png>)

회로: 방향 입력 X에 따라 토글 조건을 두 가지로 만들고 OR로 합쳤다.
- Qa: J = K = 1
- Qb: J = K = X′·Qa + X·Qa′ (AND inst4, inst5 → OR inst8)
- Qc: J = K = X′·Qa·Qb + X·Qa′·Qb′ (AND inst11, inst12 → OR inst14)

동작: X=0이면 아래 비트가 모두 1일 때 토글하므로 상향(0→7), X=1이면 아래 비트가 모두 0일 때 토글하므로 하향(7→0)이다. 모든 FF가 같은 클럭을 쓰므로, 비동기 상하향 카운터와 달리 X를 바꿔도 클럭에 가짜 에지가 생기지 않고, 다음 클럭부터 방향만 바뀐다.

## 실습 시 유의사항

- **에지 극성**: Quartus 기본소자 DFF·JKFF·TFF는 상승 에지, 74112는 하강 에지다. 같은 회로라도 기본소자로 옮길 때는 클럭에 NOT을 넣어야 한다(강의11 Example 1 두 버전 비교).
- **래치와 플립플롭**: 강의08의 SR·D 회로는 CP=1 동안 입력을 따라가는 게이트형 래치다. 에지에서만 바뀌는 플립플롭과 파형을 비교해 보자.
- **초기화**: 리셋·프리셋 입력이 없거나 넣지 않으면 시뮬레이션 출력이 X로 나온다. .vwf를 만들 때 처음에 ClrN(또는 SetN, St)을 잠깐 0으로 두는 것이 좋다.
- **비동기 리셋의 글리치**: modulo-m·0~9 리플 카운터는 금지 상태(1010)가 아주 짧게 나타났다가 지워진다. Timing 시뮬레이션에서 보이는 스파이크는 이 때문이며, 동기식 BCD 카운터는 이 문제가 없다.
- **비동기 방식의 한계**: 리플 카운터는 단마다 지연이 쌓여 상위 비트가 늦게 바뀌고, 상하향 전환 시 가짜 클럭 에지가 생길 수 있다. 같은 기능의 동기식 예제(Lec12_Counters 폴더)와 비교하면 차이가 분명하다.
- **보드 실습**: 0~9 카운터처럼 50 MHz 클럭을 바로 쓰면 LED 변화가 너무 빨라 보이지 않는다. Mod50MHz 같은 분주기로 1 Hz 안팎으로 낮춰 쓴다.
- **zip 프로젝트**: 압축을 푼 뒤 .qpf를 열고, 컴파일 후 .vwf로 시뮬레이션한다. db·simulation 폴더는 다시 만들어진다.
