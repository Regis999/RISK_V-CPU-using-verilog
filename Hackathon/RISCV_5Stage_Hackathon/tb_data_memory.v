`timescale 1ns/1ps

module tb_data_memory;

reg clk;
reg mem_read;
reg mem_write;
reg [31:0] address;
reg [31:0] write_data;

wire [31:0] read_data;

data_memory uut (
    .clk(clk),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .address(address),
    .write_data(write_data),
    .read_data(read_data)
);

// Clock generation
always #5 clk = ~clk;

initial begin

    clk = 0;
    mem_read = 0;
    mem_write = 0;
    address = 0;
    write_data = 0;

    $display("-------------------------------------");
    $display("RISC-V DATA MEMORY TEST");
    $display("-------------------------------------");

    // Write 100 into address 0
    @(negedge clk);
    address = 0;
    write_data = 100;
    mem_write = 1;

    @(negedge clk);
    mem_write = 0;

    // Read address 0
    mem_read = 1;
    #2;
    $display("Address 0 = %0d (Expected 100)", read_data);

    // Write 200 into address 4
    @(negedge clk);
    mem_read = 0;
    address = 4;
    write_data = 200;
    mem_write = 1;

    @(negedge clk);
    mem_write = 0;

    // Read address 4
    mem_read = 1;
    #2;
    $display("Address 4 = %0d (Expected 200)", read_data);

    // Disable memory read
    mem_read = 0;
    #2;
    $display("Read disabled = %0d (Expected 0)", read_data);

    $display("-------------------------------------");
    $display("DATA MEMORY TEST COMPLETED");
    $display("-------------------------------------");

    $finish;

end

endmodule