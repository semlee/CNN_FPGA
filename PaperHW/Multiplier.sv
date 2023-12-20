module Multiplier #(parameter int RES=8)(
    input wire clk,
    input wire rst_n,
    input wire [RES-1:0] a,
    input wire [RES-1:0] b,
    output wire [RES-1:0] p
);
    assign p=a*b;
endmodule