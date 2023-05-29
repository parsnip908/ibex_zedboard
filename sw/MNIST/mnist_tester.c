#ifndef MNIST_TESTER
#define MNIST_TESTER

#include "include/neural_network.h"
#include "trained_net.c"
#include "gen_test_set.c"

// Convert a pixel value from 0-255 to one from 0 to 1
// #define PIXEL_SCALE(x) (((float) (x)) / 256.0f)

volatile int* final = (volatile int*) 0x00078010;

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
        for (j = 0, predict = 0, max_activation = activations[0]; j < MNIST_LABELS; j++) 
        {
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
                "li t6, 0x18010\n"
                "lw t6, 0(t6)\n"
            );
        }
    }

    // Return the percentage we predicted correctly as the accuracy
    return correct;
}

int main(int argc, char *argv[])
{
    *final = calculate_accuracy(&test_set, &trained_net);

    asm volatile(
        "li t6, 0x18010\n"
        "lw t6, 0(t6)\n"
    );

    return 0;
}

#endif
