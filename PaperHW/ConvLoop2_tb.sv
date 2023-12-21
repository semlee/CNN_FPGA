module Conv_Loop2_tb();

import ConvLoopParam::*;

reg [128-1:0] pixels_1D;	// 16-bit wide 256 entry ROM
reg [128-1:0] weights_1D;


reg clk;
reg rst_n;

reg ready;
reg valid;

wire [128-1:0] output_pixels;
wire read_en;
wire write_en;
wire [32-1:0] bram_rd_addr;
wire [32-1:0] bram_wr_addr;

wire tile_pof_done;
wire tile_done;

ConvTop conv_top(.clk(clk),.rst_n(rst_n),.input_pixels(pixels_1D),.weights(weights_1D),.output_pixels(output_pixels),
                  .ready(ready),.valid(valid),.read_en(read_en),.write_en(write_en),.bram_rd_addr(bram_rd_addr),.bram_wr_addr(bram_wr_addr),
                  .tile_pof_done(tile_pof_done),.tile_done(tile_done));

always
		#5 clk = ~clk;
      
initial begin
   // $readmemh("input_feature_map.txt",pixels_1D);
   // $readmemh("weight_map.txt",weights_1D);

   // for (int k = 0; k < Nif; k = k + 1) begin
   //    for (int i = 0; i <(Pix+kx/2+kx/2); i = i + 1) begin
   //       for (int j= 0; j<(Piy+kx/2+kx/2); j=j+1) begin
   //             pixel_map_row_array[k][i][j]=pixels_1D[k*(Pix+kx/2+kx/2)*(Piy+kx/2+kx/2)+i*(Piy+kx/2+kx/2)+j];
   //       end
   //    end
   // end

   // for (int k = 0; k < Nif; k = k + 1) begin
   //    for (int i = 0; i <kx*kx; i = i + 1) begin
   //       weights_map_array[k][i]=weights_1D[k*kx*kx+i];
   //    end
   // end



   pixels_1D='1;
   weights_1D='1;
   ready=0;
   
   clk = 0;
	rst_n = 0;
	@(negedge clk);
	rst_n = 1;

   repeat (5) @(negedge clk);
   ready = 1;
   // @(negedge clk);
   // ready = 0;



   repeat (20*Nif*kx*kx) @(posedge clk); // if the sine waveform appears, then the design is correct.

   // ready = 1;
   // @(negedge clk);
   // ready = 0;

   repeat (20*Nif*kx*kx) @(posedge clk); // if the sine waveform appears, then the design is correct.

	$stop();



end



endmodule