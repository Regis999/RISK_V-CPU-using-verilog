`timescale 1ns/1ps

module tb_immediate_generator;

reg [31:0] instruction;
wire [31:0] immediate;

immediate_generator uut (
    .instruction(instruction),
    .immediate(immediate)
);

initial begin

    $display("--------------------------------------");
    $display("RISC-V IMMEDIATE GENERATOR TEST");
    $display("--------------------------------------");

    // I-TYPE: ADDI x1, x0, 5
    instruction = 32'h00500093;
    #10;
    $display("ADDI immediate = %0d (Expected 5)", immediate);

    // S-TYPE: SW x2, 12(x1)
    instruction = {
        7'b0000000,
        5'd2,
        5'd1,
        3'b010,
        5'd12,
        7'b0100011
    };
    #10;
    $display("SW immediate = %0d (Expected 12)", immediate);

    // B-TYPE: BEQ x1, x2, 16
    instruction = {
        1'b0,
        6'b000000,
        5'd2,
        5'd1,
        3'b000,
        4'b1000,
        1'b0,
        7'b1100011
    };
    #10;
    $display("BEQ immediate = %0d (Expected 16)", immediate);

    // U-TYPE: LUI x1, 0x12345
    instruction = 32'h123450B7;
    #10;
    $display("LUI immediate = %h (Expected 12345000)", immediate);

    // J-TYPE: JAL x1, 8
    instruction = {
        1'b0,
        10'b0000000100,
        1'b0,
        8'b00000000,
        5'd1,
        7'b1101111
    };
    #10;
    $display("JAL immediate = %0d (Expected 8)", immediate);

    $display("--------------------------------------");
    $display("IMMEDIATE GENERATOR TEST COMPLETED");
    $display("--------------------------------------");

    $finish;

end

endmodule