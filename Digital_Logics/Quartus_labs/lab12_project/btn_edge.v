// btn_edge.v : 버튼 에지 검출 (Lab 12, 22.3.5절)
//   KEY는 누르면 0(액티브 로우, 보드에서 디바운스됨). 누른 순간 한 클럭만 pulse = 1.
//   d1 : 버튼을 클럭에 맞추는 동기화기, d2 : 한 클럭 전 값
//   pulse = d2 & ~d1  (직전 1, 지금 0 → 누른 순간)
module btn_edge (
    input  wire clk,
    input  wire key_n,      // KEY[i]
    output wire pulse       // 누를 때마다 1클럭 폭 펄스 하나
);
    reg d1, d2;
    always @(posedge clk) begin
        d1 <= key_n;
        d2 <= d1;
    end
    assign pulse = d2 & ~d1;
endmodule
