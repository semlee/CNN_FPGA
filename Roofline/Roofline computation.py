import math
#import pandas as pd

# Basic Input

print("Type in your input")
input_data = input("(Nox | Noy | Nif | Nof | Nkx | Nky | S | Tox | Toy | Tif | Tof)\n")
input_list = input_data.split(" | ")
print(input_list)
input_reuse = input("reuse output framework data? Y | N : ")
if input_reuse == 'y' or input_reuse == "Y" :
    output_reuse = 1
elif input_reuse == 'n' or input_reuse == "N" :
    output_reuse = 0
else:
    print("Invalid Expression")


# Original Variables
Nox = int(input_list[0])
Noy = int(input_list[1])
Nif = int(input_list[2])
Nof = int(input_list[3])
Nkx = int(input_list[4])
Nky = int(input_list[5])
S = int(input_list[6])

Tox = int(input_list[7])
Toy = int(input_list[8])
Tif = int(input_list[9])
Tof = int(input_list[10])

# Converted Variables
Nix = Nox
Niy = Noy
Tix = Tox
Tiy = Toy

R = Nox
C = Noy
N = Nif
M = Nof
K = Nkx
Tr = Tox
Tc = Toy
Tn = Tif
Tm = Tof

# Compute Coputational Roof
Total_execution = 2 * R * C * M  * N * K * K
Num_Exe_cycles = math.ceil(M/Tm) * math.ceil(N/Tn) * R* C * K * K

Compute_Roof = Total_execution / Num_Exe_cycles

# Compute alpha and B
alpha_in = M/Tm * N/Tn * R/Tr * C/Tc
alpha_weight = alpha_in
alpha_out_no_reuse = 2 * alpha_weight # not using data reuse
alpha_out_reuse = M/Tm * R/Tr * C/Tc

if output_reuse == 1: 
    alpha_out = alpha_out_reuse 
else:
    alpha_out = alpha_out_no_reuse 

B_in = Tn * (S*Tr + K - S) * (S * Tc + K - S)
B_weight = Tm * Tn * K**2
B_out = Tm * Tr * Tc

# Compute CTC Ratio
Total_num_operation = 2 * R * C * M * N * K * K
Total_num_external_data = alpha_in * B_in + alpha_weight * B_weight + alpha_out * B_out

CTC_Ratio = Total_num_operation / Total_num_external_data

# Basic Print
print ("Computational Roof = ", Compute_Roof )
print("Computation to Communication Ratio = ", CTC_Ratio)