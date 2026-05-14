#ifndef FULL_ADDER_H
#define FULL_ADDER_H

#include <systemc.h>

/*
  1-bit Full Adder (combinational)

  Inputs:
    a, b, cin (single bits)

  Outputs:
    sum  = a xor b xor cin
    cout = 1 when at least two inputs are 1
*/
SC_MODULE(full_adder) {
  sc_in<bool> a, b, cin;
  sc_out<bool> sum, cout;

  void do_add() {
    bool A = a.read();
    bool B = b.read();
    bool C = cin.read();

    sum.write(A ^ B ^ C);
    cout.write((A & B) | (A & C) | (B & C));
  }

  SC_CTOR(full_adder) {
    SC_METHOD(do_add);
    sensitive << a << b << cin;
  }
};

#endif

