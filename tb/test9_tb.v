module test9_tb;
    reg clk = 0;
    reg reset;
    wire [31:0] pc, instr;

    integer i;

    cpu v1(.clk(clk), .pc(pc), .reset(reset), .instr(instr));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/test9.vcd");
        $dumpvars(0, test9_tb);

        reset = 1;
        #15
        reset = 0;
        
        for (i = 0; i < 30; i = i + 1) begin
            $display("time = %0d, pc = %0d, instr = %b", $time, pc, instr);
            #10;
        end
        
        for (i = 0; i < 7; i = i + 1) begin
            $display("%0d's register = %0d", i, $signed(v1.u_regfile.registers[i]));
        end
        $finish;
    end
endmodule