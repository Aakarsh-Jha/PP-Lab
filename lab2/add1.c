#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int isPrime(int num) {
    if (num <= 1) return 0;
    if (num == 2) return 1;
    if (num % 2 == 0) return 0;
    for (int i = 3; i <= sqrt(num); i += 2) {
        if (num % i == 0) return 0;
    }
    return 1;
}

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int *arr = NULL;
    int value;

    if (rank == 0) {
        arr = (int *)malloc(size * sizeof(int));
        printf("Enter %d elements:\n", size);
        for (int i = 0; i < size; i++) {
            scanf("%d", &arr[i]);
        }

        for (int i = 1; i < size; i++) {
            MPI_Send(&arr[i], 1, MPI_INT, i, 0, MPI_COMM_WORLD);
        }

        value = arr[0];
        if (isPrime(value))
            printf("Process %d: %d is prime\n", rank, value);
        else
            printf("Process %d: %d is not prime\n", rank, value);

        free(arr);
    } else {
        MPI_Recv(&value, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        if (isPrime(value))
            printf("Process %d: %d is prime\n", rank, value);
        else
            printf("Process %d: %d is not prime\n", rank, value);
    }

    MPI_Finalize();
    return 0;
}

