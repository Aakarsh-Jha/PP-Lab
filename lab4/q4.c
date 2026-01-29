#include <mpi.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    int rank, size, len;
    char word[100], result[1000] = "";

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        scanf("%s", word);
        len = strlen(word);
        if (len != size) MPI_Abort(MPI_COMM_WORLD, 1);
    }

    MPI_Bcast(&len, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Bcast(word, 100, MPI_CHAR, 0, MPI_COMM_WORLD);

    char temp[100] = "";
    for (int i = 0; i <= rank; i++)
        temp[i] = word[rank];
    temp[rank + 1] = '\0';

    MPI_Gather(temp, 100, MPI_CHAR, result, 100, MPI_CHAR, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        for (int i = 0; i < size; i++)
            printf("%s", result + i * 100);
        printf("\n");
    }

    MPI_Finalize();
    return 0;
}

