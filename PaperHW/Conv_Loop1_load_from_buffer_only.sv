module Conv_Loop1_load_from_buffer_only #(parameter int kx = 3, Pix = 3, RES=8)(clk,rst_n,weights,pixel_row,pixel_ready,weight_ready,MAC_clear,
													pixel_to_FIFO,
													FIFO_wr_en,FIFO_clear,
													accumulator_out,
													kernel_loop_one_cycle_before_done,kernel_loop_done);
	input wire clk;
	input wire rst_n;
	input  wire [RES-1:0] pixel_row[0:kx-1][0:Pix+kx/2+kx/2-1];
	input wire [RES-1:0] weights[0:kx*kx-1];
	input wire pixel_ready;
	input wire weight_ready;
	input wire MAC_clear;
	
	output wire [RES-1:0] pixel_to_FIFO [0:Pix-1];

	// FIFO
	output reg FIFO_wr_en;
	output reg FIFO_clear;

	output wire kernel_loop_done;
	output wire kernel_loop_one_cycle_before_done;
	output reg [RES-1:0] accumulator_out[0:Pix-1];



	typedef enum reg {Load_multiple_from_buffer,Load_one_from_buffer} state_t;
	
	
	state_t nxt_state,state;


	// Counters
	reg kernel_counter_enable;
	reg [$clog2(kx*kx+1)-1:0] kernel_weight_index;
    reg [$clog2(kx+1)-1:0] kx_index;
    reg [$clog2(kx+1)-1:0] ky_index;
    wire kx_done;
    assign kx_done=kx_index==kx;
	GenericCounter #(.COUNTER_SIZE(kx*kx)) kernel_counter(.clk(clk),.rst_n(rst_n),.enable(kernel_counter_enable),.count(kernel_weight_index));
    GenericCounter #(.COUNTER_SIZE(kx)) kx_counter(.clk(clk),.rst_n(rst_n),.enable(kernel_counter_enable),.count(kx_index));
    GenericCounter #(.COUNTER_SIZE(kx)) ky_counter(.clk(clk),.rst_n(rst_n),.enable(kx_done),.count(ky_index));
    
    
	assign kernel_loop_done = kernel_weight_index==kx*kx;
	assign kernel_loop_one_cycle_before_done = kernel_weight_index==kx*kx-1;

	// register array
	reg [RES-1:0] shift_reg [0:Pix+1-1];
	reg reg_array_prepare_stage;
	wire [RES-1:0] full_row[0:Pix+kx/2+kx/2-1];
	reg [RES-1:0] full_row_array[0:kx-1][0:Pix+kx/2+kx/2-1];
	reg shift_en;
	reg shift_load;

	assign full_row=full_row_array[ky_index];
    // it is $clog2(Pix+1) not $clog2(Pix) because the shift register is Pix+1, not Pix
	reg [$clog2(Pix+kx/2+kx/2+1)-1:0] next_to_read_index;
	

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for (int i = 0; i < Pix; i = i + 1) begin
				shift_reg[i] <= {RES{1'b0}};// Reset the shift register to all zeros
			end
		end else if (shift_en) begin
			shift_reg[0:Pix-1] <= shift_reg[1:Pix];
			shift_reg[Pix] <= reg_array_prepare_stage; // Shift in data from data_in
		end
		else if(shift_load)begin
			shift_reg <= full_row[0:Pix];
		end
	end
	

	assign pixel_to_FIFO = shift_reg[0:Pix-1];

	// MAC arrays
	
	reg MAC_ready;
	

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
            	accumulator_out[i] <= accumulator_out[i] + shift_reg[i]*weights[kernel_weight_index];
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
			full_row_array<=pixel_row;
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
		FIFO_clear=0;

		case(state)
			Load_multiple_from_buffer:begin
				if(pixel_ready&&weight_ready&&kernel_weight_index==0)begin
					shift_load=1;
					MAC_ready=1;
					kernel_counter_enable=1;
					FIFO_wr_en=1;
					nxt_state = Load_one_from_buffer;
				end
				else if(kernel_weight_index==kx*kx)begin
					kernel_counter_enable=1;
					FIFO_clear=1;
				end
                else if (kernel_weight_index>=kx) begin
					shift_load=1;
					MAC_ready=1;
					FIFO_wr_en=1;
                    kernel_counter_enable=1;
					nxt_state = Load_one_from_buffer;
                end
			end
			Load_one_from_buffer:begin
				if(next_to_read_index==Pix+kx/2+kx/2)begin // if the last element is just loaded to the reg_array_prepare_stage
					MAC_ready=1;
					shift_en=1; // there is still one useful piece of data in the shift register [Pix], no uesful unique data in reg_array_prepare_stage
					FIFO_wr_en=1;
					kernel_counter_enable=1;
					nxt_state = Load_multiple_from_buffer;
				end
				else begin
					reg_array_prepare_stage = full_row[next_to_read_index];
					shift_en=1;
					MAC_ready=1;
					kernel_counter_enable=1;
					FIFO_wr_en=1;
				end
			end
		endcase
	end
	
	
endmodule