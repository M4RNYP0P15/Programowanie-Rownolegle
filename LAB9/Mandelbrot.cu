#define NO_FREETYPE 

#include <math.h>
#include <chrono>
#include <iostream> 
using namespace std;
#include <sys/time.h>
#define real double

__global__ void redukcja1 (long long N, int* v, long long* out, int blockSize)  // N wielkość tablicy wejściowej; v- tablica wejsciowa(z której liczymy) ; out -...
{
 size_t s = threadIdx.x + blockIdx.x * blockDim.x; // indeks globalny wątku
 int sID = threadIdx.x;  // indeks lokalny wątku 
 size_t i;

 __shared__ long long pom[1024]; // deklatujemy tablice pomocniczną w pamięci współdzielonej
 
 if (s<N)  // sprawdzamy czy indeks globalny jest mniejszy od wielkosci tablicy wejsciowej
	pom[sID] = v[s]; // przypisanie do tablicy pomocnicznej o indeksie watku lokalnego elementu z tablicy wejciowej o indeksie watku globalnego
 else 
    pom[sID] = 0;

 __syncthreads(); // czekamy az wszystkie watki w bloku dotra do tego miejsca

 for (i=1; i<blockSize; i*=2){
    int ad = 2*i*sID;
 	if (ad<blockSize){
		pom[ad] += pom[ad + i];
 	}		
 	__syncthreads();
 }
 if (sID==0) out[blockIdx.x] = pom[0];  // na koniec przypisujemy w tablicy out ( o indeksach bloku) 
}

__global__ void redukcja (int N, long long* v, long long* out, int blockSize)  // N wielkość tablicy wejściowej; v- tablica wejsciowa(z której liczymy) ; out -...
{
 size_t s = threadIdx.x + blockIdx.x * blockDim.x; // indeks globalny wątku
 int sID = threadIdx.x;  // indeks lokalny wątku 
 size_t i;

 __shared__ long long pom[1024]; // deklatujemy tablice pomocniczną w pamięci współdzielonej
 
 if (s<N)  // sprawdzamy czy indeks globalny jest mniejszy od wielkosci tablicy wejsciowej
	pom[sID] = v[s]; // przypisanie do tablicy pomocnicznej o indeksie watku lokalnego elementu z tablicy wejciowej o indeksie watku globalnego
 else 
    pom[sID] = 0;

 __syncthreads(); // czekamy az wszystkie watki w bloku dotra do tego miejsca

 for (i=1; i<blockSize; i*=2){
    int ad = 2*i*sID;
 	if (ad<blockSize){
		pom[ad] += pom[ad + i];
 	}		
 	__syncthreads();
 }
 if (sID==0) out[blockIdx.x] = pom[0];  // na koniec przypisujemy w tablicy out ( o indeksach bloku) 
}

__global__ void cudaMandelbrot(real X0, real Y0, real X1, real Y1, int POZ, int PION, int ITER,int *Mandel ){
    int indx = blockIdx.x * blockDim.x + threadIdx.x;
    int k;
    int SIZE = POZ*PION;
    double X_re, X_im, Y_re, Y_im, d_re, d_im, t_re;

    d_re = (X1-X0)/(POZ-1);
    d_im = (Y1-Y0)/(PION-1);
    if(indx<SIZE){
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
        Mandel[indx]= k;
    }
}

double srednia(int len, double *tab){
    double sum=0;
    for(int i =1;i<len; i++ ){
        sum+=tab[i]/(len-1);
    }
    return sum;
}

long long computeMandelbrot(real X0, real Y0, real X1, real Y1, int POZ, int PION, int ITER,int *Mandel ){
    int k;
    long long SUM=0;
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
            SUM+=k;
        }
    }
    return SUM;
}

int main(int argc, char **argv) {
    //Ustaw obszar obliczeń {X0,Y0} - lewy dolny róg
    double X0=-1.0;    double Y0=0.0;
    //{X1,Y1} - prawy górny róg
	double X1=-0.5;    double Y1=0.5;
    //Ustal liczbę iteracji próbkowania {ITER}
    int ITER=256;

    int* Iters_gpu;
    int POZ, PION;

    int ile_iter=50;
    double wyniki[ile_iter];
    dim3 threadPerBlock(1024,1,1);
    cudaError_t status;
    for(int ik =1; ik<=10; ik++){
        
        POZ=1000*ik; PION=1000*ik; //Ustal rozmiar w pikselach {POZ,PION}
        cout << "Dla wymiaru obrazka:"<< POZ << "x" << PION <<endl;
        int *Iters = (int*) malloc(sizeof(int)*POZ*PION); //Zaalokuj tablicę do przechowywania wyniku

        status = cudaMalloc((void**)&Iters_gpu, sizeof(int)* POZ*PION);
        if(status!= cudaSuccess){ cout << cudaGetErrorString(status) << endl;}
        
        dim3 numBlocks(PION*POZ/threadPerBlock.x+1,1,1);
        for(int ij=0;ij<ile_iter;ij++)
        {
            auto start2 = chrono::steady_clock::now(); 
            cudaMandelbrot<<<numBlocks,threadPerBlock>>>(X0,Y0,X1,Y1,POZ,PION,ITER,Iters_gpu);
            cudaMemcpy(Iters, Iters_gpu, sizeof(int)*POZ*PION, cudaMemcpyDeviceToHost);
            auto stop = chrono::steady_clock::now();
            auto diff = stop - start2;
            
            // cout << chrono::duration <double, milli> (diff).count() << endl;
            wyniki[ij]=chrono::duration <double, milli> (diff).count();
        }
        cout << "Średnia: " << srednia(ile_iter, wyniki) << endl;
    }

    // int blockSize = 128;
    //   size_t N = POZ*PION;
    //   int blocks = (N + blockSize-1) / blockSize;
    //   int blocks1 = (blocks + blockSize-1) / blockSize;

    //     long long* outV;
    //     cudaMalloc( (void**) &outV, blocks * sizeof(long long) );
    //     long long* outV1;
    //     cudaMalloc( (void**) &outV1, blocks1 * sizeof(long long) );
    //     long long out;

    //         redukcja1 <<<blocks, blockSize>>>(POZ*PION,Iters_gpu, outV, blockSize);
    //         blocks1 = (blocks + blockSize-1) / blockSize;
    //         while(blocks1 > 0){
    //             //printf("blocks: %d  1: %d \n", blocks, blocks1);
    //             redukcja<<<blocks1, blockSize>>> (blocks, outV, outV1, blockSize);
    //             blocks = blocks1;
    //             blocks1 = (blocks1 + blockSize-1) / blockSize;
    //             redukcja<<<blocks1, blockSize>>> (blocks, outV1, outV, blockSize);
    //             if(blocks1 == 1) break;
    //             blocks = blocks1;
    //             blocks1 = (blocks1 + blockSize-1) / blockSize;
    //         }
    //     cudaDeviceSynchronize();

    //     cudaMemcpy (&out, outV, 1 * sizeof(long long), cudaMemcpyDeviceToHost);
    //     printf ("GPU wynik %lld; \n", out);

    // status = cudaFree(Iters_gpu);
    // if(status != cudaSuccess){ cout << cudaGetErrorString(status) << endl;}
    // int *Iters_cpu = (int*) malloc(sizeof(int)*POZ*PION);
    // auto start1 = chrono::steady_clock::now();
    // long long SUMA_CPU = computeMandelbrot(X0,Y0,X1,Y1,POZ,PION,ITER,Iters_cpu);
     
    // auto stop1 = chrono::steady_clock::now();
    // auto diff1 = stop1 - start1;
    // cout << "CPU czas :"<<chrono::duration <double, milli> (diff1).count() <<" Suma:"<< SUMA_CPU << endl;
    
   
    //free(Iters);
}
