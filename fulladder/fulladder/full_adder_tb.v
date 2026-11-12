`timescale 1ns/1ps

module full_adder_tb;

reg A;
reg B;
reg Cin;

wire Sum;
wire Cout;

full_adder uut (
    .A(A),
    .B(B),
    .Cin(Cin),
    .Sum(Sum),
    .Cout(Cout)
);

initial begin

    $display("====================================");
    $display("       FULL ADDER SIMULATION");
    $display("====================================");
    $display("Time   A   B   Cin   Sum   Cout");
    $display("------------------------------------");

    $monitor("%4t   %b   %b    %b     %b     %b",
             $time, A, B, Cin, Sum, Cout);

    // Test case 1: 0 + 0 + 0 = 0
    A = 1'b0;
    B = 1'b0;
    Cin = 1'b0;
    #10;

    // Test case 2: 0 + 0 + 1 = 1
    A = 1'b0;
    B = 1'b0;
    Cin = 1'b1;
    #10;

    // Test case 3: 0 + 1 + 0 = 1
    A = 1'b0;
    B = 1'b1;
    Cin = 1'b0;
    #10;

    // Test case 4: 0 + 1 + 1 = 2
    A = 1'b0;
    B = 1'b1;
    Cin = 1'b1;
    #10;

    // Test case 5: 1 + 0 + 0 = 1
    A = 1'b1;
    B = 1'b0;
    Cin = 1'b0;
    #10;

    // Test case 6: 1 + 0 + 1 = 2
    A = 1'b1;
    B = 1'b0;
    Cin = 1'b1;
    #10;

    // Test case 7: 1 + 1 + 0 = 2
    A = 1'b1;
    B = 1'b1;
    Cin = 1'b0;
    #10;

    // Test case 8: 1 + 1 + 1 = 3
    A = 1'b1;
    B = 1'b1;
    Cin = 1'b1;
    #10;

    $display("====================================");
    $display("       SIMULATION COMPLETED");
    $display("====================================");

    $finish;

end

endmodule
