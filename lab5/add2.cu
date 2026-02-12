#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>

__global__ void selectionSort(int *arr, int N) {
    
    if (threadIdx.x == 0 && blockIdx.x == 0) {
        for (int i = 0; i < N - 1; i++) {
            int minIndex = i;
            for (int j = i + 1; j < N; j++) {
                if (arr[j] < arr[minIndex]) {
                    minIndex = j;
                }
            }
            if (minIndex != i) {
                int temp = arr[i];
                arr[i] = arr[minIndex];
                arr[minIndex] = temp;
            }
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

    selectionSort<<<1,1>>>(d_arr, N);

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

