#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void addByRow(int *A, int *B, int *C, int n)
{
    int row = threadIdx.x;
    if (row < n)
        for (int col = 0; col < n; col++)
            C[row * n + col] = A[row * n + col] + B[row * n + col];
}

__global__ void addByCol(int *A, int *B, int *C, int n)
{
    int col = threadIdx.x;
    if (col < n)
        for (int row = 0; row < n; row++)
            C[row * n + col] = A[row * n + col] + B[row * n + col];
}

__global__ void addByElement(int *A, int *B, int *C, int n)
{
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    if (row < n && col < n)
        C[row * n + col] = A[row * n + col] + B[row * n + col];
}

void printMatrix(const char *name, int *M, int n)
{
    printf("\n%s:\n", name);
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++)
            printf("%4d ", M[i * n + j]);
        printf("\n");
    }
}


int main()
{
    int n;
    printf("Enter matrix size (n x n): ");
    scanf("%d", &n);

    int size = n * n * sizeof(int);

    int *A = (int *)malloc(size);
    int *B = (int *)malloc(size);
    int *C = (int *)malloc(size);

    printf("Enter elements of Matrix A (%d x %d):\n", n, n);
    for (int i = 0; i < n * n; i++)
        scanf("%d", &A[i]);

    printf("Enter elements of Matrix B (%d x %d):\n", n, n);
    for (int i = 0; i < n * n; i++)
        scanf("%d", &B[i]);

    printMatrix("Matrix A", A, n);
    printMatrix("Matrix B", B, n);

    int *d_A, *d_B, *d_C;
    cudaMalloc((void **)&d_A, size);
    cudaMalloc((void **)&d_B, size);
    cudaMalloc((void **)&d_C, size);

    cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B, size, cudaMemcpyHostToDevice);

    addByRow<<<1, n>>>(d_A, d_B, d_C, n);
    cudaDeviceSynchronize();
    cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);
    printMatrix("Result by ROW (a)", C, n);

    addByCol<<<1, n>>>(d_A, d_B, d_C, n);
    cudaDeviceSynchronize();
    cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);
    printMatrix("Result by COLUMN (b)", C, n);

    dim3 block(16, 16);
    dim3 grid((n + 15) / 16, (n + 15) / 16);

    addByElement<<<grid, block>>>(d_A, d_B, d_C, n);
    cudaDeviceSynchronize();
    cudaMemcpy(C, d_C, size, cudaMemcpyDeviceToHost);
    printMatrix("Result by ELEMENT (c)", C, n);

    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    free(A); free(B); free(C);

    return 0;
}
