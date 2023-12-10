`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/10 15:15:46
// Design Name: 
// Module Name: cnn_top_tb
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

module cnn_top_tb;

    reg clk, rst_n;
    reg [31:0] input_image [0:7] [0:31];
    reg  [31:0] filter [0:7] [0:31];
    wire [31:0] output_image [0:7] [0:31];

    // Add other necessary signals here

    // Instantiate your design
    cnn_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .input_image(input_image),
        .filter(filter),
        .output_image(output_image)
        // Add other signal connections
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Initial stimulus
    initial begin
        // Apply reset
        rst_n = 0;
        #10;

        // Deassert reset
        rst_n = 1;
        #10;

        // Example input data
        for (int i = 0; i < 8; i = i + 1) begin
            for (int j = 0; j < 32; j = j + 1) begin
                input_image[i][j] = $random; // Replace with your actual input data
            end
        end

        // Example filter data
        for (int i = 0; i < 8; i = i + 1) begin
            for (int j = 0; j < 32; j = j + 1) begin
                filter[i][j] = $random; // Replace with your actual filter data
            end
        end

        // Wait for some cycles before checking the output
        #100;

        // Print the output for verification
        $display("Output Image: %p", output_image);

        // Finish simulation after some time
        #1000 $finish;
    end

    // Add other necessary tasks for monitoring or checking results

endmodule


