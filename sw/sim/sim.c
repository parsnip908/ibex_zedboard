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
  *var = 0x00;
  // usleep(1000 * 1000); // 1000 ms
  *var = 0xFF;
  // usleep(1000 * 1000); // 1000 ms
  *var = 0x00;
  // usleep(1000 * 1000); // 1000 ms

  // uint16_t num = 0xAA;
  asm volatile(
    "nop\n"
  );

  // uint16_t data[4] = {0x4167,0xc169,0x3f10,0x4008};

  // volatile uint16_t *A = (volatile uint16_t *) 0x0000c020;
  // volatile uint16_t *B = (volatile uint16_t *) 0x0000c030;
  // volatile uint16_t *C = (volatile uint16_t *) 0x0000c040;

  // for(int i = 0; i<4; i++)
  // {
  //   A[i] = data[i];
  //   B[i] = data[i];
  //   C[i] = 0;
  // }

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
    // "  li t6, 0xc030\n"
    // "  li a7, 0xc040\n"
    "fori:\n"
    "  li t2, 0\n"
    "forj:\n"
    "  li t3, 0\n"
    "  slli t4, t1, 3\n"
    "  add t4, t4, t2\n"
    "  add t4, a7, t4\n"
    "  flh ft3, 0(t4)\n"
    // "  fsub.h ft0, ft0, ft0\n"
    "fork:\n"
    "  slli t4, t1, 3\n"
    "  add t4, t4, t3\n"
    "  add t4, t5, t4\n"
    "  flh ft1, 0(t4)\n"
    "  slli t4, t3, 3\n"
    "  add t4, t4, t2\n"
    "  add t4, t6, t4\n"
    "  flh ft2, 0(t4)\n"
    "  fmul.h ft1, ft1, ft2\n"
    "  fadd.h ft0, ft0, ft1\n"

    "  addi t3, t3, 2\n"
    "  bne t3, t0, fork\n"

    "  slli t4, t1, 1\n"
    "  add t4, t4, t2\n"
    "  add t4, a7, t4\n"
    "  fsh ft0, 0(t4)\n"
    "  fsub.h ft0, ft0, ft3\n"

    "  addi t2, t2, 2\n"
    "  bne t2, t0, forj\n"

    "  addi t1, t1, 2\n"
    "  bne t1, t0, fori\n"
      // "li t1, 13604\n"
      // "li t2, 24193\n"
      // "li t3, 49184\n"
      // "sh t1, 0(t3)\n"
      // "sh t2, 2(t3)\n"
      // "flh ft1, 0(t3)\n"
      // "flh ft2, 2(t3)\n"
      // "fadd.h ft3, ft2, ft1\n"
      // "fsh ft3, 4(t3)\n"
  );

  *var = 0xFF;
  // usleep(1000 * 1000); // 1000 ms
  *var = 0x00;
  // usleep(1000 * 1000); // 1000 ms


  uint16_t* num_p = (uint16_t *)(0xC024);
  uint16_t num = *num_p;

  //0xA00A;//

  while (1) {

    // usleep(1000 * 1000); // 1000 ms
    *var = num & 0xFF;

    // usleep(1000 * 1000); // 1000 ms
    *var = num >> 8;

    // usleep(1000 * 1000); // 1000 ms
    *var = 0x00;
    // usleep(1000 * 1000); // 1000 ms
    *var = 0xFF;
  }
    usleep(1000 * 1000); // 1000 ms
}
