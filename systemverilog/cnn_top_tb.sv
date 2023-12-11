`timescale 1ns / 1ps

module tb_cnn_top;

  reg clk, rst_n, conv_run;
  reg signed [31:0] input_image [0:31] [0:31];
  reg signed [31:0] filter [0:31] [0:31];
  reg [31:0] output_image [0:31] [0:31];

  // Instantiate the design
  cnn_top dut (
    .clk(clk),
    .rst_n(rst_n),
    .input_image(input_image),
    .filter(filter),
    .output_image(output_image)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Reset generation
  initial begin
    rst_n = 0;
    #10 rst_n = 1;
  end

  // Stimulus generation
  initial begin
    conv_run = 1; // Start convolution

    // Fill input_image with random values between 0 and 1
    foreach (input_image[i, j]) begin
      foreach (input_image[i, j]) begin
        input_image[i][j] = $rtoi($random) / $pow(2, $bits(input_image[i][j]));
      end
    end

    // Fill filter with random values between 0 and 1
    foreach (filter[i, j]) begin
      foreach (filter[i, j]) begin
        filter[i][j] = $rtoi($random) / $pow(2, $bits(filter[i][j]));
      end
    end

    // Wait for a few clock cycles
    #10000;

    // Add any checks/assertions here to verify the results
    
    $stop; // Stop simulation
  end

endmodule

