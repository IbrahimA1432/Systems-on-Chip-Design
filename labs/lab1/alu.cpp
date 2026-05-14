// COE838 - Lab1
//////////////////////////////////
#include "alu.h"

void alu_unit::alu_method() {
  sc_int<8> a = A.read();
  sc_int<8> b = B.read();

  if (op.read() == 1) Y.write(a + b);
  else               Y.write(a - b);
}

