#include <stdio.h>
#include <string.h>
#include <cuda_runtime.h>

__global__ void reverseWords(char *in, char *out, int *starts, int *lens, int wc) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < wc) {
        int s = starts[i], l = lens[i];
        for (int j = 0; j < l; j++) out[s + j] = in[s + l - 1 - j];
    }
}

int main() {
    char input[256];
    printf("Enter a string: ");
    fgets(input, sizeof(input), stdin);
    input[strcspn(input, "\n")] = '\0';  
    int n = strlen(input);

    int starts[50], lens[50], wc = 0;
    for (int i = 0; i < n;) {
        while (i < n && input[i] == ' ') i++;
        if (i >= n) break;
        int s = i;
        while (i < n && input[i] != ' ') i++;
        starts[wc] = s; lens[wc] = i - s; wc++;
    }

    char *d_in, *d_out; int *d_s, *d_l;
    cudaMalloc(&d_in, n); cudaMalloc(&d_out, n);
    cudaMalloc(&d_s, wc * sizeof(int)); cudaMalloc(&d_l, wc * sizeof(int));
    cudaMemcpy(d_in, input, n, cudaMemcpyHostToDevice);
    cudaMemcpy(d_s, starts, wc * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_l, lens, wc * sizeof(int), cudaMemcpyHostToDevice);

    reverseWords<<<(wc+255)/256, 256>>>(d_in, d_out, d_s, d_l, wc);

    char output[256];
    cudaMemcpy(output, d_out, n, cudaMemcpyDeviceToHost);
    for (int i = 0; i < n; i++) if (input[i] == ' ') output[i] = ' ';
    output[n] = '\0';

    printf("Result: %s\n", output);

    cudaFree(d_in); cudaFree(d_out); cudaFree(d_s); cudaFree(d_l);
}

