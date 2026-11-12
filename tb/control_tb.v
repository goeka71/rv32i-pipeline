`timescale 1ns/1ps

module control_tb;
    // ---- DUT 입력 ----
    reg  [6:0] opcode, funct7;
    reg  [2:0] funct3;
    // ---- DUT 출력 ----
    wire       RegWrite, ALUSrc, MemWrite, MemToReg;
    wire [1:0] ImmSrc, ALUOp, Branch;

    control dut (
        .opcode(opcode), .funct7(funct7), .funct3(funct3),
        .RegWrite(RegWrite), .ImmSrc(ImmSrc), .ALUSrc(ALUSrc), .ALUOp(ALUOp),
        .Branch(Branch), .MemWrite(MemWrite), .MemToReg(MemToReg)
    );

    // 출력 7개를 10비트 하나로 묶어서 한 번에 비교
    // 순서: RegWrite | ImmSrc(2) | ALUSrc | ALUOp(2) | Branch(2) | MemWrite | MemToReg
    wire [9:0] actual = {RegWrite, ImmSrc, ALUSrc, ALUOp, Branch, MemWrite, MemToReg};

    // mask: 1 = 비교함, 0 = don't care (결과에 영향 없는 칸)
    localparam [9:0] ALL         = 10'b11111_11111;
    localparam [9:0] NO_MEMTOREG = 10'b11111_11110; // RegWrite=0이라 MemToReg 무의미

    // opcode 상수
    localparam [6:0] OP_R      = 7'b0110011;
    localparam [6:0] OP_IMM    = 7'b0010011;
    localparam [6:0] OP_LOAD   = 7'b0000011;
    localparam [6:0] OP_STORE  = 7'b0100011;
    localparam [6:0] OP_BRANCH = 7'b1100011;

    integer pass_cnt = 0, fail_cnt = 0;

    task check;
        input [8*24-1:0] name;
        input [6:0] op;
        input [2:0] f3;
        input [6:0] f7;
        input [9:0] expected;
        input [9:0] mask;
        begin
            opcode = op; funct3 = f3; funct7 = f7;
            #1; // 조합회로가 안정될 시간
            if (((actual ^ expected) & mask) === 10'b0) begin
                pass_cnt = pass_cnt + 1;
                $display("PASS  %-22s", name);
            end else begin
                fail_cnt = fail_cnt + 1;
                $display("FAIL  %-22s", name);
                $display("        signal    : RW ImmSrc ALUSrc ALUOp Branch MW M2R");
                $display("        expected  : %b  %b     %b      %b    %b     %b  %b",
                         expected[9], expected[8:7], expected[6], expected[5:4],
                         expected[3:2], expected[1], expected[0]);
                $display("        actual    : %b  %b     %b      %b    %b     %b  %b",
                         actual[9], actual[8:7], actual[6], actual[5:4],
                         actual[3:2], actual[1], actual[0]);
            end
        end
    endtask

    initial begin
        $display("=== control unit test ===");
        //                                                  RW ImmSrc ALUSrc ALUOp Branch MW M2R
        // ---- 1. 제어신호 표 9줄 ----
        check("ADD",  OP_R,      3'b000, 7'b0000000, {1'b1, 2'b00, 1'b0, 2'b00, 2'b00, 1'b0, 1'b0}, ALL);
        check("SUB",  OP_R,      3'b000, 7'b0100000, {1'b1, 2'b00, 1'b0, 2'b01, 2'b00, 1'b0, 1'b0}, ALL);
        check("AND",  OP_R,      3'b111, 7'b0000000, {1'b1, 2'b00, 1'b0, 2'b10, 2'b00, 1'b0, 1'b0}, ALL);
        check("OR",   OP_R,      3'b110, 7'b0000000, {1'b1, 2'b00, 1'b0, 2'b11, 2'b00, 1'b0, 1'b0}, ALL);
        check("ADDI", OP_IMM,    3'b000, 7'b0000000, {1'b1, 2'b01, 1'b1, 2'b00, 2'b00, 1'b0, 1'b0}, ALL);
        check("LW",   OP_LOAD,   3'b010, 7'b0000000, {1'b1, 2'b01, 1'b1, 2'b00, 2'b00, 1'b0, 1'b1}, ALL);
        check("SW",   OP_STORE,  3'b010, 7'b0000000, {1'b0, 2'b10, 1'b1, 2'b00, 2'b00, 1'b1, 1'b0}, NO_MEMTOREG);
        check("BEQ",  OP_BRANCH, 3'b000, 7'b0000000, {1'b0, 2'b11, 1'b0, 2'b01, 2'b10, 1'b0, 1'b0}, NO_MEMTOREG);
        check("BNE",  OP_BRANCH, 3'b001, 7'b0000000, {1'b0, 2'b11, 1'b0, 2'b01, 2'b11, 1'b0, 1'b0}, NO_MEMTOREG);

        // ---- 2. 함정 케이스: [31:25]가 funct7이 아니라 즉시값인 경우 ----
        // 음수 즉시값이면 inst[31:25]가 1로 채워짐 → funct7을 먼저 보면 오동작
        check("ADDI imm<0 (f7=1111111)", OP_IMM,    3'b000, 7'b1111111, {1'b1, 2'b01, 1'b1, 2'b00, 2'b00, 1'b0, 1'b0}, ALL);
        // 즉시값 상위 비트가 우연히 SUB의 funct7과 같은 경우
        check("ADDI f7=0100000",         OP_IMM,    3'b000, 7'b0100000, {1'b1, 2'b01, 1'b1, 2'b00, 2'b00, 1'b0, 1'b0}, ALL);
        check("LW  imm<0 (f7=1111111)",  OP_LOAD,   3'b010, 7'b1111111, {1'b1, 2'b01, 1'b1, 2'b00, 2'b00, 1'b0, 1'b1}, ALL);
        check("SW  imm<0 (f7=1111111)",  OP_STORE,  3'b010, 7'b1111111, {1'b0, 2'b10, 1'b1, 2'b00, 2'b00, 1'b1, 1'b0}, NO_MEMTOREG);
        check("BEQ imm<0 (f7=1111111)",  OP_BRANCH, 3'b000, 7'b1111111, {1'b0, 2'b11, 1'b0, 2'b01, 2'b10, 1'b0, 1'b0}, NO_MEMTOREG);
        check("BNE imm<0 (f7=1111111)",  OP_BRANCH, 3'b001, 7'b1111111, {1'b0, 2'b11, 1'b0, 2'b01, 2'b11, 1'b0, 1'b0}, NO_MEMTOREG);

        // ---- 3. 모르는 opcode: 아무것도 쓰면 안 됨 (레지스터/메모리/PC 보호) ----
        // RegWrite=0, MemWrite=0, Branch=00 만 확인하고 나머지는 don't care
        check("unknown opcode 0000000", 7'b0000000, 3'b000, 7'b0000000, {1'b0, 2'b00, 1'b0, 2'b00, 2'b00, 1'b0, 1'b0}, 10'b10000_01110);
        check("unknown opcode 1111111", 7'b1111111, 3'b111, 7'b1111111, {1'b0, 2'b00, 1'b0, 2'b00, 2'b00, 1'b0, 1'b0}, 10'b10000_01110);

        $display("=========================");
        $display("TOTAL: %0d PASS, %0d FAIL", pass_cnt, fail_cnt);
        if (fail_cnt == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule