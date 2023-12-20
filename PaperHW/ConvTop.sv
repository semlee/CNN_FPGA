module ConvTop
    import ConvLoopParam::*;
    (clk,rst_n,bram_rd_addr,bram_wr_addr,input_pixels,weights,output_pixels,
    ready,valid,read_en,write_en,tile_pof_done,tile_done);
    input wire clk;
	input wire rst_n;
	input wire [128-1:0] input_pixels;
    input wire [128-1:0] weights;
    output wire [32-1:0] bram_rd_addr;
    output reg read_en;
    output reg write_en;
    output wire [32-1:0] bram_wr_addr;
    output wire [128-1:0] output_pixels;
    input wire ready;
    output wire valid;
    output wire tile_pof_done;
    output wire tile_done;

    typedef enum reg[2:0] {idle,kernel_in_progress_state,kernel_about_to_finish,input_data_ready_state,loop2_done_wait} input_stream_state_t;
    input_stream_state_t nxt_input_state,input_state;

    typedef enum reg {idle_write,writing_to_buffer} output_stream_state_t;
    output_stream_state_t nxt_output_state,output_state; 

    wire [RES-1:0] pixel_row[0:Piy+kx/2+kx/2-1][0:Pix+kx/2+kx/2-1];
    wire [RES-1:0] weights_kernel[0:kx*kx-1];

    wire [RES-1:0] accumulator_out[0:Pof-1][0:Piy-1][0:Pix-1];


    reg [32-1:0] bram_rd_addr_single;
    reg [32-1:0] bram_wr_addr_single;

    

    assign bram_rd_addr = bram_rd_addr_single;
    assign bram_wr_addr = bram_wr_addr_single;

    reg conv_loop1_weight_ready;
    reg conv_loop1_pixel_ready;

    

    wire [RES-1:0] pixel_from_FIFO [0:Pof-1][0:Piy-1][0:Pix-1];
	wire [RES-1:0] pixel_to_FIFO [0:Pof-1][0:Piy-1][0:Pix-1];

	// FIFO
	wire FIFO_wr_en[0:Pof-1][0:Piy-1];
	wire FIFO_rd_en[0:Pof-1][0:Piy-1];
	wire FIFO_clear[0:Pof-1][0:Piy-1];

    wire kernel_loop_done[0:Pof-1][0:Piy-1];
    wire kernel_loop_one_cycle_before_done[0:Pof-1][0:Piy-1];
    reg MAC_clear;

   

    // Counters
	reg [$clog2(Nif-1+1)-1:0]map_index;
	GenericCounter #(.COUNTER_SIZE(Nif-1)) kernel_counter(.clk(clk),.rst_n(rst_n),.enable(kernel_loop_done[0][0]),.count(map_index));

    reg [$clog2(Pof-1+1)-1:0]Pof_index;
    reg Pof_index_enable;
    GenericCounter #(.COUNTER_SIZE(Pof-1)) Pof_write_counter(.clk(clk),.rst_n(rst_n),.enable(Pof_index_enable),.count(Pof_index));
    
    genvar i,j,k;
    generate
        for(i = 0;i < Piy; i = i + 1) begin
        for (j = 0; j < Pix; j = j + 1) begin
            assign output_pixels[(i*(Pix)+j+1)*RES-1:((i*(Pix)+j)*RES)]=accumulator_out[Pof_index][i][j];
            // need to double check the index
        end
    end
    endgenerate
    
    
    
    generate
    for(i = 0;i < Piy+kx/2+kx/2; i = i + 1) begin
        for (j = 0; j < Pix+kx/2+kx/2; j = j + 1) begin
            assign pixel_row[i][j] = input_pixels[(i*(Pix+kx/2+kx/2)+j+1)*RES-1:((i*(Pix+kx/2+kx/2)+j)*RES)];
            // need to double check the index
        end
    end
    endgenerate


    generate
    for(i = 0;i < kx*kx; i = i + 1) begin
        assign weights_kernel[i] = weights[(i+1)*RES-1:(i*RES)];
        // need to double check the index
    end
    endgenerate


    

    

	generate
    for (k = 0;k<Pof;k=k+1) begin
        for (i = 0; i < Piy-1; i = i + 1) begin
                Conv_Loop1 #(.kx(kx),.Pix(Pix),.RES(RES)) conv_loop1(.clk(clk),.rst_n(rst_n),.weights(weights_kernel),.pixel_row(pixel_row[i]),.pixel_ready(conv_loop1_pixel_ready),.weight_ready(conv_loop1_weight_ready),.MAC_clear(MAC_clear),
                                                                        .pixel_from_FIFO(pixel_from_FIFO[k][i]),.pixel_to_FIFO(pixel_to_FIFO[k][i]),
                                                                        .FIFO_wr_en(FIFO_wr_en[k][i]),.FIFO_rd_en(FIFO_rd_en[k][i]),.FIFO_clear(FIFO_clear[k][i]),
                                                                        .accumulator_out(accumulator_out[k][i]),
                                                                        .kernel_loop_one_cycle_before_done(kernel_loop_one_cycle_before_done[k][i]),.kernel_loop_done(kernel_loop_done[k][i]));
        end
    end
	endgenerate

    generate
    for (k = 0;k<Pof;k=k+1) begin
	Conv_Loop1_load_from_buffer_only #(.kx(kx),.Pix(Pix),.RES(RES)) conv_loop1_special(.clk(clk),.rst_n(rst_n),.weights(weights_kernel),.pixel_row(pixel_row[Piy-1:Piy+kx/2+kx/2-1]),.pixel_ready(conv_loop1_pixel_ready),.weight_ready(conv_loop1_weight_ready),.MAC_clear(MAC_clear),
																	.pixel_to_FIFO(pixel_to_FIFO[k][Piy-1]),
																	.FIFO_wr_en(FIFO_wr_en[k][Piy-1]),.FIFO_clear(FIFO_clear[k][Piy-1]),
																	.accumulator_out(accumulator_out[k][Piy-1]),
																	.kernel_loop_one_cycle_before_done(kernel_loop_one_cycle_before_done[k][Piy-1]),.kernel_loop_done(kernel_loop_done[k][Piy-1]));
    end
    endgenerate
    // DualAccessFIFO generate loop
	// if there are Piy=3, FIFOs are in between, so there are only 2 FIFOs
	generate
	for (i = 0; i < Piy-1; i = i + 1) begin
    for (k = 0;k<Pof;k=k+1) begin
		DualAccessFIFO #(.RES(RES),.DEPTH(kx+1),.WIDTH(Pix)) DualAccessFIFO(.clk(clk),.rst_n(rst_n),.wr_en(FIFO_wr_en[k][i+1]),.rd_en(FIFO_rd_en[k][i]),.data_in(pixel_to_FIFO[k][i+1]),.clear(FIFO_clear[k][i+1]),.data_out(pixel_from_FIFO[k][i]),.empty(),.full());
	end
    end
	endgenerate

    // SM input_state flipflops
	always_ff@(posedge clk,negedge rst_n)begin
		if(!rst_n) begin
			input_state<=idle;
            output_state<=idle_write;
        end
		else begin
			input_state<=nxt_input_state;
            output_state<=nxt_output_state;
        end
	end

    reg bram_rd_addr_next;
    reg bram_wr_addr_next;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bram_rd_addr_single <= 0;
            bram_wr_addr_single <= 0;
        end
        else if (tile_pof_done) begin
            bram_rd_addr_single <= 0;
            bram_wr_addr_single <= 0;
        end 
        else if (bram_rd_addr_next) begin
            bram_rd_addr_single <= bram_rd_addr_single + 32'h4;
        end else if (bram_wr_addr_next) begin
            bram_wr_addr_single <= bram_wr_addr_single + 32'h4;
        end 
    end

    wire output_pixel_write_on;
    assign output_pixel_write_on = output_state==writing_to_buffer || nxt_output_state==writing_to_buffer;
    
    reg [$clog2(Tof/Pof+1)-1:0] Tof_index;
    wire Tof_enable;
    assign Tof_enable=tile_pof_done;
    reg Tof_clear;

    always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      Tof_index <= 0; // Reset the counter to 0
    end 
    else if(Tof_clear)
        Tof_index <= 0;
    else if(Tof_enable) 
        Tof_index <= Tof_index + 1; // Increment the counter on rising edge of clk
  end

    always_comb begin
		nxt_input_state=input_state;
        bram_rd_addr_next=0;
        read_en=0;
        conv_loop1_weight_ready=0;
        conv_loop1_pixel_ready=0;
        MAC_clear=0;
        Tof_clear=0;
        case(input_state)
            idle:begin
                if(ready)begin
                    conv_loop1_weight_ready=1;
                    conv_loop1_pixel_ready=1;
                    nxt_input_state=kernel_in_progress_state;
                    Tof_clear=1;
                end
                else if(Tof_index<Tof/Pof)begin
                    conv_loop1_weight_ready=1;
                    conv_loop1_pixel_ready=1;
                    nxt_input_state=kernel_in_progress_state;
                end
            end
            kernel_in_progress_state:begin
                if(kernel_loop_one_cycle_before_done[0][0])begin
                    bram_rd_addr_next = 1;
                    nxt_input_state=kernel_about_to_finish;
                end
            end
            kernel_about_to_finish:begin
                if (tile_pof_done)begin
                    nxt_input_state=idle;
                end
                else if(kernel_loop_done[0][0]&&!valid)begin
                    read_en=1;
                    nxt_input_state=input_data_ready_state;
                end
                else if(kernel_loop_done[0][0]&&valid)begin
                    read_en=1;
                    nxt_input_state=loop2_done_wait;
                end
            end
            input_data_ready_state:begin
                conv_loop1_weight_ready=1;
                conv_loop1_pixel_ready=1;
                nxt_input_state=kernel_in_progress_state;
            end
            loop2_done_wait:begin
                if(!output_pixel_write_on)begin
                    conv_loop1_weight_ready=1;
                    conv_loop1_pixel_ready=1;
                    MAC_clear=1;
                    nxt_input_state=kernel_in_progress_state;
                end
            end

        endcase
    end

    always_comb begin
        nxt_output_state=output_state;
        write_en=0;
        Pof_index_enable=0;
        bram_wr_addr_next=0;
        case(output_state)
            idle_write:begin
                if(valid)begin
                    Pof_index_enable=1;
                    write_en=1;
                    bram_wr_addr_next=1;
                    nxt_output_state=writing_to_buffer;
                end
            end
            writing_to_buffer:begin
                if(Pof_index==Pof-1)begin
                    Pof_index_enable=1;
                    write_en=1;
                    bram_wr_addr_next=1;
                    nxt_output_state=idle_write;
                end
                else begin
                    write_en=1;
                    bram_wr_addr_next=1;
                    Pof_index_enable=1;
                end
            end
        endcase
    end


    assign valid= (kernel_loop_done[0][0]&&(map_index==Nif-1));
    assign tile_pof_done = bram_rd_addr==32'h10 && valid;
    assign tile_done = (Tof_index==Tof/Pof);


endmodule

