import numpy as np
import math
import matplotlib.pyplot as plt

def find_factors(number):
    factors = []
    for i in range(2, number + 1):
        if number % i == 0:
            factors.append(i)
    return factors

def find_greatest_common_factor(N):
    current_gcd = N[0]
    for num in N[1:]:
        current_gcd = math.gcd(current_gcd, num)
    return current_gcd

def find_unrolling(Nox,Noy,Nof,DSP):
    Pox = find_greatest_common_factor(Nox)
    Poy = find_greatest_common_factor(Noy)
    Pof = find_greatest_common_factor(Nof)
    values_Pox = (find_factors(Pox))[::-1]
    values_Poy = (find_factors(Poy))[::-1]
    values_Pof = (find_factors(Pof))[::-1]
    Nox_sum = sum(Nox)
    Noy_sum = sum(Noy)
    Nof_sum = sum(Nof)
    N_sum = Nox_sum+Noy_sum+Nof_sum
    index_Pox = 0
    index_Poy = 0
    index_Pof = 0
    if np.array_equal(Nox,Noy):
        equal = 1
    else:
        equal = 0
    
    if Pox*Poy*Pof <= DSP:
        return Pox, Poy, Pof
    else: 
        while Pox*Poy*Pof > DSP:
            P_sum = Pox+Poy+Pof
            discrpancy_Pox = Pox/P_sum - Nox_sum/N_sum
            discrpancy_Poy = Poy/P_sum - Noy_sum/N_sum
            discrpancy_Pof = Pof/P_sum - Nof_sum/N_sum
            if equal == 0:
                if discrpancy_Pox >= discrpancy_Poy and discrpancy_Pox >= discrpancy_Pof and index_Pox < len(values_Pox):
                    index_Pox += 1
                    Pox = values_Pox[index_Pox]
                elif discrpancy_Poy >= discrpancy_Pox and discrpancy_Poy >= discrpancy_Pof and index_Poy < len(values_Poy):
                    index_Poy += 1
                    Poy = values_Poy[index_Poy]
                elif discrpancy_Pof >= discrpancy_Pox and discrpancy_Pof >= discrpancy_Poy and index_Pof < len(values_Pof):
                    index_Pof += 1
                    Pof = values_Pof[index_Pof]
            else:
                if discrpancy_Pox >= discrpancy_Poy and index_Pox < len(values_Pox):
                    index_Pox += 1
                    index_Poy += 1
                    Pox = values_Pox[index_Pox]
                    Poy = values_Pox[index_Poy]
                    if Pox*Poy*Pof < DSP:
                        if index_Pof != 0:
                            if Pox*Poy*values_Pof[index_Pof-1] <= DSP:
                                Pof = values_Pof[index_Pof-1]
                elif discrpancy_Pof >= discrpancy_Pox and index_Pof < len(values_Pof):
                    index_Pof += 1
                    Ps[2] = values_Pof[index_Pof]
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
    num = len(T_temp) - len(Ts)
    ite = 0
    while len(Ts) < 4:
        if ite == len(T_temp):
            break
        ite += 1
        if min(T_temp)!= float('inf'):
            Ts.append(P+P*T_temp.index(min(T_temp)))
            T_temp[T_temp.index(min(T_temp))] = float('inf')
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
    
    Toy = np.array(Toy_low)
    Tof = np.array(Tof_high)
    switched = np.array([0] * CONVs)
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
            if words_wt_temp[L] == words_wt_max:
                words_px_temp[L] = words_px_high[L] 
                Toy_temp[L] = Toy_high[L]
                words_wt_temp[L] = words_wt_low[L]
                Tof_temp[L] = Tof_low[L]
                switched_temp[L] = 1
        if max(words_px_temp) + max(words_wt_temp) < bits_BUF_px_wt:
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
        if switched[L] == 1:
            for i in range(len(Tofs[L])):
                Tiy = (Noy-1)*S + Nky
                if Tix[L] * Tiy[L] * Tif[L] + Tox[L] * Toy[L] * Tofs[L][i] * pixel_datawidth <= max_words_px and Tofs[L][i] * Tif[L] * Tkx[L] * Tky[L] * weight_datawidth <= max_words_wt:
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
    return

def optimize(pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, DSP):
    (Pox, Poy, Pof) = find_unrolling(Nox,Noy,Nof,DSP)
    tiling(Poy, Pof, pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S)

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
