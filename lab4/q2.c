#include <mpi.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
    int rank, size, mat[3][3], key, local = 0, total;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (size != 3) MPI_Abort(MPI_COMM_WORLD, 1);

    if (rank == 0) {
        for (int i = 0; i < 3; i++)
            for (int j = 0; j < 3; j++)
                scanf("%d", &mat[i][j]);
        scanf("%d", &key);
    }

    MPI_Bcast(mat, 9, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Bcast(&key, 1, MPI_INT, 0, MPI_COMM_WORLD);

    for (int j = 0; j < 3; j++)
        if (mat[rank][j] == key)
            local++;

    MPI_Reduce(&local, &total, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0)
        printf("The number %d appears a total of %d times in the given 3x3 matrix.\n", key, total);

    MPI_Finalize();
    return 0;
}

