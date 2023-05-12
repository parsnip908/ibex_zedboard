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
  usleep(1000 * 1000); // 1000 ms
  *var = 0xFF;
  usleep(1000 * 1000); // 1000 ms
  *var = 0x00;
  // usleep(1000 * 1000); // 1000 ms

  // uint16_t num = 0xAA;

  asm volatile(
      "li t1, 16518\n"
      "li t2, 16605\n"
      "li t3, 49184\n"
      "sh t1, 0(t3)\n"
      "sh t2, 4(t3)\n"
      "flh ft1, 0(t3)\n"
      "flh ft2, 4(t3)\n"
      "fadd.h ft3, ft2, ft1\n"
      "fsh ft3, 8(t3)\n"
      "li t5, 49168\n"
      // "addi a5, a5, 16\n"
      "fsh ft3, 0(t5)\n"
  );

  usleep(1000 * 1000); // 1000 ms
  *var = 0xFF;
  usleep(1000 * 1000); // 1000 ms
  *var = 0x00;


  uint16_t* num_p = (uint16_t *)(0x0000c028);
  uint16_t num = *num_p;

  //0xA00A;//

  while (1) {

    usleep(1000 * 1000); // 1000 ms
    *var = num & 0xFF;

    usleep(1000 * 1000); // 1000 ms
    *var = num >> 8;

    usleep(1000 * 1000); // 1000 ms
    *var = 0xAA;
    usleep(1000 * 1000); // 1000 ms
    *var = 0x55;
  }
}
