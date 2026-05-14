// COE838 - Lab1
//////////////////////////////////
// Testbench driver

#include <systemc.h>
#include "barrelshift.h"
#include "alu.h"

void make_lab1() {
  sc_trace_file *tf;

  sc_signal<sc_int<8>> A_sig, B_sig, B_shifted_sig, Y_sig;
  sc_signal<bool> op_sig, en_sig, lr_sig;
  sc_signal<sc_uint<5>> shamt_sig;

  sc_clock clk("clk", 10, SC_NS, 0.5);

  barrel_shift shifter("barrelshift");
  alu_unit alu("alu");

  shifter.clk(clk);
  shifter.enable(en_sig);
  shifter.left_right(lr_sig);
  shifter.shift_amt(shamt_sig);
  shifter.din(B_sig);
  shifter.dout(B_shifted_sig);

  alu.clk(clk);
  alu.op(op_sig);
  alu.A(A_sig);
  alu.B(B_shifted_sig);
  alu.Y(Y_sig);

  tf = sc_create_vcd_trace_file("trace_file");
  tf->set_time_unit(1, SC_NS);

  sc_trace(tf, clk, "clk");
  sc_trace(tf, A_sig, "A");
  sc_trace(tf, B_sig, "B");
  sc_trace(tf, en_sig, "en");
  sc_trace(tf, lr_sig, "l_r");
  sc_trace(tf, shamt_sig, "shift_amt");
  sc_trace(tf, op_sig, "op");
  sc_trace(tf, B_shifted_sig, "B_shifted");
  sc_trace(tf, Y_sig, "Y");

  cout << "\nExecuting Lab1 ALU + Barrel Shifter... check .vcd produced" << endl;

  // Initialize
  A_sig.write(0);
  B_sig.write(0);
  en_sig.write(0);
  lr_sig.write(0);
  shamt_sig.write(0);
  op_sig.write(1);
  sc_start(20, SC_NS);

  // en=0 passthrough, add: 20 + 3
  A_sig.write(20); B_sig.write(3);
  en_sig.write(0); lr_sig.write(0); shamt_sig.write(0);
  op_sig.write(1);
  sc_start(20, SC_NS);

  // en=0 passthrough, sub: 20 - 3
  op_sig.write(0);
  sc_start(20, SC_NS);

  // en=1 left shift by 1, add: 10 + (5<<1) = 20
  A_sig.write(10); B_sig.write(5);
  en_sig.write(1); lr_sig.write(0); shamt_sig.write(1);
  op_sig.write(1);
  sc_start(20, SC_NS);

  // en=1 left shift by 2, sub: 10 - (5<<2) = -10
  shamt_sig.write(2);
  op_sig.write(0);
  sc_start(20, SC_NS);

  // en=1 right shift by 1, add: 16 + (32>>1) = 32
  A_sig.write(16); B_sig.write(32);
  en_sig.write(1); lr_sig.write(1); shamt_sig.write(1);
  op_sig.write(1);
  sc_start(20, SC_NS);

  // en=1 right shift by 3, sub: 16 - (32>>3) = 12
  shamt_sig.write(3);
  op_sig.write(0);
  sc_start(20, SC_NS);

  sc_close_vcd_trace_file(tf);
}

int sc_main(int argc, char* argv[]) {
  make_lab1();
  return 0;
}

