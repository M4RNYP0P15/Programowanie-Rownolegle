#include <stdio.h>
#include "mpi.h"

int main(int argc, char **argv){
	int p;
	double suma=0;
	int A=-1;
	int n;
	int tag=50;
	double dMianownik;
	MPI_Init(&argc, &argv);  //
	MPI_Comm_size(MPI_COMM_WORLD, &n); //
	MPI_Comm_rank(MPI_COMM_WORLD, &p); //
	MPI_Status status;  //
	if(p==0){
		A*=-1;
		dMianownik=A/(2.0*(p+1)-1);
		suma+=4*dMianownik;
		printf("npr procesu: %d, n: %d, Pi= %f\n", p, p+1, suma);  
		MPI_Send(&A, 1, MPI_INT ,p+1 ,tag, MPI_COMM_WORLD);
		MPI_Send(&suma, 1, MPI_DOUBLE ,p+1 ,tag, MPI_COMM_WORLD);
		//MPI_Send(&dMianownik, 1, MPI_DOUBLE ,p+1 ,tag, MPI_COMM_WORLD);
	} 
	if((p>0)&&(p<=n-1)){
		/* odbiera dane od prosesu o jeden mnniejszego */
		MPI_Recv(&A, 1, MPI_INT, p-1, tag, MPI_COMM_WORLD, &status);
		MPI_Recv(&suma, 1, MPI_DOUBLE, p-1, tag, MPI_COMM_WORLD, &status);
		//MPI_Recv(&dMianownik, 1, MPI_DOUBLE, p-1, tag, MPI_COMM_WORLD, &status);
		A*=-1;
		dMianownik=A/(2.0*(p+1)-1.0);
		suma+=4*dMianownik;
		printf("npr procesu: %d, n: %d, Pi= %f\n", p, p+1, suma); 
		
		if(p!=n-1){
		/* wysyla wyniki do procesu o 1 wiekszego */
			MPI_Send(&A, 1, MPI_INT,p+1,tag,MPI_COMM_WORLD);
			MPI_Send(&suma, 1, MPI_DOUBLE,p+1,tag,MPI_COMM_WORLD);
			//MPI_Send(&dMianownik, 1, MPI_DOUBLE,p+1,tag,MPI_COMM_WORLD);
		}
	}    
	MPI_Finalize();
	return 0;
}
