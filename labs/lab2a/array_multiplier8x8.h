#ifndef ARRAY_MULTIPLIER_8X8_H
#define ARRAY_MULTIPLIER_8X8_H

#include <systemc.h>
#include <sstream>
#include "csa_cell.h"
#include "cpa_cell.h"

/*
  8x8 Unsigned Array Multiplier

    - CSA grid is 8 rows (B0..B7) by 8 cols (A0..A7)
    - Each CSA cell uses:
        cin  from the cell above (same column, previous row)
        sin  from the cell above-right (previous row, next column)
      With edge rules:
        first row: cin=0, sin=0
        last column: sin=0

    - LSB outputs:
        P[i] = sum_out of column 0 in row i
        So P0..P7 come directly from the CSA grid.

    - Final CPA row outputs MSBs:
        It adds bottom-row carry bits and bottom-row shifted sum bits:
          for j=0..7:
            A_in = carry_from_bottom_row[j]
            B_in = bottom_sum[j+1] (or 0 for j=7)
            cin  = previous CPA carry (ripple)
          sum_out becomes P[8+j]
        Final carry-out is ignored (unsigned array multiplier)
*/
SC_MODULE(array_multiplier8x8) {
  sc_in<sc_uint<8>>  A;
  sc_in<sc_uint<8>>  B;
  sc_out<sc_uint<16>> P;

  // Split A and B into single-bit signals for clean module wiring
  sc_signal<bool> A_b[8];
  sc_signal<bool> B_b[8];

  // CSA grid internal wires
  sc_signal<bool> s[8][8];   // sum outputs from each CSA cell
  sc_signal<bool> c[8][8];   // carry outputs from each CSA cell

  // CPA last row wires
  sc_signal<bool> cpa_sum[8];
  sc_signal<bool> cpa_carry[8];

  // Constant 0 signal used for edge conditions
  sc_signal<bool> zero;

  // Module instances
  csa_cell* csa[8][8];
  cpa_cell* cpa[8];

  // Split A and B buses into bits
  void split_inputs() {
    sc_uint<8> a = A.read();
    sc_uint<8> b = B.read();

    for (int j = 0; j < 8; j++) A_b[j].write(a[j]);
    for (int i = 0; i < 8; i++) B_b[i].write(b[i]);
  }

  // Pack P[15:0] from CSA LSBs and CPA MSBs
  void pack_output() {
    sc_uint<16> out = 0;

    // P0..P7 from CSA grid, column 0 down each row
    for (int i = 0; i < 8; i++) {
      out[i] = s[i][0].read();
    }

    // P8..P15 from CPA row sums
    for (int j = 0; j < 8; j++) {
      out[8 + j] = cpa_sum[j].read();
    }

    P.write(out);
  }

  SC_CTOR(array_multiplier8x8) {
    // zero is always false
    zero.write(false);

    // Drive A_b and B_b whenever A or B changes
    SC_METHOD(split_inputs);
    sensitive << A << B;

    // Instantiate and wire the 8x8 CSA grid
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        std::stringstream name;
        name << "csa_" << i << "_" << j;
        csa[i][j] = new csa_cell(name.str().c_str());

        // A and B bits for this cell
        csa[i][j]->a_bit(A_b[j]);
        csa[i][j]->b_bit(B_b[i]);

        // cin: from above, or 0 if first row
        if (i == 0) csa[i][j]->cin(zero);
        else        csa[i][j]->cin(c[i - 1][j]);

        // sin: from above-right, or 0 if first row or last column
        if (i == 0)           csa[i][j]->sin(zero);
        else if (j == 7)      csa[i][j]->sin(zero);
        else                  csa[i][j]->sin(s[i - 1][j + 1]);

        // outputs
        csa[i][j]->so(s[i][j]);
        csa[i][j]->co(c[i][j]);
      }
    }

    // Instantiate and wire the final CPA row (8 CPA cells)
    for (int j = 0; j < 8; j++) {
      std::stringstream name;
      name << "cpa_" << j;
      cpa[j] = new cpa_cell(name.str().c_str());

      // A_in: carry from bottom CSA row, same column
      cpa[j]->a_in(c[7][j]);

      // B_in: bottom CSA sum shifted (sum from next column),
      // last column uses 0
      if (j == 7) cpa[j]->b_in(zero);
      else        cpa[j]->b_in(s[7][j + 1]);

      // cin: ripple from previous CPA carry, first one is 0
      if (j == 0) cpa[j]->cin(zero);
      else        cpa[j]->cin(cpa_carry[j - 1]);

      // outputs
      cpa[j]->so(cpa_sum[j]);
      cpa[j]->co(cpa_carry[j]);
    }

    // Pack output whenever relevant internal signals change
    SC_METHOD(pack_output);

    for (int i = 0; i < 8; i++) {
      sensitive << s[i][0];
    }
    for (int j = 0; j < 8; j++) {
      sensitive << cpa_sum[j];
    }
  }
};

#endif

