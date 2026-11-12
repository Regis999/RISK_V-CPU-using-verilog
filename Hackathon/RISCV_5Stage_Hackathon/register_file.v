
`timescale 1ns/1ps

module register_file (
    input wire clk,
    input wire reset,

    input wire reg_write,

    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rd,

    input wire [31:0] write_data,

    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

reg [31:0] registers [0:31];

integer i;

// Read port 1
assign read_data1 =
    (rs1 == 0) ? 32'd0 : registers[rs1];

// Read port 2
assign read_data2 =
    (rs2 == 0) ? 32'd0 : registers[rs2];

// Write operation
always @(posedge clk or posedge reset) begin

    if (reset) begin

        for (i = 0; i < 32; i = i + 1)
            registers[i] <= 32'd0;

    end

    else begin

        if (reg_write && rd != 0)
            registers[rd] <= write_data;

        registers[0] <= 32'd0;

    end

end

endmodule
