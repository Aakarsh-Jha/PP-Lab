#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>

__global__ void convertToOctal(int *input, int *output, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        int num = input[idx];
        int octal = 0, place = 1;

        while (num > 0) {
            int rem = num % 8;
            octal += rem * place;
            num /= 8;
            place *= 10;
        }
        output[idx] = octal;
    }
}

int main() {
    int n;
    printf("Enter number of elements: ");
    scanf("%d", &n);

    size_t size = n * sizeof(int);

    int *h_input = (int*)malloc(size);
    int *h_output = (int*)malloc(size);

    printf("Enter %d integers:\n", n);
    for (int i = 0; i < n; i++) {
        scanf("%d", &h_input[i]);
    }

    int *d_input, *d_output;
    cudaMalloc((void**)&d_input, size);
    cudaMalloc((void**)&d_output, size);

    cudaMemcpy(d_input, h_input, size, cudaMemcpyHostToDevice);

    int blockSize = 256;
    int gridSize = (n + blockSize - 1) / blockSize;
    convertToOctal<<<gridSize, blockSize>>>(d_input, d_output, n);

    cudaMemcpy(h_output, d_output, size, cudaMemcpyDeviceToHost);

    printf("Octal values:\n");
    for (int i = 0; i < n; i++) {
        printf("%d -> %d\n", h_input[i], h_output[i]);
    }

    free(h_input);
    free(h_output);
    cudaFree(d_input);
    cudaFree(d_output);

    return 0;
}

