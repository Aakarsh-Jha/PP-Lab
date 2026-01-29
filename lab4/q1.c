#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    int rank, size, n;
    long long local, prefix, fact = 1, sum = 0;

    if (MPI_Init(&argc, &argv) != MPI_SUCCESS) exit(1);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        if (argc != 2) {
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
        n = atoi(argv[1]);
        if (n <= 0 || n < size) {
            MPI_Abort(MPI_COMM_WORLD, 2);
        }
    }

    MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);

    for (int i = 1; i <= rank + 1; i++)
        fact *= i;

    local = fact;

    MPI_Scan(&local, &prefix, 1, MPI_LONG_LONG, MPI_SUM, MPI_COMM_WORLD);

    if (rank == size - 1) {
        sum = prefix;
        printf("Sum of factorials 1! + 2! + ... + %d! = %lld\n", n, sum);
    }

    MPI_Finalize();
    return 0;
}

