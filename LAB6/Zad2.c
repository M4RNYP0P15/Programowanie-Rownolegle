#include <stdio.h>
#include <string.h>
#include <math.h>
#include "mpi.h"

double func(double x){
	return x*x;
}

int main(int argc, char **argv)
{
	int nLProcesow,nrProc;
	int tag=20;
	double suma=0.0,a,b,S=0.0;
	double dx;
	double p_b;
	
	a=0; // poczatek przedzialu
	b=3; // koniec przedzialu
	double p_a= func(a);
	
	MPI_Status status;
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &nLProcesow);
	dx = (b - a) / (float)nLProcesow;
	double srodek = a+(b-a)/(2.0*nLProcesow);
	
	MPI_Comm_rank(MPI_COMM_WORLD, &nrProc);
	if (nrProc == nLProcesow-1)
	{
		p_b = func(a + (nrProc+1) * dx);
		suma += (p_a+p_b)*0.5*dx;
		p_a=p_b;
		S+=func(srodek)*dx; //obliczenie wysokości prostokąta
		srodek+=dx; //przejście do następnego środka
		printf("Proces: %d Trapez= %f SumaTrapez= %f\n",nrProc ,p_b, suma);
		printf("Prostokat= %f SumaProstokat= %f\n", srodek, S);
		//wysylamy zmienne do procesu ostatniego 
		MPI_Send(&p_a, 1, MPI_DOUBLE, nrProc-1,tag, MPI_COMM_WORLD);
		MPI_Send(&suma, 1, MPI_DOUBLE, nrProc-1,tag, MPI_COMM_WORLD);
		MPI_Send(&srodek, 1, MPI_DOUBLE, nrProc-1,tag, MPI_COMM_WORLD);
		MPI_Send(&S, 1, MPI_DOUBLE, nrProc-1,tag, MPI_COMM_WORLD);
	}
	if (nrProc>0 && nrProc<nLProcesow-1)
	{
		//odbieramy zmienne a i suma od kolejnego
		MPI_Recv(&p_a, 1, MPI_DOUBLE, nrProc+1, tag,MPI_COMM_WORLD, &status);
		MPI_Recv(&suma, 1, MPI_DOUBLE, nrProc+1, tag,MPI_COMM_WORLD, &status);
		MPI_Recv(&srodek, 1, MPI_DOUBLE, nrProc+1, tag,MPI_COMM_WORLD, &status);
		MPI_Recv(&S, 1, MPI_DOUBLE, nrProc+1, tag,MPI_COMM_WORLD, &status);
		p_b = func(a + (nrProc+1) * dx);
		suma += (p_a+p_b)*0.5*dx;
		p_a=p_b;
		S+=func(srodek)*dx; //obliczenie wysokości prostokąta
		srodek+=dx; //przejście do następnego środka
		printf("Proces: %d Trapez= %f SumaTrapez = %f\n",nrProc, p_b, suma);
		printf("Prostokat= %f SumaProstokat= %f\n", srodek, S);
		//przeslanie zmiennych do poprzedniego procesu
		MPI_Send(&p_a, 1, MPI_DOUBLE, nrProc-1,tag, MPI_COMM_WORLD);
		MPI_Send(&suma, 1, MPI_DOUBLE, nrProc-1,tag, MPI_COMM_WORLD);
		MPI_Send(&srodek, 1, MPI_DOUBLE, nrProc-1,tag, MPI_COMM_WORLD);
		MPI_Send(&S, 1, MPI_DOUBLE, nrProc-1,tag, MPI_COMM_WORLD);
	}
	if(nrProc == 0)
	{
		//pobieramy a i suma od kolejnego procesu
		MPI_Recv(&p_a, 1, MPI_DOUBLE, nrProc+1, tag,MPI_COMM_WORLD, &status);
		MPI_Recv(&suma, 1, MPI_DOUBLE, nrProc+1, tag,MPI_COMM_WORLD, &status);
		MPI_Recv(&srodek, 1, MPI_DOUBLE, nrProc+1, tag,MPI_COMM_WORLD, &status);
		MPI_Recv(&S, 1, MPI_DOUBLE, nrProc+1, tag,MPI_COMM_WORLD, &status);
		p_b = func(a + (nrProc+1) * dx);
		suma += (p_a+p_b)*0.5*dx;
		
		//p_a=p_b;
		printf("Proces: %d Trapez= %f SumaTrapez = %f\n",nrProc, p_b, suma);
		printf("<Trapezy>Wartosc calki dla a=%f b=%f n=%d wynosi w przyblizeniu %f\n",a, b, nLProcesow, suma);
		printf("<Prostokaty>Wartosc calki dla a=%f b=%f n=%d wynosi w przyblizeniu %f\n",a, b, nLProcesow, S);

	}
	MPI_Finalize();
	return 0;
}
