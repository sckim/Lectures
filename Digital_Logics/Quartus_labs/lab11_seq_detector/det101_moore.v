// det101_moore.v : 101 검출기 (Moore, 중첩 허용)  19.7.2절 템플릿  Lab 11 Part B
// 19.7.2절 코드와 같다. 보드 LED로 상태를 보려고 출력 st(= state)만 더했다.
module det101_moore (
    input  wire       clk,
    input  wire       rst_n,     // 비동기 리셋, 액티브 로우
    input  wire       x,
    output wire       z,
    output wire [1:0] st         // 현재 상태 (LED 표시용)
);
    // ① 상태 이름: 숫자 대신 이름을 붙인다
    localparam [1:0] S0 = 2'b00,   // 아직 아무것도 못 찾음
                     S1 = 2'b01,   // 마지막 입력이 1
                     S2 = 2'b10,   // 마지막 두 입력이 10
                     S3 = 2'b11;   // 101을 찾음 (z = 1)

    reg [1:0] state, next;

    // ② 상태 레지스터: 클럭 에지에서만 바뀐다
    always @(posedge clk or negedge rst_n)
        if (!rst_n) state <= S0;
        else        state <= next;

    // ③ 다음 상태 논리: 조합회로
    always @* begin
        next = state;              // 기본값: 제자리 (래치 방지)
        case (state)
            S0: next = x ? S1 : S0;
            S1: next = x ? S1 : S2;
            S2: next = x ? S3 : S0;
            S3: next = x ? S1 : S2;
            default: next = S0;    // 쓰지 않는 코드에서 복귀
        endcase
    end

    // ④ 출력 논리: Moore는 상태만 본다
    assign z  = (state == S3);
    assign st = state;
endmodule
