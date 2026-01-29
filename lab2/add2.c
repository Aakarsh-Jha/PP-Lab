#include <mpi.h>
#include <stdio.h>

int factorial(int num) {
    int fact = 1;
    for (int i = 1; i <= num; i++) {
        fact *= i;
    }
    return fact;
}

int sumSeries(int k) {
    int sum = 0;
    for (int i = 1; i <= k; i++) {
        sum += i;
    }
    return sum;
}

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int n;
    int local_result = 0, final_result = 0;

    if (rank == 0) {
        printf("Enter value of n (equal to number of processes): ");
        fflush(stdout);
        scanf("%d", &n);

        if (n != size) {
            printf("Error: run with -np %d processes\n", n);
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
    }

    MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if (rank % 2 == 1) {
        local_result = factorial(rank);
    } else {
        local_result = sumSeries(rank + 1);
    }

    MPI_Reduce(&local_result, &final_result, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        printf("Final result: %d\n", final_result);
    }

    MPI_Finalize();
    return 0;
}

