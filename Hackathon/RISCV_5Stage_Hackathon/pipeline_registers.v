`timescale 1ns/1ps

// ==================================================
// 1. IF/ID PIPELINE REGISTER
// ==================================================

module if_id_register (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,

    input wire [31:0] pc_in,
    input wire [31:0] instruction_in,

    output reg [31:0] pc_out,
    output reg [31:0] instruction_out
);

always @(posedge clk or posedge reset) begin

    if (reset) begin
        pc_out <= 0;
        instruction_out <= 32'h00000013;
    end
    else if (flush) begin
        pc_out <= 0;
        instruction_out <= 32'h00000013;
    end
    else if (!stall) begin
        pc_out <= pc_in;
        instruction_out <= instruction_in;
    end

end

endmodule


// ==================================================
// 2. ID/EX PIPELINE REGISTER
// ==================================================

module id_ex_register (

    input wire clk,
    input wire reset,
    input wire flush,

    input wire [31:0] pc_in,
    input wire [31:0] rs1_data_in,
    input wire [31:0] rs2_data_in,
    input wire [31:0] immediate_in,

    input wire [4:0] rs1_in,
    input wire [4:0] rs2_in,
    input wire [4:0] rd_in,

    input wire [2:0] funct3_in,
    input wire [6:0] funct7_in,

    input wire reg_write_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire mem_to_reg_in,
    input wire alu_src_in,
    input wire branch_in,
    input wire [3:0] alu_control_in,

    output reg [31:0] pc_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] immediate_out,

    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,

    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,

    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg alu_src_out,
    output reg branch_out,
    output reg [3:0] alu_control_out

);

always @(posedge clk or posedge reset) begin

    if (reset) begin

        pc_out <= 0;
        rs1_data_out <= 0;
        rs2_data_out <= 0;
        immediate_out <= 0;

        rs1_out <= 0;
        rs2_out <= 0;
        rd_out <= 0;

        funct3_out <= 0;
        funct7_out <= 0;

        reg_write_out <= 0;
        mem_read_out <= 0;
        mem_write_out <= 0;
        mem_to_reg_out <= 0;
        alu_src_out <= 0;
        branch_out <= 0;
        alu_control_out <= 0;

    end
    else if (flush) begin

        pc_out <= 0;
        rs1_data_out <= 0;
        rs2_data_out <= 0;
        immediate_out <= 0;

        rs1_out <= 0;
        rs2_out <= 0;
        rd_out <= 0;

        funct3_out <= 0;
        funct7_out <= 0;

        reg_write_out <= 0;
        mem_read_out <= 0;
        mem_write_out <= 0;
        mem_to_reg_out <= 0;
        alu_src_out <= 0;
        branch_out <= 0;
        alu_control_out <= 0;

    end
    else begin

        pc_out <= pc_in;
        rs1_data_out <= rs1_data_in;
        rs2_data_out <= rs2_data_in;
        immediate_out <= immediate_in;

        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out <= rd_in;

        funct3_out <= funct3_in;
        funct7_out <= funct7_in;

        reg_write_out <= reg_write_in;
        mem_read_out <= mem_read_in;
        mem_write_out <= mem_write_in;
        mem_to_reg_out <= mem_to_reg_in;
        alu_src_out <= alu_src_in;
        branch_out <= branch_in;
        alu_control_out <= alu_control_in;

    end

end

endmodule


// ==================================================
// 3. EX/MEM PIPELINE REGISTER
// ==================================================

module ex_mem_register (

    input wire clk,
    input wire reset,
    input wire flush,

    input wire [31:0] pc_in,
    input wire [31:0] alu_result_in,
    input wire [31:0] store_data_in,

    input wire [4:0] rd_in,

    input wire reg_write_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire mem_to_reg_in,

    output reg [31:0] pc_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] store_data_out,

    output reg [4:0] rd_out,

    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out

);

always @(posedge clk or posedge reset) begin

    if (reset) begin

        pc_out <= 0;
        alu_result_out <= 0;
        store_data_out <= 0;
        rd_out <= 0;

        reg_write_out <= 0;
        mem_read_out <= 0;
        mem_write_out <= 0;
        mem_to_reg_out <= 0;

    end
    else if (flush) begin

        pc_out <= 0;
        alu_result_out <= 0;
        store_data_out <= 0;
        rd_out <= 0;

        reg_write_out <= 0;
        mem_read_out <= 0;
        mem_write_out <= 0;
        mem_to_reg_out <= 0;

    end
    else begin

        pc_out <= pc_in;
        alu_result_out <= alu_result_in;
        store_data_out <= store_data_in;
        rd_out <= rd_in;

        reg_write_out <= reg_write_in;
        mem_read_out <= mem_read_in;
        mem_write_out <= mem_write_in;
        mem_to_reg_out <= mem_to_reg_in;

    end

end

endmodule


// ==================================================
// 4. MEM/WB PIPELINE REGISTER
// ==================================================

module mem_wb_register (

    input wire clk,
    input wire reset,

    input wire [31:0] memory_data_in,
    input wire [31:0] alu_result_in,

    input wire [4:0] rd_in,

    input wire reg_write_in,
    input wire mem_to_reg_in,

    output reg [31:0] memory_data_out,
    output reg [31:0] alu_result_out,

    output reg [4:0] rd_out,

    output reg reg_write_out,
    output reg mem_to_reg_out

);

always @(posedge clk or posedge reset) begin

    if (reset) begin

        memory_data_out <= 0;
        alu_result_out <= 0;
        rd_out <= 0;

        reg_write_out <= 0;
        mem_to_reg_out <= 0;

    end
    else begin

        memory_data_out <= memory_data_in;
        alu_result_out <= alu_result_in;
        rd_out <= rd_in;

        reg_write_out <= reg_write_in;
        mem_to_reg_out <= mem_to_reg_in;

    end

end

endmodule