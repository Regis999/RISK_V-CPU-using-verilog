
module d_flipflop_tb;

reg D;
reg clk;
reg reset;
wire Q;

// Instantiate the D Flip-Flop
d_flipflop uut (
    .D(D),
    .clk(clk),
    .reset(reset),
    .Q(Q)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test inputs
initial begin
    $monitor("Time=%0t | D=%b | clk=%b | reset=%b | Q=%b",
              $time, D, clk, reset, Q);

    reset = 1;
    D = 0;
    #10;

    reset = 0;
    D = 1;
    #10;

    D = 0;
    #10;

    D = 1;
    #10;

    D = 0;
    #10;

    $finish;
end

endmodule
