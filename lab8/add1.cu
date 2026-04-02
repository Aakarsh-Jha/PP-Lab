#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void transform(int *A, int *B, int M, int N)
{
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < M && col < N) {
        int val = A[row * N + col];

        if (val % 2 == 0) {
            int rowSum = 0;
            for (int j = 0; j < N; j++)
                rowSum += A[row * N + j];
            B[row * N + col] = rowSum;
        } else {
            int colSum = 0;
            for (int i = 0; i < M; i++)
                colSum += A[i * N + col];
            B[row * N + col] = colSum;
        }
    }
}

void printMatrix(const char *name, int *M, int rows, int cols)
{
    printf("\n%s:\n", name);
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++)
            printf("%4d ", M[i * cols + j]);
        printf("\n");
    }
}

int main()
{
    int M, N;
    printf("Enter rows and columns (M N): ");
    scanf("%d %d", &M, &N);
    while (getchar() != '\n');

    int size = M * N * sizeof(int);

    int *A = (int *)malloc(size);
    int *B = (int *)malloc(size);

    printf("Enter elements of Matrix A (%d x %d):\n", M, N);
    for (int i = 0; i < M * N; i++)
        scanf("%d", &A[i]);

    printMatrix("Matrix A", A, M, N);

    int *d_A, *d_B;
    cudaMalloc((void **)&d_A, size);
    cudaMalloc((void **)&d_B, size);

    cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);

    dim3 block(16, 16);
    dim3 grid((N + 15) / 16, (M + 15) / 16);

    transform<<<grid, block>>>(d_A, d_B, M, N);
    cudaDeviceSynchronize();

    cudaMemcpy(B, d_B, size, cudaMemcpyDeviceToHost);

    printMatrix("Matrix B (Result)", B, M, N);

    cudaFree(d_A); cudaFree(d_B);
    free(A); free(B);

    return 0;
}
