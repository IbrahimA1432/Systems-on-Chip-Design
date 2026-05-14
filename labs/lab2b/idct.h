#include "systemc.h"
#include <math.h>

#ifndef IDCT_H
#define IDCT_H

// Inverse DCT hardware module.
// Inputs: 8x8 block of (unquantized) DCT coefficients + cosine table
// Output: 8x8 reconstructed 8-bit pixel block (0..255)
struct idct : sc_module {
    sc_in<double> in64[8][8];
    sc_in<double> icosine[8][8];
    sc_out<unsigned char> out64[8][8];

    sc_in<bool> clk;

    void calculate_idct(void);

    SC_CTOR(idct) {
        SC_METHOD(calculate_idct);
        dont_initialize();
        // Trigger on falling edge (mirrors FDCT structure).
        sensitive << clk.neg();
    }
};

#endif
