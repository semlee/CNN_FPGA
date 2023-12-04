import numpy as np
import math
import matplotlib.pyplot as plt

def gcd(a, b):
    while b:
        a, b = b, a % b
    return a

def find_greatest_common_factor(N):
    current_gcd = N[0]
    for num in N[1:]:
        current_gcd = gcd(current_gcd, num)
    return current_gcd

def find_unrolling(Nox, Noy, Nof, DSP):
    Pox_step = find_greatest_common_factor(Nox)
    Poy_step = find_greatest_common_factor(Noy)
    Pof_step = find_greatest_common_factor(Nof)
    Pox = Pox_step
    Poy = Poy_step
    Pof = Pof_step
    while True:
        fail_num = 3
        if Pox+Pox_step <= min(Nox) and (Pox+Pox_step)*Poy*Pof <= DSP:
            fail_num -= 1
            Pox = Pox + Pox_step
        if Poy+Poy_step <= min(Noy) and Pox*(Poy+Poy_step)*Pof <= DSP:
            fail_num -= 1
            Poy = Poy + Poy_step
        if Pof+Pof_step <= min(Nof) and Pox*Poy*(Pof+Pof_step) <= DSP:
            fail_num -= 1
            Pof = Pof + Pof_step
        if fail_num == 3:
            break
    return Poy, Pof          

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
    #print(f'\nfinal: {bits_BUF_px_wt}\n')
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
#     print(f'Toy: {Toy}')
#     print(f'Tof: {Tof}')
    max_words_px = max(words_px)
    max_words_wt = max(words_wt)
    Tix = (Tox-1)*S + Nkx
    for L in range (CONVs):
        if switched[L] == 1:
            for i in range(len(Tofs[L])):
                Tiy = (Noy-1)*S + Nky
                if Tix[L] * Tiy[L] * Tif[L] + Tox[L] * Toy[L] * Tofs[L][i] <= max_words_px and Tofs[L][i] * Tif[L] * Tkx[L] * Tky[L] <= max_words_wt:
                    Tof[L] = Tofs[L][i]
                else:
                    break
        else:
            for i in range(len(Toys[L])):
                Tiy = (Toys[L][i]-1)*S + Nky
                if Tix[L] * Tiy[L] * Tif[L] + Tox[L] * Tofs[L][i] * Tof[L] <= max_words_px:
                    Toy[L] = Toys[L][i]
                else:
                    break
    #print(f'\nfinal: {bits_BUF_px_wt}\n')
#     print(f'Toy: {Toy}')
#     print(f'Tof: {Tof}')
    return

def optimize(pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, DSP):
    (Poy, Pof) = find_unrolling(Nox,Noy,Nof,DSP)
    tiling(Poy, Pof, pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S)

pixel_datawidth = 1
weight_datawidth = 1
Nox = np.array([224,224,112,112,56,56,56,28,28,28,14,14,14])
Noy = np.array([224,224,112,112,56,56,56,28,28,28,14,14,14])
Nof = np.array([64,64,128,128,256,256,256,512,512,512,512,512,512])
S = np.array([1,1,1,1,1,1,1,1,1,1,1,1,1])
Nkx = np.array([3,3,3,3,3,3,3,3,3,3,3,3,3])
Nky = np.array([3,3,3,3,3,3,3,3,3,3,3,3,3])
Nif = np.array([3,64,128,128,256,256,256,512,512,512,512,512,512])
DSP = 3000
optimize(pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, DSP)
