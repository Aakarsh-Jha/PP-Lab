#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);

    int n;
    int *A=NULL;
    int *sub=NULL;
    int *res=NULL;
    int *final=NULL;
    int local_even=0, local_odd=0;
    int *all_even=NULL, *all_odd=NULL;

    if(rank==0){
        scanf("%d",&n);
        if(n % size != 0){
            printf("Array size must be divisible by number of processes\n");
            MPI_Abort(MPI_COMM_WORLD,1);
        }
        A = malloc(n*sizeof(int));
        for(int i=0;i<n;i++) scanf("%d",&A[i]);
    }

    MPI_Bcast(&n,1,MPI_INT,0,MPI_COMM_WORLD);
    int chunk = n/size;

    sub = malloc(chunk*sizeof(int));
    res = malloc(chunk*sizeof(int));

    MPI_Scatter(A,chunk,MPI_INT,sub,chunk,MPI_INT,0,MPI_COMM_WORLD);

    for(int i=0;i<chunk;i++){
        if(sub[i] % 2 == 0){
            res[i] = 1;
            local_even++;
        } else {
            res[i] = 0;
            local_odd++;
        }
    }

    if(rank==0){
        final = malloc(n*sizeof(int));
        all_even = malloc(size*sizeof(int));
        all_odd  = malloc(size*sizeof(int));
    }

    MPI_Gather(res,chunk,MPI_INT,final,chunk,MPI_INT,0,MPI_COMM_WORLD);
    MPI_Gather(&local_even,1,MPI_INT,all_even,1,MPI_INT,0,MPI_COMM_WORLD);
    MPI_Gather(&local_odd,1,MPI_INT,all_odd,1,MPI_INT,0,MPI_COMM_WORLD);

    if(rank==0){
        printf("Resultant array:\n");
        for(int i=0;i<n;i++) printf("%d ",final[i]);
        printf("\n");

        int total_even=0, total_odd=0;
        for(int i=0;i<size;i++){
            total_even += all_even[i];
            total_odd  += all_odd[i];
        }
        printf("Total even count = %d\n", total_even);
        printf("Total odd count  = %d\n", total_odd);

        free(A);
        free(final);
        free(all_even);
        free(all_odd);
    }

    free(sub);
    free(res);
    MPI_Finalize();
    return 0;
}

