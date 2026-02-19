#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>

__global__ void oddEvenSort(int *arr, int N, int phase) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    // Odd phase: compare (1,2), (3,4), ...
    // Even phase: compare (0,1), (2,3), ...
    int idx = i * 2 + (phase % 2);

    if (idx + 1 < N) {
        if (arr[idx] > arr[idx + 1]) {
            int temp = arr[idx];
            arr[idx] = arr[idx + 1];
            arr[idx + 1] = temp;
        }
    }
}

int main() {
    int N;
    printf("Enter number of elements: ");
    scanf("%d", &N);

    size_t size = N * sizeof(int);
    int *h_arr = (int*)malloc(size);

    printf("Enter %d elements:\n", N);
    for (int i = 0; i < N; i++) {
        scanf("%d", &h_arr[i]);
    }

    int *d_arr;
    cudaMalloc((void**)&d_arr, size);
    cudaMemcpy(d_arr, h_arr, size, cudaMemcpyHostToDevice);

    int blockSize = 256;
    int gridSize = (N/2 + blockSize - 1) / blockSize;

    for (int phase = 0; phase < N; phase++) {
        oddEvenSort<<<gridSize, blockSize>>>(d_arr, N, phase);
        cudaDeviceSynchronize();
    }

    cudaMemcpy(h_arr, d_arr, size, cudaMemcpyDeviceToHost);

    printf("Sorted array:\n");
    for (int i = 0; i < N; i++) {
        printf("%d ", h_arr[i]);
    }
    printf("\n");

    free(h_arr);
    cudaFree(d_arr);

    return 0;
}

