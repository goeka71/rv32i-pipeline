/* 전체 동일 과정
    1. pc값 -> imem.v 입력
    2. imem.v 결과값
        - funct7, funct3, opcode -> control.v : 제어신호들 출력
        - _31_25, _24_20, _11_7 -> immGen.v : imm값들 출력
            - 결과적으로 32비트 값 imm_i, imm_s, imm_b 만들어짐
        - _24_20, _19_15, _11_7 -> regfile.v : 레지스터 로드/스토어
    3. regfile.v에서 _24_20, _19_15의 레지스터값 READ
        - 결과적으로 32비트 값 rn1(_19_15), rn2(_24_20) 만들어짐
    4. ImmSrc에 따라 적절한 imm 값이 골라짐
    5. ALUSrc Src에 따라 rn2 vs. imm 중 적절한 값이 골라짐
    6. ALUOp에 따라 alu.v에서 적절한 연산이 이루어짐
*/

/*
    R타입 -> ADDI -> LW -> SW -> BEQ + BNE 순서로 구현
    1. R타입 
        - RegWrite = 1 : 결과값을 레지스터 rd에 WRITE
        - ImmSrc = 00 : imm 값이 0(선택 X)
        - ALUSrc = 0 : imm vs rn2에서 rn2 선택
*/

module cpu(
    input clk,
    input reset,
    output [31:0] pc,
    output [31:0] instr
);
    wire [31:0] next_pc;

    // 명령어 구성
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [4:0] _24_20, _19_15, _11_7;
    wire [6:0] _31_25; // 이게 funct7 역할도 함. 
    
    // 제어신호
    wire RegWrite, ALUSrc, MemWrite, MemToReg;
    wire [1:0] ImmSrc, ALUOp, Branch;

    // 32비트 : 레지스터 값 & imm
    wire [31:0] rn1, rn2, imm_i, imm_s, imm_b, offset;

    wire [31:0] alu_res;
    wire zero;

    wire [31:0] load_data;

    wire branch0, branch1;
    wire PCSrc;

    assign next_pc = PCSrc ? pc + offset : pc + 4;

    pc u_pc(.clk(clk), .reset(reset), .next_pc(next_pc), .pc(pc)); // posedge마다 pc <= next_pc(=pc+4)가 작동 (branch의 경우 예외)
    imem u_imem(.pc(pc), .imem_o(instr)); // pc값에 맞는 imem 내 명령어가 instr에 들어감
    
    // 명령어 분할
    assign opcode = instr[6:0];
    assign _11_7 = instr[11:7];
    assign funct3 = instr[14:12];
    assign _19_15 = instr[19:15];
    assign _24_20 = instr[24:20];
    assign _31_25 = instr[31:25];

    // 분할 결과 통해 제어신호 도출
    control u_control(opcode, _31_25, funct3, RegWrite, ImmSrc, ALUSrc, ALUOp, Branch, MemWrite, MemToReg);

    // 분할 결과 통해 imm 값들 도출
    immGen u_immGen(._31_25(_31_25), ._24_20(_24_20), ._11_7(_11_7), 
                    .imm_i(imm_i), .imm_s(imm_s), .imm_b(imm_b));
    // ImmSrc = 00 -> offset = 0, 01 -> imm_i, 10 -> imm_s, 11 -> imm_b
    assign offset = (ImmSrc == 2'b00) ? 32'b0 : 
                    ((ImmSrc == 2'b01) ? imm_i : 
                    ((ImmSrc == 2'b10) ? imm_s :
                                        imm_b));

    // RegWrite = 1이면 레지스터 rd에 write_data WRITE.
        // MemToReg = 1 : dmem에서 READ한 값(read_data)을 레지스터 rd에 WRITE
        // MemToReg = 0 : alu_res를 레지스터 rd에 WRITE 
    // 항상 레지스터 rs1 값 rn1에, rs2 값 rn2에 READ.
    regfile u_regfile(.rs1(_19_15), .rs2(_24_20), .rd(_11_7), .write_data(MemToReg ? load_data : alu_res), 
                        .clk(clk), .RegWrite(RegWrite), 
                        .rn1(rn1), .rn2(rn2));

    // ALUSrc = 0 -> rn2, 1 -> offset
    alu u_alu(.i1(rn1), .i2(ALUSrc ? offset : rn2), .ALUOp(ALUOp), .AluRes(alu_res), .zero(zero));

    assign branch0 = Branch[0]; // beq or bne
    assign branch1 = Branch[1];  // branch or not
    assign PCSrc = (branch0 ^ zero) && branch1; // zero에 결과에 따라 PCSrc 저장

    // MemWrite = 1이면 주소 addr에 write_data WRITE.
    // 항상 주소 addr의 값을 read_data에 READ. 
    dmem u_dmem(.MemWrite(MemWrite), .clk(clk), .addr(alu_res), .write_data(rn2), .read_data(load_data));
endmodule