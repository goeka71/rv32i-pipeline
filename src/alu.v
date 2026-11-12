module alu(i1, i2, ALUOp, AluRes, zero);
    input [31:0] i1, i2;
    input [1:0] ALUOp;
    output reg [31:0] AluRes;
    output reg zero;

    always@(*) begin
        case (ALUOp)
            2'b00: AluRes = i1 + i2; // 덧셈 = 00
            2'b01: AluRes = i1 - i2; // 뺄셈 = 01
            2'b10: AluRes = i1 & i2; // AND = 10
            2'b11: AluRes = i1 | i2; // OR = 11
        endcase

        if (AluRes == 0) zero = 1'b1;
        else zero = 1'b0;
    end
endmodule