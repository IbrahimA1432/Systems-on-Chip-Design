#include "idct.h"

// Round to nearest integer
static inline int rnd_int(double x) {
    if (x >= 0.0) return (int)((int)(x + 1.5) - 1);
    return (int)((int)(x - 1.5) + 1);
}

//inverse discrete cosine transform
void idct::calculate_idct(void) {
    unsigned char x, y, u, v;

    for (x = 0; x < 8; x++) {
        for (y = 0; y < 8; y++) {
            double temp = 0.0;

            for (u = 0; u < 8; u++) {
                for (v = 0; v < 8; v++) {
                    double cu = (u == 0) ? (1.0 / sqrt(2.0)) : 1.0;
                    double cv = (v == 0) ? (1.0 / sqrt(2.0)) : 1.0;

                    temp += cu * cv
                          * in64[u][v].read()
                          * icosine[x][u].read()
                          * icosine[y][v].read();
                }
            }

            temp /= 4.0;

            // Shift back from signed range to unsigned 8-bit range
            int pix = rnd_int(temp) + 128;
            if (pix < 0) pix = 0;
            if (pix > 255) pix = 255;

            out64[x][y].write((unsigned char)pix);
        }
    }

    printf(".");
}
