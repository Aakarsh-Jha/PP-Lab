#include <mpi.h>
#include <stdio.h>
#include <math.h>

int main(int argc, char *argv[]) {
    int rank;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    int x = 2;
    printf("Rank %d: %d^%d = %.0f\n", rank, x, rank, pow(x, rank));

    MPI_Finalize();
    return 0;
}

