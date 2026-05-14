#include <systemc.h>
#include <iostream>
#include "array_multiplier8x8.h"

/*
  Simple helper that:
   - writes A and B
   - runs a short sim time so signals settle
   - prints and checks against normal C++ multiplication
*/
static void run_test(sc_signal<sc_uint<8>>& A_sig,
                     sc_signal<sc_uint<8>>& B_sig,
                     sc_signal<sc_uint<16>>& P_sig,
                     unsigned int a,
                     unsigned int b)
{
  A_sig.write(a);
  B_sig.write(b);

  // Give combinational logic time to update (delta cycles + a little time)
  sc_start(1, SC_NS);

  unsigned int hw = P_sig.read().to_uint();
  unsigned int sw = (a & 0xFF) * (b & 0xFF);

  std::cout << "A=" << a << " B=" << b
            << "  HW=" << hw
            << "  SW=" << sw
            << (hw == sw ? "  [OK]" : "  [MISMATCH]") << std::endl;
}

int sc_main(int argc, char* argv[]) {
  sc_signal<sc_uint<8>>  A_sig, B_sig;
  sc_signal<sc_uint<16>> P_sig;

  // DUT
  array_multiplier8x8 dut("array_multiplier8x8");
  dut.A(A_sig);
  dut.B(B_sig);
  dut.P(P_sig);

  // Trace
  sc_trace_file* tf = sc_create_vcd_trace_file("lab2_mult_trace");
  tf->set_time_unit(1, SC_NS);

  sc_trace(tf, A_sig, "A");
  sc_trace(tf, B_sig, "B");
  sc_trace(tf, P_sig, "P");

  std::cout << "\nRunning 8x8 Array Multiplier tests...\n" << std::endl;

  // Corner cases + normal cases
  run_test(A_sig, B_sig, P_sig, 0, 0);
  run_test(A_sig, B_sig, P_sig, 0, 255);
  run_test(A_sig, B_sig, P_sig, 255, 0);
  run_test(A_sig, B_sig, P_sig, 255, 255);

  run_test(A_sig, B_sig, P_sig, 1, 1);
  run_test(A_sig, B_sig, P_sig, 2, 3);
  run_test(A_sig, B_sig, P_sig, 7, 9);
  run_test(A_sig, B_sig, P_sig, 13, 37);
  run_test(A_sig, B_sig, P_sig, 99, 17);
  run_test(A_sig, B_sig, P_sig, 128, 2);
  run_test(A_sig, B_sig, P_sig, 64, 4);
  run_test(A_sig, B_sig, P_sig, 200, 123);

  sc_close_vcd_trace_file(tf);
  return 0;
}

