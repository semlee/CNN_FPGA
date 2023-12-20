
#include "conv.hpp"


// template <int N, typename T> void load ( T (&out)[N], const T* in) {
// #pragma HLS INLINE off
//     for (int i = 0; i < N; ++i) {
// #pragma HLS pipeline
//         out[i] = in[i];
//     }
// }

// template <int N, typename T> void store (T* out, const T (&in)[N]) {
// #pragma HLS INLINE off
//     for (int i = 0; i < N; ++i) {
// #pragma HLS pipeline
//         out[i] = in[i];
//     }
// }

static void read_input(const float8* in, float8* input_buf, const int vSize) {
// Auto-pipeline is going to apply pipeline to this loop
mem_rd:
    for (int i = 0; i < vSize; i++) {
        // Blocking write command to inStream
        input_buf[i] = in[i];
    }
}

static void write_result(float8* out, float8 output_buf) {
// Auto-pipeline is going to apply pipeline to this loop
mem_wr:
    out[0] = output_buf;
}

// Read Input data from inStream and write the result into outStream
// static void compute_conv(const float32* input,
//                         const float32* filter,
//                         float32* output, 
//                         int Nof, int Noy, int Nox, int Nif, int Nky, int Nkx, int S) {

void compute_conv (float8 output, float8* input, float8* filter, uint8_t Nof, uint8_t Noy, uint8_t Nox, uint8_t Nif, uint8_t Nky, uint8_t Nkx, uint8_t S) {
    uint8_t ni, ky, kx;
// Auto-pipeline is going to apply pipeline to this loop
#pragma HLS INLINE off
    for (ni = 0; ni < Nif; ni++) {
#pragma HLS pipeline
        for (ky = 0; ky < Nky; ky++) {
#pragma HLS pipeline
            for (kx = 0; kx < Nkx; kx++) {
#pragma HLS pipeline
                // Pox * Poy * Pof
                int inputIndex =    ni * (S*Nox + Nkx) * (S*Noy + Nky) +
                                    kx * (S*Noy + Nky) +
                                    ky ;
                int filterIndex =   ni * Nof * Nkx * Nky +
                                    kx  * Nky +
                                    ky;
                output += input[inputIndex] * filter[filterIndex];
            }
        }
    }
}

/*
    Vector Addition Kernel Implementation using dataflow
    Arguments:
        input   (input)  --> Input Vector 1
        filter   (input)  --> Input Vector 2
        output  (output) --> Output Vector
        Nof, Noy, Nox, Nif, Nky, Nkx, S--> Size of Vector in Integer
        Pof, Poy, Pox --> Unroll size
*/
void conv (const float8* input, const float8* filter, float8* output) {
#pragma HLS INTERFACE m_axi port = input offset = slave bundle = gmem0 depth = 288
#pragma HLS INTERFACE m_axi port = filter offset = slave bundle = gmem1 depth = 288
#pragma HLS INTERFACE m_axi port = output offset = slave bundle = gmem2 depth = 288

    volatile uint8_t no, y, x, index;
    volatile int inputIndex, filterIndex, outputIndex;

#pragma HLS DATAFLOW
	for (no = 0; no < Nof; no+= Pof) {
// #pragma HLS UNROLL factor=Pof
		for (y = 0; y < Noy; y++) {
#pragma HLS UNROLL factor=Poy
			for (x = 0; x < Nox; x++) {
// #pragma HLS UNROLL factor=Pox
                inputIndex = S * x * (S*Noy + Nky) + S * y;
                filterIndex = no  * Nkx * Nky;
                outputIndex = no * Nox * Noy + x * Noy + y;
                float8 input_buf[loopSize];
                float8 filter_buf[loopSize];
                float8 output_buf;
            // dataflow pragma instruct compiler to run following three APIs in parallel
                read_input(&input[inputIndex], input_buf, loopSize);
                read_input(&filter[filterIndex], filter_buf, loopSize);
                compute_conv(output_buf, input_buf, filter_buf, Nof, Noy, Nox, Nif, Nky, Nkx, S);
                write_result(&output[outputIndex], output_buf);
            }
        }
    }
}

/*

	for (no = 0; no < Nof; no++) {
#pragma HLS UNROLL factor=Pof
		for (y = 0; y < Noy; y++) {
#pragma HLS UNROLL factor=Poy
			for (x = 0; x < Nox; x++) {
#pragma HLS UNROLL factor=Pox

                // read_input(&input[inputIndex], input_buf, in_loopSize);
                // read_input(&filter[filterIndex], filter_buf, in_loopSize);
                // write_result(&output[outputIndex], output_buf, in_loopSize);


                

*/