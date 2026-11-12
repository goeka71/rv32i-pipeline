module regfile(rs1, rs2, rd, write_data, clk, RegWrite, rn1, rn2);
    input [4:0] rs1, rs2, rd; // 읽을 레지스터 번호들
    input [31:0] write_data; // 쓸 값(rdn)
    input clk;
    input RegWrite;
    output [31:0] rn1, rn2; // 레지스터 rs1, rs2의 값

    reg [31:0] registers [0:31];

    // Read
    assign rn1 = (rs1 == 0) ? 32'b0 : registers[rs1];
    assign rn2 = (rs2 == 0) ? 32'b0 : registers[rs2];

    // Write
    always@(posedge clk)
    begin
        if (rd != 0) begin
            if (RegWrite == 1'b1) begin
                registers[rd] <= write_data;
            end
        end
    end

endmodule