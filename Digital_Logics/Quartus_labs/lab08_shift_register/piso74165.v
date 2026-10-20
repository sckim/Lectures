// piso74165.v : 8비트 PISO 시프트 레지스터 74165와 같은 동작 (Lab 08 Part B)
// piso74165_sch.bdf(기존 PISO_74165\piso.bdf, 74165 매크로 하나)와 같은 핀을 쓴다.  12.4.3절
//   - Shift_load (SH/LD') = 0 : 병렬 입력 A–H를 클럭과 상관없이 즉시 저장(비동기 병렬 로드)
//   - Shift_load = 1          : (Clk OR Clk_Inhibit)의 상승 에지마다 QA ← SI, QB ← QA, …, QH ← QG
//   - Clk_Inhibit = 1         : OR 출력이 1에 고정되어 에지가 생기지 않음 → 시프트 정지
//   - 밖으로 나오는 것은 마지막 단 QH와 그 반전 QHn뿐이다.
// [주의] 이 모델은 로드 신호의 하강 에지에서 A–H를 저장한다. 실제 74165는 SH/LD' = 0인 동안
//        A–H를 계속 따라가므로, 로드 중에는 A–H를 바꾸지 않는다(테스트벤치도 그렇게 한다).
module piso74165 (
    input  wire Clk,           // KEY[0] 뗄 때 상승 에지
    input  wire SI,            // SW[8]  직렬 입력 (74165의 SER)
    input  wire A, B, C, D,    // SW[7] SW[6] SW[5] SW[4]   A가 첫 단(QA)에 실린다
    input  wire E, F, G, H,    // SW[3] SW[2] SW[1] SW[0]   H가 마지막 단(QH)에 실린다
    input  wire Shift_load,    // KEY[1] 누르면 0 = 로드
    input  wire Clk_Inhibit,   // SW[9]  1 = 클럭 막음
    output wire QH,            // LEDR[0]
    output wire QHn            // LEDR[1]
);
    reg  [7:0] q;                          // q[7] = QA … q[0] = QH
    wire clk_g = Clk | Clk_Inhibit;        // 74165 안의 OR 게이트
    always @(posedge clk_g or negedge Shift_load)
        if (!Shift_load) q <= {A, B, C, D, E, F, G, H};   // 비동기 병렬 로드
        else             q <= {SI, q[7:1]};               // 오른쪽(QA → QH) 시프트
    assign QH  = q[0];
    assign QHn = ~q[0];
endmodule
