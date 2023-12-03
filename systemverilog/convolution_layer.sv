`timescale 1ns/1ps

module mac_unit (
    input clk, rstn,
    input wire signed [31:0] input_fm, // Operand A
    input wire signed [31:0] weight, // Operand B
    inout wire signed [31:0] output_fm // Result (accumulated product)
);
  reg signed [31:0] product; // Intermediate product
  
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
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
    output wire signed [31:0] out_data [1:0][1:0]
);
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
    output wire signed [31:0] out_data [1:0][1:0]
)
    always_comb begin
        out_data[0][0] = (in_data[0][0] > 0) ? in_data[0][0] : 0;
        out_data[0][1] = (in_data[0][1] > 0) ? in_data[0][1] : 0;
        out_data[1][0] = (in_data[1][0] > 0) ? in_data[1][0] : 0;
        out_data[1][1] = (in_data[1][1] > 0) ? in_data[1][1] : 0;
    end
endmodule