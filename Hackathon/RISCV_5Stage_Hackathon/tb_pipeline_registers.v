`timescale 1ns/1ps

module tb_pipeline_registers;

reg clk;
reg reset;

// IF/ID signals
reg if_stall, if_flush;
reg [31:0] if_pc_in, if_instruction_in;
wire [31:0] if_pc_out, if_instruction_out;

// ID/EX signals
reg id_flush;
reg [31:0] id_pc_in, id_rs1_data_in, id_rs2_data_in, id_immediate_in;
reg [4:0] id_rs1_in, id_rs2_in, id_rd_in;
reg [2:0] id_funct3_in;
reg [6:0] id_funct7_in;
reg id_reg_write_in, id_mem_read_in, id_mem_write_in;
reg id_mem_to_reg_in, id_alu_src_in, id_branch_in;
reg [3:0] id_alu_control_in;

wire [31:0] id_pc_out, id_rs1_data_out, id_rs2_data_out, id_immediate_out;
wire [4:0] id_rs1_out, id_rs2_out, id_rd_out;
wire [2:0] id_funct3_out;
wire [6:0] id_funct7_out;
wire id_reg_write_out, id_mem_read_out, id_mem_write_out;
wire id_mem_to_reg_out, id_alu_src_out, id_branch_out;
wire [3:0] id_alu_control_out;

// EX/MEM signals
reg ex_flush;
reg [31:0] ex_pc_in, ex_alu_result_in, ex_store_data_in;
reg [4:0] ex_rd_in;
reg ex_reg_write_in, ex_mem_read_in, ex_mem_write_in, ex_mem_to_reg_in;

wire [31:0] ex_pc_out, ex_alu_result_out, ex_store_data_out;
wire [4:0] ex_rd_out;
wire ex_reg_write_out, ex_mem_read_out, ex_mem_write_out, ex_mem_to_reg_out;

// MEM/WB signals
reg [31:0] wb_memory_data_in, wb_alu_result_in;
reg [4:0] wb_rd_in;
reg wb_reg_write_in, wb_mem_to_reg_in;

wire [31:0] wb_memory_data_out, wb_alu_result_out;
wire [4:0] wb_rd_out;
wire wb_reg_write_out, wb_mem_to_reg_out;

// Instantiate IF/ID
if_id_register IF_ID (
    .clk(clk),
    .reset(reset),
    .stall(if_stall),
    .flush(if_flush),
    .pc_in(if_pc_in),
    .instruction_in(if_instruction_in),
    .pc_out(if_pc_out),
    .instruction_out(if_instruction_out)
);

// Instantiate ID/EX
id_ex_register ID_EX (
    .clk(clk),
    .reset(reset),
    .flush(id_flush),
    .pc_in(id_pc_in),
    .rs1_data_in(id_rs1_data_in),
    .rs2_data_in(id_rs2_data_in),
    .immediate_in(id_immediate_in),
    .rs1_in(id_rs1_in),
    .rs2_in(id_rs2_in),
    .rd_in(id_rd_in),
    .funct3_in(id_funct3_in),
    .funct7_in(id_funct7_in),
    .reg_write_in(id_reg_write_in),
    .mem_read_in(id_mem_read_in),
    .mem_write_in(id_mem_write_in),
    .mem_to_reg_in(id_mem_to_reg_in),
    .alu_src_in(id_alu_src_in),
    .branch_in(id_branch_in),
    .alu_control_in(id_alu_control_in),
    .pc_out(id_pc_out),
    .rs1_data_out(id_rs1_data_out),
    .rs2_data_out(id_rs2_data_out),
    .immediate_out(id_immediate_out),
    .rs1_out(id_rs1_out),
    .rs2_out(id_rs2_out),
    .rd_out(id_rd_out),
    .funct3_out(id_funct3_out),
    .funct7_out(id_funct7_out),
    .reg_write_out(id_reg_write_out),
    .mem_read_out(id_mem_read_out),
    .mem_write_out(id_mem_write_out),
    .mem_to_reg_out(id_mem_to_reg_out),
    .alu_src_out(id_alu_src_out),
    .branch_out(id_branch_out),
    .alu_control_out(id_alu_control_out)
);

// Instantiate EX/MEM
ex_mem_register EX_MEM (
    .clk(clk),
    .reset(reset),
    .flush(ex_flush),
    .pc_in(ex_pc_in),
    .alu_result_in(ex_alu_result_in),
    .store_data_in(ex_store_data_in),
    .rd_in(ex_rd_in),
    .reg_write_in(ex_reg_write_in),
    .mem_read_in(ex_mem_read_in),
    .mem_write_in(ex_mem_write_in),
    .mem_to_reg_in(ex_mem_to_reg_in),
    .pc_out(ex_pc_out),
    .alu_result_out(ex_alu_result_out),
    .store_data_out(ex_store_data_out),
    .rd_out(ex_rd_out),
    .reg_write_out(ex_reg_write_out),
    .mem_read_out(ex_mem_read_out),
    .mem_write_out(ex_mem_write_out),
    .mem_to_reg_out(ex_mem_to_reg_out)
);

// Instantiate MEM/WB
mem_wb_register MEM_WB (
    .clk(clk),
    .reset(reset),
    .memory_data_in(wb_memory_data_in),
    .alu_result_in(wb_alu_result_in),
    .rd_in(wb_rd_in),
    .reg_write_in(wb_reg_write_in),
    .mem_to_reg_in(wb_mem_to_reg_in),
    .memory_data_out(wb_memory_data_out),
    .alu_result_out(wb_alu_result_out),
    .rd_out(wb_rd_out),
    .reg_write_out(wb_reg_write_out),
    .mem_to_reg_out(wb_mem_to_reg_out)
);

// Clock generation
always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;

    if_stall = 0;
    if_flush = 0;
    if_pc_in = 0;
    if_instruction_in = 0;

    id_flush = 0;
    id_pc_in = 0;
    id_rs1_data_in = 0;
    id_rs2_data_in = 0;
    id_immediate_in = 0;
    id_rs1_in = 0;
    id_rs2_in = 0;
    id_rd_in = 0;
    id_funct3_in = 0;
    id_funct7_in = 0;
    id_reg_write_in = 0;
    id_mem_read_in = 0;
    id_mem_write_in = 0;
    id_mem_to_reg_in = 0;
    id_alu_src_in = 0;
    id_branch_in = 0;
    id_alu_control_in = 0;

    ex_flush = 0;
    ex_pc_in = 0;
    ex_alu_result_in = 0;
    ex_store_data_in = 0;
    ex_rd_in = 0;
    ex_reg_write_in = 0;
    ex_mem_read_in = 0;
    ex_mem_write_in = 0;
    ex_mem_to_reg_in = 0;

    wb_memory_data_in = 0;
    wb_alu_result_in = 0;
    wb_rd_in = 0;
    wb_reg_write_in = 0;
    wb_mem_to_reg_in = 0;

    // Reset all pipeline registers
    #10;
    reset = 0;

    // TEST 1: IF/ID captures instruction and PC
    if_pc_in = 32'd100;
    if_instruction_in = 32'h00500093;

    // TEST 2: ID/EX captures values
    id_pc_in = 32'd100;
    id_rs1_data_in = 32'd10;
    id_rs2_data_in = 32'd20;
    id_immediate_in = 32'd5;
    id_rs1_in = 5'd1;
    id_rs2_in = 5'd2;
    id_rd_in = 5'd3;
    id_reg_write_in = 1;

    // TEST 3: EX/MEM captures ALU result
    ex_pc_in = 32'd100;
    ex_alu_result_in = 32'd30;
    ex_store_data_in = 32'd20;
    ex_rd_in = 5'd3;
    ex_reg_write_in = 1;

    // TEST 4: MEM/WB captures results
    wb_memory_data_in = 32'd50;
    wb_alu_result_in = 32'd30;
    wb_rd_in = 5'd3;
    wb_reg_write_in = 1;
    wb_mem_to_reg_in = 1;

    #10;

    $display("---- PIPELINE REGISTER TESTS ----");

    if (if_pc_out == 100 && if_instruction_out == 32'h00500093)
        $display("PASS: IF/ID captures PC and instruction");
    else
        $display("FAIL: IF/ID capture");

    if (id_pc_out == 100 && id_rs1_data_out == 10 &&
        id_rs2_data_out == 20 && id_rd_out == 3 &&
        id_reg_write_out == 1)
        $display("PASS: ID/EX captures data and control signals");
    else
        $display("FAIL: ID/EX capture");

    if (ex_pc_out == 100 && ex_alu_result_out == 30 &&
        ex_store_data_out == 20 && ex_rd_out == 3)
        $display("PASS: EX/MEM captures execution results");
    else
        $display("FAIL: EX/MEM capture");

    if (wb_memory_data_out == 50 && wb_alu_result_out == 30 &&
        wb_rd_out == 3 && wb_reg_write_out == 1)
        $display("PASS: MEM/WB captures memory and ALU results");
    else
        $display("FAIL: MEM/WB capture");

    // TEST 5: IF/ID stall must hold previous values
    if_stall = 1;
    if_pc_in = 32'd200;
    if_instruction_in = 32'h00A00113;

    #10;

    if (if_pc_out == 100 && if_instruction_out == 32'h00500093)
        $display("PASS: IF/ID holds values during stall");
    else
        $display("FAIL: IF/ID stall");

    // TEST 6: IF/ID flush must clear instruction
    if_stall = 0;
    if_flush = 1;

    #10;

    if (if_instruction_out == 32'h00000013)
        $display("PASS: IF/ID flush inserts NOP");
    else
        $display("FAIL: IF/ID flush");

    // TEST 7: ID/EX flush must clear control signals
    id_flush = 1;

    #10;

    if (id_reg_write_out == 0 && id_mem_read_out == 0 &&
        id_mem_write_out == 0 && id_branch_out == 0)
        $display("PASS: ID/EX flush clears control signals");
    else
        $display("FAIL: ID/EX flush");

    // TEST 8: EX/MEM flush must clear control signals
    ex_flush = 1;

    #10;

    if (ex_reg_write_out == 0 && ex_mem_read_out == 0 &&
        ex_mem_write_out == 0)
        $display("PASS: EX/MEM flush clears control signals");
    else
        $display("FAIL: EX/MEM flush");

    $display("---------------------------------");
    $display("PIPELINE REGISTER TEST COMPLETED");

    $finish;
end

endmodule