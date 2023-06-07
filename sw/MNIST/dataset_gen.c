#include <stdio.h>
#include <stdlib.h>
#include "include/mnist_file.h"

const char * test_images_file = "data/t10k-images-idx3-ubyte";
const char * test_labels_file = "data/t10k-labels-idx1-ubyte";

int main(int argc, char *argv[])
{
    mnist_dataset_t * test_dataset;
    test_dataset = mnist_get_dataset(test_images_file, test_labels_file);

    uint min = 0;
    uint max = 0;
    uint size = 0;

    while(min>=max)
    {
        printf("first index: ");
        size = scanf("%d", &min);
        printf("last  index: ");
        size = scanf("%d", &max);
        size = max-min;
    }


    FILE * output = fopen("gen_test_set.c", "w+");

    fprintf(output, "mnist_image_t test_images[%d] = {\n", size);
    for (int i = min; i < max; ++i)
    {
        fprintf(output, "{{\t");
        for(int j = 0; j<MNIST_IMAGE_SIZE-1; j++)
        {
            fprintf(output, "%3d,", test_dataset->images[i].pixels[j]);
            if((j+1) % 28 == 0)
                fprintf(output, "\n\t");
        }
        if(i==max-1)
            fprintf(output, "%3d}}\n};\n", test_dataset->images[i].pixels[MNIST_IMAGE_SIZE-1]);
        else
            fprintf(output, "%3d}},\n", test_dataset->images[i].pixels[MNIST_IMAGE_SIZE-1]);
    }

    uint word_align = (0 - size) % 4; 
    printf("%d\n", word_align);

    fprintf(output, "\nuint8_t test_labels[%d] = {\n\t", size + word_align);
    for (int i = min; i < max-1; ++i)
    {
        fprintf(output, "%d, ", test_dataset->labels[i]);
        if((i+1) % 10 == 0)
            fprintf(output, "\n\t");
    }
    fprintf(output, "%d};\n\n", test_dataset->labels[max-1]);

    fprintf(output, "mnist_dataset_t test_set = {test_images, test_labels, %d};\n", size);

    mnist_free_dataset(test_dataset);
    return 0;
}
