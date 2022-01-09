#include <stdio.h>
#include <stdlib.h>
#include <chrono>
#include <iostream> 
using namespace std;

double func(float x)
{
	return 3*x*x-6*x+5;
}

double M_Trapezow(float a, float b, int n)
{
    double calka = 0;
    float dx = (b-a)/n;

    for (int i=1; i<=n-1; i++)
    {
	calka += func(a+i*dx);
    }
	
	calka += (func(a)+func(b))/2;
	calka *= dx;
    return calka;
}

double M_Prostokatow(float xp, float xk, int n)
{
    double calka = 0;
    double dx = (xk - xp) / (float)n;
 
    for (int i=1; i<=n; i++) {
    calka += func(xp + i * dx);
    }
    calka *= dx;
    return calka;
}

double M_Simpson(float xp, float xk, int n)
{
    double calka = 0;
    double s, x;
    int i;
    double dx = (xk - xp) / (float)n;

    s = 0;
    for (i=1; i<n; i++) {
        x = xp + i*dx;
        s += func(x - dx / 2);
        calka += func(x);
    }
    s += func(xk - dx / 2);
    calka = (dx/6) * (func(xp) + func(xk) + 2*calka + 4*s);
    
    return calka;
}

int main(int argc, char **argv)
{
    int xp,xk,n;
    // printf("Podaj poczatek przedzialu calkowania\n");
    // scanf("%f", &xp);
    
    // printf("Podaj koniec przedzialu calkowania\n");
    // scanf("%f", &xk);

    xp=1;
    xk=2;
    // printf("Ilosc procesow: "); 
    // int procesy;
    // scanf("%d", &procesy);

    printf("Podaj dokladnosc calkowania\n");
    scanf("%d", &n);

    printf("Przedzial xp: %d, xk: %d\n", xp, xk);
    double trapezy, prostokaty, simpson;
    ///Trapezy
    auto start2 = chrono::steady_clock::now();
    trapezy = M_Trapezow(xp, xk, n);
    auto stop = chrono::steady_clock::now();
    auto diff = stop - start2;
    cout << "Wynik metoda trapezow: " << trapezy << " :" << chrono::duration <double, milli> (diff).count() << " ms" << endl;
    //Prostokaty
    start2 = chrono::steady_clock::now();
    prostokaty = M_Prostokatow(xp, xk, n);
    stop = chrono::steady_clock::now();
    diff = stop - start2;
    cout << "Wynik metoda prostokatow: " << prostokaty << " :" << chrono::duration <double, milli> (diff).count() << " ms" << endl;
    //Simpson
    start2 = chrono::steady_clock::now();
    simpson = M_Simpson(xp, xk, n);
    stop = chrono::steady_clock::now();
    diff = stop - start2;
    cout << "Wynik metoda simpsona: " << simpson << " :" << chrono::duration <double, milli> (diff).count() << " ms" << endl;
}
