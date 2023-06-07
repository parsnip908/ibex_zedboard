// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdint.h>
// #define CLK_FIXED_FREQ_HZ (50ULL * 1000 * 1000)

/**
 * Delay loop executing within 8 cycles on ibex
 */
// static void delay_loop_ibex(unsigned long loops) {
// 	int out; /* only to notify compiler of modifications to |loops| */
// 	asm volatile(
// 		"1: nop             \n" // 1 cycle
// 		"   nop             \n" // 1 cycle
// 		"   nop             \n" // 1 cycle
// 		"   nop             \n" // 1 cycle
// 		"   addi %1, %1, -1 \n" // 1 cycle
// 		"   bnez %1, 1b     \n" // 3 cycles
// 		: "=&r" (out)
// 		: "0" (loops)
// 	);
// }

// static int usleep_ibex(unsigned long usec) {
// 	unsigned long usec_cycles;
// 	usec_cycles = CLK_FIXED_FREQ_HZ * usec / 1000 / 1000 / 8;

// 	delay_loop_ibex(usec_cycles);
// 	return 0;
// }

// static int usleep(unsigned long usec) {
// 	return usleep_ibex(usec);
// }


union intfp {
	uint32_t i;
	float f;
};

#include "Matrix_A.c"
#include "Matrix_B.c"
#include "Matrix_C.c"

#define MSIZE 8

int main(int argc, char **argv)
{
	// Adderess C010 on the "stack" are connected to the LEDs of the board.
	// volatile uint8_t *leds = (volatile uint8_t *) 0x0000c010;
	volatile float* final = (volatile float*) 0x0000c010;

	float result[8][8];
	float diff[8][8];
	float diff_sum = 0;

	for (int i = 0; i < MSIZE; i++)
	{
		for (int j = 0; j < MSIZE; j++)
		{
			result[i][j] = 0;
			for (int k = 0; k < MSIZE; k++)
			{
				result[i][j] += matrixA[i][k].f * matrixB[k][j].f;
			}
			diff[i][j] = result[i][j] - matrixC[i][j].f;
			diff_sum += diff[i][j];
		}
	}

	*final = diff_sum;

	asm volatile(
	    "fcvt.w.s t1, ft1\n"
	);

	return 0;

	// while (1) {
	// }
	// 	usleep(1000 * 1000); // 1000 ms
}
