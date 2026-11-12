module tb;
    reg [31:0] i1, i2;
    reg [1:0] ALUOp;
    wire [31:0] AluRes;
    wire zero;

    alu u1(.i1(i1), .i2(i2), .ALUOp(ALUOp), .AluRes(AluRes), .zero(zero));

    initial begin
        i1 = 32'b0000000000000001;
        i2 = 32'b0000000000000001;
        ALUOp = 2'b00;

        #10

        $display("Input 1 = %d, Input 2 = %d, ALUOp = %d", i1, i2, ALUOp);
        $display("res = %d", AluRes);
        $finish;
    end
endmodule