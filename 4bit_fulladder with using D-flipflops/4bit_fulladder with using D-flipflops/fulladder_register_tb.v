`timescale 1ns/1ps

module full_adder_reg_tb;

reg clk, rst, load, cin;
reg [3:0] a, b;

wire [3:0] reg_a, reg_b, sum;
wire reg_cin, cout;

// DUT instantiation
full_adder_reg uut (
    .clk(clk),
    .rst(rst),
    .load(load),
    .a(a),
    .b(b),
    .cin(cin),
    .reg_a(reg_a),
    .reg_b(reg_b),
    .reg_cin(reg_cin),
    .sum(sum),
    .cout(cout)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    $monitor("Time=%0t A=%b B=%b Cin=%b | RegA=%b RegB=%b | Cout=%b Sum=%b",
    $time, a, b, cin, reg_a, reg_b, cout, sum);

    rst = 1;
    load = 0;
    a = 0;
    b = 0;
    cin = 0;
    #12 rst = 0;

    // Test 1: 3 + 2 = 5
    @(negedge clk);
    load = 1;
    a = 4'b0011;
    b = 4'b0010;
    cin = 0;

    @(negedge clk);
    load = 0;

    // Test 2: 7 + 8 + 1 = 16
    @(negedge clk);
    load = 1;
    a = 4'b0111;
    b = 4'b1000;
    cin = 1;

    @(negedge clk);
    load = 0;

    // Test 3: 15 + 1 = 16
    @(negedge clk);
    load = 1;
    a = 4'b1111;
    b = 4'b0001;
    cin = 0;

    @(negedge clk);
    load = 0;

    #10;
    $finish;
end

endmodule