#include <mpi.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);

    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    char word[50];

    if (rank == 0) {
        printf("Enter a word: ");
        fflush(stdout);
        scanf("%49s", word);

        MPI_Ssend(word, strlen(word) + 1, MPI_CHAR, 1, 0, MPI_COMM_WORLD);
        MPI_Recv(word, 50, MPI_CHAR, 1, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        printf("Final word at sender: %s\n", word);
    } else if (rank == 1) {
        MPI_Recv(word, 50, MPI_CHAR, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        for (int i = 0; word[i]; i++) {
            if (islower(word[i]))
                word[i] = toupper(word[i]);
            else if (isupper(word[i]))
                word[i] = tolower(word[i]);
        }

        MPI_Ssend(word, strlen(word) + 1, MPI_CHAR, 0, 0, MPI_COMM_WORLD);
    }

    MPI_Finalize();
    return 0;
}

