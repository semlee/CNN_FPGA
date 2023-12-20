#ifndef _CONV_H
#define _CONV_H

// Includes
#include <iostream>
#include <ap_int.h>
#include "hls_vector.h"

const uint8_t Nof = 32;
const uint8_t Noy = 3;
const uint8_t Nox = 3;
const uint8_t Nif = 2;
const uint8_t Nky = 3;
const uint8_t Nkx = 3;
const uint8_t S = 1;
const uint8_t Pof = 8;
const uint8_t Poy = 3;
const uint8_t Pox = 3;

const int size = 128;
const int loopSize = 36; // Nif * Nkx * Nky
typedef hls::vector<float, 8> float8;

extern "C" {
void conv (const float8* input, const float8* filter, float8* output);
}

#endif