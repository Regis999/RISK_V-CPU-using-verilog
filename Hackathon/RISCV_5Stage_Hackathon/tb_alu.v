`timescale 1ns/1ps

module tb_alu;

reg [31:0] a;
reg [31:0] b;
reg [3:0] alu_control;

wire [31:0] result;
wire zero;

alu uut (
    .a(a),
    .b(b),
    .alu_control(alu_control),
    .result(result),
    .zero(zero)
);

initial begin

$display("------------------------------");
    $display("       RISC-V ALU TEST");
    $display("------------------------------");

a = 10;
    b = 5;

alu_control = 4'b0000;
    #10;
    $display("ADD = %0d (Expected 15)", result);

alu_control = 4'b0001;
    #10;
    $display("SUB = %0d (Expected 5)", result);

alu_control = 4'b0010;
    #10;
    $display("AND = %0d (Expected 0)", result);

alu_control = 4'b0011;
    #10;
    $display("OR = %0d (Expected 15)", result);

alu_control = 4'b0100;
    #10;
    $display("XOR = %0d (Expected 15)", result);

alu_control = 4'b0101;
    #10;
    $display("SLL = %0d (Expected 320)", result);

alu_control = 4'b0110;
    #10;
    $display("SRL = %0d (Expected 0)", result);

alu_control = 4'b1000;
    #10;
    $display("SLT = %0d (Expected 0)", result);

alu_control = 4'b1001;
    #10;
    $display("SLTU = %0d (Expected 0)", result);

$display("------------------------------");
    $display("ALU TEST COMPLETED");
    $display("------------------------------");

    $finish;

end

endmodule