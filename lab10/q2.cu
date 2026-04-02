#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define MASK_WIDTH 5
__constant__ float d_mask[MASK_WIDTH];

__global__ void convolution1D(float* I, float* J, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (i < n) {
        float result = 0.0f;
        int radius = MASK_WIDTH / 2;

        for (int j = 0; j < MASK_WIDTH; j++) {
            int cur_index = i + j - radius;
            
            if (cur_index >= 0 && cur_index < n) {
                result += I[cur_index] * d_mask[j];
            }
        }
        J[i] = result;
    }
}

int main() {
    int n;
    printf("Enter the size of the input array (n): ");
    scanf("%d", &n);

    size_t size = n * sizeof(float);
    
    float *h_I = (float*)malloc(size);
    float *h_J = (float*)malloc(size);
    float h_mask[MASK_WIDTH];

    printf("Enter %d elements for the input array: ", n);
    for (int i = 0; i < n; i++) {
        scanf("%f", &h_I[i]);
    }

    printf("Enter %d elements for the mask: ", MASK_WIDTH);
    for (int i = 0; i < MASK_WIDTH; i++) {
        scanf("%f", &h_mask[i]);
    }

    float *d_I, *d_J;
    cudaMalloc((void**)&d_I, size);
    cudaMalloc((void**)&d_J, size);

    cudaMemcpy(d_I, h_I, size, cudaMemcpyHostToDevice);
    cudaMemcpyToSymbol(d_mask, h_mask, MASK_WIDTH * sizeof(float));

    int threadsPerBlock = 256;
    int blocksPerGrid = (n + threadsPerBlock - 1) / threadsPerBlock;

    convolution1D<<<blocksPerGrid, threadsPerBlock>>>(d_I, d_J, n);

    cudaMemcpy(h_J, d_J, size, cudaMemcpyDeviceToHost);

    printf("\nConvolution Result:\n");
    for (int i = 0; i < n; i++) {
        printf("%.2f ", h_J[i]);
    }
    printf("\n");

    cudaFree(d_I);
    cudaFree(d_J);
    free(h_I);
    free(h_J);

    return 0;
}
