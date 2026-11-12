`timescale 1ns/1ps

module control_unit (
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,

    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg alu_src,
    output reg branch,
    output reg [3:0] alu_control
);

always @(*) begin

    // Default control signals
    reg_write = 0;
    mem_read = 0;
    mem_write = 0;
    mem_to_reg = 0;
    alu_src = 0;
    branch = 0;
    alu_control = 4'b0000;

    case (opcode)

        // R-TYPE INSTRUCTIONS
        7'b0110011: begin
            reg_write = 1;

            case (funct3)

                3'b000: begin
                    if (funct7 == 7'b0100000)
                        alu_control = 4'b0001; // SUB
                    else
                        alu_control = 4'b0000; // ADD
                end

                3'b111: alu_control = 4'b0010; // AND
                3'b110: alu_control = 4'b0011; // OR
                3'b100: alu_control = 4'b0100; // XOR
                3'b001: alu_control = 4'b0101; // SLL
                3'b101: begin
                    if (funct7 == 7'b0100000)
                        alu_control = 4'b0111; // SRA
                    else
                        alu_control = 4'b0110; // SRL
                end
                3'b010: alu_control = 4'b1000; // SLT
                3'b011: alu_control = 4'b1001; // SLTU

                default: alu_control = 4'b0000;
            endcase
        end

        // I-TYPE ARITHMETIC INSTRUCTIONS
        7'b0010011: begin
            reg_write = 1;
            alu_src = 1;

            case (funct3)

                3'b000: alu_control = 4'b0000; // ADDI
                3'b111: alu_control = 4'b0010; // ANDI
                3'b110: alu_control = 4'b0011; // ORI
                3'b100: alu_control = 4'b0100; // XORI
                3'b010: alu_control = 4'b1000; // SLTI
                3'b011: alu_control = 4'b1001; // SLTIU
                3'b001: alu_control = 4'b0101; // SLLI

                3'b101: begin
                    if (funct7 == 7'b0100000)
                        alu_control = 4'b0111; // SRAI
                    else
                        alu_control = 4'b0110; // SRLI
                end

                default: alu_control = 4'b0000;
            endcase
        end

        // LOAD WORD
        7'b0000011: begin
            reg_write = 1;
            mem_read = 1;
            mem_to_reg = 1;
            alu_src = 1;
            alu_control = 4'b0000;
        end

        // STORE WORD
        7'b0100011: begin
            mem_write = 1;
            alu_src = 1;
            alu_control = 4'b0000;
        end

        // BRANCH INSTRUCTIONS
        7'b1100011: begin
            branch = 1;

            case (funct3)
                3'b000: alu_control = 4'b0001; // BEQ
                3'b001: alu_control = 4'b0001; // BNE
                3'b100: alu_control = 4'b1000; // BLT
                3'b101: alu_control = 4'b1000; // BGE
                3'b110: alu_control = 4'b1001; // BLTU
                3'b111: alu_control = 4'b1001; // BGEU
                default: alu_control = 4'b0001;
            endcase
        end

        default: begin
            // Unsupported instruction: keep all controls inactive
        end

    endcase
end

endmodule