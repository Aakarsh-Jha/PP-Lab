#include <stdio.h>
#include <string.h>
#include <cuda_runtime.h>

__global__ void concatKernel(char *in, char *out, int len, int N) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int total = len * N;
    if (idx < total) {
        out[idx] = in[idx % len];  
    }
}

int main() {
    char Sin[256];
    int N;
    printf("Input:      Sin: ");
    fgets(Sin, sizeof(Sin), stdin);
    Sin[strcspn(Sin, "\n")] = '\0';  
    printf("Enter N: ");
    scanf("%d", &N);

    int len = strlen(Sin);
    int totalLen = len * N;

    char *d_in, *d_out;
    cudaMalloc(&d_in, len);
    cudaMalloc(&d_out, totalLen);

    cudaMemcpy(d_in, Sin, len, cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocks = (totalLen + threadsPerBlock - 1) / threadsPerBlock;
    concatKernel<<<blocks, threadsPerBlock>>>(d_in, d_out, len, N);

    char Sout[1024];
    cudaMemcpy(Sout, d_out, totalLen, cudaMemcpyDeviceToHost);
    Sout[totalLen] = '\0';

    printf("Output:     Sout: %s\n", Sout);

    cudaFree(d_in);
    cudaFree(d_out);
    return 0;
}

