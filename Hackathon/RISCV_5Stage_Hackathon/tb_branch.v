
`timescale 1ns/1ps

module tb_branch;

reg clk;
reg reset;
wire [31:0] pc_debug;

riscv_top DUT (
    .clk(clk),
    .reset(reset),
    .pc_debug(pc_debug)
);

always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;

    // Wait for instruction memory initialization
    #1;

    // Branch test program
    DUT.IMEM.memory[0] = 32'h00500093; // ADDI x1,x0,5
    DUT.IMEM.memory[1] = 32'h00108463; // BEQ x1,x1,+8
    DUT.IMEM.memory[2] = 32'h06300113; // ADDI x2,x0,99 (must be skipped)
    DUT.IMEM.memory[3] = 32'h00700193; // ADDI x3,x0,7

    #19;
    reset = 0;

    #200;

    $display("===== BRANCH TEST RESULTS =====");

    $display("Register x1 = %0d (Expected 5)", DUT.RF.registers[1]);
    $display("Register x2 = %0d (Expected 0)", DUT.RF.registers[2]);
    $display("Register x3 = %0d (Expected 7)", DUT.RF.registers[3]);

    if (DUT.RF.registers[1] == 5 &&
        DUT.RF.registers[2] == 0 &&
        DUT.RF.registers[3] == 7)
        $display("PASS: BRANCH TEST");
    else
        $display("FAIL: BRANCH TEST");

    $display("==============================");

    $finish;

end

endmodule
