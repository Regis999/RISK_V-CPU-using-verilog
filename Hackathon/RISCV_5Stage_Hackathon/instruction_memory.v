`timescale 1ns/1ps

module instruction_memory (
    input wire [31:0] address,
    output wire [31:0] instruction
);

reg [31:0] memory [0:255];

integer i;

initial begin

    // Initialize all locations with NOP instructions
    for (i = 0; i < 256; i = i + 1) begin
        memory[i] = 32'h00000013;
    end

    // Test program

    // Address 0: ADDI x1, x0, 5
    memory[0] = 32'h00500093;

    // Address 4: ADDI x2, x0, 10
    memory[1] = 32'h00A00113;

    // Address 8: ADD x3, x1, x2
    memory[2] = 32'h002081B3;

    // Address 12: SW x3, 0(x0)
    memory[3] = 32'h00302023;

    // Address 16: LW x4, 0(x0)
    memory[4] = 32'h00002203;

    // Address 20: ADDI x5, x4, 1
    memory[5] = 32'h00120293;

end

// Each instruction is 4 bytes.
// Therefore, use address bits [9:2].
assign instruction = memory[address[9:2]];

endmodule