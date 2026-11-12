`timescale 1ns/1ps

module full_adder (
    input  A,
    input  B,
    input  Cin,
    output reg Sum,
    output reg Cout
);

reg [1:0] temp;

always @(*) begin

    temp = A + B + Cin;
    Sum  = temp[0];
    Cout = temp[1];

end

endmodule
