#ifndef CSA_CELL_H
#define CSA_CELL_H

#include <systemc.h>
#include "full_adder.h"

/*
  CSA Cell

  The CSA cell does:
    ab = A_bit AND B_bit
    then full_adder(ab, S_in, C_in) -> So, Co

  Inputs:
    a_bit, b_bit : multiplier bits (A column bit, B row bit)
    sin          : sum-in coming from the cell "above-right" (diagonal)
    cin          : carry-in coming from the cell directly above

  Outputs:
    so : sum-out
    co : carry-out
*/
SC_MODULE(csa_cell) {
  sc_in<bool> a_bit, b_bit;
  sc_in<bool> sin, cin;
  sc_out<bool> so, co;

  sc_signal<bool> ab_sig;   // partial product bit = a_bit & b_bit
  full_adder fa;

  void make_ab() {
    ab_sig.write(a_bit.read() & b_bit.read());
  }

  SC_CTOR(csa_cell) : fa("fa") {
    // Create partial product
    SC_METHOD(make_ab);
    sensitive << a_bit << b_bit;

    // Full adder inside the CSA cell
    fa.a(ab_sig);
    fa.b(sin);
    fa.cin(cin);
    fa.sum(so);
    fa.cout(co);
  }
};

#endif

