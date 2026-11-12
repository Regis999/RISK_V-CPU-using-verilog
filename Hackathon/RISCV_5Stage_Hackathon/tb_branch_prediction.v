`timescale 1ns/1ps

module tb_branch_prediction;

reg clk;
reg reset;

wire [31:0] predict_pc;
wire predict_taken;
wire [31:0] predicted_target;

reg update_valid;
reg [31:0] update_pc;
reg actual_taken;
reg [31:0] actual_target;

branch_predictor DUT (
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

assign predict_pc = 32'h00000004;

always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;
    update_valid = 0;
    update_pc = 0;
    actual_taken = 0;
    actual_target = 0;

    #10;
    reset = 0;

    // First prediction: BTB miss
    #1;
    if (predict_taken == 0)
        $display("PASS: Initial prediction is NOT TAKEN");
    else
        $display("FAIL: Initial prediction");

    // Train predictor: branch taken
    @(negedge clk);
    update_valid = 1;
    update_pc = 32'h00000004;
    actual_taken = 1;
    actual_target = 32'h00000020;

    @(negedge clk);
    update_valid = 0;

    // Check prediction after training
    #1;
    if (predict_taken == 1 &&
        predicted_target == 32'h00000020)
        $display("PASS: Predictor learned TAKEN branch");
    else
        $display("FAIL: Predictor did not learn branch");

    // Train taken one more time
    @(negedge clk);
    update_valid = 1;
    update_pc = 32'h00000004;
    actual_taken = 1;
    actual_target = 32'h00000020;

    @(negedge clk);
    update_valid = 0;

    #1;
    if (predict_taken == 1)
        $display("PASS: Predictor continues predicting TAKEN");
    else
        $display("FAIL: TAKEN prediction");

    // Train not taken once
    @(negedge clk);
    update_valid = 1;
    update_pc = 32'h00000004;
    actual_taken = 0;
    actual_target = 32'h00000020;

    @(negedge clk);
    update_valid = 0;

    #1;
    if (predict_taken == 1)
        $display("PASS: Counter remains TAKEN after one miss");
    else
        $display("FAIL: Counter changed too early");

    // Train not taken again
    @(negedge clk);
    update_valid = 1;
    update_pc = 32'h00000004;
    actual_taken = 0;
    actual_target = 32'h00000020;

    @(negedge clk);
    update_valid = 0;

    #1;
    if (predict_taken == 0)
        $display("PASS: Predictor changed to NOT TAKEN");
    else
        $display("FAIL: Predictor did not change");

    $display("==============================");
    $display("BRANCH PREDICTOR TEST FINISHED");
    $display("==============================");

    $finish;
end

endmodule