#ifndef CPA_CELL_H
#define CPA_CELL_H

#include <systemc.h>
#include "full_adder.h"

/*
  CPA Cell

  Just a plain full adder:
    full_adder(A_in, B_in, C_in) -> So, Co
*/
SC_MODULE(cpa_cell) {
  sc_in<bool> a_in, b_in, cin;
  sc_out<bool> so, co;

  full_adder fa;

  SC_CTOR(cpa_cell) : fa("fa") {
    fa.a(a_in);
    fa.b(b_in);
    fa.cin(cin);
    fa.sum(so);
    fa.cout(co);
  }
};

#endif

