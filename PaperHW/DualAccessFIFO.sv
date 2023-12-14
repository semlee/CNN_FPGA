module DualAccessFIFO#(
    parameter RES = 8,
    parameter DEPTH = 4,
    parameter WIDTH = 3
) (
    input clk,
    input rst_n,
    input wr_en,
    input rd_en,
    input [RES-1:0] data_in[WIDTH-1:0],
    input clear,
    output reg [RES-1:0] data_out[WIDTH-1:0],
    output reg empty,
    output reg full
);

reg [RES-1:0] mem [DEPTH-1:0][WIDTH-1:0];
reg [RES-1:0] data_out_reg[WIDTH-1:0];
reg [DEPTH-1:0] wr_ptr;
reg [DEPTH-1:0] rd_ptr;
reg [DEPTH:0] count;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        count <= 0;
        empty <= 1;
        full <= 0;

    end 
    else if(clear)begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        count <= 0;
        empty <= 1;
        full <= 0;

    end
    else begin
        
        if (wr_en && !full) begin
            mem[wr_ptr] <= data_in;
            wr_ptr <= (wr_ptr + 1)%DEPTH;
            count <= count + 1;
            empty <= 0;
            if (count == DEPTH) full <= 1;
        end
        if (rd_en && !empty) begin
            data_out_reg <= mem[rd_ptr];
            rd_ptr <= (rd_ptr + 1)%DEPTH;
            count <= count - 1;
            full <= 0;
            if (count == 1) empty <= 1;
        end
        
    end
end

assign data_out = data_out_reg;

endmodule
