## find the minimum number of cycles required to compute one layer after applying the roorline model
def roofline (Nox, Noy, Nif, Nof, Nkx, Nky, S, Tox, Toy, Tif, Tof, bandwidth):
    R = Nox
    C = Noy
    N = Nif
    M = Nof
    K = Nkx
    Tr = Tox
    Tc = Toy
    Tn = Tif
    Tm = Tof
    Nix = Nox
    Niy = Noy
    Tix = Tox
    Tiy = Toy
    output_reuse = 1
    
    Total_num_operation = 2 * R * C * M  * N * K * K
    Num_Exe_cycles = math.ceil(M/Tm) * math.ceil(N/Tn) * R * C * K * K
    Compute_Roof = Total_num_operation / Num_Exe_cycles
    
    
    alpha_in = M/Tm * N/Tn * R/Tr * C/Tc
    alpha_weight = alpha_in
    alpha_out_no_reuse = 2 * alpha_weight # not using data reuse
    alpha_out_reuse = M/Tm * R/Tr * C/Tc

    if output_reuse == 1: 
        alpha_out = alpha_out_reuse 
    else:
        alpha_out = alpha_out_no_reuse 

    B_in = Tn * (S*Tr + K - S) * (S * Tc + K - S)
    B_weight = Tm * Tn * K * K
    B_out = Tm * Tr * Tc

    # Compute CTC Ratio
    Total_num_external_data = alpha_in * B_in + alpha_weight * B_weight + alpha_out * B_out

    CTC_Ratio = Total_num_operation / Total_num_external_data
    
    final_Gflops = min(bandwidth*CTC_Ratio, Compute_Roof)
    num_cycles = Total_num_operation / final_Gflops
    
    return num_cycles

def Tiling(pixel_datawidth, weight_datawidth, NifL, NoxL, NoyL, NkxL, NkyL, NofL, S):
    CONVs = len(NifL); # number of convolution layers

    # Tiling variables that are already set
    TkxL = NkxL
    TkyL = NkyL
    TifL = NifL

    # Initialize the minimum buffer size to a large number
    min_BUF_px_wt = float('inf')
    opt_Tox = 0
    opt_Toy = 0
    opt_Tof = 0

    top_solutions = []

    # Iteratee over possible values of Tox, Toy, and Tof
    for Tox in range (1, max(NoxL)):
        for Toy in range (1, max(NoyL)):
            for Tof in range (1, max(NofL)):
                words_pxL = (Tox * Toy * TifL) + (Tox * Toy * Tof)
                words_wtL = Tof * TifL * TkxL * TkyL
                
                # Calculate buffer sizes for each layer and sum them
                bits_BUF_px = max(words_pxL) * pixel_datawidth
                bits_BUF_wt = max(words_wtL) * weight_datawidth
                bits_BUF_px_wt = bits_BUF_px + bits_BUF_wt

                # Calculate the number of tiles for each layer
                Tile_pxL = np.ceil(NoxL / Tox) * np.ceil(NoyL / Toy)
                Tile_wtL = np.ceil(NofL / Tof)

                condition_satisfied = np.all((Tile_pxL == 1) | (Tile_wtL == 1))

                if condition_satisfied:
                    heapq.heappush(top_solutions, (-bits_BUF_px_wt, Tof, Tox, Toy))
                    if len(top_solutions) > 5:
                        heapq.heappop(top_solutions)
    return top_solutions


# find the top (20) sets of Tox, Toy and Tof that result in minimum buffer size
def Tiling(pixel_datawidth, weight_datawidth, NifL, NoxL, NoyL, NkxL, NkyL, NofL, S):
    CONVs = len(NifL); # number of convolution layers

    # Tiling variables that are already set
    TkxL = NkxL
    TkyL = NkyL
    TifL = NifL

    # Initialize the minimum buffer size to a large number
    min_BUF_px_wt = float('inf')
    opt_Tox = 0
    opt_Toy = 0
    opt_Tof = 0

    top_solutions = []

    # Iteratee over possible values of Tox, Toy, and Tof
    for Tox in range (1, max(NoxL)):
        for Toy in range (1, max(NoyL)):
            for Tof in range (1, max(NofL)):
                words_pxL = (Tox * Toy * TifL) + (Tox * Toy * Tof)
                words_wtL = Tof * TifL * TkxL * TkyL
                
                # Calculate buffer sizes for each layer and sum them
                bits_BUF_px = max(words_pxL) * pixel_datawidth
                bits_BUF_wt = max(words_wtL) * weight_datawidth
                bits_BUF_px_wt = bits_BUF_px + bits_BUF_wt

                # Calculate the number of tiles for each layer
                Tile_pxL = np.ceil(NoxL / Tox) * np.ceil(NoyL / Toy)
                Tile_wtL = np.ceil(NofL / Tof)

                condition_satisfied = np.all((Tile_pxL == 1) | (Tile_wtL == 1))

                if condition_satisfied:
                    heapq.heappush(top_solutions, (-bits_BUF_px_wt, Tof, Tox, Toy))
                    if len(top_solutions) > 20:
                        heapq.heappop(top_solutions)
    return top_solutions


# find the optimal solution given the parameters of the CNN
def find_optimal_solution(pixel_datawidth, weight_datawidth, NifL, NoxL, NoyL, NkxL, NkyL, NofL, S, bandwidth):
    optimal_solutions = Tiling(pixel_datawidth, weight_datawidth, NifL, NoxL, NoyL, NkxL, NkyL, NofL, S)
    optimal_solutions = sorted(optimal_solutions, reverse=True)
    best_solution_index = 0
    best_solution_cycles = float('inf')
    for i in range (len(optimal_solutions)):
        total_cycles = 0
        for j in range (len(NifL)):
            num_cycles = roofline(NoxL[j],NoyL[j], NifL[j], NofL[j], NkxL[j], NkyL[j], S[j], optimal_solutions[i][1],optimal_solutions[i][2], NifL[j], optimal_solutions[i][3], bandwidth)
            total_cycles += num_cycles
        if(total_cycles < best_solution_cycles):
            best_solution_cycles = total_cycles
            best_solution_index = i
    print(f'The optimal solution is Tox:{optimal_solutions[best_solution_index][1]} , Toy: {optimal_solutions[best_solution_index][2]}, Tof: {optimal_solutions[best_solution_index][3]}')
    
    
import numpy as np
import heapq
import math

pixel_datawidth = 5
weight_datawidth = 5
NifL = np.array([8,6,1])
NoxL = np.array([5,6,7])
NoyL = np.array([7,9,11])
NkxL = np.array([12,9,7])
NkyL = np.array([4,4,4])
NofL = np.array([1,8,5])
S = np.array([1,1,1])
bandwidth = 1

find_optimal_solution(pixel_datawidth, weight_datawidth, NifL, NoxL, NoyL, NkxL, NkyL, NofL, S, bandwidth)
