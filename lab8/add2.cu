#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__device__ int factorial(int x)
{
    int result = 1;
    for (int i = 2; i <= x; i++)
        result *= i;
    return result;
}

__device__ int sumOfDigits(int x)
{
    int sum = 0;
    if (x < 0) x = -x;
    while (x > 0) {
        sum += x % 10;
        x /= 10;
    }
    return sum;
}

__global__ void transform(int *A, int n)
{
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < n && col < n) {
        int val = A[row * n + col];

        if (row == col)
            A[row * n + col] = 0;
        else if (col > row)
            A[row * n + col] = factorial(val);
        else
            A[row * n + col] = sumOfDigits(val);
    }
}

void printMatrix(const char *name, int *M, int n)
{
    printf("\n%s:\n", name);
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++)
            printf("%6d ", M[i * n + j]);
        printf("\n");
    }
}

int main()
{
    int n;
    printf("Enter matrix size (n x n): ");
    scanf("%d", &n);
    while (getchar() != '\n');

    int size = n * n * sizeof(int);
    int *A = (int *)malloc(size);

    printf("Enter elements of Matrix A (%d x %d):\n", n, n);
    for (int i = 0; i < n * n; i++)
        scanf("%d", &A[i]);

    printMatrix("Matrix A (before)", A, n);

    int *d_A;
    cudaMalloc((void **)&d_A, size);
    cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);

    dim3 block(16, 16);
    dim3 grid((n + 15) / 16, (n + 15) / 16);

    transform<<<grid, block>>>(d_A, n);
    cudaDeviceSynchronize();

    cudaMemcpy(A, d_A, size, cudaMemcpyDeviceToHost);

    printMatrix("Matrix A (after)", A, n);

    cudaFree(d_A);
    free(A);

    return 0;
}
