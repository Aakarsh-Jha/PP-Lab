#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>

__global__ void convolution1D(int *N, int *M, int *P, int width, int mask_width) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int radius = mask_width / 2;

    if (i < width) {
        int value = 0;
        for (int j = 0; j < mask_width; j++) {
            int idx = i - radius + j;
            if (idx >= 0 && idx < width) {
                value += N[idx] * M[j];
            }
        }
        P[i] = value;
    }
}

int main() {
    int width, mask_width;

    printf("Enter size of input array (width): ");
    scanf("%d", &width);
    printf("Enter size of mask array (mask_width): ");
    scanf("%d", &mask_width);

    int *h_N = (int*)malloc(width * sizeof(int));
    int *h_M = (int*)malloc(mask_width * sizeof(int));
    int *h_P = (int*)malloc(width * sizeof(int));

    printf("Enter %d elements for input array N:\n", width);
    for (int i = 0; i < width; i++) {
        scanf("%d", &h_N[i]);
    }

    printf("Enter %d elements for mask array M:\n", mask_width);
    for (int i = 0; i < mask_width; i++) {
        scanf("%d", &h_M[i]);
    }

    int *d_N, *d_M, *d_P;
    cudaMalloc((void**)&d_N, width * sizeof(int));
    cudaMalloc((void**)&d_M, mask_width * sizeof(int));
    cudaMalloc((void**)&d_P, width * sizeof(int));

    cudaMemcpy(d_N, h_N, width * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_M, h_M, mask_width * sizeof(int), cudaMemcpyHostToDevice);

    int blockSize = 256;
    int gridSize = (width + blockSize - 1) / blockSize;
    convolution1D<<<gridSize, blockSize>>>(d_N, d_M, d_P, width, mask_width);

    cudaMemcpy(h_P, d_P, width * sizeof(int), cudaMemcpyDeviceToHost);

    printf("Resultant array P:\n");
    for (int i = 0; i < width; i++) {
        printf("%d ", h_P[i]);
    }
    printf("\n");

    free(h_N);
    free(h_M);
    free(h_P);
    cudaFree(d_N);
    cudaFree(d_M);
    cudaFree(d_P);

    return 0;
}

