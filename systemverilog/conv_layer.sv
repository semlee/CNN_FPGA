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
  
module cnn_top (clk, rst_n, input_image, filter, output_image);
	input clk, rst_n;
	input signed [31:0] input_image [0:31] [0:31][0:31];
	input signed [31:0] filter [0:31] [0:31];
	output logic signed [31:0] output_image [0:31] [0:31];

	localparam Pof = 4;
	localparam Poy = 7;
	localparam Pox = 7; 
	localparam Nif = 3;
	localparam Nkx = 3;
	localparam Nky = 3;
	localparam Nof = 64;
	localparam Nox = 224;
	localparam Noy = 224;
	localparam Tox = 1;
	localparam Toy = 1;
	localparam Tof = 1;
	localparam S = 1;
	 
	
	logic signed [31:0] input_fm [0:Pof-1][0:Pox-1][0:Poy-1];
    logic signed [31:0] weight [0:Pof-1][0:Pox-1][0:Poy-1];
    logic signed [31:0] output_fm [0:Pof-1][0:Pox-1][0:Poy-1];
	logic conv_done;
	
	integer i, j, k, no, x, y, ni, ky, kx;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			// Reset the registers on the negative edge of reset
			for (i = 0; i < Pof; i = i + 1) begin
				for (j = 0; j < Pox; j = j + 1) begin
					for (k = 0; k < Poy; k = k + 1) begin
						input_fm[i][j][k] <= 32'h0;
						weight[i][j][k] <= 32'h0;
					end
				end
			end
		end else if (conv_done) begin
			// Set the registers from the original image and filter
			for (i = 0; i < Pof; i = i + 1) begin
				for (j = 0; j < Pox; j = j + 1) begin
					for (k = 0; k < Nky * Poy; k = k + 1) begin
						input_fm[i][j][k] <= input_image[ni][S * x + kx][S * y + ky]; //input[ni][S*x+kx][S*y+ky]
						weight[i][j][k] <= filter[no * Nif + ni][S * x + kx][S * y + ky]; //weight[ni,no][kx][ky]
					end
				end
			end
			
			for (no = 0; no < Nof; no = no + Pof) begin
				for (y = 0; y < Noy; y = y + Poy) begin
					for (x = 0; x < Nox; x = x + Pox) begin
						for (ni = 0; ni < Nif; ni = ni + 1) begin
							for (ky = 0; ky < Nky; ky = ky + 1) begin
								for (kx = 0; kx < Nkx; kx = kx + 1) begin
									input_fm[no][S * x + kx][S * y + ky] <= input_image[no][S * x + kx][S * y + ky];
									weight[no * Nif + ni][kx][ky] <= filter[no * Nif + ni][S * x + kx][S * y + ky];
									
									output_fm[no][x][y] += input[ni][S*x+kx][S*y+ky] * weight[ni,no][kx][ky]
								end
							end
						end
					end
				end
			end
		end
	end
		
	
	mac_unit_generator #(
        .Nif(Nif),
        .Nky(Nky),
        .Nkx(Nkx),
        .Pof(Pof),
        .Poy(Poy),
        .Pox(Pox)
    ) mac_unit_gen_inst (
        .clk(clk),
        .rst_n(rst_n),
        .input_reg(input_fm),
        .weight_reg(weight),
        .output_reg(output_fm)
		.no(no), .y(y), .x(x), .ni(ni), .ky(ky), .kx(kx),
    );
	
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
		.output_fm(output_fm),
		.conv_done(conv_done)
	);

	max_pool max_pool_1 (.in_data(output_fm), .out_data(output_fm));

	relu relu_1 (.in_data(output_fm), .out_data(output_fm));

	//fc_layer #(16) fc_layer_1 (.clk(clk), .rst_n(rst_n), .input_data(input_data), .weights(weights), .bias(bias), .output_data(output_data));
  
endmodule

module conv_controller #(
	parameter Nof = 4,
	parameter Noy = 7,
	parameter Nox = 7,
	parameter Nif = 3,
    parameter Nky = 3,
    parameter Nkx = 3,
    parameter Pof = 4,
    parameter Poy = 7,
    parameter Pox = 7,
	parameter Tox = 1,
	parameter Toy = 1,
	parameter Tof = 1,
	parameter S = 1
	)  (
    input wire clk, rst_n,
    input wire conv_run,
    input wire signed [31:0] input_fm [0:Pof-1][0:Pox*Nkx-1][0:Poy*Nky-1],
    input wire signed [31:0] weight [0:Pof*Nif-1][0:Nkx*Pox-1][0:Nky*Poy-1],
    output logic signed [31:0] output_fm [0:Pof-1][0:Pox-1][0:Poy-1],
	output logic signed [31:0] no, y, x, ni, ky, kx,
	output logic conv_done
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
    typedef enum logic [2:0] {IDLE, NOF_st, NOY_st, NOX_st, NIF_st, NKY_st, NKX_st, WAIT} state_t;
    state_t state, nxt_state;
    integer x_index, y_index, w_index;
    //integer no, x, y, ni, kx, ky;
    integer Nof_st = Nof / Pof;
    integer Noy_st = Noy / Poy;
    integer Nox_st = Nox / Pox;
		
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
                    no = 0;
                    y = 0;
                    x = 0;
                    ni = 0;
                    ky = 0;
                    kx = 0;
					conv_done = 1'b0;
                    nxt_state = NKX_st;
                end
			NKX_st: if (kx == Nkx) begin
                    nxt_state = NKY_st;
                    kx = 0;
                    ky = ky + 1;
                end
                else begin
					kx = kx + 1;
				end
			NKY_st: if (ky == Nky) begin
                    nxt_state = NIF_st;
                    ky = 0;
                    ni = ni + 1;
                end
                else begin
                    nxt_state = NKX_st;
                end
			NIF_st: if(ni == Nif) begin
                    nxt_state = NOX_st;
                    ni = 0;
                    x = x + 1;
                end
                else begin
                    nxt_state = NKY_st;
                end
			NOX_st  : if (x == Nox_st) begin
                    nxt_state = NOY_st;
                    x = 0;
                    y = y + 1;
                end 
                else begin
                    nxt_state = NIF_st;
                end
			NOY_st : if (y == Noy_st) begin
                    nxt_state = NOF_st;
                    y = 0;
                    no = no + 1;
                end
                else begin
                    nxt_state = NOX_st;
                end
            NOF_st : if (no == Nof_st) begin
                    nxt_state = IDLE;
					no = 0;
					conv_done = 1'b1;
                end
                else begin
                    nxt_state = NOY_st;
                end
        endcase
    end
    
endmodule

module mac_unit_generator #(
    parameter Nif = 3,
    parameter Nky = 3,
    parameter Nkx = 3,
    parameter Pof = 4,
    parameter Poy = 7,
    parameter Pox = 7
) (
    input wire clk, rst_n,
	input wire signed [31:0] no, y, x, ni, ky, kx,
    input wire signed [31:0] input_reg [0:Pof-1][0:Pox-1][0:Poy-1];,
    input wire signed [31:0] weight_reg [0:Pof-1][0:Pox-1][0:Poy-1];,
    output logic signed [31:0] output_reg [0:Pof-1][0:Pox-1][0:Poy-1];
);

	/*
	STILL NEED TO WORK ON:
	output_fm[no][x][y] += input[ni][S*x+kx][S*y+ky] * weight[ni,no][kx][ky]
	
	indexing based on the index given above
	*/
	// Assign input and weight based on your logic outside of generate
	generate
		genvar i, j, k;
		for (i = 0; i < Pof; i = i + 1) begin
			for (j = 0; j < Poy; j = j + 1) begin
				for (k = 0; k < Pox; k = k + 1) begin
					// Call the mac_unit module with the registers
					mac_unit #(
						.Nif(Nif), .Nky(Nky), .Nkx(Nkx)
					) mac_unit_inst(
						.clk(clk), .rst_n(rst_n),
						.input_fm(input_reg[i][k][j]),
						.weight(weight_reg[i][k][j]),
						.output_fm(output_reg[i][k][j])
					);
				end
			end
		end
	endgenerate

endmodule


module mac_unit #(
    parameter Nif = 3,
    parameter Nky = 3,
    parameter Nkx = 3
)  (
    input clk, rst_n,
    input wire signed [31:0] input_fm, // Operand A
    input wire signed [31:0] weight, // Operand B
    output logic signed [31:0] output_fm // Result (accumulated product)
);
  reg signed [31:0] product; // Intermediate product
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      product <= 0; // Reset the product on reset
    end 
    else begin
      // Multiply A and B, then add the result to the accumulator
      product <= input_fm * weight + output_fm;
    end
  end

  assign output_fm = product;
endmodule

module max_pool (
    input wire signed [31:0] in_data [3:0][3:0],
    output logic signed [31:0] out_data [1:0][1:0]
);
    logic [31:0] max_val;
    always_comb begin
        max_val = (in_data[0][0] > in_data[0][1]) ? in_data[0][0] : in_data[0][1];
        max_val = (max_val > in_data[1][0]) ? max_val : in_data[1][0];
        max_val = (max_val > in_data[1][1]) ? max_val : in_data[1][1];
        out_data[0][0] = max_val;
        
        max_val = (in_data[0][2] > in_data[0][3]) ? in_data[0][2] : in_data[0][3];
        max_val = (max_val > in_data[1][2]) ? max_val : in_data[1][2];
        max_val = (max_val > in_data[1][3]) ? max_val : in_data[1][3];
        out_data[0][1] = max_val;

        max_val = (in_data[2][0] > in_data[2][1]) ? in_data[2][0] : in_data[2][1];
        max_val = (max_val > in_data[3][0]) ? max_val : in_data[3][0];
        max_val = (max_val > in_data[3][1]) ? max_val : in_data[3][1];
        out_data[1][0] = max_val;

        max_val = (in_data[2][2] > in_data[2][3]) ? in_data[2][2] : in_data[2][3];
        max_val = (max_val > in_data[3][2]) ? max_val : in_data[3][2];
        max_val = (max_val > in_data[3][3]) ? max_val : in_data[3][3];
        out_data[1][1] = max_val;
    end

endmodule

module relu (
    input wire signed [31:0] in_data [1:0][1:0],
    output logic signed [31:0] out_data [1:0][1:0]
);
    always_comb begin
        out_data[0][0] = (in_data[0][0] > 0) ? in_data[0][0] : 0;
        out_data[0][1] = (in_data[0][1] > 0) ? in_data[0][1] : 0;
        out_data[1][0] = (in_data[1][0] > 0) ? in_data[1][0] : 0;
        out_data[1][1] = (in_data[1][1] > 0) ? in_data[1][1] : 0;
    end
endmodule

