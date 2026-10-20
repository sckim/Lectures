// safe.v : 디지털 금고 (Lab 12 선택 과제 2, 22.6절)
//   22.6.4절의 다음 상태 논리에 상태 레지스터와 무어 출력을 붙여 완성한 것. 비밀번호 P0-P1-P2 = 7-2-5
//   ent는 btn_edge로 만든 1클럭 펄스, d는 SW[3:0]. open = 열림(LEDR0), alarm = 경보(LEDR1)
module safe #(parameter [3:0] P0 = 4'd7, P1 = 4'd2, P2 = 4'd5) (
    input  wire       clk, rst_n,   // rst_n: 잠그기(처음 상태로)
    input  wire       ent,          // 1클럭 펄스: 한 자리 입력
    input  wire [3:0] d,            // 입력한 숫자
    output wire       open, alarm
);
    localparam S0 = 3'd0, S1 = 3'd1, S2 = 3'd2,   // 지금까지 모두 맞음
               E1 = 3'd3, E2 = 3'd4,              // 이미 틀린 자리가 있음
               OPEN = 3'd5, FAIL = 3'd6;
    reg [2:0] state, next;

    always @(posedge clk or negedge rst_n)        // 상태 레지스터
        if (!rst_n) state <= S0;
        else        state <= next;

    always @(*) begin                             // 다음 상태 논리
        next = state;
        if (ent)
            case (state)
                S0: next = (d == P0) ? S1   : E1;
                S1: next = (d == P1) ? S2   : E2;
                S2: next = (d == P2) ? OPEN : FAIL;
                E1: next = E2;
                E2: next = FAIL;
                default: next = state;            // OPEN, FAIL은 잠글 때까지 유지
            endcase
    end

    assign open  = (state == OPEN);               // 무어 출력
    assign alarm = (state == FAIL);
endmodule
