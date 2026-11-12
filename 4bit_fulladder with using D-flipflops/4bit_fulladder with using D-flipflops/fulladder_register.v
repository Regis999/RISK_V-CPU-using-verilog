module full_adder_reg (
    input wire clk, rst, load,
    input wire [3:0] a, b,
    input wire cin,
    output reg [3:0] reg_a, reg_b,
    output reg reg_cin,
    output wire [3:0] sum,
    output wire cout
);

// Input registers
always @(posedge clk or posedge rst) begin
    if (rst) begin
        reg_a <= 4'b0000;
        reg_b <= 4'b0000;
        reg_cin <= 1'b0;
    end
    else if (load) begin
        reg_a <= a;
        reg_b <= b;
        reg_cin <= cin;
    end
end

// 4-bit full adder
assign {cout, sum} = reg_a + reg_b + reg_cin;

endmodule