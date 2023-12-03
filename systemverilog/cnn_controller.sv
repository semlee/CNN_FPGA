`timescale 1ns / 1ps

module cnn_controller (clk, rst_n, conv_go, relu_go, maxp_go, fc_go, sfmax_go, Nif, Nox, Nkx, Nky, Nof, Pox, Poy, Pof, Tox, Toy, Tof, S);
input logic clk, rst_n;
input[31:0] logic conv_go, relu_go, maxp_go, fc_go, sfmax_go;
input logic conv_done, relu_done, maxp_done, fc_done, sfmax_done;
output logic conv_run, relu_run, maxp_run, fc_run, sfmax_run;

typedef enum logic [2:0] {IDLE, CONV, RELU, MAXPOOL, FULLCONNECT, SOFTMAX} state_t;
state_t state, nxt_state;

integer count;

always_ff @ (posedge clk, negedge rst_n)
    if (!rst_n)
        state <= IDLE;
    else
        state <= nxt_state;

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
endmodule


module memory_controller (
    input wire clk, rstn,
    output wire mem_index;
);

always_ff @ (posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        mem_index <= 0;
    end
    else begin
        mem_index <= ~mem_index;
    end

endmodule

module cnn_top (clk, rst_n, input_image, filter, output_image, Nif, Nox, Nkx, Nky, Nof, Pox, Poy, Pof, Tox, Toy, Tof, S);
input logic clk, rst_n;
input logic [31:0] input_image [31:0][31:0];
input logic [31:0] filter [31:0][31:0];
output logic [31:0] output_image [31:0][31:0];

parameter Nif, Nox, Nkx, Nky, Nof, Pox, Poy, Pof, Tox, Toy, Tof, S; 

logic [31:0] input_fm [31:0][31:0];
logic [31:0] filter_fm [31:0][31:0];
logic [31:0] output_fm [31:0][31:0];

mac_unit mac_1 (.clk(clk), .rst_n(rst_n), .input_fm(input_fm), .weight(filter_fm), output_fm(output_fm));

max_pool max_pool_1 (.in_data(output_fm), .out_data(output_fm));

relu relu_1 (.in_data(output_fm), .out_data(output_fm));

fc_layer #(16) fc_layer_1 (.clk(clk), .rst_n(rst_n), .input_data(input_data), .weights(weights), .bias(bias), .output_data(output_data));
  
endmodule