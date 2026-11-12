`timescale 1ns/1ps

module branch_predictor (

    input wire clk,
    input wire reset,

    // Prediction inputs
    input wire [31:0] predict_pc,
    output wire predict_taken,
    output wire [31:0] predicted_target,

    // Branch update inputs
    input wire update_valid,
    input wire [31:0] update_pc,
    input wire actual_taken,
    input wire [31:0] actual_target

);

reg valid [0:15];
reg [25:0] tag [0:15];
reg [31:0] target [0:15];
reg [1:0] counter [0:15];

wire [3:0] predict_index;
wire [3:0] update_index;

integer i;

assign predict_index = predict_pc[5:2];
assign update_index = update_pc[5:2];

// Predict taken only when the BTB entry matches
// and the 2-bit counter predicts taken.
assign predict_taken =
    valid[predict_index] &&
    (tag[predict_index] == predict_pc[31:6]) &&
    counter[predict_index][1];

assign predicted_target =
    (valid[predict_index] &&
     (tag[predict_index] == predict_pc[31:6]))
     ? target[predict_index] : 32'd0;

// Update predictor
always @(posedge clk or posedge reset) begin

    if (reset) begin

        for (i = 0; i < 16; i = i + 1) begin
            valid[i] <= 0;
            tag[i] <= 0;
            target[i] <= 0;
            counter[i] <= 2'b01;
        end

    end else if (update_valid) begin

        if (!valid[update_index] ||
            tag[update_index] != update_pc[31:6]) begin

            valid[update_index] <= 1;
            tag[update_index] <= update_pc[31:6];
            target[update_index] <= actual_target;

            if (actual_taken)
                counter[update_index] <= 2'b10;
            else
                counter[update_index] <= 2'b01;

        end else begin

            target[update_index] <= actual_target;

            // Two-bit saturating counter
            if (actual_taken) begin

                if (counter[update_index] != 2'b11)
                    counter[update_index] <=
                        counter[update_index] + 1'b1;

            end else begin

                if (counter[update_index] != 2'b00)
                    counter[update_index] <=
                        counter[update_index] - 1'b1;

            end

        end

    end

end

endmodule