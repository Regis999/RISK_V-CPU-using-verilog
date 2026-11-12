
`timescale 1ns/1ps

module tb_riscv_top;

reg clk;
reg reset;

wire [31:0] pc_debug;

// Instantiate processor
riscv_top DUT (
    .clk(clk),
    .reset(reset),
    .pc_debug(pc_debug)
);

// Generate clock
always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;

    $display("==================================");
    $display(" RISC-V 32-BIT PIPELINED PROCESSOR");
    $display("==================================");

    // Apply reset
    #20;
    reset = 0;

    // Allow processor to execute instructions
    #250;

    $display("");
    $display("========== FINAL RESULTS ==========");

    $display("Register x1 = %0d", DUT.RF.registers[1]);
    $display("Register x2 = %0d", DUT.RF.registers[2]);
    $display("Register x3 = %0d", DUT.RF.registers[3]);
    $display("Register x4 = %0d", DUT.RF.registers[4]);
    $display("Register x5 = %0d", DUT.RF.registers[5]);

    $display("Data Memory[0] = %0d", DUT.DMEM.memory[0]);

    $display("===================================");

    // Check expected results

    if (DUT.RF.registers[1] == 5)
        $display("PASS: ADDI x1");
    else
        $display("FAIL: ADDI x1");

    if (DUT.RF.registers[2] == 10)
        $display("PASS: ADDI x2");
    else
        $display("FAIL: ADDI x2");

    if (DUT.RF.registers[3] == 15)
        $display("PASS: ADD x3");
    else
        $display("FAIL: ADD x3");

    if (DUT.DMEM.memory[0] == 15)
        $display("PASS: SW instruction");
    else
        $display("FAIL: SW instruction");

    if (DUT.RF.registers[4] == 15)
        $display("PASS: LW instruction");
    else
        $display("FAIL: LW instruction");

    if (DUT.RF.registers[5] == 16)
        $display("PASS: Load-use forwarding");
    else
        $display("FAIL: Load-use forwarding");

    $display("==================================");
    $display("PROCESSOR TEST COMPLETED");

    $finish;

end

endmodule
