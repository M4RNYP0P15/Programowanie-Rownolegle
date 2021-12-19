#define NO_FREETYPE 

#include <math.h>
#include <chrono>
#include <iostream> 
using namespace std;
#include <sys/time.h>
#define real double

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
    //Ustal liczbę iteracji próbkowania {ITER}
    int ITER=256;

    int POZ, PION;

    for(int ik =1; ik<=10; ik++){
        
        POZ=1000*ik; PION=1000*ik; //Ustal rozmiar w pikselach {POZ,PION}
        cout << "Dla wymiaru obrazka:"<< POZ << "x" << PION <<endl;
        int *Iters = (int*) malloc(sizeof(int)*POZ*PION); //Zaalokuj tablicę do przechowywania wyniku
            auto start2 = chrono::steady_clock::now(); 
            computeMandelbrot(X0,Y0,X1,Y1,POZ,PION,ITER,Iters);
            auto stop = chrono::steady_clock::now();
            auto diff = stop - start2;
            
        cout << chrono::duration <double, milli> (diff).count() << endl;
    }
}
