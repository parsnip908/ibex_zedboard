// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdint.h>
#define CLK_FIXED_FREQ_HZ (50ULL * 1000 * 1000)

/**
 * Delay loop executing within 8 cycles on ibex
 */
static void delay_loop_ibex(unsigned long loops) {
  int out; /* only to notify compiler of modifications to |loops| */
  asm volatile(
      "1: nop             \n" // 1 cycle
      "   nop             \n" // 1 cycle
      "   nop             \n" // 1 cycle
      "   nop             \n" // 1 cycle
      "   addi %1, %1, -1 \n" // 1 cycle
      "   bnez %1, 1b     \n" // 3 cycles
      : "=&r" (out)
      : "0" (loops)
  );
}

static int usleep_ibex(unsigned long usec) {
  unsigned long usec_cycles;
  usec_cycles = CLK_FIXED_FREQ_HZ * usec / 1000 / 1000 / 8;

  delay_loop_ibex(usec_cycles);
  return 0;
}

static int usleep(unsigned long usec) {
  return usleep_ibex(usec);
}

int main(int argc, char **argv) {
  // The lowest four bits of the highest byte written to the memory region named
  // "stack" are connected to the LEDs of the board.
  volatile uint8_t *var = (volatile uint8_t *) 0x0000c010;
  // volatile uint8_t *result = (volatile uint8_t *) 0x0000c020;
  *var = 0x00;
  // usleep(1000 * 1000); // 1000 ms
  *var = 0xFF;
  // usleep(1000 * 1000); // 1000 ms
  *var = 0x00;
  // usleep(1000 * 1000); // 1000 ms

  // uint16_t num = 0xAA;
  while (1) {

asm volatile(
    "li t1, 0x40860000\n"
    "li t2, 0x40DD0000\n"
    //move int to fp
    "fmv.w.x ft1, t1\n"
    "fmv.w.x ft2, t2\n"
    //arithmetic
    "fadd.s ft3, ft2, ft1\n"
    "fmul.s ft4, ft2, ft1\n"
    "fmin.s ft5, ft1, ft2\n"
    "fmax.s ft5, ft1, ft2\n"
    "fmin.s ft5, ft2, ft1\n"
    "fmax.s ft5, ft2, ft1\n"
    "fsub.s ft2, ft0, ft2\n"
    //mv fp to int
    "fmv.x.w t1, ft3\n"
    "fmv.x.w t2, ft4\n"
    //comparison
    "flt.s t3, ft1, ft2\n"
    "flt.s t3, ft2, ft1\n"
    "fle.s t3, ft1, ft2\n"
    "fle.s t3, ft2, ft1\n"
    "fle.s t3, ft1, ft1\n"
    "feq.s t3, ft2, ft1\n"
    "feq.s t3, ft1, ft1\n"
    //sign injection
    "fsgnj.s ft5, ft1, ft2\n"
    "fsgnjn.s ft5, ft1, ft2\n"
    "fsgnjx.s ft5, ft2, ft2\n"
    //convert fp to int
    "fcvt.w.s t1, ft1\n"
    "fcvt.wu.s t1, ft1\n"
    "fcvt.w.s t2, ft2\n"
    "fcvt.wu.s t2, ft2\n"
    //convert fp to int
    "li t1, 5458\n"
    "li t2, -23423\n"
    "fcvt.s.w ft1, t1\n"
    "fcvt.s.wu ft1, t1\n"
    "fcvt.s.w ft2, t2\n"
    "fcvt.s.wu ft2, t2\n"
    //reset registers
    "li t1, 0\n"
    "li t2, 0\n"
    "li t3, 0\n"
    "fmv.w.x ft1, x0\n"    
    "fmv.w.x ft2, x0\n"    
    "fmv.w.x ft3, x0\n"    
    "fmv.w.x ft4, x0\n"    
    "fmv.w.x ft5, x0\n"    
    "fmv.w.x ft6, x0\n"    
  );
  usleep(1000 * 1000); // 1000 ms
  // *var = 0xFF;
  // usleep(1000 * 1000); // 1000 ms
  *var = 0x00;

  // uint16_t num_add = *(uint16_t *)(0x0000c024);
  // uint16_t num_mul = *(uint16_t *)(0x0000c026);

  //   usleep(1000 * 1000); // 1000 ms
  //   *var = num_add >> 8;
  //   usleep(1000 * 1000); // 1000 ms
  //   *var = num_add & 0xFF;

    usleep(1000 * 1000); // 1000 ms
    *var = 0xFF;

    // usleep(1000 * 1000); // 1000 ms
    // *var = num_mul >> 8;
    // usleep(1000 * 1000); // 1000 ms
    // *var = num_mul & 0xFF;

    // usleep(1000 * 1000); // 1000 ms
    // *var = 0x00;
  }
}
