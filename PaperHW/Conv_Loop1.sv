module Conv_Loop1 #(parameter int kx = 3, Pix = 3, RES=8)(clk,rst_n,weights,pixel_row,pixel_ready,weight_ready,MAC_clear,
													pixel_from_FIFO,pixel_to_FIFO,
													FIFO_wr_en,FIFO_rd_en,FIFO_clear,
													accumulator_out,
													kernel_loop_one_cycle_before_done,kernel_loop_done);
	input wire clk;
	input wire rst_n;
	input wire [RES-1:0] pixel_row[0:Pix+kx/2+kx/2-1];
	input wire [RES-1:0] weights[0:kx*kx-1];
	input wire pixel_ready;
	input wire weight_ready;
	input wire MAC_clear;
	
	input wire [RES-1:0] pixel_from_FIFO [0:Pix-1];
	output wire [RES-1:0] pixel_to_FIFO [0:Pix-1];

	// FIFO
	output reg FIFO_wr_en;
	output reg FIFO_rd_en;
	output reg FIFO_clear;

	output wire kernel_loop_done;
	output wire kernel_loop_one_cycle_before_done;
	output reg [RES-1:0] accumulator_out[0:Pix-1];



	typedef enum reg[1:0] {Load_multiple_from_buffer,Load_one_from_buffer,Load_first_FIFO,Load_from_FIFO} state_t;
	
	
	state_t nxt_state,state;


	// Counters
	reg kernel_counter_enable;
	reg [$clog2(kx*kx-1+1)-1:0] kernel_weight_index;
	GenericCounter #(.COUNTER_SIZE(kx*kx-1)) kernel_counter(.clk(clk),.rst_n(rst_n),.enable(kernel_counter_enable),.count(kernel_weight_index));

	assign kernel_loop_done = kernel_weight_index==kx*kx-1;
	assign kernel_loop_one_cycle_before_done = kernel_weight_index==kx*kx-2;

	// register array
	reg [RES-1:0] shift_reg [0:Pix+1-1];
	reg reg_array_prepare_stage;
	reg [RES-1:0] full_row[0:Pix+kx/2+kx/2-1];
	reg shift_en;
	reg shift_load;


	// it is $clog2(Pix+1) not $clog2(Pix) because the shift register is Pix+1, not Pix
	reg [$clog2(Pix+kx/2+kx/2+1)-1:0] next_to_read_index;
	

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for (int i = 0; i < Pix; i = i + 1) begin
				shift_reg[i] <= {RES{1'b0}};// Reset the shift register to all zeros
			end
		end else if (shift_en) begin
			shift_reg[0:Pix-1] <= shift_reg[1:Pix];
			shift_reg[Pix] <= reg_array_prepare_stage;
		end
		else if(shift_load)begin
			shift_reg <= full_row[0:Pix];
		end
	end
	

	assign pixel_to_FIFO = shift_reg[0:Pix-1];

	// MAC arrays
	
	reg MAC_ready;

	wire [RES-1:0] multiplier_outputs[0:Pix-1];
	genvar i;
	generate
	for(i=0;i<Pix;i=i+1)begin
		Multiplier #(.RES(RES)) multiplier(.clk(clk),.rst_n(rst_n),.a(shift_reg[i]),.b(weights[kernel_weight_index]),.p(multiplier_outputs[i]));
	end
	endgenerate

	always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
			for (int i = 0; i < Pix; i = i + 1) begin
            	accumulator_out[i] <= {RES{1'b0}};// Reset the accumulator to all zeros
			end
        end else if (MAC_ready) begin
			for (int i = 0; i < Pix; i = i + 1) begin
				// Synthesis attributes to suggest DSP slice usage
				// synthesis attribute DSP_style : "use_DSP" 
				// synthesis attribute FULL_ADDER_STYLE : "DSP";
            	accumulator_out[i] <= accumulator_out[i] + multiplier_outputs[i];
			end
        end
        else if (MAC_clear) begin
            for (int i = 0; i < Pix; i = i + 1) begin
            	accumulator_out[i] <= {RES{1'b0}};// Reset the accumulator to all zeros
			end
        end
    end

	
	

	// SM state flipflops
	always_ff@(posedge clk,negedge rst_n)begin
		if(!rst_n)
			state<=Load_multiple_from_buffer;
		else
			state<=nxt_state;
	end

	always @ (pixel_ready or weight_ready) begin
		if(pixel_ready&&weight_ready&&kernel_weight_index==0)
			for (int i = 0; i < Pix+kx/2+kx/2; i = i + 1) begin
				full_row[i]<=pixel_row[i];
			end
	end

	always @ (posedge clk or negedge rst_n) begin
		if(!rst_n)
			next_to_read_index<=Pix;
		else if(nxt_state==Load_one_from_buffer)
			next_to_read_index<=next_to_read_index+1;
		else
			next_to_read_index<=Pix;
	end
	
	always_comb begin
		nxt_state=state;
		MAC_ready=0;
		shift_en=0;
		shift_load=0;
		kernel_counter_enable=0;
		FIFO_wr_en=0;
		FIFO_rd_en=0;
		FIFO_clear=0;

		case(state)
			Load_multiple_from_buffer:begin
				if(pixel_ready&&weight_ready&&kernel_weight_index==0)begin
					
					shift_load=1;
					MAC_ready=1;
					FIFO_wr_en=1;
					nxt_state = Load_one_from_buffer;
					
				end
				else begin
					FIFO_clear=1;
				end
			end
			Load_one_from_buffer:begin
				if(next_to_read_index==Pix+kx/2+kx/2)begin // if full row is loaded
					MAC_ready=1;
					shift_en=1; // there is still one useful piece of data in the shift register [Pix], no uesful unique data in reg_array_prepare_stage
					kernel_counter_enable=1;
					FIFO_wr_en=1;
					nxt_state = Load_first_FIFO;
				end
				else begin
					reg_array_prepare_stage = full_row[next_to_read_index];
					shift_en=1;
					MAC_ready=1;
					kernel_counter_enable=1;
					FIFO_wr_en=1;
				end
			end
			Load_first_FIFO:begin
				FIFO_rd_en=1;
				FIFO_wr_en=1;
				MAC_ready=1;
				kernel_counter_enable=1;
				nxt_state=Load_from_FIFO;
			end
			Load_from_FIFO:begin		
				if(kernel_weight_index==kx*kx-1)begin
					// if went through all the weights, which means it takes kx*kx cycles
					FIFO_clear=1;
					kernel_counter_enable=1;
					MAC_ready=1;
					nxt_state=Load_multiple_from_buffer;
				end
				else begin
					FIFO_rd_en=1;
					FIFO_wr_en=1;
					MAC_ready=1;
					kernel_counter_enable=1;
				end
			end
		endcase
	end
	
	
endmodule