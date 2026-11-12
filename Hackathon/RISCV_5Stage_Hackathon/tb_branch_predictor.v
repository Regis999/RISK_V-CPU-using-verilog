`timescale 1ns/1ps

module tb_branch_predictor;

reg clk;
reg reset;

reg [31:0] predict_pc;

wire predict_taken;
wire [31:0] predicted_target;

reg update_valid;
reg [31:0] update_pc;
reg actual_taken;
reg [31:0] actual_target;

branch_predictor uut (

    .clk(clk),
    .reset(reset),

    .predict_pc(predict_pc),
    .predict_taken(predict_taken),
    .predicted_target(predicted_target),

    .update_valid(update_valid),
    .update_pc(update_pc),
    .actual_taken(actual_taken),
    .actual_target(actual_target)

);

always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;

    predict_pc = 32'h00000100;

    update_valid = 0;
    update_pc = 0;
    actual_taken = 0;
    actual_target = 0;

    $display("----------------------------------------");
    $display("RISC-V BRANCH PREDICTOR TEST");
    $display("----------------------------------------");

    // Reset predictor
    #12;
    reset = 0;

    // Test 1: First prediction - BTB miss
    #2;
    $display("Test 1: Taken=%b (Expected 0)", predict_taken);

    // Train branch as taken
    @(negedge clk);
    update_valid = 1;
    update_pc = 32'h00000100;
    actual_taken = 1;
    actual_target = 32'h00000120;

    @(negedge clk);
    update_valid = 0;

    #2;
    $display("Test 2: Taken=%b Target=%h (Expected 1, 00000120)",
             predict_taken, predicted_target);

    // Train the same branch as taken again
    @(negedge clk);
    update_valid = 1;
    update_pc = 32'h00000100;
    actual_taken = 1;
    actual_target = 32'h00000120;

    @(negedge clk);
    update_valid = 0;

    #2;
    $display("Test 3: Taken=%b (Expected 1)", predict_taken);

    // One not-taken result should not reverse strong prediction
    @(negedge clk);
    update_valid = 1;
    update_pc = 32'h00000100;
    actual_taken = 0;
    actual_target = 32'h00000120;

    @(negedge clk);
    update_valid = 0;

    #2;
    $display("Test 4: Taken=%b (Expected 1)", predict_taken);

    // Second not-taken result changes prediction
    @(negedge clk);
    update_valid = 1;
    update_pc = 32'h00000100;
    actual_taken = 0;
    actual_target = 32'h00000120;

    @(negedge clk);
    update_valid = 0;

    #2;
    $display("Test 5: Taken=%b (Expected 0)", predict_taken);

    // Test another branch at a different tag
    predict_pc = 32'h00000140;

    #2;
    $display("Test 6: Different branch Taken=%b (Expected 0)",
             predict_taken);

    $display("----------------------------------------");
    $display("BRANCH PREDICTOR TEST COMPLETED");
    $display("----------------------------------------");

    $finish;

end

endmodule