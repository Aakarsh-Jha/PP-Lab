#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

long long factorial(int num) {
    long long fact = 1;
    for (int i = 1; i <= num; i++) fact *= i;
    return fact;
}

int main(int argc, char *argv[]) {
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int *numbers = NULL, num;
    long long fact, sum;

    if (rank == 0) {
        numbers = malloc(size * sizeof(int));
        for (int i = 0; i < size; i++) scanf("%d", &numbers[i]);
    }

    MPI_Scatter(numbers, 1, MPI_INT, &num, 1, MPI_INT, 0, MPI_COMM_WORLD);
    fact = factorial(num);

    long long *results = NULL;
    if (rank == 0) results = malloc(size * sizeof(long long));
    MPI_Gather(&fact, 1, MPI_LONG_LONG, results, 1, MPI_LONG_LONG, 0, MPI_COMM_WORLD);

    for (int i = 0; i < size; i++) {
        MPI_Barrier(MPI_COMM_WORLD);
        if (rank == i) {
            printf("Process %d got %d, factorial = %lld\n", rank, num, fact);
            fflush(stdout);
        }
    }

    if (rank == 0) {
        sum = 0;
        for (int i = 0; i < size; i++) sum += results[i];
        printf("Sum = %lld\n", sum);
        free(numbers);
        free(results);
    }

    MPI_Finalize();
    return 0;
}

