`timescale 1ns/1ps

module immediate_generator (
    input wire [31:0] instruction,
    output reg [31:0] immediate
);

always @(*) begin

    case (instruction[6:0])

        // I-TYPE: ADDI, ANDI, ORI, LW, JALR
        7'b0010011,
        7'b0000011,
        7'b1100111: begin
            immediate = {{20{instruction[31]}},
                          instruction[31:20]};
        end

        // S-TYPE: SW
        7'b0100011: begin
            immediate = {{20{instruction[31]}},
                          instruction[31:25],
                          instruction[11:7]};
        end

        // B-TYPE: BEQ, BNE, BLT, BGE, BLTU, BGEU
        7'b1100011: begin
            immediate = {{19{instruction[31]}},
                          instruction[31],
                          instruction[7],
                          instruction[30:25],
                          instruction[11:8],
                          1'b0};
        end

        // U-TYPE: LUI, AUIPC
        7'b0110111,
        7'b0010111: begin
            immediate = {instruction[31:12], 12'b0};
        end

        // J-TYPE: JAL
        7'b1101111: begin
            immediate = {{11{instruction[31]}},
                          instruction[31],
                          instruction[19:12],
                          instruction[20],
                          instruction[30:21],
                          1'b0};
        end

        default: begin
            immediate = 32'd0;
        end

    endcase

end

endmodule