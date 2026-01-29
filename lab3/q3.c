#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpi.h>
#include <ctype.h>

int is_vowel(char c) {
    c = tolower(c);
    return (c=='a'||c=='e'||c=='i'||c=='o'||c=='u');
}

int main(int argc, char *argv[]) {
    int rank, size;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);

    char *str=NULL;
    int len, chunk;
    char *sub;
    int local_count=0;
    int *counts=NULL;

    if(rank==0){
        char buffer[1024];
        scanf("%s",buffer);
        len=strlen(buffer);
        if(len%size!=0){MPI_Abort(MPI_COMM_WORLD,1);}
        str=buffer;
    }

    MPI_Bcast(&len,1,MPI_INT,0,MPI_COMM_WORLD);
    chunk=len/size;
    sub=(char*)malloc(chunk);

    MPI_Scatter(str,chunk,MPI_CHAR,sub,chunk,MPI_CHAR,0,MPI_COMM_WORLD);

    for(int i=0;i<chunk;i++) if(!is_vowel(sub[i])) local_count++;

    if(rank==0) counts=(int*)malloc(size*sizeof(int));
    MPI_Gather(&local_count,1,MPI_INT,counts,1,MPI_INT,0,MPI_COMM_WORLD);

    if(rank==0){
        int total=0;
        for(int i=0;i<size;i++){
            printf("Process %d found %d non-vowels\n",i,counts[i]);
            total+=counts[i];
        }
        printf("Total non-vowels = %d\n",total);
        free(counts);
    }

    free(sub);
    MPI_Finalize();
    return 0;
}

