#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int *arr = NULL;
    int value;

    int bufsize = size * (sizeof(int) + MPI_BSEND_OVERHEAD);
    void *buffer = malloc(bufsize);
    MPI_Buffer_attach(buffer, bufsize);

    if (rank == 0) {
        arr = (int *)malloc(size * sizeof(int));
        printf("Enter %d elements:\n", size);
        for (int i = 0; i < size; i++) {
            scanf("%d", &arr[i]);
        }

        for (int i = 1; i < size; i++) {
            MPI_Bsend(&arr[i], 1, MPI_INT, i, 0, MPI_COMM_WORLD);
        }

        value = arr[0];
        if (rank % 2 == 0)
            printf("Process %d (even) squared: %d\n", rank, value * value);
        else
            printf("Process %d (odd) cubed: %d\n", rank, value * value * value);

        free(arr);
    } else {
        MPI_Recv(&value, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        if (rank % 2 == 0)
            printf("Process %d (even) squared: %d\n", rank, value * value);
        else
            printf("Process %d (odd) cubed: %d\n", rank, value * value * value);
    }

    MPI_Buffer_detach(&buffer, &bufsize);
    free(buffer);

    MPI_Finalize();
    return 0;
}

