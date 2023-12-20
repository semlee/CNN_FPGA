module Conv_Loop2 #(parameter int kx = 3, Pix = 3, Piy=3, RES=8, Nif=10)(clk,rst_n,weights_array,pixel_row_array,pixel_ready,weight_ready,
																accumulator_out,accumulator_out_valid);
    input wire clk;
	input wire rst_n;
	input wire [RES-1:0] pixel_row_array[0:Nif-1][0:Piy+kx/2+kx/2-1][0:Pix+kx/2+kx/2-1]; // including north padding and south padding and east padding
	input wire [RES-1:0] weights_array[0:Nif-1][0:kx*kx-1];
	input wire pixel_ready;
	input wire weight_ready;

	output reg [RES-1:0] accumulator_out[0:Piy-1][0:Pix-1];
	output wire accumulator_out_valid;
	
	wire [RES-1:0] pixel_from_FIFO [0:Piy-1][0:Pix-1];
	wire [RES-1:0] pixel_to_FIFO [0:Piy-1][0:Pix-1];

	// FIFO
	wire FIFO_wr_en[0:Piy-1];
	wire FIFO_rd_en[0:Piy-1];
	wire FIFO_clear[0:Piy-1];

    wire kernel_loop_done[0:Piy-1];

	reg [RES-1:0] pixel_row[0:Piy+kx/2+kx/2-1][0:Pix+kx/2+kx/2-1];
	reg [RES-1:0] weights[0:kx*kx-1];


	// Counters
	reg map_counter_enable;
	reg [$clog2(Nif-1)-1:0]map_index;
	GenericCounter #(.COUNTER_SIZE(Nif-1)) kernel_counter(.clk(clk),.rst_n(rst_n),.enable(map_counter_enable),.count(map_index));
	
	reg conv_loop1_pixel_ready;
	reg conv_loop1_weight_ready;
	// Conv_Loop generate loop
	genvar i;
	generate
	for (i = 0; i < Piy-1; i = i + 1) begin
			Conv_Loop1 #(.kx(kx),.Pix(Pix),.RES(RES)) conv_loop1(.clk(clk),.rst_n(rst_n),.weights(weights),.pixel_row(pixel_row[i]),.pixel_ready(conv_loop1_pixel_ready),.weight_ready(conv_loop1_weight_ready),.MAC_clear(pixel_ready&&weight_ready&&map_index==0),
																	.pixel_from_FIFO(pixel_from_FIFO[i]),.pixel_to_FIFO(pixel_to_FIFO[i]),
																	.FIFO_wr_en(FIFO_wr_en[i]),.FIFO_rd_en(FIFO_rd_en[i]),.FIFO_clear(FIFO_clear[i]),
																	.accumulator_out(accumulator_out[i]),
																	.kernel_loop_done(kernel_loop_done[i]));
		end
	endgenerate

	Conv_Loop1_load_from_buffer_only #(.kx(kx),.Pix(Pix),.RES(RES)) conv_loop1_special(.clk(clk),.rst_n(rst_n),.weights(weights),.pixel_row(pixel_row[Piy-1:Piy+kx/2+kx/2-1]),.pixel_ready(conv_loop1_pixel_ready),.weight_ready(conv_loop1_weight_ready),.MAC_clear(pixel_ready&&weight_ready&&map_index==0),
																	.pixel_to_FIFO(pixel_to_FIFO[Piy-1]),
																	.FIFO_wr_en(FIFO_wr_en[Piy-1]),.FIFO_clear(FIFO_clear[Piy-1]),
																	.accumulator_out(accumulator_out[Piy-1]),
																	.kernel_loop_done(kernel_loop_done[Piy-1]));


	// DualAccessFIFO generate loop
	// if there are Piy=3, FIFOs are in between, so there are only 2 FIFOs
	generate
	for (i = 0; i < Piy-1; i = i + 1) begin
		DualAccessFIFO #(.RES(RES),.DEPTH(kx+1),.WIDTH(Pix)) DualAccessFIFO(.clk(clk),.rst_n(rst_n),.wr_en(FIFO_wr_en[i+1]),.rd_en(FIFO_rd_en[i]),.data_in(pixel_to_FIFO[i+1]),.clear(FIFO_clear[i+1]),.data_out(pixel_from_FIFO[i]),.empty(),.full());
	end
	endgenerate

	
	always_comb begin
		if(pixel_ready&&weight_ready&&map_index==0||kernel_loop_done[0]==1)begin
			pixel_row = pixel_row_array[map_index];
			weights = weights_array[map_index];
			map_counter_enable=1;
			conv_loop1_pixel_ready=1;
			conv_loop1_weight_ready=1;
		end
		else begin
			conv_loop1_pixel_ready=0;
			conv_loop1_weight_ready=0;
			map_counter_enable=0;
		end
	end

	assign accumulator_out_valid=kernel_loop_done[Piy-1]&&(map_index==Nif-1);



endmodule