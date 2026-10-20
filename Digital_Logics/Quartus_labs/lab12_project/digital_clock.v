// digital_clock.v : 디지털 시계 최상위 (Lab 12 Part B, 22.4.5절)
//   HEX5 HEX4 : 시 00..23,  HEX3 HEX2 : 분 00..59,  HEX1 HEX0 : 초 00..59
//   KEY[0] 리셋(00:00:00), SW[0] = 1 설정 모드(초 정지), KEY[1] 분 +1, KEY[2] 시 +1
//   모든 플립플롭이 CLOCK_50 하나를 쓰고, 1초 tick과 자리올림 co는 인에이블로만 쓴다.
//   digital_clock_sch.bdf와 같은 연결이다(인스턴스 이름 = 회로도 inst 이름).
module digital_clock #(
    parameter N = 50_000_000          // 분주비. 테스트벤치에서 #(.N(4))
) (
    input  wire       CLOCK_50,
    input  wire [3:0] KEY,            // 누르면 0
    input  wire [9:0] SW,             // 위로 올리면 1
    output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5   // 0 = 세그먼트 켜짐
);
    wire rst_n = KEY[0];
    wire set   = SW[0];
    wire tick, m_btn, h_btn, s_co, m_co;
    wire [3:0] s10, s1, m10, m1, h10, h1;

    clk_div  #(.N(N)) u_div (.clk(CLOCK_50), .rst_n(rst_n), .tick(tick));
    btn_edge u_bm (.clk(CLOCK_50), .key_n(KEY[1]), .pulse(m_btn));   // 분 버튼
    btn_edge u_bh (.clk(CLOCK_50), .key_n(KEY[2]), .pulse(h_btn));   // 시 버튼

    // 설정 모드 선택 (9장 2x1 MUX). 회로도에서는 NOT, AND2, OR2로 그렸다.
    wire en_s = tick & ~set;                    // 설정 모드에서는 초가 멈춘다
    wire en_m = set ? m_btn : s_co;             // 설정이면 분 버튼, 아니면 초의 자리올림
    wire en_h = set ? h_btn : m_co;             // 설정이면 시 버튼, 아니면 분의 자리올림

    cnt60 u_sec (.clk(CLOCK_50), .rst_n(rst_n), .en(en_s), .tens(s10), .ones(s1), .co(s_co));
    cnt60 u_min (.clk(CLOCK_50), .rst_n(rst_n), .en(en_m), .tens(m10), .ones(m1), .co(m_co));
    cnt24 u_hr  (.clk(CLOCK_50), .rst_n(rst_n), .en(en_h), .tens(h10), .ones(h1));

    hex7seg u_d0 (.SW(s1),  .HEX0(HEX0));
    hex7seg u_d1 (.SW(s10), .HEX0(HEX1));
    hex7seg u_d2 (.SW(m1),  .HEX0(HEX2));
    hex7seg u_d3 (.SW(m10), .HEX0(HEX3));
    hex7seg u_d4 (.SW(h1),  .HEX0(HEX4));
    hex7seg u_d5 (.SW(h10), .HEX0(HEX5));
endmodule
