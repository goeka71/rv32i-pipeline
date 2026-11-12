module control(opcode, funct7, funct3, RegWrite, ImmSrc, ALUSrc, ALUOp, Branch, MemWrite, MemToReg);
    input [6:0] opcode, funct7;
    input [2:0] funct3;
    output reg RegWrite, ALUSrc, MemWrite, MemToReg;
    output reg [1:0] ImmSrc, ALUOp, Branch;

    always@(*)
    begin
        RegWrite = 1;
        ImmSrc = 2'b00;
        ALUSrc = 0;
        ALUOp = 00;
        Branch = 2'b00;
        MemWrite = 0;
        MemToReg = 0;

        case (opcode)
            7'b0110011 : begin // R-Type
                case (funct3)
                    3'b000 : begin
                        if (funct7 == 7'b0000_000) ALUOp = 2'b00;
                        else if (funct7 == 7'b0100_000) ALUOp = 2'b01;
                    end
                    3'b111 : ALUOp = 2'b10;
                    3'b110 : ALUOp = 2'b11;
                endcase
            end

            7'b0010011 : begin // ADDI
                ImmSrc = 2'b01;
                ALUSrc = 1;
            end

            7'b0000011 : begin // LW 
                ImmSrc = 2'b01;
                ALUSrc = 1;
                MemToReg = 1;
            end

            7'b0100011 : begin // SW
                RegWrite = 0;
                ImmSrc = 2'b10;
                ALUSrc = 1;
                MemWrite = 1;
            end

            7'b1100011 : begin// B-Type
                RegWrite = 0;
                ImmSrc = 2'b11;
                ALUOp = 2'b01;
                if (funct3 == 3'b000) Branch = 2'b10;
                else Branch = 2'b11;
            end

            default : RegWrite = 0;
        endcase
    end
endmodule