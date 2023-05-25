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

#include "Matrix_A.c"
#include "Matrix_B.c"
#include "Matrix_C.c"

int main(int argc, char **argv) {
  // The lowest four bits of the highest byte written to the memory region named
  // "stack" are connected to the LEDs of the board.
  volatile uint8_t *var = (volatile uint8_t *) 0x0000c010;
  // volatile uint8_t *result = (volatile uint8_t *) 0x0000c020;

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

  // FCVT.W.S
  // FCVT.WU.S
  // FCVT.S.W
  // FCVT.S.WU
  // FCLASS.S



  volatile uint16_t **Matricies = (volatile uint16_t **) 0x0000c020;
  Matricies[0] = matrixA;
  Matricies[1] = matrixB;
  Matricies[2] = matrixC;

  asm volatile(
    "  li t0, 16\n"
    "  li t1, 0\n"
    "  li t2, 0\n"
    "  li t3, 0\n"
    "  li t5, 0xc020\n"
    "  lw t6, 4(t5)\n"
    "  lw a7, 8(t5)\n"
    "  lw t5, 0(t5)\n"
    "  addi t6, t6, -2\n"
    "  addi a7, a7, -2\n"
    "  addi t5, t5, -2\n"
    // "  li t6, 0xc030\n"
    // "  li a7, 0xc040\n"
    "fori:\n"
    "  li t2, 0\n"
    "forj:\n"
    "  li t3, 0\n"
    "  slli t4, t1, 3\n"
    "  add t4, t4, t2\n"
    "  add t4, a7, t4\n"
    "  flw ft3, 0(t4)\n"
    // "  fsub.h ft0, ft0, ft0\n"
    "fork:\n"
    "  slli t4, t1, 3\n"
    "  add t4, t4, t3\n"
    "  add t4, t5, t4\n"
    "  flw ft1, 0(t4)\n"
    "  slli t4, t3, 3\n"
    "  add t4, t4, t2\n"
    "  add t4, t6, t4\n"
    "  flw ft2, 0(t4)\n"
    "  fmul.s ft1, ft1, ft2\n"
    "  fadd.s ft0, ft0, ft1\n"

    "  addi t3, t3, 2\n"
    "  bne t3, t0, fork\n"

    "  slli t4, t1, 1\n"
    "  add t4, t4, t2\n"
    "  add t4, a7, t4\n"
    "  fsh ft0, 0(t4)\n"
    "  fsub.s ft0, ft0, ft3\n"
    "  fadd.s ft4, ft0, ft4\n"

    "  addi t2, t2, 2\n"
    "  bne t2, t0, forj\n"

    "  addi t1, t1, 2\n"
    "  bne t1, t0, fori\n"
  );

  *var = 0xFF;
  *var = 0x00;


  uint16_t* num_p = (uint16_t *)(0xC024);
  uint16_t num = *num_p;



    *var = (uint8_t)(num & 0xFF);

    *var = (uint8_t)(num >> 8);

    // *var = 0x00;
    // *var = 0xFF;
  while (1) {
  }
    usleep(1000 * 1000); // 1000 ms
}
