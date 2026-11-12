`timescale 1ns/1ps

module tb_instruction_memory;

reg [31:0] address;
wire [31:0] instruction;

instruction_memory uut (
    .address(address),
    .instruction(instruction)
);

initial begin

    $display("----------------------------------------");
    $display("RISC-V INSTRUCTION MEMORY TEST");
    $display("----------------------------------------");

    address = 0;
    #10;
    $display("PC = %0d | Instruction = %h | Expected = 00500093",
             address, instruction);

    address = 4;
    #10;
    $display("PC = %0d | Instruction = %h | Expected = 00A00113",
             address, instruction);

    address = 8;
    #10;
    $display("PC = %0d | Instruction = %h | Expected = 002081B3",
             address, instruction);

    address = 12;
    #10;
    $display("PC = %0d | Instruction = %h | Expected = 00302023",
             address, instruction);

    address = 16;
    #10;
    $display("PC = %0d | Instruction = %h | Expected = 00002203",
             address, instruction);

    address = 20;
    #10;
    $display("PC = %0d | Instruction = %h | Expected = 00120293",
             address, instruction);

    $display("----------------------------------------");
    $display("INSTRUCTION MEMORY TEST COMPLETED");
    $display("----------------------------------------");

    $finish;

end

endmodule