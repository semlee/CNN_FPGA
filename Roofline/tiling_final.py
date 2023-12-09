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

## finds the unrolling factors Pox, Poy, Pof
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
    
    Nox_sum = sum(Nox)
    Noy_sum = sum(Noy)
    Nof_sum = sum(Nof)
    N_sum = Nox_sum + Noy_sum + Nof_sum
    
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
                    break      
                cycles = 0
                for L in range (len(Nof)):
                    cycles += (Nox[L]/Pox_temp[x])*(Noy[L]/Poy_temp[y])*(Nof[L]/Pof_temp[f])
                if cycles < min_cycles:
                    min_cycles = cycles
                    optimals = [[Pox_temp[x], Poy_temp[y], Pof_temp[f]]]
                elif cycles == min_cycles:
                    optimals.append([Pox_temp[x], Poy_temp[y], Pof_temp[f]])
    min_discrepancy = float('inf')
    Pox = 0
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
    if Pox == 0:
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
        
def tiling(Poy, Pof, pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S):
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
    for L in range (CONVs):
        Toys[L] = sorted(find_possible_tiling(Noy[L], Poy))
        Tofs[L] = sorted(find_possible_tiling(Nof[L], Pof))
        Toy_low[L] = Toys[L][0]
        Toy_high[L] = Noy[L]
        Tof_low[L] = Tofs[L][0]
        Tof_high[L] = Nof[L]
        
    words_px_high = np.array([0]*CONVs)
    words_wt_high = np.array([0]*CONVs)
    words_px_low = np.array([0]*CONVs)
    words_wt_low = np.array([0]*CONVs)
    
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
    print(f'Initial buffer size fully buffering weights for every layer: {bits_BUF_px_wt}\n')
    while True:
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
        if max(words_px_temp) + max(words_wt_temp) < bits_BUF_px_wt:
            # if resulting total buffer size is less than before, keep the switched results
            words_px = np.array(words_px_temp)
            words_wt = np.array(words_wt_temp)
            Toy = np.array(Toy_temp)
            Tof = np.array(Tof_temp)
            switched = np.array(switched_temp)
        else:
            break
    max_words_px = max(words_px)
    max_words_wt = max(words_wt)
    print(f'Optimized buffer size: {max_words_px + max_words_wt}\n')
    Tix = (Tox-1)*S + Nkx
    for L in range (CONVs): 
        # maximize the T variable that is less than N for each layer without requiring extra buffer space
        if switched[L] == 1:
            for i in range(len(Tofs[L])):
                Tiy = (Noy-1)*S + Nky
                if Tix[L] * Tiy[L] * Tif[L] + Tox[L] * Toy[L] * Tofs[L][i] * pixel_datawidth <= max_words_px:
                    if Tofs[L][i] * Tif[L] * Tkx[L] * Tky[L] * weight_datawidth <= max_words_wt:
                        Tof[L] = Tofs[L][i]
                else:
                    break
        else:
            for i in range(len(Toys[L])):
                Tiy = (Toys[L][i]-1)*S + Nky
                if Tix[L] * Tiy[L] * Tif[L] + Tox[L] * Toys[L][i] * Tof[L] * pixel_datawidth<= max_words_px:
                    Toy[L] = Toys[L][i]
                else:
                    break
    print(f'Final Tiling Variables: \nToy - {Toy}\nTof - {Tof}\n')
    return [words_px_high, words_wt_high, max(words_px), max(words_wt), words_px_low, words_wt_low]

def optimize(pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, DSP):
    (Pox, Poy, Pof) = find_unrolling(Nox,Noy,Nof,DSP)
    output = tiling(Poy, Pof, pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S)
    hista(*output)
    
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
pixel_datawidth = 16
weight_datawidth = 16
Nox = np.array([224,224,112,112,56,56,56,28,28,28,14,14,14])
Noy = np.array([224,224,112,112,56,56,56,28,28,28,14,14,14])
Nof = np.array([64,64,128,128,256,256,256,512,512,512,512,512,512])
S = np.array([1,1,1,1,1,1,1,1,1,1,1,1,1])
Nkx = np.array([3,3,3,3,3,3,3,3,3,3,3,3,3])
Nky = np.array([3,3,3,3,3,3,3,3,3,3,3,3,3])
Nif = np.array([3,64,128,128,256,256,256,512,512,512,512,512,512])
DSP = 3200
optimize(pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, DSP)
