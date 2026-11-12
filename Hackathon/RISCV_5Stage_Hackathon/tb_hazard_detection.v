`timescale 1ns/1ps

module tb_hazard_detection;

reg id_ex_mem_read;
reg [4:0] id_ex_rd;

reg [4:0] if_id_rs1;
reg [4:0] if_id_rs2;

reg if_id_uses_rs1;
reg if_id_uses_rs2;

wire pc_write;
wire if_id_write;
wire control_stall;

hazard_detection uut (

    .id_ex_mem_read(id_ex_mem_read),
    .id_ex_rd(id_ex_rd),

    .if_id_rs1(if_id_rs1),
    .if_id_rs2(if_id_rs2),

    .if_id_uses_rs1(if_id_uses_rs1),
    .if_id_uses_rs2(if_id_uses_rs2),

    .pc_write(pc_write),
    .if_id_write(if_id_write),
    .control_stall(control_stall)

);

initial begin

    $display("----------------------------------------");
    $display("RISC-V HAZARD DETECTION UNIT TEST");
    $display("----------------------------------------");

    // Test 1: No load instruction
    id_ex_mem_read = 0;
    id_ex_rd = 1;
    if_id_rs1 = 1;
    if_id_rs2 = 2;
    if_id_uses_rs1 = 1;
    if_id_uses_rs2 = 1;

    #10;
    $display("Test 1: PC=%b IF_ID=%b Stall=%b (Expected 1 1 0)",
             pc_write, if_id_write, control_stall);

    // Test 2: Load-use hazard on rs1
    id_ex_mem_read = 1;
    id_ex_rd = 5;
    if_id_rs1 = 5;
    if_id_rs2 = 6;

    #10;
    $display("Test 2: PC=%b IF_ID=%b Stall=%b (Expected 0 0 1)",
             pc_write, if_id_write, control_stall);

    // Test 3: Load-use hazard on rs2
    id_ex_rd = 7;
    if_id_rs1 = 3;
    if_id_rs2 = 7;

    #10;
    $display("Test 3: PC=%b IF_ID=%b Stall=%b (Expected 0 0 1)",
             pc_write, if_id_write, control_stall);

    // Test 4: No hazard because registers are different
    id_ex_rd = 8;
    if_id_rs1 = 2;
    if_id_rs2 = 3;

    #10;
    $display("Test 4: PC=%b IF_ID=%b Stall=%b (Expected 1 1 0)",
             pc_write, if_id_write, control_stall);

    // Test 5: No hazard when destination is x0
    id_ex_rd = 0;
    if_id_rs1 = 0;
    if_id_rs2 = 0;

    #10;
    $display("Test 5: PC=%b IF_ID=%b Stall=%b (Expected 1 1 0)",
             pc_write, if_id_write, control_stall);

    // Test 6: Unused source register must not cause a stall
    id_ex_rd = 9;
    if_id_rs1 = 9;
    if_id_rs2 = 2;
    if_id_uses_rs1 = 0;
    if_id_uses_rs2 = 1;

    #10;
    $display("Test 6: PC=%b IF_ID=%b Stall=%b (Expected 1 1 0)",
             pc_write, if_id_write, control_stall);

    $display("----------------------------------------");
    $display("HAZARD DETECTION TEST COMPLETED");
    $display("----------------------------------------");

    $finish;

end

endmodule