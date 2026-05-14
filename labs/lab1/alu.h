// COE838 - Lab1
//////////////////////////////////

#ifndef ALU_H
#define ALU_H

#include <systemc.h>

SC_MODULE(alu_unit) {
  sc_in<bool> clk;

  sc_in<bool> op;           // op: 0 = subtract, 1 = add
  sc_in<sc_int<8>> A;
  sc_in<sc_int<8>> B;      // this will be shifted B

  sc_out<sc_int<8>> Y;

  void alu_method();

  SC_CTOR(alu_unit) {
    SC_METHOD(alu_method);
    dont_initialize();
    sensitive << clk.pos();
  }
};

#endif

