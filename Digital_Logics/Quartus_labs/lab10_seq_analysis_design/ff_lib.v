// ff_lib.v : Lab 10에서 함께 쓰는 상승 에지 플립플롭 (Quartus 프리미티브 DFF, JKFF, SRFF, TFF와 같은 동작)
//   - 동기 입력은 CLK 상승 에지에서만 반영된다(11.4–11.6절).
//   - CLRN(액티브 로우)은 클럭과 상관없이 즉시 0으로 만든다(11.7절).
//   - d_ff_pc만 PRN(액티브 로우 프리셋)이 있다. Part E(예제 16-2)에서 시작 상태를 싣는 데 쓴다.
// [주의] 모듈 이름을 dff, jkff, srff, tff로 하지 않는다. Quartus 프리미티브 이름과 겹친다(Lab 07 5.3절).

module d_ff_c (input wire CLK, CLRN, D, output reg Q);
    always @(posedge CLK or negedge CLRN)
        if (!CLRN) Q <= 1'b0;
        else       Q <= D;                          // Q+ = D
endmodule

module jk_ff_c (input wire CLK, CLRN, J, K, output reg Q);
    always @(posedge CLK or negedge CLRN)
        if (!CLRN) Q <= 1'b0;
        else       Q <= (J & ~Q) | (~K & Q);        // Q+ = JQ' + K'Q
endmodule

module sr_ff_c (input wire CLK, CLRN, S, R, output reg Q);
    always @(posedge CLK or negedge CLRN)
        if (!CLRN) Q <= 1'b0;
        else       Q <= S | (~R & Q);               // Q+ = S + R'Q  (SR = 0인 회로에서만 쓴다)
endmodule

module t_ff_c (input wire CLK, CLRN, T, output reg Q);
    always @(posedge CLK or negedge CLRN)
        if (!CLRN) Q <= 1'b0;
        else       Q <= T ^ Q;                      // Q+ = T xor Q
endmodule

module d_ff_pc (input wire CLK, PRN, CLRN, D, output reg Q);
    always @(posedge CLK or negedge CLRN or negedge PRN)
        if      (!CLRN) Q <= 1'b0;                  // 비동기 클리어가 먼저
        else if (!PRN)  Q <= 1'b1;                  // 비동기 프리셋
        else            Q <= D;
endmodule
