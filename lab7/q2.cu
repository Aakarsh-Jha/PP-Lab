/*2. Write a CUDA program that reads a string § and produces the string RS as follows:
Input string §: PCAP
Output string RS: PCAPPCAPCP
Note: Each work item copies required number of characters from S in RS.*/






#include <stdio.h>
#include <string.h>
#include <cuda_runtime.h>

__global__ void buildRS(char *S, char *RS, int lenS) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    int lenRS = (lenS * (lenS + 1)) / 2;

    if (i < lenRS) {
        int pos = i;
        for (int k = lenS; k > 0; k--) {
            if (pos < k) {
                RS[i] = S[pos];  
                break;
            }
            pos -= k;
        }
    }
}

int main() {
    char h_S[128];
    printf("Enter string S: ");
    fgets(h_S, sizeof(h_S), stdin);
    h_S[strcspn(h_S, "\n")] = '\0'; 

    int lenS = strlen(h_S);
    int lenRS = (lenS * (lenS + 1)) / 2;  

    char *d_S, *d_RS;
    char h_RS[1024];

    cudaMalloc(&d_S, lenS);
    cudaMalloc(&d_RS, lenRS);

    cudaMemcpy(d_S, h_S, lenS, cudaMemcpyHostToDevice);

    int threads = 256;
    int blocks = (lenRS + threads - 1) / threads;
    buildRS<<<blocks, threads>>>(d_S, d_RS, lenS);

    cudaMemcpy(h_RS, d_RS, lenRS, cudaMemcpyDeviceToHost);
    h_RS[lenRS] = '\0';

    printf("Output string RS: %s\n", h_RS);

    cudaFree(d_S);
    cudaFree(d_RS);

    return 0;
}

