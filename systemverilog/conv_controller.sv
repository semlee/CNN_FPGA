`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/08 09:35:58
// Design Name: 
// Module Name: conv_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module conv_controller(
    input wire clk, rst_n,
    input wire conv_run,
    input wire signed [31:0] input_fm [0:7] [0:31], // Operand A
    input wire signed [31:0] weight [0:7] [0:31], // Operand B
    input [7:0] Nif, Nox, Nkx, Nky, Nof, Pox, Poy, Pof, Tox, Toy, Tof, S,
    output logic signed [31:0] output_fm [0:7] [0:31]
    );
    /*
    // Unrolled
    NOF
    NOY
    NOX
    // Tiling
    NIF
    NKY
    NKX
    for no in range(Nof)
        for y in range(Noy)
            for x in range(Nox)
                for ni in range(Nif)
                    for ky in range(Nky)
                        for kx in range(Nkx)
                            output_fm[no][x][y] += input[ni][S*x+kx][S*y+ky] * weight[ni,no][kx][ky]
                 output[no][x][y] = output[no][x][y] + bias[no]
    */
    typedef enum logic [2:0] {IDLE, NIF_st, NKY_st, NKX_st} state_t;
    state_t state, nxt_state;
    integer x_index, y_index, w_index;
    integer ni, kx, ky;
    
    parameter NIF = 8; // Set to the actual value of Nif
    parameter NKY = 3; // Set to the actual value of Nky
    parameter NKX = 3; // Set to the actual value of Nkx
    parameter POX = 28; // Set to the actual value of Pox
    parameter POY = 28; // Set to the actual value of Poy
    parameter POF = 8; // Set to the actual value of Pof
    
    always_ff @ (posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end
        else begin
            state <= nxt_state;
        end
    end
    
    always_comb begin
        nxt_state = state;
        case (state)
            IDLE: if(conv_run) begin
                    ni <= 0;
                    ky <= 0;
                    kx <= 0;
                    nxt_state = NIF_st;
                end
            NIF_st: if(ni == Nif) begin
                    nxt_state = IDLE;
                end
                else begin
                    nxt_state = NKY_st;
                    ni = ni + 1;
                end
            NKY_st: if (ky == Nky) begin
                    nxt_state = NIF_st;
                end
                else begin
                    nxt_state = NKX_st;
                    ky = ky + 1;
                end
            NKX_st: if (kx == Nkx) begin
                    nxt_state = NKY_st;
                end
                else begin
                    kx = kx + 1;
                    x_index = S * x + kx;
                    y_index = S * y + ky;
                    w_index = kx * Nkx + ky;
                end
        endcase
    end
    
    generate
        genvar no, x, y;
        for (no = 0; no < POF; no = no + 1) begin
            for (y = 0; y < POY; y = y + 1) begin
                for (x = 0; x < POX; x = x + 1) begin
                    Mac_Unit #(
                        .NI(NIF), .NKY(NKY), .NKX(NKX)
                    ) mac_unit(
                        .clk(clk), .rst_n(rst_n),
                        .input_fm(input_fm[ni][x_index][y_index]),
                        .weight(weight[no * Pof + ni][w_index]),
                        .output_fm(output_fm[no][x * X + y])
                    );
                end
            end 
        end
    endgenerate
    
endmodule
