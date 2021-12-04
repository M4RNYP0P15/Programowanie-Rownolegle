// Kompilacja
// mpicc Zad2.c -o Zad2 -lm -lpng
// mpirun -np 3 ./Zad2
// apt install libpng-dev

#define NO_FREETYPE

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <png.h>
#include <string.h>
#include "mpi.h"

typedef enum { DATA_TAG, TERM_TAG, RESULT_TAG} Tags;

void write_png_file(char* file_name, int *Mandel,int width, int height, int MAX) // tworzy plik png z tablicy Iters
{
	FILE *fp = fopen(file_name, "wb");
	if (!fp) printf("[write_png_file] File %s could not be opened for writing", file_name);
	
	png_structp png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	if (!png_ptr) printf("[write_png_file] png_create_write_struct failed");
	
	png_infop info_ptr = png_create_info_struct(png_ptr);
	if (!info_ptr) printf("[write_png_file] png_create_info_struct failed");
	
	if (setjmp(png_jmpbuf(png_ptr))) printf("[write_png_file] Error during init_io");
	
	png_init_io(png_ptr, fp);
	
	if (setjmp(png_jmpbuf(png_ptr))) printf("[write_png_file] Error during writing header");
	
	png_set_IHDR(png_ptr, info_ptr, width, height,8, PNG_COLOR_TYPE_RGB, PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_BASE, PNG_FILTER_TYPE_BASE);
	png_write_info(png_ptr, info_ptr);
	png_bytep row = (png_bytep) malloc(sizeof(png_byte) * width * 3);
	
	double red_value, green_value, blue_value;
    	float scale = 256.0/MAX;
   	double MyPalette[41][3]={
        {1.0,1.0,1.0},{1.0,1.0,1.0},{1.0,1.0,1.0},{1.0,1.0,1.0},// 0, 1, 2, 3, 
        {1.0,1.0,1.0},{1.0,0.7,1.0},{1.0,0.7,1.0},{1.0,0.7,1.0},// 4, 5, 6, 7,
        {0.97,0.5,0.94},{0.97,0.5,0.94},{0.94,0.25,0.88},{0.94,0.25,0.88},//8, 9, 10, 11,
        {0.91,0.12,0.81},{0.88,0.06,0.75},{0.85,0.03,0.69},{0.82,0.015,0.63},//12, 13, 14, 15, 
        {0.78,0.008,0.56},{0.75,0.004,0.50},{0.72,0.0,0.44},{0.69,0.0,0.37},//16, 17, 18, 19,
        {0.66,0.0,0.31},{0.63,0.0,0.25},{0.60,0.0,0.19},{0.56,0.0,0.13},//20, 21, 22, 23,
        {0.53,0.0,0.06},{0.5,0.0,0.0},{0.47,0.06,0.0},{0.44,0.12,0},//24, 25, 26, 27, 
        {0.41,0.18,0.0},{0.38,0.25,0.0},{0.35,0.31,0.0},{0.31,0.38,0.0},//28, 29, 30, 31,
        {0.28,0.44,0.0},{0.25,0.50,0.0},{0.22,0.56,0.0},{0.19,0.63,0.0},//32, 33, 34, 35,
        {0.16,0.69,0.0},{0.13,0.75,0.0},{0.06,0.88,0.0},{0.03,0.94,0.0},//36, 37, 38, 39,
        {0.0,0.0,0.0}//40 
	};
	int x, y, indx;
	for (y=0; y<height; y++){
        	for (x=0; x<width; x++) {
			png_byte* ptr = &(row[x*3]);
			indx= (int) floor(5.0*scale*log2f(1.0f*Mandel[y*width+x]+1));
			//printf("Pixel at position [ %d - %d ] has RGBA values: %d - %d - %d - %d\n",
		     //      x, y, ptr[0], ptr[1], ptr[2], ptr[3]);
            		ptr[0] = MyPalette[indx][0] *255;
            		ptr[1] = MyPalette[indx][2] *255;
			ptr[2] = MyPalette[indx][1] *255;
		}
		png_write_row(png_ptr, row);
	}
	png_write_end(png_ptr, NULL);
	if (setjmp(png_jmpbuf(png_ptr))) printf("[write_png_file] Error during end of write");
	free(row);
	fclose(fp);
}

void worker(double X0, double Y0, double d_re, double d_im, int POZ, int PION, int ITER) // jest wykonywany przez wątki "potomne"
{
	MPI_Status status;
	int zakres,rank;
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Recv(&zakres , 1 , MPI_INT, 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
	int koniec = rank*zakres;
	if(koniec > PION*POZ)
		koniec = PION*POZ;
	int pocz = (rank-1)*zakres;
	int * colors = malloc(sizeof(int) * (koniec-pocz));
	int k, indx, i=0;
	double X_re, X_im, Y_re, Y_im, t_re;
	for(indx = pocz ;indx<koniec; indx++){
		X_re= X0+ d_re*(indx%POZ);
		X_im= Y0+ (indx/POZ)*d_im;
		Y_re= X_re;
		Y_im= X_im;
		k=0;
		while(k<ITER & (Y_re*Y_re + Y_im*Y_im)<4){
			t_re = Y_re*Y_re-Y_im*Y_im+X_re;
			Y_im = 2*Y_re*Y_im+X_im;
			Y_re = t_re;
			k++;
		}
		colors[i]= k;
		i++;
	}
	MPI_Send(&rank, 1, MPI_INT, 0, RESULT_TAG,MPI_COMM_WORLD);
	MPI_Send(&koniec, 1, MPI_INT, 0, RESULT_TAG,MPI_COMM_WORLD);
	MPI_Send(colors, koniec-pocz, MPI_INT, 0, RESULT_TAG,MPI_COMM_WORLD);
}

void copya(int * Iters, int * col, int zakres){  //kopiuje tablice z wątku do tablicy wątku głównego
	for(int i =0; i< zakres; i++){
		Iters[i]= col[i];
	}
}

int main(int argc, char **argv) {
	//Ustal rozmiar w pikselach {POZ,PION} 
	int POZ = 1024; int PION = 1024; // rozmiary obrazka
	//Ustaw obszar obliczeń {X0,Y0} - lewy dolny róg
	double X0=-1.0;    double Y0=0.0;
	//{X1,Y1} - prawy górny róg
	double X1=-0.5;    double Y1=0.5;
	//Ustal liczbę iteracji próbkowania {ITER}
	int ITER=256;
	int *Iters = (int*) malloc(sizeof(int)*POZ*PION);
	int nProcesy, nProces;
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &nProcesy);
	MPI_Comm_rank(MPI_COMM_WORLD, &nProces);
	if(POZ<nProcesy)
		exit(1);
	int SIZE = POZ*PION;
	int zakres = SIZE/(nProcesy-1);

	double d_re = (X1-X0)/(POZ-1);
	double d_im = (Y1-Y0)/(PION-1);
	if(nProces == 0){
		int k, count=0;
		for(k = 1; k < nProcesy; k++)
		{
			MPI_Send(&zakres, 1, MPI_INT, k, DATA_TAG,MPI_COMM_WORLD);
			count++;
		}
		MPI_Status status;
		int rank, koniec;
		do{
			MPI_Recv(&rank , 1 , MPI_INT, MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
			MPI_Recv(&koniec , 1 , MPI_INT, rank, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
			int * colors = (int *) malloc(sizeof(int) * (koniec-(rank-1)*zakres));
			MPI_Recv(colors , koniec-(rank-1)*zakres , MPI_INT, rank, RESULT_TAG, MPI_COMM_WORLD, &status);
			//memcpy(Iters[(rank-1)*zakres], colors[0], sizeof(int)*((rank-1)*zakres-koniec));
			//memcpy(&Iters[(rank-1)*zakres], &colors[0], sizeof(int)*(koniec - (rank-1)*zakres));
			copya(&Iters[(rank-1)*zakres], colors, (koniec - (rank-1)*zakres));
			count--;
		}while(count > 0);
		write_png_file("mandelbrot.png", Iters, POZ, PION,ITER);
		printf("Proces 0 ukonczony\n");
	}
	else{
		worker(X0,Y0,d_re, d_im,POZ,PION,ITER);
	}
	MPI_Barrier(MPI_COMM_WORLD);
	MPI_Finalize();
	return 0;
}
