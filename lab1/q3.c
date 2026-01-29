#include <mpi.h>
#include <stdio.h>
#include <ctype.h>

int main(int argc, char *argv[]) {
    int rank;
    char str[] = "HELLO";

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if (rank < 5) {
        char ch = tolower(str[rank]);
        printf("Rank %d: %c\n", rank, ch);
    }

    MPI_Finalize();
    return 0;
}

