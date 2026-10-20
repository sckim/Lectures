// johnson_lockout.v : 예제 16-2 6상태 카운터 000 -> 100 -> 110 -> 111 -> 011 -> 001 -> 000  Lab 10 Part E
//   FIX = 0 : 미사용 상태 010, 101을 don't care로 둔 설계  DA = C', DB = A, DC = B
//             -> 010 <-> 101 끼리만 오간다(록아웃)
//   FIX = 1 : 010의 다음 상태를 100으로 정한 설계          DA = C', DB = A, DC = B(A + C)
//             -> 어느 상태에서 시작해도 2클럭 안에 정상 루프에 들어간다(자기 시작)
// 시작 상태를 마음대로 정하려고 비동기 로드를 넣었다. LoadN = 0인 동안 A B C = S2 S1 S0이 된다.
//   PRN = (LD · S)',  CLRN = (LD · S')'   (LD = LoadN')  -> 회로도의 NAND inst1–inst6
// [정리자 주] Cyclone V 레지스터에는 비동기 프리셋이 없어 Quartus가 래치를 덧붙인다(Lab 07, 경고 13004/13310).
//            미사용 상태에서 회로를 출발시키는 실험에만 쓰는 장치이다.

module johnson6 #(parameter FIX = 0) (
    input  wire CLK, LoadN, S2, S1, S0,
    output wire A, B, C
);
    wire LD = ~LoadN;                                   // not_LoadN
    wire PA = ~(LD & S2), CA = ~(LD & ~S2);             // inst1, inst2
    wire PB = ~(LD & S1), CB = ~(LD & ~S1);             // inst3, inst4
    wire PC = ~(LD & S0), CC = ~(LD & ~S0);             // inst5, inst6
    wire DA = ~C;                                       // not_C1 / not_C2
    wire DB = A;
    wire DC = FIX ? (B & (A | C)) : B;                  // FIX: inst7 OR2 + inst8 AND2
    d_ff_pc u_a (.CLK(CLK), .PRN(PA), .CLRN(CA), .D(DA), .Q(A));
    d_ff_pc u_b (.CLK(CLK), .PRN(PB), .CLRN(CB), .D(DB), .Q(B));
    d_ff_pc u_c (.CLK(CLK), .PRN(PC), .CLRN(CC), .D(DC), .Q(C));
endmodule

// 보드용 top : 두 설계에 같은 클럭과 같은 시작 상태를 준다 (johnson_lockout_sch.bdf와 같다)
module johnson_lockout (
    input  wire CLK,            // KEY[0]
    input  wire LoadN,          // KEY[1]  누르고 있는 동안 시작 상태를 싣는다
    input  wire S2, S1, S0,     // SW[2], SW[1], SW[0]  시작 상태 A B C
    output wire A1, B1, C1,     // LEDR[2], LEDR[1], LEDR[0]  don't care 설계 (록아웃)
    output wire A2, B2, C2      // LEDR[6], LEDR[5], LEDR[4]  고친 설계
);
    johnson6 #(.FIX(0)) u_lock (.CLK(CLK), .LoadN(LoadN), .S2(S2), .S1(S1), .S0(S0), .A(A1), .B(B1), .C(C1));
    johnson6 #(.FIX(1)) u_fix  (.CLK(CLK), .LoadN(LoadN), .S2(S2), .S1(S1), .S0(S0), .A(A2), .B(B2), .C(C2));
endmodule
