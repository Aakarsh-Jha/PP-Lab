#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>

__global__ void saxpyKernel(float a, float *x, float *y, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) {
        y[i] = a * x[i] + y[i];
    }
}

int main() {
    int N;
    float a;

    printf("Enter length of vectors N: ");
    scanf("%d", &N);

    printf("Enter scalar a: ");
    scanf("%f", &a);

    size_t size = N * sizeof(float);

    float *h_x = (float*)malloc(size);
    float *h_y = (float*)malloc(size);

    printf("Enter elements of vector x:\n");
    for (int i = 0; i < N; i++) {
        scanf("%f", &h_x[i]);
    }

    printf("Enter elements of vector y:\n");
    for (int i = 0; i < N; i++) {
        scanf("%f", &h_y[i]);
    }

    float *d_x, *d_y;
    cudaMalloc((void**)&d_x, size);
    cudaMalloc((void**)&d_y, size);

    cudaMemcpy(d_x, h_x, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, h_y, size, cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocks = (N + threadsPerBlock - 1) / threadsPerBlock;

    saxpyKernel<<<blocks, threadsPerBlock>>>(a, d_x, d_y, N);

    cudaMemcpy(h_y, d_y, size, cudaMemcpyDeviceToHost);

    printf("Result vector y:\n");
    for (int i = 0; i < N; i++) {
        printf("%f ", h_y[i]);
    }
    printf("\n");

    free(h_x); free(h_y);
    cudaFree(d_x); cudaFree(d_y);

    return 0;
}

