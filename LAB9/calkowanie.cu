#include <iomanip>
#include <iostream>
#include <cstdlib>
#include <chrono>

using namespace std;
//  mialem liczyc na karcie graficznej (device) ale wyniki się różniły o mw 0,003 - 0,008
template <typename T,unsigned int blockSize>
__device__ void warpReduce(volatile T *sdata, unsigned int tid) {
    if (blockSize >= 64) sdata[tid] += sdata[tid + 32];
    if (blockSize >= 32) sdata[tid] += sdata[tid + 16];
    if (blockSize >= 16) sdata[tid] += sdata[tid + 8];
    if (blockSize >= 8) sdata[tid] += sdata[tid + 4];
    if (blockSize >= 4) sdata[tid] += sdata[tid + 2];
    if (blockSize >= 2) sdata[tid] += sdata[tid + 1];
}
template <typename T,unsigned int blockSize>
__global__ void reduce6(T *g_idata, T *g_odata, unsigned int n) {
    extern __shared__ T sdata[];
    unsigned int tid = threadIdx.x;
    unsigned int i = blockIdx.x*(blockSize*2) + tid;
    unsigned int gridSize = blockSize*2*gridDim.x;
    sdata[tid] = 0;
    while (i < n) { 
        sdata[tid] += g_idata[i] + g_idata[i+blockSize]; 
        i += gridSize; 
    }
    
    __syncthreads();
    //printf("gridDim: %d i: %d tid[%d]: %lf\n",gridDim.x,i, tid, sdata[tid]);
    if (blockSize >= 512) { if (tid < 256) { sdata[tid] += sdata[tid + 256]; } __syncthreads(); }
    if (blockSize >= 256) { if (tid < 128) { sdata[tid] += sdata[tid + 128]; } __syncthreads(); }
    if (blockSize >= 128) { if (tid < 64) { sdata[tid] += sdata[tid + 64]; } __syncthreads(); }
    if (tid < 32) warpReduce<T,blockSize>(sdata, tid);
    if (tid == 0) g_odata[blockIdx.x] = sdata[0];
}

__device__ double f(double x) { return(x * x + 2 * x); }

__global__ void licz(long long N, double xp, double dx, double * pTab){
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if(tid<=N) pTab[tid]=f(xp + tid * dx)*dx;
}

int main()
{
  int N = 3000; //liczba punktów/prostokątów podziałowych / liczba watkow
  double xp,xk,dx;
  double * pGPU;
//   double * pOGPU;

  cout << setprecision(3) << fixed;   // 3 cyfry po przecinku ; format stałoprzecinkowy
  cout << "Obliczanie  calki oznaczonej za pomoca metody prostokatow\n"
          "f(x) = x * x + 2 * x\n"
          "Podaj poczatek przedzialu calkowania\n"
          "xp = 1";
  //cin >> xp;
  xp=1.0;
  cout << "\nPodaj koniec przedzialu calkowania\n"
          "xk = 2";
  //cin >> xk;
  xk=2.0;
  cout << "\nPodaj dokladnosci calkowania\n"
          "n = ";
    cin >> N;
  cout << endl;


  dx = (xk - xp) / N;
  int threads = 128;
  long blocks = (N+threads-1)/threads;
//   int Ni = ((N+threads-1)/threads)/2;
    double sumaCPU=0;

  double *Iters = (double*) malloc(sizeof(double)*N+1);
//   double *Iters_cop = (double*) malloc(sizeof(double)*Ni);

  cudaMalloc((void**)&pGPU, sizeof(double)* N+1);
//   cudaMalloc((void**)&pOGPU, sizeof(double)* Ni);
    auto start2 = chrono::steady_clock::now();
  licz<<<blocks, threads>>>(N, xp, dx, pGPU);
  cudaMemcpy(Iters, pGPU, N* sizeof(double), cudaMemcpyDeviceToHost);

    // dim3 dimBlock(threads, 1, 1);
    // dim3 dimGrid(blocks/2, 1, 1);

    // when there is only one warp per block, we need to allocate two warps
    // worth of shared memory so that we don't index shared memory out of bounds
    // int smemSize = (threads <= 32) ? 2 * threads * sizeof(double) : threads * sizeof(double);
    // switch (threads) {
    //     case 512:
    //       reduce5<512> <<<dimGrid, dimBlock, smemSize>>>(pGPU, pOGPU, N);
    //       break;

    //     case 256:
    //       reduce5<256>
    //           <<<dimGrid, dimBlock, smemSize>>>(pGPU, pOGPU, N);
    //       break;

    //     case 128:
        //   reduce6<double, 128> <<<dimGrid, dimBlock, smemSize>>>(pGPU, pOGPU, N);
    //       break;

    //     case 64:
    //       reduce5<64>
    //           <<<dimGrid, dimBlock, smemSize>>>(pGPU, pOGPU, N);
    //       break;

    //     case 32:
    //       reduce5<32>
    //           <<<dimGrid, dimBlock, smemSize>>>(pGPU, pOGPU, N);
    //       break;

    //     case 16:
    //       reduce5<16>
    //           <<<dimGrid, dimBlock, smemSize>>>(pGPU, pOGPU, N);
    //       break;

    //     case 8:
    //       reduce5<8>
    //           <<<dimGrid, dimBlock, smemSize>>>(pGPU, pOGPU, N);
    //       break;

    //     case 4:
    //       reduce5<4>
    //           <<<dimGrid, dimBlock, smemSize>>>(pGPU, pOGPU, N);
    //       break;

    //     case 2:
    //       reduce5<2>
    //           <<<dimGrid, dimBlock, smemSize>>>(pGPU, pOGPU, N);
    //       break;

    //     case 1:
    //       reduce5<1>
    //           <<<dimGrid, dimBlock, smemSize>>>(pGPU, pOGPU, N);
    //       break;
    //   }
//   cudaDeviceSynchronize();
//   cudaMemcpy(Iters_cop, pOGPU, Ni* sizeof(double), cudaMemcpyDeviceToHost);

//   cudaMemcpy (&s, pOGPU, 1 * sizeof(double), cudaMemcpyDeviceToHost);
  
    for(int h=1;h<=N;h++) sumaCPU+=Iters[h];

    auto stop = chrono::steady_clock::now();
  auto diff = stop - start2;
    cout << chrono::duration <double, milli> (diff).count() << endl;
    printf("\nSuma GPU: %lf\n", sumaCPU);
//   cout << "Wartosc calki wynosi : " << setw(8) << s << endl;
    // double suma=0;
    // for(int h=0;h<Ni;h++){
    //     suma+=Iters_cop[h];
    //     printf("[%lf]\n", Iters_cop[h]);
    // }
    // printf("%f\n", suma);
  return 0;
}


