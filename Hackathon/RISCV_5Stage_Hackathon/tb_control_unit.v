`timescale 1ns/1ps

module tb_control_unit;

reg [6:0] opcode;
reg [2:0] funct3;
reg [6:0] funct7;

wire reg_write;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire alu_src;
wire branch;
wire [3:0] alu_control;

control_unit uut (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .alu_src(alu_src),
    .branch(branch),
    .alu_control(alu_control)
);

initial begin

    $display("-------------------------------------");
    $display("RISC-V CONTROL UNIT TEST");
    $display("-------------------------------------");

    // ADD instruction
    opcode = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10;
    $display("ADD: RegWrite=%b ALUControl=%b",
             reg_write, alu_control);

    // SUB instruction
    funct7 = 7'b0100000;
    #10;
    $display("SUB: RegWrite=%b ALUControl=%b",
             reg_write, alu_control);

    // AND instruction
    funct3 = 3'b111;
    funct7 = 7'b0000000;
    #10;
    $display("AND: ALUControl=%b", alu_control);

    // ADDI instruction
    opcode = 7'b0010011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10;
    $display("ADDI: RegWrite=%b ALUSrc=%b ALUControl=%b",
             reg_write, alu_src, alu_control);

    // LOAD WORD
    opcode = 7'b0000011;
    #10;
    $display("LW: RegWrite=%b MemRead=%b MemToReg=%b",
             reg_write, mem_read, mem_to_reg);

    // STORE WORD
    opcode = 7'b0100011;
    #10;
    $display("SW: MemWrite=%b ALUSrc=%b",
             mem_write, alu_src);

    // BEQ instruction
    opcode = 7'b1100011;
    funct3 = 3'b000;
    #10;
    $display("BEQ: Branch=%b ALUControl=%b",
             branch, alu_control);

    $display("-------------------------------------");
    $display("CONTROL UNIT TEST COMPLETED");
    $display("-------------------------------------");

    $finish;

end

endmodule