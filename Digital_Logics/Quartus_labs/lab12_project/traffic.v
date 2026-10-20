// traffic.v : 교차로 신호등 (Lab 12 선택 과제 1, 22.5.4절의 코드와 같다. 주석만 늘렸다)
//   무어 FSM(상태 S0-S3) + 초 타이머. clk_div.v가 함께 필요하다.
//   A, B = {적, 황, 녹} (1 = 켜짐 → LEDR에 그대로 연결)
module traffic #(parameter N = 50_000_000, TG = 5, TY = 2) (
    input  wire clk, rst_n,
    output wire [2:0] A,        // {적, 황, 녹} 남북 방향
    output wire [2:0] B         // {적, 황, 녹} 동서 방향
);
    localparam S0 = 2'b00,      // A 녹, B 적
               S1 = 2'b01,      // A 황, B 적
               S2 = 2'b10,      // A 적, B 녹
               S3 = 2'b11;      // A 적, B 황
    reg  [1:0] state;
    reg  [3:0] sec;             // 현재 상태에 머문 초
    wire       tick;
    clk_div #(.N(N)) u_div (.clk(clk), .rst_n(rst_n), .tick(tick));

    wire [3:0] dur  = state[0] ? TY : TG;          // 황이면 2초, 녹이면 5초
    wire       done = tick && (sec == dur - 1);    // 이 상태의 마지막 초가 끝남

    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin state <= S0; sec <= 0; end
        else if (done) begin state <= state + 2'b01; sec <= 0; end   // S3 다음은 S0
        else if (tick)  sec <= sec + 4'd1;

    assign A = (state == S0) ? 3'b001 : (state == S1) ? 3'b010 : 3'b100;
    assign B = (state == S2) ? 3'b001 : (state == S3) ? 3'b010 : 3'b100;
endmodule
