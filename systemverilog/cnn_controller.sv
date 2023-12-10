`timescale 1ns / 1ps

module cnn_controller (clk, rst_n, conv_go, relu_go, maxp_go, conv_done, relu_done, maxp_done, fc_done, sfmax_done, conv_run, relu_run, maxp_run, fc_run, sfmax_run, fc_go, sfmax_go, Nif, Nox, Nkx, Nky, Nof, Pox, Poy, Pof, Tox, Toy, Tof, S);
input clk, rst_n;
input[31:0] conv_go, relu_go, maxp_go, fc_go, sfmax_go;
input[7:0] Nif, Nox, Nkx, Nky, Nof, Pox, Poy, Pof, Tox, Toy, Tof, S;
input conv_done, relu_done, maxp_done, fc_done, sfmax_done;
output logic conv_run, relu_run, maxp_run, fc_run, sfmax_run;

typedef enum logic [2:0] {IDLE, CONV, RELU, MAXPOOL, FULLCONNECT, SOFTMAX} state_t;
state_t state, nxt_state;

integer count;

always_ff @ (posedge clk, negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= nxt_state;
end        

always_comb begin
    conv_run = 1'b0;
    relu_run = 1'b0;
    maxp_run = 1'b0;
    fc_run = 1'b0;
    sfmax_run = 1'b0;
    nxt_state = state;

    case (state)
        IDLE : 
            if (conv_go[count]) begin
                conv_run = 1'b1;
                nxt_state = CONV;
            end
            else if (fc_go[count]) begin
                fc_run = 1'b1;
                nxt_state = FULLCONNECT;
            end
        CONV : if (conv_done) begin
            if (relu_go[count]) begin
                relu_run = 1'b1;
                nxt_state = RELU;
            end
            else if (maxp_go[count]) begin
                maxp_run = 1'b1;
                nxt_state = MAXPOOL;
            end
        end
        RELU : if (relu_done) begin
            if (maxp_go[count]) begin
                maxp_run = 1'b1;
                nxt_state = MAXPOOL;
            end
            else begin
                count = count + 1;
                nxt_state = IDLE;
            end
        end
        MAXPOOL : if (maxp_done) begin
            if (sfmax_go[count]) begin
                sfmax_run = 1'b1;
                nxt_state = SOFTMAX;
            end
            else begin
                count = count + 1;
                nxt_state = IDLE;
            end
        end
        FULLCONNECT : if (fc_done) begin
            if (maxp_go[count]) begin
                maxp_run = 1'b1;
                nxt_state = MAXPOOL;
            end
            else begin
                count = count + 1;
                nxt_state = IDLE;
            end
        end
        SOFTMAX : if (sfmax_done) begin
            count = count + 1;
            nxt_state = IDLE;
        end
    endcase
end
endmodule


module memory_controller (
    input wire clk, rst_n,
    output logic mem_index
);

always_ff @ (posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        mem_index <= 0;
    end
    else begin
        mem_index <= ~mem_index;
    end
end
endmodule

module cnn_top (clk, rst_n, input_image, filter, output_image);
input clk, rst_n;
input [31:0] input_image [0:7] [0:31];
input  [31:0] filter [0:7] [0:31];
output logic [31:0] output_image [0:7] [0:31];

localparam Nif = 8;
localparam Nox = 16;
localparam Nkx = 3;
localparam Nky = 3;
localparam Nof = 8;
localparam Pox = 14;
localparam Poy = 14;
localparam Pof = 8;
localparam Tox = 1;
localparam Toy = 1;
localparam Tof = 1;
localparam S = 1;

logic signed [31:0] input_fm [0:7] [0:31];
logic signed [31:0] weight [0:7] [0:31];
logic [31:0] output_fm [0:7] [0:31];

conv_controller #(
    .Nif(Nif), .Nox(Nox), .Nkx(Nkx), .Nky(Nky), .Nof(Nof),
    .Pox(Pox), .Poy(Poy), .Pof(Pof),
    .Tox(Tox), .Toy(Toy), .Tof(Tof), .S(S)
) conv_ctrl_inst (
    .clk(clk),
    .rst_n(rst_n),
    .conv_run(conv_run),
    .input_fm(input_fm),
    .weight(weight),
    .output_fm(output_fm)
);

max_pool max_pool_1 (.in_data(output_fm), .out_data(output_fm));

relu relu_1 (.in_data(output_fm), .out_data(output_fm));

fc_layer #(16) fc_layer_1 (.clk(clk), .rst_n(rst_n), .input_data(input_data), .weights(weights), .bias(bias), .output_data(output_data));
  
endmodule