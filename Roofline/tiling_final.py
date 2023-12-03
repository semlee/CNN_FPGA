import numpy as np
import math

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
    CONVs = len(Nif)
    Toys = [0]*CONVs
    Tofs = [0]*CONVs
    Toy_interm = np.array([0]*CONVs)
    Tof_interm = np.array([0]*CONVs)
    for L in range (CONVs):
        Toys[L] = sorted(find_possible_tiling(Noy[L], Poy)) #y
        Tofs[L] = sorted(find_possible_tiling(Nof[L], Pof)) #f
        Toy_interm[L] = Toys[L][0] # assume smallest Noy buffer 
        Tof_interm[L] = Nof[L] #assume choose fully buffer Nof 
    words_px = [0]*CONVs
    words_wt = [0]*CONVs
    for L in range (CONVs):
        Tix = (Tox[L]-1)*S + Nkx
        Tiy = (Toy_interm-1)*S + Nky
        words_px[L] = Tix[L] * Tiy[L] * Tif[L] + Tox[L] * Toy_interm[L] * Tof_interm[L]
        words_wt[L] = Nof[L] * Tif[L] * Tkx[L] * Tky[L]
    bits_BUF_px_wt = max(words_px)*pixel_datawidth + max(words_wt) * weight_datawidth
    print(f'\ninitial: {bits_BUF_px_wt}\n')
    switched = [0] * CONVs
    Tix = (Tox-1)*S + Nkx
    Tiy = (Noy-1)*S + Nky
    while True:   
        temp_words_px = words_px
        temp_words_wt = words_wt
        switch_index = temp_words_wt.index(max(temp_words_wt))
        temp_words_px[switch_index] = Tix[switch_index] * Tiy[switch_index] * Tif[switch_index] + Tox[switch_index] * Noy[switch_index] * Tofs[switch_index][0]
        temp_words_wt[switch_index] = Tofs[switch_index][0] * Tif[switch_index] * Tkx[switch_index] * Tky[switch_index]
        if max(temp_words_px)*pixel_datawidth + max(temp_words_wt) * weight_datawidth < bits_BUF_px_wt:
            words_px = temp_words_px
            words_wt = temp_words_wt
            Toy_interm[switch_index] = Noy[switch_index]
            Tof_interm[switch_index] = Tofs[switch_index][0]
            switched[switch_index] = 1
            bits_BUF_px_wt = max(temp_words_px)*pixel_datawidth + max(temp_words_wt) * weight_datawidth
            print('SWITCHING')
            print(switched)
        else:
            break
            
    max_words_px = max(words_px)
    #print(f'max_words_px: {max_words_px}')
    max_words_wt = max(words_wt)
    Tix = (Tox-1)*S + Nkx
    for L in range (CONVs):
        if switched[L] == 1:
            for i in range(len(Tofs[L])):
                Tiy = (Noy-1)*S + Nky
                if Tix[L] * Tiy[L] * Tif[L] + Tox[L] * Toy_interm[L] * Tofs[L][i] <= max_words_px and Tofs[L][i] * Tif[L] * Tkx[L] * Tky[L] <= max_words_wt:
                    Tof_interm[L] = Tofs[L][i]
                    #print(f'working 1 {L}')
                else:
                    break
        else:
            for i in range(len(Toys[L])):
                Tiy = (Toys[L][i]-1)*S + Nky
                #print(f'words_px = {Tix[L] * Tiy[L] * Tif[L] + Tox[L] * Tofs[L][i] * Tof_interm[L]} {L}')
                if Tix[L] * Tiy[L] * Tif[L] + Tox[L] * Tofs[L][i] * Tof_interm[L] <= max_words_px:
                    Toy_interm[L] = Toys[L][i]
                    #print(f'working 2 {L}')
                else:
                    break
    print(f'\nfinal: {bits_BUF_px_wt}\n')
    print(f'Toy: {Toy_interm}')
    print(f'Tof: {Tof_interm}')
    return

def optimize(pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, DSP):
    (Poy, Pof) = find_unrolling(Nox,Noy,Nof,DSP)
    tiling(Poy, Pof, pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S)

pixel_datawidth = 1
weight_datawidth = 1
Nox = np.array([64,32,16,8,4])
Noy = np.array([64,32,16,8,4])
Nof = np.array([40,80,160,320,640])
S = np.array([1,1,1,1,1])
DSP = 2000
Nkx = np.array([3,4,5,6,7])
Nky = np.array([3,4,5,6,7])
Nif = np.array([8,8,8,8,8])
optimize(pixel_datawidth, weight_datawidth, Nif, Nox, Noy, Nkx, Nky, Nof, S, DSP)
