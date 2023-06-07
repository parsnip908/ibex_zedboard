#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>

#include "include/mnist_file.h"
#include "include/neural_network.h"
// #include "trained_net.c"

#define STEPS 1000
#define BATCH_SIZE 100

/**
 * Downloaded from: http://yann.lecun.com/exdb/mnist/
 */
const char * train_images_file = "data/train-images-idx3-ubyte";
const char * train_labels_file = "data/train-labels-idx1-ubyte";
const char * test_images_file = "data/t10k-images-idx3-ubyte";
const char * test_labels_file = "data/t10k-labels-idx1-ubyte";

/**
 * Calculate the accuracy of the predictions of a neural network on a dataset.
 */
float calculate_accuracy(mnist_dataset_t * dataset, neural_network_t * network)
{
    float activations[MNIST_LABELS], max_activation;
    int i, j, correct, predict;

    // Loop through the dataset
    for (i = 0, correct = 0; i < dataset->size; i++) {
        // Calculate the activations for each image using the neural network
        neural_network_hypothesis(&dataset->images[i], network, activations);

        // Set predict to the index of the greatest activation
        for (j = 0, predict = 0, max_activation = activations[0]; j < MNIST_LABELS; j++) {
            if (max_activation < activations[j]) {
                max_activation = activations[j];
                predict = j;
            }
        }

        // Increment the correct count if we predicted the right label
        if (predict == dataset->labels[i]) {
            correct++;
        }
    }

    // Return the percentage we predicted correctly as the accuracy
    return ((float) correct) / ((float) dataset->size);
}

int main(int argc, char *argv[])
{
    mnist_dataset_t * train_dataset, * test_dataset;
    mnist_dataset_t batch;
    neural_network_t network;
    float loss, accuracy;
    int i, batches;

    // for(i = 0; i<MNIST_LABELS; i++)
    //     printf("%e\n", trained_net.b[i]);

    // Read the datasets from the files
    train_dataset = mnist_get_dataset(train_images_file, train_labels_file);
    test_dataset = mnist_get_dataset(test_images_file, test_labels_file);
    
    // accuracy = calculate_accuracy(test_dataset, &trained_net);
    // printf("Previous Accuracy: %.3f\n", accuracy);

    // Initialise weights and biases with random values
    neural_network_random_weights(&network);

    // Calculate how many batches (so we know when to wrap around)
    batches = train_dataset->size / BATCH_SIZE;

    for (i = 0; i < STEPS; i++) {
        // Initialise a new batch
        mnist_batch(train_dataset, &batch, 100, i % batches);

        // Run one step of gradient descent and calculate the loss
        loss = neural_network_training_step(&batch, &network, 0.5);

        // Calculate the accuracy using the whole test dataset
        accuracy = calculate_accuracy(test_dataset, &network);

        printf("Step %04d\tAverage Loss: %.2f\tAccuracy: %.3f\n", i, loss / batch.size, accuracy);
    }
    
    printf("\nFinal Accuracy: %f\n", accuracy);

/*****************************************/

    FILE * output = fopen("trained_net.c", "w+");

    fprintf(output, "neural_network_t trained_net = {\n{");

    for(i = 0; i<MNIST_LABELS-1; i++)
        fprintf(output, "%e, ", network.b[i]);
    fprintf(output, "%e},\n", network.b[MNIST_LABELS-1]);

    fprintf(output, "{\n\t{");
    for(i = 0; i<MNIST_LABELS; i++)
    {
        for(int j = 0; j<MNIST_IMAGE_SIZE-1; j++)
        {
            fprintf(output, "%e, ", network.W[i][j]);
            if((j+1) % 28 == 0)
                fprintf(output, "\n\t ");
        }
        if(i == MNIST_LABELS-1)
            fprintf(output, "%e}\n}};\n", network.W[i][MNIST_IMAGE_SIZE-1]);
        else
            fprintf(output, "%e},\n\t{", network.W[i][MNIST_IMAGE_SIZE-1]);
    }

    fclose(output);
    
/*****************************************/

    output = fopen("test_set.c", "w+");
    
    fprintf(output, "mnist_image_t images[50] = {\n");
    for (int i = 0; i < 50; ++i)
    {
        fprintf(output, "{{\t");
        for(int j = 0; j<MNIST_IMAGE_SIZE-1; j++)
        {
            fprintf(output, "%3d,", test_dataset->images[i].pixels[j]);
            if((j+1) % 28 == 0)
                fprintf(output, "\n\t");
        }
        if(i==49)
            fprintf(output, "%3d}}\n};\n", test_dataset->images[i].pixels[MNIST_IMAGE_SIZE-1]);
        else
            fprintf(output, "%3d}},\n", test_dataset->images[i].pixels[MNIST_IMAGE_SIZE-1]);
    }

    fprintf(output, "\nuint8_t labels[50] = {\n\t");
    for (int i = 0; i < 49; ++i)
    {
        fprintf(output, "%d, ", test_dataset->labels[i]);
        if((i+1) % 10 == 0)
            fprintf(output, "\n\t");
    }
    fprintf(output, "%d};\n\n", test_dataset->labels[49]);

    fprintf(output, "mnist_dataset_t test_set = {images, labels, 50};\n");

/*****************************************/

    // Cleanup
    mnist_free_dataset(train_dataset);
    mnist_free_dataset(test_dataset);
    return 0;
}
