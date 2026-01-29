#include <mpi.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
    int rank;
    int a = 20, b = 10;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if (rank == 0) {
        printf("Addition: %d + %d = %d\n", a, b, a + b);
    }
    else if (rank == 1) {
        printf("Subtraction: %d - %d = %d\n", a, b, a - b);
    }
    else if (rank == 2) {
        printf("Multiplication: %d * %d = %d\n", a, b, a * b);
    }
    else if (rank == 3) {
        if (b != 0)
            printf("Division: %d / %d = %d\n", a, b, a / b);
        else
            printf("Division: Cannot divide by zero\n");
    }

    MPI_Finalize();
    return 0;
}

