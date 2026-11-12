module tb;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] write_data;
    reg clk = 0;
    reg RegWrite;
    wire [31:0] rn1, rn2;

    regfile u1(.rs1(rs1), .rs2(rs2), .rd(rd), .write_data(write_data), .clk(clk), .RegWrite(RegWrite), .rn1(rn1), .rn2(rn2));
    
    always #5 clk = ~clk;

    initial begin
        RegWrite = 1;
        rd = 5'b1; // 주소 1
        write_data = 32'b0011; // 쓰는 값 3
        $display("Destination Address = %d, Write Data = %d, RegWrite = %d", rd, write_data, RegWrite);
        #10

        rd = 5'b010; // 주소 2
        write_data = 32'b0100; // 쓰는 값 4
        $display("Destination Address = %d, Write Data = %d, RegWrite = %d", rd, write_data, RegWrite);
        #10

        RegWrite = 0;
        rs1 = 3'b001; // 주소1 = 1
        rs2 = 3'b010; // 주소2 = 2
        $display("rs1 = %d, rs2 = %d, RegWrite = %d", rs1, rs2, RegWrite);
        #5
        $display("rs1 value = %d, rs2 value = %d", rn1, rn2);
        
        $finish;
    end
endmodule