#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>

int main(int argc, char *argv[]) {
    int rank, size;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);

    int M;
    int *array=NULL;
    int *sub=NULL;
    int *res=NULL;
    int *final=NULL;

    if(rank==0){
        scanf("%d",&M);
        array = malloc(size*M*sizeof(int));
        for(int i=0;i<size*M;i++) scanf("%d",&array[i]);
    }

    MPI_Bcast(&M,1,MPI_INT,0,MPI_COMM_WORLD);

    sub = malloc(M*sizeof(int));
    res = malloc(M*sizeof(int));

    MPI_Scatter(array,M,MPI_INT,sub,M,MPI_INT,0,MPI_COMM_WORLD);

    int power = rank+2; // process 0 squares, process 1 cubes, etc.
    for(int i=0;i<M;i++){
        res[i] = (int)pow(sub[i], power);
    }

    if(rank==0) final = malloc(size*M*sizeof(int));
    MPI_Gather(res,M,MPI_INT,final,M,MPI_INT,0,MPI_COMM_WORLD);

    if(rank==0){
        printf("Resultant array:\n");
        for(int i=0;i<size*M;i++) printf("%d ",final[i]);
        printf("\n");
        free(array);
        free(final);
    }

    free(sub);
    free(res);
    MPI_Finalize();
    return 0;
}

