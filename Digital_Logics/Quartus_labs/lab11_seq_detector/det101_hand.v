// det101_hand.v : 19.6절 손 설계 결과 (밀리 101 검출기, 중첩 허용, A B = 00/01/10 = S0/S1/S2)  Lab 11 Part A
//   D_A = B x'    D_B = x    Z = A x
// 회로도 det101_hand_sch.bdf(기존 Demo4\Seq_detector.bdf)와 같은 연결이다. 상승 에지, ClrN은 비동기 클리어.
// 19.7.4절의 det101_hand와 같은 회로이며, 포트 이름만 회로도 핀 이름에 맞추고 상태 출력 A, B를 더했다.
module det101_hand (
    input  wire CLK,    // KEY[0]  (뗄 때 0 -> 1, 상승 에지)
    input  wire ClrN,   // KEY[1]  누르면 0 -> S0
    input  wire X,      // SW[0]
    output wire Z,      // LEDR[0]
    output reg  A,      // LEDR[5]  (회로도 inst의 Q)
    output reg  B       // LEDR[4]  (회로도 inst1의 Q)
);
    wire DA = ~X & B;       // inst8 NOT, inst9 AND2
    wire DB = X;

    always @(posedge CLK or negedge ClrN)          // inst, inst1 (DFF, PRN = VCC)
        if (!ClrN) begin A <= 1'b0; B <= 1'b0; end
        else       begin A <= DA;   B <= DB;   end

    assign Z = A & X;       // inst2 AND2 : 입력 X가 출력에 들어간다(밀리)
endmodule
