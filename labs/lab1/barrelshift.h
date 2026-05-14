// COE838 - Lab1
//////////////////////////////////

#ifndef BARRELSHIFT_H
#define BARRELSHIFT_H

#include <systemc.h>

void make_lab1();

SC_MODULE(barrel_shift) {
  sc_in<bool> clk;

  sc_in<bool> enable;            // en: 0 = passthrough, 1 = shift
  sc_in<bool> left_right;        // l_r: 0 = left, 1 = right
  sc_in<sc_uint<5>> shift_amt;   // shift amount 0..31

  sc_in<sc_int<8>> din;         // B input
  sc_out<sc_int<8>> dout;       // shifted B output

  void barrel_method();

  SC_CTOR(barrel_shift) {
    SC_METHOD(barrel_method);
    dont_initialize();
    sensitive << clk.pos();
  }
};

#endif

