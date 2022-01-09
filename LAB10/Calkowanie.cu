//%%cu
#include <cooperative_groups.h>
#include <iostream>
using namespace std;
namespace cg = cooperative_groups;


#define H_ERR(a)\
{\
    cudaError_t status = a;\
    if(status!= cudaSuccess){ printf("%s", cudaGetErrorString(status)); exit(0);}\
}

inline double funcc(double x){
    return 3*x*x-6*x+5;
}

inline __device__ double func(double x){
    return 3*x*x-6*x+5;
}

bool isPow2(unsigned int x) { return ((x & (x - 1)) == 0); }

template <unsigned int blockSize, bool nIsPow2>
__global__ void redukcja7(unsigned int n, double *g_idata, double *g_odata) {
  cg::thread_block cta = cg::this_thread_block();
  //double *sdata = SharedMemory<double>();
  extern __shared__ double sdata[];

  unsigned int tid = threadIdx.x;
  unsigned int gridSize = blockSize * gridDim.x;

  double mySum = 0;

  // we reduce multiple elements per thread.  The number is determined by the
  // number of active thread blocks (via gridDim).  More blocks will result in a larger gridSize and therefore fewer elements per thread
  if (nIsPow2) {
    unsigned int i = blockIdx.x * blockSize * 2 + threadIdx.x;
    gridSize = gridSize << 1;

    while (i < n) {
      mySum += g_idata[i];
      if ((i + blockSize) < n) {
        mySum += g_idata[i + blockSize];
      }
      i += gridSize;
    }
  } else {
    unsigned int i = blockIdx.x * blockSize + threadIdx.x;
    while (i < n) {
      mySum += g_idata[i];
      i += gridSize;
    }
  }

  sdata[tid] = mySum;
  cg::sync(cta);

  if ((blockSize >= 512) && (tid < 256)) {  sdata[tid] = mySum = mySum + sdata[tid + 256];  }

  cg::sync(cta);

  if ((blockSize >= 256) && (tid < 128)) {   sdata[tid] = mySum = mySum + sdata[tid + 128]; }

  cg::sync(cta);

  if ((blockSize >= 128) && (tid < 64)) { sdata[tid] = mySum = mySum + sdata[tid + 64]; }

  cg::sync(cta);

  cg::thread_block_tile<32> tile32 = cg::tiled_partition<32>(cta);

  if (cta.thread_rank() < 32) {
    // Fetch final intermediate sum from 2nd warp
    if (blockSize >= 64) mySum += sdata[tid + 32];
    for (int offset = tile32.size() / 2; offset > 0; offset /= 2) {
      mySum += tile32.shfl_down(mySum, offset);
    }
  }

  if (cta.thread_rank() == 0) g_odata[blockIdx.x] = mySum;
}

__global__ void M_Trapezow(double a, double b, double dx, int n, double * wyniki){
    unsigned int g_x = blockIdx.x*blockDim.x+ threadIdx.x;
    if(g_x == 0){
        wyniki[g_x] = dx*(func(a)+func(b))/2.0;
        //wyniki[g_x] =1;
    }
    if(g_x > 0 && g_x< n-1){
        wyniki[g_x] = func(a+g_x*dx)*dx;
        //wyniki[g_x] =1;
    }
}

__global__ void M_Prostokatow(double a, double b, double dx, int n, double * wyniki){
    unsigned int g_x = blockIdx.x*blockDim.x+ threadIdx.x;
    if(g_x == 0){
        wyniki[g_x] = 0;
    }
    if(g_x > 0 && g_x<= n){
        wyniki[g_x] = func(a + g_x*dx)*dx;
    }
}

__global__ void M_Simpson(double a, double b, double dx, int n, double * wyniki, double *swyn){
    unsigned int g_x = blockIdx.x*blockDim.x+ threadIdx.x;
    if(g_x == 0){
        swyn[g_x] = func(b - dx / 2);
    }
    if(g_x > 0 && g_x< n){
        wyniki[g_x] = func(a + g_x*dx);
        swyn[g_x] = func((a + g_x*dx) - dx/2);
    }
}

double Sumuj(int SIZE, double * inputDoSum){
    double* buffer1;
    double* buffer2;
    double* buf_in;
    double* buf_out;
    double* tmp_buf;
    double* buf;
    int Blocks_red = 128;
    double* result_host;
    unsigned int buf_size = (SIZE-1)/Blocks_red+1;
    H_ERR( cudaMalloc ((void**)&buffer1 ,buf_size * sizeof(double))    );
    H_ERR( cudaMallocHost( (void**) &result_host , 1 * sizeof(double))  );
    H_ERR( cudaMalloc ((void**)&buffer2 ,(buf_size/Blocks_red +1) * sizeof(double))    );
    H_ERR( cudaMalloc ((void**)&buf ,1 * sizeof(double))    );
    // buf_size = (SIZE-1)/Blocks_red+1;
    //GridSize = (n-1)/Blocks_red +1; // Dobry wynik dla SIZE >1
    long int GridSize = ((SIZE+Blocks_red-1))/Blocks_red;
    long int MySize = SIZE;
    buf_in = inputDoSum;
    buf_out = buffer1;

    if (isPow2(GridSize)) {
        switch (Blocks_red){
            case 512:
            redukcja7<512, true><<<GridSize/2,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
            case 256:
            redukcja7<256, true><<<GridSize/2,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
            case 128:
            redukcja7<128, true><<<GridSize/2,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
        }
    }else
    {
        switch (Blocks_red){
            case 512:
            redukcja7<512, false><<<GridSize,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
            case 256:
            redukcja7<256, false><<<GridSize,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
            case 128:
            redukcja7<128, false><<<GridSize,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
        }
    }

    // Przygotowanie do wejścia do pętli
    buf_in = buffer1;
    buf_out = buffer2;
    MySize=GridSize;
    //GridSize = (GridSize-1)/Blocks_red +1; 
    GridSize = (GridSize+Blocks_red-1)/Blocks_red;
    while (GridSize >1 ) { 
        if (isPow2(GridSize)) {
            switch (Blocks_red){
                case 512:
                redukcja7<512, true><<<GridSize/2,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
                case 256:
                redukcja7<256, true><<<GridSize/2,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
                case 128:
                redukcja7<128, true><<<GridSize/2,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
                }
                break;
        }
        else{
            switch (Blocks_red){
                case 512:
                redukcja7<512, false><<<GridSize,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
                case 256:
                redukcja7<256, false><<<GridSize,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
                case 128:
                redukcja7<128, false><<<GridSize,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
                }
            break;
            }
        // Zamieniamy miejscami bufory robocze
        tmp_buf = buf_in;
        buf_in = buf_out;
        buf_out = tmp_buf;
        // 
        MySize=GridSize;
        //GridSize = (GridSize-1)/Blocks_red +1;
        GridSize = (GridSize+Blocks_red-1)/Blocks_red;
    }
    buf_out = buf;
    if (isPow2(GridSize)) {
        switch (Blocks_red){
            case 512:
                redukcja7<512, true><<<GridSize,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
            case 256:
                redukcja7<256, true><<<GridSize,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
            case 128:
                redukcja7<128, true><<<GridSize,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
        }
    }
    else
    {
        switch (Blocks_red)
        {
            case 512:
                redukcja7<512, false><<<GridSize,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
            case 256:
                redukcja7<256, false><<<GridSize,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
            case 128:
                redukcja7<128, false><<<GridSize,Blocks_red,Blocks_red*sizeof(double) >>>(MySize, buf_in, buf_out); break;
        }
    }
    H_ERR( cudaMemcpy( result_host, buf, 1*sizeof(double), cudaMemcpyDeviceToHost)    );
    //printf("%lf \n", result_host[0]);
    return result_host[0];
}

int main(int argc, char **argv)
{
    double xp,xk;
    long int n;
    int blocks = 1;
    int threads;
    //dim3 threadsPerBlock(128,1,1);
    //dim3 numBlocks((n)/threadsPerBlock.x+1,1,1);
    // printf("Podaj poczatek przedzialu calkowania\n");
    // scanf("%f", &xp);
    // printf("Podaj koniec przedzialu calkowania\n");
    // scanf("%f", &xk);
    float exec_time;

    xp=1.0;
    xk=2.0;
    printf("Przedzial xp: %lf, xk: %lf\n", xp, xk);
    // printf("Podaj dokladnosc calkowania\n");
    // scanf("%d", &n);

    n = 10000;
    printf("%ld\n", n);
    double dx = (xk - xp)/(float)n;
    double* wyniki_c;
    double* s_wyniki;
    double s;
    double calka;
    cudaEvent_t event1, event2;
    cudaEventCreate(&event1);
    cudaEventCreate(&event2);
    
    H_ERR( cudaMalloc ((void**)&wyniki_c, n*sizeof(double))    );
    H_ERR( cudaMalloc ((void**)&s_wyniki, n*sizeof(double))    );
    if(n>1024){
        blocks = (n + 1023)/1024;
        threads = 1024;
    }else{
        threads = n;
    }
    //////////////// Trapezy ////////////
    cudaEventRecord(event1, 0);
    M_Trapezow<<<blocks, threads, 0>>>(xp, xk, dx, n, wyniki_c);
    H_ERR(  cudaDeviceSynchronize() ); 
    // wstawić sumowanie tablicy na GPU
    calka = Sumuj(n, wyniki_c);
    
    
    cudaEventRecord(event2,0);
    cudaEventSynchronize(event2);
    cudaEventElapsedTime(&exec_time, event1, event2);
    printf("Wynik metoda trapezow: %f \t czas: %f \n", calka, exec_time);
    /////////////// Prostokaty ///////////////
    cudaEventRecord(event1, 0);
    M_Prostokatow<<<blocks, threads, 0>>>(xp, xk, dx, n, wyniki_c);
    H_ERR(  cudaDeviceSynchronize() ); 
    // wstawić sumowanie wynikic
    calka = Sumuj(n, wyniki_c);

    cudaEventRecord(event2,0);
    cudaEventSynchronize(event2);
    cudaEventElapsedTime(&exec_time, event1, event2);
    printf("Wynik metoda prostokatow: %f  \t czas: %f\n", calka, exec_time);

    ////////// Simpson ////////////////

    cudaEventRecord(event1, 0);
    M_Simpson<<<blocks, threads, 0>>>(xp, xk, dx, n, wyniki_c, s_wyniki);
    H_ERR(  cudaDeviceSynchronize() ); 
    // wstawić sumowanie wynikic i swyniki
    calka = Sumuj(n, wyniki_c);
    s = Sumuj(n, s_wyniki);
    cudaEventRecord(event2,0);
    cudaEventSynchronize(event2);
    cudaEventElapsedTime(&exec_time, event1, event2);
    printf("Wynik metoda simpsona: %f \t czas: %f\n", ( (dx/6) * (funcc(xp) + funcc(xk) + 2*calka + 4*s)), exec_time );
}
