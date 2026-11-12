
`timescale 1ns/1ps

module riscv_top (
    input wire clk,
    input wire reset,
    output wire [31:0] pc_debug
);

// ==================================================
// 1. INSTRUCTION FETCH
// ==================================================

reg [31:0] pc;

wire [31:0] instruction;
wire [31:0] predict_taken_target;
wire predict_taken;

wire [31:0] if_pc_plus4;

assign pc_debug = pc;
assign if_pc_plus4 = pc + 32'd4;

instruction_memory IMEM (
    .address(pc),
    .instruction(instruction)
);

// ==================================================
// 2. BRANCH AND PREDICTION SIGNALS
// ==================================================

wire branch_taken;
wire branch_mispredict;
wire [31:0] branch_target;

wire [31:0] if_id_pc;
wire [31:0] if_id_instruction;

wire [31:0] id_ex_pc;
wire [31:0] id_ex_immediate;
wire id_ex_branch;

reg branch_condition;

reg if_id_pred_taken;
reg [31:0] if_id_pred_target;

reg id_ex_pred_taken;
reg [31:0] id_ex_pred_target;

// ==================================================
// 3. PIPELINE CONTROL SIGNALS
// ==================================================

wire hazard_pc_write;
wire hazard_if_id_write;
wire control_stall;

if_id_register IF_ID (
    .clk(clk),
    .reset(reset),
    .stall(!hazard_if_id_write && !branch_mispredict),
    .flush(branch_mispredict),
    .pc_in(pc),
    .instruction_in(instruction),
    .pc_out(if_id_pc),
    .instruction_out(if_id_instruction)
);

// Save prediction information for IF/ID
always @(posedge clk or posedge reset) begin
    if (reset || branch_mispredict) begin
        if_id_pred_taken <= 1'b0;
        if_id_pred_target <= 32'd0;
    end
    else if (hazard_if_id_write) begin
        if_id_pred_taken <= predict_taken;
        if_id_pred_target <= predict_taken_target;
    end
end

// ==================================================
// 4. INSTRUCTION DECODE
// ==================================================

wire [6:0] opcode;
wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;
wire [2:0] funct3;
wire [6:0] funct7;

assign opcode = if_id_instruction[6:0];
assign rd = if_id_instruction[11:7];
assign funct3 = if_id_instruction[14:12];
assign rs1 = if_id_instruction[19:15];
assign rs2 = if_id_instruction[24:20];
assign funct7 = if_id_instruction[31:25];

wire reg_write;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire alu_src;
wire branch;
wire [3:0] alu_control;

control_unit CU (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .alu_src(alu_src),
    .branch(branch),
    .alu_control(alu_control)
);

// Immediate generator

wire [31:0] immediate;

immediate_generator IMM (
    .instruction(if_id_instruction),
    .immediate(immediate)
);

// ==================================================
// 5. REGISTER FILE AND WRITE-BACK BYPASS
// ==================================================

wire [31:0] register_data1;
wire [31:0] register_data2;

wire [31:0] rf_read_data1;
wire [31:0] rf_read_data2;

wire [31:0] writeback_data;

wire [4:0] wb_rd;
wire wb_reg_write;

register_file RF (
    .clk(clk),
    .reset(reset),
    .reg_write(wb_reg_write),
    .rs1(rs1),
    .rs2(rs2),
    .rd(wb_rd),
    .write_data(writeback_data),
    .read_data1(rf_read_data1),
    .read_data2(rf_read_data2)
);

// Bypass current WB result to instruction decode

assign register_data1 =
    (wb_reg_write && wb_rd != 0 && wb_rd == rs1)
    ? writeback_data : rf_read_data1;

assign register_data2 =
    (wb_reg_write && wb_rd != 0 && wb_rd == rs2)
    ? writeback_data : rf_read_data2;

// ==================================================
// 6. SOURCE REGISTER USAGE
// ==================================================

reg uses_rs1;
reg uses_rs2;

always @(*) begin
    uses_rs1 = 0;
    uses_rs2 = 0;

    case (opcode)

        7'b0110011: begin
            uses_rs1 = 1;
            uses_rs2 = 1;
        end

        7'b0010011,
        7'b0000011: begin
            uses_rs1 = 1;
        end

        7'b0100011,
        7'b1100011: begin
            uses_rs1 = 1;
            uses_rs2 = 1;
        end

        default: begin
            uses_rs1 = 0;
            uses_rs2 = 0;
        end

    endcase
end

// ==================================================
// 7. HAZARD DETECTION
// ==================================================

wire id_ex_mem_read;
wire [4:0] id_ex_rd;

hazard_detection HD (
    .id_ex_mem_read(id_ex_mem_read),
    .id_ex_rd(id_ex_rd),
    .if_id_rs1(rs1),
    .if_id_rs2(rs2),
    .if_id_uses_rs1(uses_rs1),
    .if_id_uses_rs2(uses_rs2),
    .pc_write(hazard_pc_write),
    .if_id_write(hazard_if_id_write),
    .control_stall(control_stall)
);

// ==================================================
// 8. ID/EX PIPELINE REGISTER
// ==================================================

wire [31:0] id_ex_rs1_data;
wire [31:0] id_ex_rs2_data;

wire [4:0] id_ex_rs1;
wire [4:0] id_ex_rs2;

wire [2:0] id_ex_funct3;
wire [6:0] id_ex_funct7;

wire id_ex_reg_write;
wire id_ex_mem_write;
wire id_ex_mem_to_reg;
wire id_ex_alu_src;

wire [3:0] id_ex_alu_control;

id_ex_register ID_EX (
    .clk(clk),
    .reset(reset),
    .flush(control_stall || branch_mispredict),

    .pc_in(if_id_pc),
    .rs1_data_in(register_data1),
    .rs2_data_in(register_data2),
    .immediate_in(immediate),

    .rs1_in(rs1),
    .rs2_in(rs2),
    .rd_in(rd),

    .funct3_in(funct3),
    .funct7_in(funct7),

    .reg_write_in(reg_write),
    .mem_read_in(mem_read),
    .mem_write_in(mem_write),
    .mem_to_reg_in(mem_to_reg),
    .alu_src_in(alu_src),
    .branch_in(branch),
    .alu_control_in(alu_control),

    .pc_out(id_ex_pc),
    .rs1_data_out(id_ex_rs1_data),
    .rs2_data_out(id_ex_rs2_data),
    .immediate_out(id_ex_immediate),

    .rs1_out(id_ex_rs1),
    .rs2_out(id_ex_rs2),
    .rd_out(id_ex_rd),

    .funct3_out(id_ex_funct3),
    .funct7_out(id_ex_funct7),

    .reg_write_out(id_ex_reg_write),
    .mem_read_out(id_ex_mem_read),
    .mem_write_out(id_ex_mem_write),
    .mem_to_reg_out(id_ex_mem_to_reg),
    .alu_src_out(id_ex_alu_src),
    .branch_out(id_ex_branch),
    .alu_control_out(id_ex_alu_control)
);

// Save prediction information for ID/EX

always @(posedge clk or posedge reset) begin
    if (reset || control_stall || branch_mispredict) begin
        id_ex_pred_taken <= 1'b0;
        id_ex_pred_target <= 32'd0;
    end
    else begin
        id_ex_pred_taken <= if_id_pred_taken;
        id_ex_pred_target <= if_id_pred_target;
    end
end

// ==================================================
// 9. EXECUTE STAGE - FORWARDING
// ==================================================

wire [1:0] forward_a;
wire [1:0] forward_b;

wire [31:0] ex_mem_alu_result;
wire [31:0] ex_mem_store_data;

wire [4:0] ex_mem_rd;

wire ex_mem_reg_write;
wire ex_mem_mem_read;
wire ex_mem_mem_write;
wire ex_mem_mem_to_reg;

wire [31:0] mem_wb_alu_result;
wire [31:0] mem_wb_memory_data;

wire [4:0] mem_wb_rd;

wire mem_wb_reg_write;
wire mem_wb_mem_to_reg;

forwarding_unit FU (
    .rs1(id_ex_rs1),
    .rs2(id_ex_rs2),

    .ex_mem_rd(ex_mem_rd),
    .ex_mem_reg_write(ex_mem_reg_write),

    .mem_wb_rd(mem_wb_rd),
    .mem_wb_reg_write(mem_wb_reg_write),

    .forward_a(forward_a),
    .forward_b(forward_b)
);

// Forwarding multiplexers

reg [31:0] forwarded_a;
reg [31:0] forwarded_b;

always @(*) begin

    case (forward_a)
        2'b00: forwarded_a = id_ex_rs1_data;
        2'b10: forwarded_a = ex_mem_alu_result;
        2'b01: forwarded_a = writeback_data;
        default: forwarded_a = id_ex_rs1_data;
    endcase

    case (forward_b)
        2'b00: forwarded_b = id_ex_rs2_data;
        2'b10: forwarded_b = ex_mem_alu_result;
        2'b01: forwarded_b = writeback_data;
        default: forwarded_b = id_ex_rs2_data;
    endcase

end

// ==================================================
// 10. ALU
// ==================================================

wire [31:0] alu_operand_b;
wire [31:0] alu_result;
wire alu_zero;

assign alu_operand_b =
    id_ex_alu_src ? id_ex_immediate : forwarded_b;

alu ALU (
    .a(forwarded_a),
    .b(alu_operand_b),
    .alu_control(id_ex_alu_control),
    .result(alu_result),
    .zero(alu_zero)
);

// ==================================================
// 11. BRANCH DECISION
// ==================================================

always @(*) begin

    branch_condition = 0;

    case (id_ex_funct3)

        3'b000:
            branch_condition = (forwarded_a == forwarded_b);

        3'b001:
            branch_condition = (forwarded_a != forwarded_b);

        3'b100:
            branch_condition =
                ($signed(forwarded_a) < $signed(forwarded_b));

        3'b101:
            branch_condition =
                ($signed(forwarded_a) >= $signed(forwarded_b));

        3'b110:
            branch_condition = (forwarded_a < forwarded_b);

        3'b111:
            branch_condition = (forwarded_a >= forwarded_b);

        default:
            branch_condition = 0;

    endcase

end

assign branch_taken = id_ex_branch && branch_condition;

assign branch_target = id_ex_pc + id_ex_immediate;

// Misprediction detection

assign branch_mispredict =
    id_ex_branch &&
    (
        (id_ex_pred_taken != branch_condition) ||
        (
            branch_condition &&
            id_ex_pred_taken &&
            (id_ex_pred_target != branch_target)
        )
    );

// ==================================================
// 12. BRANCH PREDICTOR
// ==================================================

branch_predictor BP (
    .clk(clk),
    .reset(reset),

    .predict_pc(pc),
    .predict_taken(predict_taken),
    .predicted_target(predict_taken_target),

    .update_valid(id_ex_branch),
    .update_pc(id_ex_pc),
    .actual_taken(branch_condition),
    .actual_target(branch_target)
);

// ==================================================
// 13. EX/MEM PIPELINE REGISTER
// ==================================================

wire [31:0] ex_mem_pc;

ex_mem_register EX_MEM (
    .clk(clk),
    .reset(reset),
    .flush(1'b0),

    .pc_in(id_ex_pc),
    .alu_result_in(alu_result),
    .store_data_in(forwarded_b),
    .rd_in(id_ex_rd),

    .reg_write_in(id_ex_reg_write),
    .mem_read_in(id_ex_mem_read),
    .mem_write_in(id_ex_mem_write),
    .mem_to_reg_in(id_ex_mem_to_reg),

    .pc_out(ex_mem_pc),
    .alu_result_out(ex_mem_alu_result),
    .store_data_out(ex_mem_store_data),
    .rd_out(ex_mem_rd),

    .reg_write_out(ex_mem_reg_write),
    .mem_read_out(ex_mem_mem_read),
    .mem_write_out(ex_mem_mem_write),
    .mem_to_reg_out(ex_mem_mem_to_reg)
);

// ==================================================
// 14. MEMORY ACCESS
// ==================================================

wire [31:0] memory_read_data;

data_memory DMEM (
    .clk(clk),
    .mem_read(ex_mem_mem_read),
    .mem_write(ex_mem_mem_write),
    .address(ex_mem_alu_result),
    .write_data(ex_mem_store_data),
    .read_data(memory_read_data)
);

// ==================================================
// 15. MEM/WB PIPELINE REGISTER
// ==================================================

mem_wb_register MEM_WB (
    .clk(clk),
    .reset(reset),

    .memory_data_in(memory_read_data),
    .alu_result_in(ex_mem_alu_result),
    .rd_in(ex_mem_rd),

    .reg_write_in(ex_mem_reg_write),
    .mem_to_reg_in(ex_mem_mem_to_reg),

    .memory_data_out(mem_wb_memory_data),
    .alu_result_out(mem_wb_alu_result),
    .rd_out(mem_wb_rd),

    .reg_write_out(mem_wb_reg_write),
    .mem_to_reg_out(mem_wb_mem_to_reg)
);

// ==================================================
// 16. WRITE BACK
// ==================================================

assign writeback_data =
    mem_wb_mem_to_reg ? mem_wb_memory_data : mem_wb_alu_result;

assign wb_rd = mem_wb_rd;
assign wb_reg_write = mem_wb_reg_write;

// ==================================================
// 17. PROGRAM COUNTER UPDATE
// ==================================================

always @(posedge clk or posedge reset) begin

    if (reset) begin
        pc <= 32'd0;
    end

    else if (branch_mispredict) begin
        if (branch_condition)
            pc <= branch_target;
        else
            pc <= id_ex_pc + 32'd4;
    end

    else if (hazard_pc_write) begin
        if (predict_taken)
            pc <= predict_taken_target;
        else
            pc <= pc + 32'd4;
    end

end

endmodule
