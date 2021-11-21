#include <stdio.h>
#include <stdlib.h>
#include <math.h>

float Leibniz(int n)
{
    float wynik = 0;
    float suma = 0;
    for (int i=1; i<=n; i++)
    {
        suma = pow(-1, i-1) / (2 * i - 1);
        wynik += suma;
    }
    return 4 * wynik;
}

int main ()
{
    int lp;
    printf("Podaj Ilość procesorów/wątków: ");
    
    scanf("%d", &lp);

    for(int i=0; i<lp; i++)
    {
        if(fork()==0)
        {
            srand(time(NULL) ^ (getpid()<<16));
            int n = 100 + rand()%5000+1;
            printf("<Leibniz> Przyblizenie liczby Pi wynosi %f  dla n=%d\n", Leibniz(n), n);
            exit(0);
        }
    }
}
