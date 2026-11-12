// 입력 : [31:25], [24:20], [11:7]
// 출력 : imm_i, imm_s, imm_b

module immGen(_31_25, _24_20, _11_7, imm_i, imm_s, imm_b);
    input [6:0] _31_25;
    input [4:0] _24_20, _11_7;
    output [31:0] imm_i, imm_s, imm_b;

    assign imm_i = {{20{_31_25[6]}}, _31_25, _24_20};
    assign imm_s = {{20{_31_25[6]}}, _31_25, _11_7};
    assign imm_b = {{20{_31_25[6]}}, _11_7[0], _31_25[5:0], _11_7[4:1], 1'b0};
endmodule