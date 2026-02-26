/*Write a CUDA program which takes N binary numbers as input and stores the one's
complement of each element in another array in parallel*/



#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

__global__ void onesComplement(char *input, char *output, int n, int maxLen) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        for (int j = 0; j < maxLen; j++) {
            char bit = input[idx * maxLen + j];
            if (bit == '0') output[idx * maxLen + j] = '1';
            else if (bit == '1') output[idx * maxLen + j] = '0';
            else output[idx * maxLen + j] = bit; 
        }
    }
}

int main() {
    int n;
    printf("Enter number of binary numbers: ");
    scanf("%d", &n);

    int maxLen = 32; 
    size_t size = n * maxLen * sizeof(char);

    char *h_input = (char*)malloc(size);
    char *h_output = (char*)malloc(size);

    printf("Enter %d binary numbers:\n", n);
    for (int i = 0; i < n; i++) {
        char temp[32];
        scanf("%s", temp);
        // copy into fixed-length slot
        strncpy(&h_input[i * maxLen], temp, maxLen);
    }

    char *d_input, *d_output;
    cudaMalloc((void**)&d_input, size);
    cudaMalloc((void**)&d_output, size);

    cudaMemcpy(d_input, h_input, size, cudaMemcpyHostToDevice);

    int blockSize = 256;
    int gridSize = (n + blockSize - 1) / blockSize;
    onesComplement<<<gridSize, blockSize>>>(d_input, d_output, n, maxLen);

    cudaMemcpy(h_output, d_output, size, cudaMemcpyDeviceToHost);

    printf("One's complement values:\n");
    for (int i = 0; i < n; i++) {
        printf("%.*s -> %.*s\n", maxLen, &h_input[i * maxLen], maxLen, &h_output[i * maxLen]);
    }

    free(h_input);
    free(h_output);
    cudaFree(d_input);
    cudaFree(d_output);

    return 0;
}

