#ifndef MNIST_TESTER
#define MNIST_TESTER

#include <stdint.h>
// #include <stdlib.h>
#include <stdio.h>
#include "include/neural_network.h"
#include "trained_net.c"
#include "gen_test_set.c"

// Convert a pixel value from 0-255 to one from 0 to 1
// #define PIXEL_SCALE(x) (((float) (x)) / 256.0f)

volatile int* final = (volatile int*) 0x00038010;
volatile char* OLED_base = (volatile char*) 0x00038000;

uint32_t nums_int[8] = {0x40dd0000, 0x40860000, 0x41580000, 0x40d0000, 
                        0x42ff0000, 0x3e000000};
float* nums = (float*) nums_int;


#define CLK_FIXED_FREQ_HZ (50ULL * 1000 * 1000)

char output[68] = "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
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

/**
 * Use the weights and bias vector to forward propogate through the neural
 * network and calculate the activations.
 */
void neural_network_hypothesis(mnist_image_t * image, neural_network_t * network, float activations[MNIST_LABELS])
{
    int i, j;

    for (i = 0; i < MNIST_LABELS; i++) 
        activations[i] = network->b[i];

    for (j = 0; j < MNIST_IMAGE_SIZE; j++) 
    {
        // asm volatile("nop\n");
        float pixel = ((float) image->pixels[j]) / 256.0f;
        for (i = 0; i < MNIST_LABELS; i++) 
            activations[i] += network->W[i][j] * pixel;
    }
}


/**
 * Calculate the accuracy of the predictions of a neural network on a dataset.
 */
int calculate_accuracy(mnist_dataset_t * dataset, neural_network_t * network)
{
    float activations[MNIST_LABELS], max_activation;
    unsigned int i, j, correct;
    unsigned int predict = -1;

    // Loop through the dataset
    for (i = 0, correct = 0; i < dataset->size; i++) {
        // Calculate the activations for each image using the neural network
        neural_network_hypothesis(&dataset->images[i], network, activations);

        // Set predict to the index of the greatest activation
        for (j = 1, predict = 0, max_activation = activations[0]; j < MNIST_LABELS; j++) 
        {
            if (max_activation == activations[j]) 
                asm volatile("addi t5, t5, 1\n");
            if (max_activation < activations[j]) 
            {
                max_activation = activations[j];
                predict = j;
            }
        }

        // Increment the correct count if we predicted the right label
        if (predict == dataset->labels[i]) 
            correct++;
        else
        {
            *final = (predict << 16) + (dataset->labels[i] << 8) + i;
            asm volatile(
                "li t6, 0x38010\n"
                "lw t6, 0(t6)\n"
            );
        }
    }

    // Return the percentage we predicted correctly as the accuracy
    return correct;
}

void flushOutput()
{
    for(int i = 0; i<64; i++)
    {
        OLED_base[i] = output[i];
        output[i] = ' ';
        usleep(1000); // 100 ms
    }
}

int main(int argc, char *argv[])
{
    *final = 0xFF;
    usleep(1000 * 500); // 1000 ms
    int acc = calculate_accuracy(&test_set, &trained_net);
    *final = acc;
    // usleep(1000 * 500); // 1000 ms
    // asm volatile(
    //     "li t6, 0x38010\n"
    //     "lw t6, 0(t6)\n"
    // );
    while(1)
    {
        flushOutput();
        usleep(1000 * 2000); // 1000 ms
        sprintf(output+00, " MNIST acc:");
        sprintf(output+16, " %d/%d!!", acc, (unsigned int) test_set.size);
        sprintf(output+32, " -------------- ");
        sprintf(output+48, " We did it boyz ");
        flushOutput();
        usleep(1000 * 2000); // 1000 ms
        sprintf(output+00, " Let's do math: ");
        sprintf(output+16, " 127.5 * 0.125  ");
        sprintf(output+32, " =  15.9375     ");
        sprintf(output+48, " We did it boyz ");
        flushOutput();
        usleep(1000 * 2000); // 1000 ms
        sprintf(output+00, " Let's do math: ");
        sprintf(output+16, " 3.14 + 0.09345");
        sprintf(output+32, " =  3.234375");
        sprintf(output+48, " We did it boyz ");
    }

    return 0;
}

#endif
