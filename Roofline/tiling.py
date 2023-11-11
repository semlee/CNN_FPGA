import numpy as np

## inputs obtained from surveying of CNN
pixel_datawidth = 5
weight_datawidth = 5
NifL = np.array([4,4,4])
NoxL = np.array([5,5,5])
NoyL = np.array([4,4,4])
NkxL = np.array([9,9,9])
NkyL = np.array([4,4,4])
NofL = np.array([4,4,4])
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
            Noxltof = NoxL/Tox
            Tile_pxL = np.ceil(NoxL / Tox) * np.ceil(NoyL / Toy)
            Tile_wtL = np.ceil(NofL / Tof)

            condition_satisfied = np.all((Tile_pxL == 1) | (Tile_wtL == 1))

            if condition_satisfied & bits_BUF_px_wt < min_BUF_px_wt:
                min_BUF_px_wt = bits_BUF_px_wt
                opt_Tox = Tox
                opt_Toy = Toy
                opt_Tof = Tof

# display the optimal solution
print(f'Overall optimal solutions: Tox = {opt_Tox}, Toy = {opt_Toy}, Tof = {opt_Tof}.')
