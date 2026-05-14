// COE838 - Lab1
//////////////////////////////////
#include "barrelshift.h"

void barrel_shift::barrel_method() {
  sc_int<8> b = din.read();

  if (enable.read() == 0) {
    dout.write(b);  // passthrough when shifting disabled
    return;
  }

  unsigned s = shift_amt.read().to_uint();

  if (left_right.read() == 0) {
    dout.write(b << s);
  } else {
    dout.write(b >> s); // arithmetic right shift for signed sc_int
  }
}

