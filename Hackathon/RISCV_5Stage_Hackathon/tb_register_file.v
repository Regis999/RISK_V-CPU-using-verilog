`timescale 1ns/1ps


module tb_register_file;

reg clk;
reg reset;
reg reg_write;

reg [4:0] rs1;
reg [4:0] rs2;
reg [4:0] rd;

reg [31:0] write_data;

wire [31:0] read_data1;
wire [31:0] read_data2;

register_file uut (
.clk(clk),
.reset(reset),
.reg_write(reg_write),
.rs1(rs1),
.rs2(rs2),
.rd(rd),
.write_data(write_data),
.read_data1(read_data1),
.read_data2(read_data2)
);

always #5 clk = ~clk;

initial begin

clk = 0;
reset = 1;
reg_write = 0;

rs1 = 0;
rs2 = 0;
rd = 0;
write_data = 0;

#12;
reset = 0;

// Write 10 into x1
@(negedge clk);
rd = 1;
write_data = 10;
reg_write = 1;

@(negedge clk);

// Write 20 into x2
rd = 2;
write_data = 20;

@(negedge clk);

reg_write = 0;

// Read x1 and x2
rs1 = 1;
rs2 = 2;

#2;

$display("x1 = %0d (Expected 10)", read_data1);
$display("x2 = %0d (Expected 20)", read_data2);

// Check x0
rs1 = 0;
#2;

$display("x0 = %0d (Expected 0)", read_data1);

$display("-----------------------------");
$display("REGISTER FILE TEST COMPLETED");
$display("-----------------------------");

$finish;

end

endmodule