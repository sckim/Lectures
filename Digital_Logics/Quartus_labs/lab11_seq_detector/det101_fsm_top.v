// det101_fsm_top.v : 보드용 top. 같은 X, 같은 클럭을 Mealy·Moore 두 FSM에 함께 넣는다  Lab 11 Part B, C
// State Machine Viewer에는 u_mealy|state, u_moore|state 두 상태 머신이 나와야 한다({{VERIFY}}: 표시 이름).
module det101_fsm_top (
    input  wire CLK,            // KEY[0]  (뗄 때 0 -> 1, 상승 에지)
    input  wire ClrN,           // KEY[1]  누르면 두 FSM 모두 S0
    input  wire X,              // SW[0]
    output wire Z_MEALY,        // LEDR[0]
    output wire Z_MOORE,        // LEDR[1]
    output wire [1:0] ST_MEALY, // LEDR[5:4]
    output wire [1:0] ST_MOORE  // LEDR[7:6]
);
    det101_mealy u_mealy (.clk(CLK), .rst_n(ClrN), .x(X), .z(Z_MEALY), .st(ST_MEALY));
    det101_moore u_moore (.clk(CLK), .rst_n(ClrN), .x(X), .z(Z_MOORE), .st(ST_MOORE));
endmodule
