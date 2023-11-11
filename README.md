# CNN_FPGA

## Introduction
CNN accelerators are compute intensive, with strong dependency on GPUs that are well known for handling data-intensive Machine Learning Frameworks.  
However, there are number of attempts to generate CNN accelerators onto FPGAs, for the ease of cloud computation with inference using edge device.  
We propose a CNN accelerator suitable for FPGAs,, but considering the roofline models to generate optimal throughput, as well as automated generation of RTL code for CNN accelerators with optimal performance.  
The methodologies of optimization include Loop unrolling, tiling, and interchange, as well as data reuse and data management using DMA.  
