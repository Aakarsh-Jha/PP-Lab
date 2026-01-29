#include <mpi.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
    int rank, size;
    int mat[4][4], result[4][4];

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (size != 4)
        MPI_Abort(MPI_COMM_WORLD, 1);

    if (rank == 0) {
        for (int i = 0; i < 4; i++)
            for (int j = 0; j < 4; j++)
                scanf("%d", &mat[i][j]);
    }

    MPI_Bcast(mat, 16, MPI_INT, 0, MPI_COMM_WORLD);

    MPI_Scan(mat[rank], result[rank], 4, MPI_INT, MPI_SUM, MPI_COMM_WORLD);

    MPI_Gather(result[rank], 4, MPI_INT,
               result, 4, MPI_INT, 0, MPI_COMM_WORLD);
    
    if (rank == 0) {
        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++)
                printf("%d ", result[i][j]);
            printf("\n");
        }
    }

    MPI_Finalize();
    return 0;
}

