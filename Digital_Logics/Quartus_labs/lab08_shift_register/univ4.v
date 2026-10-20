// univ4.v : 4비트 범용 시프트 레지스터 (Lab 08 Part C)
// univ4는 12.9절의 코드 그대로이다(74194와 같은 기능표, 12.7.3절).
//   s = {S1, S0}: 00 유지, 01 오른쪽 시프트(QA ← sr), 10 왼쪽 시프트(QD ← sl), 11 병렬 로드
// univ74194는 univ74194_sch.bdf(기존 Register_74194.bdf, 74194 매크로 하나)와 같은 핀 이름으로
// univ4를 감싼 보드용 top이다.

// 4비트 범용 시프트 레지스터(74194와 같은 기능표)
module univ4 (
    input  wire       clk, clrn,
    input  wire [1:0] s,        // s = {S1, S0}
    input  wire       sr, sl,   // 오른쪽/왼쪽 시프트 직렬 입력
    input  wire [3:0] d,        // 병렬 입력 {A, B, C, D}
    output reg  [3:0] q         // {QA, QB, QC, QD}
);
    always @(posedge clk or negedge clrn)
        if (!clrn) q <= 4'b0000;
        else case (s)
            2'b00: q <= q;                 // 유지
            2'b01: q <= {sr, q[3:1]};      // 오른쪽 시프트
            2'b10: q <= {q[2:0], sl};      // 왼쪽 시프트
            2'b11: q <= d;                 // 병렬 로드
        endcase
endmodule

// 보드용 top: 핀 이름은 univ74194_sch.bdf와 같다
module univ74194 (
    input  wire       SLSI,     // SW[6]  왼쪽 시프트 직렬 입력 → QD로 들어감 (74194의 SL)
    input  wire       SRSI,     // SW[7]  오른쪽 시프트 직렬 입력 → QA로 들어감 (74194의 SR)
    input  wire [3:0] In,       // SW[3:0] In[3] = A … In[0] = D
    input  wire       S0,       // SW[8]
    input  wire       S1,       // SW[9]
    input  wire       ClrN,     // KEY[1] 누르면 비동기 클리어
    input  wire       Clk,      // KEY[0] 뗄 때 상승 에지
    output wire       QA,       // LEDR[3]
    output wire       QB,       // LEDR[2]
    output wire       QC,       // LEDR[1]
    output wire       QD        // LEDR[0]
);
    wire [3:0] q;
    univ4 u (.clk(Clk), .clrn(ClrN), .s({S1, S0}), .sr(SRSI), .sl(SLSI), .d(In), .q(q));   // 회로도 inst (74194)
    assign {QA, QB, QC, QD} = q;
endmodule
