module tb;
    reg [31:0] pc;
    wire [31:0] imem_o;

    imem u1(.pc(pc), .imem_o(imem_o));

    initial begin
        pc = 0;
        #5
        $display("pc = %d, instruction = %d", pc, imem_o);

        pc = 4;
        #5
        $display("pc = %d, instruction = %d", pc, imem_o);

        pc = 8;
        #5
        $display("pc = %d, instruction = %d", pc, imem_o);

        pc = 12;
        #5
        $display("pc = %d, instruction = %d", pc, imem_o);
        $finish;
    end
endmodule