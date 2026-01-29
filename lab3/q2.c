#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int M;
    int *array = NULL;
    int *subarray;
    double avg, total_avg;

    if (rank == 0) {
        scanf("%d", &M);
        array = malloc(size * M * sizeof(int));
        for (int i = 0; i < size * M; i++) {
            scanf("%d", &array[i]);
        }
    }

    MPI_Bcast(&M, 1, MPI_INT, 0, MPI_COMM_WORLD);

    subarray = malloc(M * sizeof(int));
    MPI_Scatter(array, M, MPI_INT, subarray, M, MPI_INT, 0, MPI_COMM_WORLD);

    int sum = 0;
    for (int i = 0; i < M; i++) sum += subarray[i];
    avg = (double)sum / M;

    double *all_avgs = NULL;
    if (rank == 0) {
        all_avgs = malloc(size * sizeof(double));
    }
    MPI_Gather(&avg, 1, MPI_DOUBLE, all_avgs, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    for (int i = 0; i < size; i++) {
        MPI_Barrier(MPI_COMM_WORLD);
        if (rank == i) {
            printf("Process %d got elements: ", rank);
            for (int j = 0; j < M; j++) printf("%d ", subarray[j]);
            printf("-> local average = %.2f\n", avg);
            fflush(stdout);
        }
    }

    if (rank == 0) {
        double sum_avgs = 0.0;
        for (int i = 0; i < size; i++) sum_avgs += all_avgs[i];
        total_avg = sum_avgs / size;
        printf("Total average = %.2f\n", total_avg);
        free(array);
        free(all_avgs);
    }

    free(subarray);
    MPI_Finalize();
    return 0;
}

