module dmem(MemWrite, clk, addr, write_data, read_data);
    input MemWrite, clk;
    input [31:0] addr, write_data;
    output [31:0] read_data;

    reg [31:0] memory [0:1023];

    assign read_data = memory[addr[11:2]];

    always@(posedge clk)
    begin
        if (MemWrite == 1) 
            memory[addr[11:2]] <= write_data;
    end
endmodule