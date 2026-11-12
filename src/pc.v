module pc(clk, reset, next_pc, pc);
    input clk, reset;
    input [31:0] next_pc;
    output reg [31:0] pc;

    always@(posedge clk)
    begin
        if (reset == 1) pc <= 0;
        else pc <= next_pc;
    end
endmodule