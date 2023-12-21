# CNN_FPGA

## Introduction
CNN accelerators are compute intensive, with strong dependency on GPUs that are well known for handling data-intensive Machine Learning Frameworks.  
However, there are number of attempts to generate CNN accelerators onto FPGAs, for the ease of cloud computation with inference using edge device.  
We propose a CNN accelerator suitable for FPGAs,, but considering the roofline models to generate optimal throughput, as well as automated generation of RTL code for CNN accelerators with optimal performance.  
The methodologies of optimization include Loop unrolling, tiling, and interchange, as well as data reuse. 



## Content
### Optimization
This folder is for finding optimal loop unrolling and loop tiling parameters [1].
### PaperHW
This folder includes system verilog code and FPGA files to implement the CNN accelerator archietcture proposed in [1]. 
### RISC-V
This folder includes source code of RISC-V because we initially wanted to implement CNN-accelerator controlled by RISC-V. We then gave up idea and used the embedded ZYNQ processor on PYNQ-Z1 instead.
### Roofline
This is a directory for computing the roofline of the CNN accelerator performance. However, this is not our design space search method for our framework. This is our attempt to combine the roofline model with the design space search method proposed in [1]. 
### systemverilog
This is a failed attempt to design the RTL code for the CNN accelerator. 
### VitisHLS
This is an on-going attempt to test design complexity for the CNN accelerator using VitisHLS.
### Tensil
This shows proof of testing the RESNET-20 performance on Tensil. https://www.tensil.ai/docs/tutorials/resnet20-pynqz1/



## Reference
[1] Y. Ma, Y. Cao, S. Vrudhula and J. -s. Seo, "Optimizing the Convolution Operation to Accelerate Deep Neural Networks on FPGA," in IEEE Transactions on Very Large Scale Integration (VLSI) Systems, vol. 26, no. 7, pp. 1354-1367, July 2018, doi: 10.1109/TVLSI.2018.2815603. 