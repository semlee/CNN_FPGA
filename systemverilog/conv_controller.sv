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
    input [7:0] Nif, Noy, Nox, Nkx, Nky, Nof, Pox, Poy, Pof, Tox, Toy, Tof, S,
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
    typedef enum logic [2:0] {IDLE, NOF_st, NOY_st, NOX_st, NIF_st, NKY_st, NKX_st} state_t;
    state_t state, nxt_state;
    integer x_index, y_index, w_index;
    integer no, x, y, ni, kx, ky;
    integer Nof_st = Nof / Pof;
    integer Noy_st = Noy / Poy;
    integer Nox_st = Nox / Pox;
    
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
                    no <= 0;
                    y <= 0;
                    x <= 0;
                    ni <= 0;
                    ky <= 0;
                    kx <= 0;
                    nxt_state = NOF_st;
                end
            NOF_st : if (no == Nof_st) begin
                    nxt_state = IDLE;
                end
                else begin
                    nxt_state = NOY_st;
                end
            NOY_st : if (y == Noy_st) begin
                    nxt_state = NOF_st;
                    y = 0;
                    no = no + 1;
                end
                else begin
                    nxt_state = NOX_st;
                end
            NOX_st  : if (x == Nox_st) begin
                    nxt_state = NOY_st;
                    x = 0;
                    y = y + 1;
                end 
                else begin
                    nxt_state = NIF_st;
                end
            NIF_st: if(ni == Nif) begin
                    nxt_state = NOX_st;
                    ni = 0;
                    x = x + 1;
                end
                else begin
                    nxt_state = NKY_st;
                end
            NKY_st: if (ky == Nky) begin
                    nxt_state = NIF_st;
                    ky = 0;
                    ni = ni + 1;
                end
                else begin
                    nxt_state = NKX_st;
                end
            NKX_st: if (kx == Nkx) begin
                    nxt_state = NKY_st;
                    kx = 0;
                    ky = ky + 1;
                end
                else begin
                    x_index = S * x + kx;
                    y_index = S * y + ky;
                    w_index = kx * Nkx + ky;
                    kx = kx + 1;
                end
        endcase
    end
    
    // fixed MAC unit
    generate
        genvar i, j, k;
        for (i = 0; i < POF; i = i + 1) begin
            for (j = 0; j < POY; j = j + 1) begin
                for (k = 0; k < POX; k = k + 1) begin
                    Mac_Unit #(
                        .NI(NIF), .NKY(NKY), .NKX(NKX)
                    ) mac_unit(
                        .clk(clk), .rst_n(rst_n),
                        .input_fm(input_fm[ni][S * x + kx][S * y + ky]),
                        .weight(weight[(no * POF + ni)][kx * Nkx + ky]),
                        .output_fm(output_fm[no][x * POX + y])
                    );
                    //output_fm[no][x][y] += input[ni][S*x+kx][S*y+ky] * weight[ni,no][kx][ky]
                end
            end 
        end
    endgenerate
    
endmodule
