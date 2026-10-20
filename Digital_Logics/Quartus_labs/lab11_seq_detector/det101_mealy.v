// det101_mealy.v : 101 검출기 (Mealy, 중첩 허용)  19.7.3절 템플릿  Lab 11 Part B
// 19.7.3절 코드와 같다. 보드 LED로 상태를 보려고 출력 st(= state)만 더했다.
module det101_mealy (
    input  wire       clk,
    input  wire       rst_n,     // 비동기 리셋, 액티브 로우
    input  wire       x,
    output reg        z,
    output wire [1:0] st         // 현재 상태 (LED 표시용)
);
    localparam [1:0] S0 = 2'b00,   // 아직 아무것도 못 찾음
                     S1 = 2'b01,   // 마지막 입력이 1
                     S2 = 2'b10;   // 마지막 두 입력이 10

    reg [1:0] state, next;

    // 상태 레지스터
    always @(posedge clk or negedge rst_n)
        if (!rst_n) state <= S0;
        else        state <= next;

    // 다음 상태 논리와 출력 논리를 한 블록에 (둘 다 조합회로)
    always @* begin
        next = state;              // 기본값
        z    = 1'b0;               // 기본값
        case (state)
            S0: next = x ? S1 : S0;
            S1: next = x ? S1 : S2;
            S2: begin
                    next = x ? S1 : S0;
                    z    = x;      // Mealy: 상태 + 입력
                end
            default: next = S0;
        endcase
    end

    assign st = state;
endmodule
