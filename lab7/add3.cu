#include <stdio.h>
#include <string.h>
#include <cuda_runtime.h>

__global__ void repeatChars(char *in, char *out, int *pos, int len) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < len) {
        char c = in[idx];
        int start = pos[idx];
        int count = idx + 1;  
        for (int j = 0; j < count; j++) {
            out[start + j] = c;
        }
    }
}

int main() {
    char Sin[256];
    printf("Input     Sin: ");
    fgets(Sin, sizeof(Sin), stdin);
    Sin[strcspn(Sin, "\n")] = '\0';  
    int len = strlen(Sin);

    int pos[256];
    int totalLen = 0;
    for (int i = 0; i < len; i++) {
        pos[i] = totalLen;
        totalLen += (i + 1);
    }

    char *d_in, *d_out;
    int *d_pos;
    cudaMalloc(&d_in, len);
    cudaMalloc(&d_out, totalLen);
    cudaMalloc(&d_pos, len * sizeof(int));

    cudaMemcpy(d_in, Sin, len, cudaMemcpyHostToDevice);
    cudaMemcpy(d_pos, pos, len * sizeof(int), cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocks = (len + threadsPerBlock - 1) / threadsPerBlock;
    repeatChars<<<blocks, threadsPerBlock>>>(d_in, d_out, d_pos, len);

    char T[1024];
    cudaMemcpy(T, d_out, totalLen, cudaMemcpyDeviceToHost);
    T[totalLen] = '\0';

    printf("Output:     T: %s\n", T);

    cudaFree(d_in);
    cudaFree(d_out);
    cudaFree(d_pos);
    return 0;
}

