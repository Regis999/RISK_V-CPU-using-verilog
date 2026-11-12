`timescale 1ns/1ps

module tb_forwarding_unit;

reg [4:0] rs1;
reg [4:0] rs2;

reg [4:0] ex_mem_rd;
reg ex_mem_reg_write;

reg [4:0] mem_wb_rd;
reg mem_wb_reg_write;

wire [1:0] forward_a;
wire [1:0] forward_b;

forwarding_unit uut (

    .rs1(rs1),
    .rs2(rs2),

    .ex_mem_rd(ex_mem_rd),
    .ex_mem_reg_write(ex_mem_reg_write),

    .mem_wb_rd(mem_wb_rd),
    .mem_wb_reg_write(mem_wb_reg_write),

    .forward_a(forward_a),
    .forward_b(forward_b)

);

initial begin

    $display("----------------------------------------");
    $display("RISC-V FORWARDING UNIT TEST");
    $display("----------------------------------------");

    // Test 1: No forwarding
    rs1 = 1;
    rs2 = 2;
    ex_mem_rd = 3;
    ex_mem_reg_write = 1;
    mem_wb_rd = 4;
    mem_wb_reg_write = 1;

    #10;
    $display("Test 1: Forward A=%b B=%b (Expected 00, 00)",
             forward_a, forward_b);

    // Test 2: Forward from EX/MEM
    rs1 = 5;
    rs2 = 6;
    ex_mem_rd = 5;
    ex_mem_reg_write = 1;
    mem_wb_rd = 7;
    mem_wb_reg_write = 1;

    #10;
    $display("Test 2: Forward A=%b B=%b (Expected 10, 00)",
             forward_a, forward_b);

    // Test 3: Forward from MEM/WB
    rs1 = 8;
    rs2 = 9;
    ex_mem_rd = 3;
    ex_mem_reg_write = 1;
    mem_wb_rd = 9;
    mem_wb_reg_write = 1;

    #10;
    $display("Test 3: Forward A=%b B=%b (Expected 00, 01)",
             forward_a, forward_b);

    // Test 4: Forward both operands
    rs1 = 10;
    rs2 = 11;
    ex_mem_rd = 10;
    ex_mem_reg_write = 1;
    mem_wb_rd = 11;
    mem_wb_reg_write = 1;

    #10;
    $display("Test 4: Forward A=%b B=%b (Expected 10, 01)",
             forward_a, forward_b);

    // Test 5: EX/MEM has priority
    rs1 = 12;
    rs2 = 12;
    ex_mem_rd = 12;
    ex_mem_reg_write = 1;
    mem_wb_rd = 12;
    mem_wb_reg_write = 1;

    #10;
    $display("Test 5: Forward A=%b B=%b (Expected 10, 10)",
             forward_a, forward_b);

    // Test 6: Never forward register x0
    rs1 = 0;
    rs2 = 0;
    ex_mem_rd = 0;
    ex_mem_reg_write = 1;
    mem_wb_rd = 0;
    mem_wb_reg_write = 1;

    #10;
    $display("Test 6: Forward A=%b B=%b (Expected 00, 00)",
             forward_a, forward_b);

    $display("----------------------------------------");
    $display("FORWARDING UNIT TEST COMPLETED");
    $display("----------------------------------------");

    $finish;

end

endmodule