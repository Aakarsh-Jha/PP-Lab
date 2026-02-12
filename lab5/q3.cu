#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

__global__ void computeSine(float *angles, float *results, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) {
        results[i] = sinf(angles[i]);  
    }
}

int main() {
    int N;
    printf("Enter number of angles N: ");
    scanf("%d", &N);

    size_t size = N * sizeof(float);

    float *h_angles = (float*)malloc(size);
    float *h_results = (float*)malloc(size);

    printf("Enter %d angles in radians:\n", N);
    for (int i = 0; i < N; i++) {
        scanf("%f", &h_angles[i]);
    }

    float *d_angles, *d_results;
    cudaMalloc((void**)&d_angles, size);
    cudaMalloc((void**)&d_results, size);

    cudaMemcpy(d_angles, h_angles, size, cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocks = (N + threadsPerBlock - 1) / threadsPerBlock;

    computeSine<<<blocks, threadsPerBlock>>>(d_angles, d_results, N);

    cudaMemcpy(h_results, d_results, size, cudaMemcpyDeviceToHost);

    printf("Sine values:\n");
    for (int i = 0; i < N; i++) {
        printf("%f ", h_results[i]);
    }
    printf("\n");

    free(h_angles); free(h_results);
    cudaFree(d_angles); cudaFree(d_results);

    return 0;
}

