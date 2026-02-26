#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <cuda_runtime.h>

__global__ void countWord(char *sentence, char *word, int *count, int sLen, int wLen) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i <= sLen - wLen) {
        bool match = true;
        for (int j = 0; j < wLen; j++) {
            if (sentence[i + j] != word[j]) { match = false; break; }
        }
        if (match) atomicAdd(count, 1);
    }
}

int main() {
    char sentence[1024], word[128];
    printf("Enter a sentence: ");
    fgets(sentence, sizeof(sentence), stdin);
    sentence[strcspn(sentence, "\n")] = '\0';

    printf("Enter the word to search: ");
    fgets(word, sizeof(word), stdin);
    word[strcspn(word, "\n")] = '\0';

    int sLen = strlen(sentence), wLen = strlen(word);

    for (int i = 0; i < sLen; i++) sentence[i] = tolower(sentence[i]);
    for (int i = 0; i < wLen; i++) word[i] = tolower(word[i]);

    char *d_sentence, *d_word; int *d_count, h_count = 0;
    cudaMalloc(&d_sentence, sLen); 
    cudaMalloc(&d_word, wLen); 
    cudaMalloc(&d_count, sizeof(int));

    cudaMemcpy(d_sentence, sentence, sLen, cudaMemcpyHostToDevice);
    cudaMemcpy(d_word, word, wLen, cudaMemcpyHostToDevice);
    cudaMemcpy(d_count, &h_count, sizeof(int), cudaMemcpyHostToDevice);

    int threads = 256, blocks = (sLen + threads - 1) / threads;
    countWord<<<blocks, threads>>>(d_sentence, d_word, d_count, sLen, wLen);
    cudaMemcpy(&h_count, d_count, sizeof(int), cudaMemcpyDeviceToHost);

    printf("The word '%s' appears %d times in the sentence.\n", word, h_count);

    cudaFree(d_sentence); cudaFree(d_word); cudaFree(d_count);
    return 0;
}

