module GenericCounter #(parameter int COUNTER_SIZE = 5)(
  input wire clk,
  input wire rst_n,
  input wire enable,
  output wire [$clog2(COUNTER_SIZE+1)-1:0] count
);


  reg [$clog2(COUNTER_SIZE+1)-1:0] count_reg;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count_reg <= 0; // Reset the counter to 0
    end 
    else if(enable)begin
      if (count_reg == COUNTER_SIZE) begin
        count_reg <= 0; // Reset when it reaches the specified size
      end
      else begin
        count_reg <= count_reg + 1; // Increment the counter on rising edge of clk
      end 
    end
  end

  assign count = count_reg;

endmodule
