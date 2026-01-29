#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);

    char *S1=NULL, *S2=NULL;
    int len, chunk;
    char *sub1, *sub2, *subres;
    char *result=NULL;

    if(rank==0){
        char buf1[1024], buf2[1024];
        printf("Enter string S1: ");
        fflush(stdout);
        scanf("%s", buf1);
        printf("Enter string S2: ");
        fflush(stdout);
        scanf("%s", buf2);

        len = strlen(buf1);
        if(len != strlen(buf2)){
            printf("Strings must be same length\n");
            MPI_Abort(MPI_COMM_WORLD,1);
        }
        if(len % size != 0){
            printf("String length must be divisible by number of processes\n");
            MPI_Abort(MPI_COMM_WORLD,1);
        }
        S1 = buf1;
        S2 = buf2;
    }

    MPI_Bcast(&len,1,MPI_INT,0,MPI_COMM_WORLD);
    chunk = len/size;

    sub1 = malloc(chunk);
    sub2 = malloc(chunk);
    subres = malloc(2*chunk);

    MPI_Scatter(S1,chunk,MPI_CHAR,sub1,chunk,MPI_CHAR,0,MPI_COMM_WORLD);
    MPI_Scatter(S2,chunk,MPI_CHAR,sub2,chunk,MPI_CHAR,0,MPI_COMM_WORLD);

    for(int i=0;i<chunk;i++){
        subres[2*i]   = sub1[i];
        subres[2*i+1] = sub2[i];
    }

    if(rank==0) result = malloc(2*len+1);
    MPI_Gather(subres,2*chunk,MPI_CHAR,result,2*chunk,MPI_CHAR,0,MPI_COMM_WORLD);

    if(rank==0){
        result[2*len]='\0';
        printf("Resultant string = %s\n", result);
        free(result);
    }

    free(sub1);
    free(sub2);
    free(subres);
    MPI_Finalize();
    return 0;
}

