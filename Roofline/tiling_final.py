import numpy as np
import math
import matplotlib.pyplot as plt


## finds all factors of a nubmer other than 1, from largest to smallest
def find_factors(number):
    factors = []
    for i in range(2, number + 1):
        if number % i == 0:
            factors.append(i)
    return factors[::-1]

## finds the greatest common factor among the nubmbers in list N
def find_greatest_common_factor(N):
    current_gcd = N[0]
    for num in N[1:]:
        current_gcd = math.gcd(current_gcd, num)
    return current_gcd

## finds the possible unrolling factors Pox, Poy, Pof that minimize latecy (intra_tiling_cycles x inter_tiling_cycles)
def find_unrolling(Nox,Noy,Nof,DSP):
    Pox = find_greatest_common_factor(Nox)
    Poy = find_greatest_common_factor(Noy)
    Pof = find_greatest_common_factor(Nof)
    values_Pox = (find_factors(Pox))
    values_Poy = (find_factors(Poy))
    values_Pof = (find_factors(Pof))  
    Pox_temp = np.array(values_Pox)
    Poy_temp = np.array(values_Poy)
    Pof_temp = np.array(values_Pof)
    print(Pox_temp[-1])

    if np.array_equal(Nox,Noy):
        equal = 1
    else:
        equal = 0
    
    min_cycles = float('inf')
    optimals = []
    for x in range (len(Pox_temp)):
        for y in range (len(Poy_temp)):
            for f in range (len(Pof_temp)):
                if Pox_temp[x] * Poy_temp[y] * Pof_temp[f] > DSP:
                    continue      
                cycles = 0
                for L in range (len(Nof)):
                    cycles += (Nox[L]/Pox_temp[x])*(Noy[L]/Poy_temp[y])*(Nof[L]/Pof_temp[f])
                if cycles < min_cycles:
                    min_cycles = cycles
                    optimals = [[Pox_temp[x], Poy_temp[y], Pof_temp[f]]]
                elif cycles == min_cycles:
                    optimals.append([Pox_temp[x], Poy_temp[y], Pof_temp[f]]) 
    if len(optimals) == 0:
        return [0,Pox_temp[-1]*Poy_temp[-1]*Pof_temp[-1]]
    return optimals

## Finds the best unrolling factors among a set which best minimizes the difference between P*/Psum and N*/Nsum.
## In other words, larger P* should be larger relative to other P when N* is larger relative to other N if possible
def find_best_unrolling(Nox, Noy, Nof, optimals):
    Nox_sum = sum(Nox)
    Noy_sum = sum(Noy)
    Nof_sum = sum(Nof)
    N_sum = Nox_sum + Noy_sum + Nof_sum
    
    min_discrepancy = float('inf')
    if np.array_equal(Nox,Noy):
        equal = 1
    else:
        equal = 0
    success = 0
    
    for i in range (len(optimals)):
        if equal == 1:
            if optimals[i][0] != optimals[i][1]:
                continue
        P_sum = sum(optimals[i])
        discrpancy_Pox = optimals[i][0]/P_sum - Nox_sum/N_sum
        discrpancy_Poy = optimals[i][1]/P_sum - Noy_sum/N_sum
        discrpancy_Pof = optimals[i][2]/P_sum - Nof_sum/N_sum
        overall_dis = max(discrpancy_Pox, discrpancy_Poy, discrpancy_Pof)
        if overall_dis < min_discrepancy:
            Pox = optimals[i][0]
            Poy = optimals[i][1]
            Pof = optimals[i][2]
            min_discrepancy = overall_dis
            success = 1
            
    if success == 0:
        for i in range (len(optimals)):
            P_sum = sum(optimals[i])
            discrpancy_Pox = optimals[i][0]/P_sum - Nox_sum/N_sum
            discrpancy_Poy = optimals[i][1]/P_sum - Noy_sum/N_sum
            discrpancy_Pof = optimals[i][2]/P_sum - Nof_sum/N_sum
            overall_dis = max(discrpancy_Pox, discrpancy_Poy, discrpancy_Pof)
            if overall_dis < min_discrepancy:
                Pox = optimals[i][0]
                Poy = optimals[i][1]
                Pof = optimals[i][2]
                min_discrepancy = overall_dis           
    return Pox, Poy, Pof

## Finds the possible tiling variables where N*/T* and T*/P* are both integers
def find_possible_tiling(N, P):
    T_temp = []
    Ts = []
    T = P
    
    while T <= N:
        if N%T == 0:
            Ts.append(T)
            T_temp.append(float('inf'))
        else:
            T_temp.append(math.ceil(N/T)-N/T)
        if T+P > N:
            break
        T += P
    return np.array(Ts)
        
## When the on-board BRAM is large enough to support Tox = Nox
## Finds the tiling variable that minimizes the buffer size while minimizing DRAM accesses
def tiling(Pox, Poy, Pof, pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, fpga_buffer_size, histogram):
    Tkx = Nkx
    Tky = Nky
    Tif = Nif
    Tox = Nox
    Tix = (Tox-1)*S + Nkx
    CONVs = len(Nif)
    Toys = [0]*CONVs
    Tofs = [0]*CONVs
    Toy_high = np.array([0]*CONVs)
    Tof_high = np.array([0]*CONVs)
    Toy_low = np.array([0]*CONVs)
    Tof_low = np.array([0]*CONVs)
    words_px_high = np.array([0]*CONVs)
    words_wt_high = np.array([0]*CONVs)
    words_px_low = np.array([0]*CONVs)
    words_wt_low = np.array([0]*CONVs)
    
    for L in range (CONVs):
        Toys[L] = sorted(find_possible_tiling(Noy[L], Poy))
        Tofs[L] = sorted(find_possible_tiling(Nof[L], Pof))
        Toy_low[L] = Toys[L][0]
        Toy_high[L] = Noy[L]
        Tof_low[L] = Tofs[L][0]
        Tof_high[L] = Nof[L]
    
    Tiy = (Toy_high-1)*S + Nky
    words_px_high = Tix * Tiy * Tif + Tox * Toy_high * Tof_low * pixel_datawidth
    words_wt_low = Tof_low * Tif * Tkx * Tky * weight_datawidth
    
    Tiy = (Toy_low-1)*S + Nky
    words_px_low = Tix * Tiy * Tif + Tox * Toy_low * Tof_high * pixel_datawidth
    words_wt_high = Tof_high * Tif * Tkx * Tky * weight_datawidth

    words_px = np.array(words_px_low)
    words_wt = np.array(words_wt_high)
    
    Toy = np.array(Toy_low) # Assume that pixels are buffered as little as possible (minimal Toy)
    Tof = np.array(Tof_high) # Assume that all weights are buffered (Tof = Nof)
    switched = np.array([0] * CONVs) # Keep track of layers where Pixels, instead of weights, should be buffered
    switched_temp = np.array([0] * CONVs)
    bits_BUF_px_wt = max(words_px_low) + max(words_wt_high)
    initial_buffer_size = bits_BUF_px_wt
    
    for Layer in range (0,CONVs):
        Toy_temp = np.array(Toy)
        Tof_temp = np.array(Tof)
        words_px_temp = np.array(words_px)
        words_wt_temp = np.array(words_wt)
        words_px_max = max(words_px_temp)
        words_wt_max = max(words_wt_temp)
        bits_BUF_px_wt = words_px_max + words_wt_max
        for L in range(CONVs): 
            # find all layers contributing to current max(words_wt), make them fully buffer pixels instead
            if words_wt_temp[L] == words_wt_max:
                words_px_temp[L] = words_px_high[L] 
                Toy_temp[L] = Toy_high[L]
                words_wt_temp[L] = words_wt_low[L]
                Tof_temp[L] = Tof_low[L]
                switched_temp[L] = 1
        if max(words_px_temp) + max(words_wt_temp) <= bits_BUF_px_wt:
            # if resulting total buffer size is less than before, keep the switched results
            words_px = np.array(words_px_temp)
            words_wt = np.array(words_wt_temp)
            Toy = np.array(Toy_temp)
            Tof = np.array(Tof_temp)
            switched = np.array(switched_temp)
        else:
            break
            
    if histogram == 1:
        hista(words_px_high, words_wt_high, max(words_px), max(words_wt), words_px_low, words_wt_low)
    return Tox, Toy, Tof, bits_BUF_px_wt, initial_buffer_size

## When the on-board BRAM is not large enough to support Tox = Nox
## Finds the tiling variable that minimizes the buffer size while minimizing DRAM accesses
def tiling_subop(Pox, Poy, Pof, pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, fpga_buffer_size, histogram):
    Tkx = Nkx
    Tky = Nky
    Tif = Nif
    CONVs = len(Nif)
    Toxs = [0]*CONVs
    Toys = [0]*CONVs
    Tofs = [0]*CONVs
    Tox_high = np.array([0]*CONVs)
    Toy_high = np.array([0]*CONVs)
    Tof_high = np.array([0]*CONVs)
    Tox_low = np.array([0]*CONVs)
    Toy_low = np.array([0]*CONVs)
    Tof_low = np.array([0]*CONVs)
    words_px_high = np.array([0]*CONVs)
    words_wt_high = np.array([0]*CONVs)
    words_px_low = np.array([0]*CONVs)
    words_wt_low = np.array([0]*CONVs)
    
    for L in range (CONVs):
        Toxs[L] = sorted(find_possible_tiling(Nox[L], Pox))
        Toys[L] = sorted(find_possible_tiling(Noy[L], Poy))
        Tofs[L] = sorted(find_possible_tiling(Nof[L], Pof))
        Tox_low[L] = Toxs[L][0]
        Toy_low[L] = Toys[L][0]
        Tof_low[L] = Tofs[L][0]
        Tox_high[L] = Nox[L]
        Toy_high[L] = Noy[L]
        Tof_high[L] = Nof[L]
    
    Tix = (Tox_high-1)*S + Nkx
    Tiy = (Toy_high-1)*S + Nky
    words_px_high = Tix * Tiy * Tif + Tox_high * Toy_high * Tof_low * pixel_datawidth
    words_wt_low = Tof_low * Tif * Tkx * Tky * weight_datawidth
    
    Tix = (Tox_low-1)*S + Nkx
    Tiy = (Toy_low-1)*S + Nky
    words_px_low = Tix * Tiy * Tif + Tox_low * Toy_low * Tof_high * pixel_datawidth
    words_wt_high = Tof_high * Tif * Tkx * Tky * weight_datawidth

    words_px = np.array(words_px_low)
    words_wt = np.array(words_wt_high)
    
    Tox = np.array(Tox_low) # Assume that pixels are buffered as little as possible (minimal Tox, Toy)
    Toy = np.array(Toy_low)
    Tof = np.array(Tof_high) # Assume that all weights are buffered (Tof = Nof)
    switched = np.array([0] * CONVs) # Keep track of layers where Pixels, instead of weights, should be buffered
    switched_temp = np.array([0] * CONVs)
    bits_BUF_px_wt = max(words_px_low) + max(words_wt_high)
    initial_buffer_size = bits_BUF_px_wt
    
    for Layer in range (0,CONVs):
        Tox_temp = np.array(Tox)
        Toy_temp = np.array(Toy)
        Tof_temp = np.array(Tof)
        words_px_temp = np.array(words_px)
        words_wt_temp = np.array(words_wt)
        words_px_max = max(words_px_temp)
        words_wt_max = max(words_wt_temp)
        bits_BUF_px_wt = words_px_max + words_wt_max
        for L in range(CONVs): 
            # find all layers contributing to current max(words_wt), make them fully buffer pixels instead
            if words_wt_temp[L] == words_wt_max:
                words_px_temp[L] = words_px_high[L] 
                Tox_temp[L] = Tox_high[L]
                Toy_temp[L] = Toy_high[L]
                words_wt_temp[L] = words_wt_low[L]
                Tof_temp[L] = Tof_low[L]
                switched_temp[L] = 1
        if max(words_px_temp) + max(words_wt_temp) <= bits_BUF_px_wt:
            # if resulting total buffer size is less than before, keep the switched results
            words_px = np.array(words_px_temp)
            words_wt = np.array(words_wt_temp)
            Tox = np.array(Tox_temp)
            Toy = np.array(Toy_temp)
            Tof = np.array(Tof_temp)
            switched = np.array(switched_temp)
        else:
            break
            
    if histogram == 1:
        hista(words_px_high, words_wt_high, max(words_px), max(words_wt), words_px_low, words_wt_low)
    return Tox, Toy, Tof, bits_BUF_px_wt, initial_buffer_size
    
## Produces the final output of the optimized design space search
def optimize(pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, DSP, fpga_buffer_size):
    optimals_tmp = find_unrolling(Nox,Noy,Nof,DSP) # finds all possible sets of unrolling variables that minimize latency
    if optimals_tmp[0] == 0:
        print(f'An FPGA board with at least {optimals_tmp[1]} DSP units is required.')
        return
    optimals = [] # used to store filtered unrolling variables
    unrolling_id = 0 # index of unrolling variable currently under evaluation
    ox_full = 1 # 1 if Tox = Nox, 0 otherwise
    min_buffer = float('inf')
    for unrolling_id in range (len(optimals_tmp)): # search design space for each set of unrolling variable with Tox = Nox
        output = tiling(optimals_tmp[unrolling_id][0], optimals_tmp[unrolling_id][1], optimals_tmp[unrolling_id][2], pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, fpga_buffer_size, 0)
        if output[3] <= fpga_buffer_size: # keeps the sets of unrolling variables that result in a smaller buffer size than the available BRAM
            Tiling = [output[0],output[1],output[2]]
            optimals.append(optimals_tmp[unrolling_id])
        if output[3] < min_buffer: # finds the minimum BRAM size required
            min_buffer = output[3]
        unrolling_id += 1 # move on to the next set of unrolling variables
    if len(optimals) == 0: # if not able to find design variables that result in a smaller buffer than the available BRAM with Tox = Nox
        ox_full = 0
        for unrolling_id in range (len(optimals_tmp)): # search design space for each set of unrolling variable with Tox = Nox
            output = tiling_subop(optimals_tmp[unrolling_id][0], optimals_tmp[unrolling_id][1], optimals_tmp[unrolling_id][2], pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, fpga_buffer_size, 0)
            if output[3] <= fpga_buffer_size: # keeps the sets of unrolling variables that result in a smaller buffer size than the available BRAM
                Tiling = [output[0],output[1],output[2]]
                optimals.append(optimals_tmp[unrolling_id])
            if output[3] < min_buffer: # finds the minimum BRAM size required
                min_buffer = output[3]
            unrolling_id += 1 # move on to the next set of unrolling variables
    if len(optimals) == 0: # if not able to find design variables that result in a smaller buffer than the available BRAM
        print(f'An FPGA board with at least {min_buffer/(1000000)} Mbit BRAM is required')
        return
    else:
        (Pox, Poy, Pof) = find_best_unrolling(Nox, Noy, Nof, optimals) # find the set of unrolling variable where Pox:Poy:Pof is as similar to Nox:Noy:Nof as possible
        if ox_full == 1: # Retrieves tililng variables for this set of unrolling variables if Tox = Nox
            (Tox, Toy, Tof, buffer_size, initial_buffer_size) = tiling(Pox, Poy, Pof, pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, fpga_buffer_size, 1)
        else: # Retrieves tililng variables for this set of unrolling variables if Tox < Nox
            (Tox, Toy, Tof, buffer_size, initial_buffer_size) = tiling_subop(Pox, Poy, Pof, pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, fpga_buffer_size, 1)
        print(f'Pox: {Pox}\nPoy: {Poy}\nPof: {Pof}')
        print(f'Tox: {Tox}\nToy: {Toy}\nTof: {Tof}\nInitial Buffer Size: {initial_buffer_size}\nFinal Buffer Size: {buffer_size}')
        
def hista(words_px,words_wt, max_px, max_wt, words_px_low, words_wt_low):
    indices = np.arange(len(words_px))
    plt.figure(figsize=(12, 8))
    plt.bar(indices - 0.3, words_px, width=0.2, label='all input pixel bits', color='red')
    plt.bar(indices - 0.1, words_px_low, width=0.2, label='pixel buffer lower bound', color='pink')
    plt.bar(indices + 0.1, words_wt, width=0.2, label='all weight bits', color='blue')
    plt.bar(indices + 0.3, words_wt_low, width=0.2, label='weight buffer lower bound', color='dodgerblue')
    plt.title('Bar Chart Comparing Two Lists')
    plt.xticks(indices, [f"Layer{i+1}" for i in range(len(words_px))])
    plt.legend()
    plt.axhline(y=max_px, color='r', linestyle='--')
    plt.axhline(y=max_wt, color='b', linestyle='--')
    plt.show()

## Inputs
fpga_buffer_size = 5000000
pixel_datawidth = 16
weight_datawidth = 16
Nox = np.array([224,224,112,112,56,56,56,28,28,28,14,14,14])
Noy = np.array([224,224,112,112,56,56,56,28,28,28,14,14,14])
Nof = np.array([64,64,128,128,256,256,256,512,512,512,512,512,512])
S = np.array([1,1,1,1,1,1,1,1,1,1,1,1,1])
Nkx = np.array([3,3,3,3,3,3,3,3,3,3,3,3,3])
Nky = np.array([3,3,3,3,3,3,3,3,3,3,3,3,3])
Nif = np.array([3,64,128,128,256,256,256,512,512,512,512,512,512])
DSP = 5
optimize(pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, DSP, fpga_buffer_size)
