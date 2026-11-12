module tb;
    reg [6:0] _31_25;
    reg [4:0] _24_20, _11_7;
    wire [31:0] imm_i, imm_s, imm_b;

    immGen u1(._31_25(_31_25), ._24_20(_24_20), ._11_7(_11_7), .imm_i(imm_i), .imm_s(imm_s), .imm_b(imm_b));
    initial begin
        _31_25 = 7'b000_0001;
        _24_20 = 5'b000_10;
        _11_7 = 5'b001_00;
        #5
        $display("imm_i = %b, imm_s = %b, imm_b = %b", imm_i, imm_s, imm_b);
        $finish;
    end
endmodule