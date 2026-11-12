`timescale 1ns/1ps

module forwarding_unit (

    input wire [4:0] rs1,
    input wire [4:0] rs2,

    input wire [4:0] ex_mem_rd,
    input wire ex_mem_reg_write,

    input wire [4:0] mem_wb_rd,
    input wire mem_wb_reg_write,

    output reg [1:0] forward_a,
    output reg [1:0] forward_b

);

always @(*) begin

    // Default: use values from register file
    forward_a = 2'b00;
    forward_b = 2'b00;

    // Forwarding for first ALU input
    if (ex_mem_reg_write &&
        (ex_mem_rd != 0) &&
        (ex_mem_rd == rs1)) begin

        forward_a = 2'b10;

    end
    else if (mem_wb_reg_write &&
             (mem_wb_rd != 0) &&
             (mem_wb_rd == rs1)) begin

        forward_a = 2'b01;

    end

    // Forwarding for second ALU input
    if (ex_mem_reg_write &&
        (ex_mem_rd != 0) &&
        (ex_mem_rd == rs2)) begin

        forward_b = 2'b10;

    end
    else if (mem_wb_reg_write &&
             (mem_wb_rd != 0) &&
             (mem_wb_rd == rs2)) begin

        forward_b = 2'b01;

    end

end

endmodule