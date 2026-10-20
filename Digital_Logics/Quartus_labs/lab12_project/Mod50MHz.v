// Mod50MHz.v : 기존 예제 6_Counter/Mod50MHz.vhd(VHDL)를 Verilog로 다시 쓴 것 (Lab 12 Part C)
//   ttl_clock_sch.bdf의 Mod50MHz 심볼(n_cp, n_rd, q[25..0])이 이 모듈을 쓴다. 이름·포트는 원본과 같다.
//   원본 동작: n_rd = 0이면 q = 0 (비동기), n_cp의 하강 에지마다 q = 0, 1, ..., 49,999,999, 0, ...
//   회로도는 q[25]만 쓴다. q[25]는 q >= 33,554,432일 때 1이므로, q가 49,999,999에서 0으로
//   돌아가는 순간 1 → 0으로 떨어진다. 이 하강 에지가 1초에 한 번 7490(초 일의 자리)을 센다.
//   [시뮬레이션용] FAST_TICK을 정의하면 4클럭에 한 바퀴를 돌되 한 번에 2^24씩 세어,
//   q[25]가 똑같이 "마지막 두 클럭 동안 1, 한 바퀴의 끝에서 1 → 0"이 된다.
module Mod50MHz #(
`ifdef FAST_TICK
    parameter N    = 4,            // 한 바퀴의 클럭 수
    parameter STEP = 26'd16777216  // 2^24
`else
    parameter N    = 50_000_000,
    parameter STEP = 26'd1
`endif
) (
    input  wire        n_cp,       // CLOCK_50
    input  wire        n_rd,       // 0이면 리셋 (SW[0])
    output reg  [25:0] q = 26'd0   // 전원 투입 값 0 (선언에서 초기화)
);
    always @(negedge n_cp or negedge n_rd)
        if (!n_rd)                  q <= 26'd0;
        else if (q == (N-1) * STEP) q <= 26'd0;
        else                        q <= q + STEP;
endmodule
