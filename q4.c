#include <mpi.h>
#include <stdio.h>

long factorial(int n) {
    long f = 1;
    for (int i = 1; i <= n; i++) f *= i;
    return f;
}

int fibonacci(int n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

int main(int argc, char *argv[]) {
    int rank;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if (rank % 2 == 0)
        printf("Rank %d Factorial = %ld\n", rank, factorial(rank));
    else
        printf("Rank %d Fibonacci = %d\n", rank, fibonacci(rank));

    MPI_Finalize();
    return 0;
}

