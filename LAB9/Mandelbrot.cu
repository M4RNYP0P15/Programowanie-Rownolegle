%%cu
#define NO_FREETYPE 

#include <math.h>
#include <chrono>
#include <iostream> 
using namespace std;
#include <sys/time.h>
#define real double

__global__ void cudaMandelbrot2D(real X0, real Y0, real X1, real Y1, int POZ, int PION, int ITER,int *Mandel ){
    int k;
    real X_re, X_im, Y_re, Y_im, d_re, d_im, t_re;
    int inx = blockIdx.x * blockDim.x + threadIdx.x;
    int iny = blockIdx.y * blockDim.y + threadIdx.y;
    // int stepx = gridDim.x * blockDim.x;
    // int stepy = gridDim.y * blockDim.y;
    d_re = (X1-X0)/(POZ-1);
    d_im = (Y1-Y0)/(PION-1);
    if(inx<PION && iny<POZ){
                X_re= X0+ d_re*iny;
                X_im = Y0+ inx*d_im;
                Y_re= X_re;
                Y_im= X_im;
                k=0;
                while(k<ITER & (Y_re*Y_re + Y_im*Y_im)<4){
                    t_re = Y_re*Y_re-Y_im*Y_im+X_re;
                    Y_im = 2*Y_re*Y_im+X_im;
                    Y_re = t_re;
                    k++;
                }
                Mandel[inx*POZ+iny]= k;

    }
    
}

void swap(double *p,double *q) {
   double t;
   t=*p; 
   *p=*q; 
   *q=t;
}

double srednia(int len, double *tab){
    double sum=0;
    for(int i =1;i<len; i++ ){
        sum+=tab[i]/(len-1);
    }
    return sum;
}

double min(int len, double *tab){
    double sum=tab[0];
    for(int i =1;i<len; i++ ){
        if(tab[i]<sum)
            sum=tab[i];
    }
    return sum;
}

void computeMandelbrot(real X0, real Y0, real X1, real Y1, int POZ, int PION, int ITER,int *Mandel ){
    int k;
    real X_re, X_im, Y_re, Y_im, d_re, d_im, t_re;

    d_re = (X1-X0)/(POZ-1);
    d_im = (Y1-Y0)/(PION-1);

    for(int i =0; i<PION; i++){
        for(int j =0; j<POZ; j++){
            X_re= X0+ d_re*j;
            X_im = Y0+ i*d_im;
            Y_re= X_re;
            Y_im= X_im;
            k=0;
            while(k<ITER & (Y_re*Y_re + Y_im*Y_im)<4){
                t_re = Y_re*Y_re-Y_im*Y_im+X_re;
                Y_im = 2*Y_re*Y_im+X_im;
                Y_re = t_re;
                k++;
            }
            Mandel[i*POZ+j]= k;
        }
    }
}

int main(int argc, char **argv) {
    //Ustaw obszar obliczeń {X0,Y0} - lewy dolny róg
    double X0=-1.0;    double Y0=0.0;
    //{X1,Y1} - prawy górny róg
	  double X1=-0.5;    double Y1=0.5;
    //Ustal rozmiar w pikselach {POZ,PION}
    int POZ=1000; int PION=1000;
    //Ustal liczbę iteracji próbkowania {ITER}
    int ITER=256;

    //Zaalokuj tablicę do przechowywania wyniku
    int *Iters = (int*) malloc(sizeof(int)*POZ*PION);

    int* Iters_gpu;

    cudaError_t status;

    status = cudaMalloc((void**)&Iters_gpu, sizeof(int)* POZ*PION);
    if(status!= cudaSuccess){ cout << cudaGetErrorString(status) << endl;}
    
    //printf("Computations for rectangle { (%lf %lf), (%lf %lf) }\n",X0,Y0,X1,Y1);
    int block_szer;
    int block_wys;
    int ile_iter=50;
    float dt_ms;
    double wyniki[ile_iter];
    cout << "2D" << endl;
    for(int i=8; i<=32;i*=2){
        block_szer = i;
        block_wys = i;

        dim3 threadPerBlock(block_szer,block_wys,1);
        dim3 numBlocks(POZ/block_szer+1,PION/block_wys+1,1);
        for(int ij=0;ij<ile_iter;ij++)
        {
            auto start2 = chrono::steady_clock::now(); 
            cudaMandelbrot2D<<<numBlocks,threadPerBlock,0>>>(X0,Y0,X1,Y1,POZ,PION,ITER,Iters_gpu);
            status = cudaMemcpy(Iters,Iters_gpu,sizeof(int)*POZ*PION, cudaMemcpyDeviceToHost);
            if(status != cudaSuccess){ cout << cudaGetErrorString(status) << endl;}

            auto stop = chrono::steady_clock::now();
            auto diff = stop - start2;

            //cout << chrono::duration <double, milli> (diff).count() << endl;
            wyniki[ij]=chrono::duration <double, milli> (diff).count();
        }
        cout << block_szer << "x" << block_wys << " Średnia: " << srednia(ile_iter, wyniki) << " Min: "<< min(ile_iter, wyniki)<< endl;
    }
    
    status = cudaFree(Iters_gpu);
    if(status != cudaSuccess){ cout << cudaGetErrorString(status) << endl;}
    int *Iters_cpu = (int*) malloc(sizeof(int)*POZ*PION);
    auto start2 = chrono::steady_clock::now();
    computeMandelbrot(X0,Y0,X1,Y1,POZ,PION,ITER,Iters_cpu);
     
    auto stop = chrono::steady_clock::now();
    auto diff = stop - start2;
    cout << "CPU czas :"<<chrono::duration <double, milli> (diff).count() << endl;
    cout << "Dla wymiaru obrazka:"<< POZ << "x" << PION <<endl;
   
    free(Iters);
}
