`timescale 1ns/1ps

module hazard_detection (

    input wire id_ex_mem_read,
    input wire [4:0] id_ex_rd,

    input wire [4:0] if_id_rs1,
    input wire [4:0] if_id_rs2,

    input wire if_id_uses_rs1,
    input wire if_id_uses_rs2,

    output reg pc_write,
    output reg if_id_write,
    output reg control_stall

);

always @(*) begin

    // Default: normal pipeline operation
    pc_write = 1;
    if_id_write = 1;
    control_stall = 0;

    // Detect load-use data hazard
    if (id_ex_mem_read &&
        (id_ex_rd != 0) &&
        (
            (if_id_uses_rs1 && (id_ex_rd == if_id_rs1)) ||
            (if_id_uses_rs2 && (id_ex_rd == if_id_rs2))
        )
    ) begin

        //Stall the pipeline for one cycle
        pc_write = 0;
        if_id_write = 0;
        control_stall = 1;

    end

end

endmodule