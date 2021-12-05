#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include "mpi.h"

#define REZERWA 500
#define GRANICA 1
#define START 2
#define EXODUS 3
#define DOTARLNIEMCY 4
#define ZGON 5
#define ZLAPANY 6
#define PIENIADZE 5000
int pieniadze_uchodzca = 5000;
short LADUJ=1, NIE_LADUJ=0;
int liczba_procesow;
int nr_procesu;
int ilosc_uchodzcow;
int ilosc_furtek=4;
int nr_furtek=0;
int tag=1;
int wyslij[2];
int odbierz[2];
MPI_Status mpi_status;
void Wyslij(int nr_imigranta, int stan){
    wyslij[0]=nr_imigranta;
    wyslij[1]=stan;
    MPI_Send(&wyslij, 2, MPI_INT, 0, tag, MPI_COMM_WORLD);
    sleep(1);
}
void Baza_uchodzcow(int liczba_procesow){
    int nr_imigranta, status;
    ilosc_uchodzcow = liczba_procesow - 1;
    printf("Witam serdecznie, tu straż graniczna\n");
    if(rand()%2==1){
        printf("Mamy piekna pogode sprzyjajaca nielegalnym przekroczeniom granicy.\n");
    }
    else{
        printf("Niestety pogoda nie sprzyja imigrantom.\n");
    }
    printf("Zyczymy Panstwu, przyjemnej ucieczki \n \n");
    printf("Wykrylismy %d furtek umozliwiajacych przekroczenie granicy\n", ilosc_furtek);
    sleep(2);
    while(ilosc_furtek<=ilosc_uchodzcow){
        MPI_Recv(&odbierz,2,MPI_INT,MPI_ANY_SOURCE,tag,MPI_COMM_WORLD, &mpi_status);
        nr_imigranta=odbierz[0];
        status=odbierz[1];
        if(status==1){
            printf("Uchodzca %d stoi na granicy.\n", nr_imigranta);
        }
        if(status==2){
            printf("Uchodzca %d wtargnięcie przez furtkę nr %d\n", nr_imigranta, nr_furtek);
            nr_furtek--;
        }
        if(status==3){
            printf("Uchodzca %d brawurowo kroczy po terytorium państwa 'Polskiego' w celu dostania się do 'Niemieckiej' granicy\n", nr_imigranta);
        }
        if(status==4){
            if(nr_furtek<ilosc_furtek){
                nr_furtek++;
            }
        }
        if(status==5){
            ilosc_uchodzcow--;
            printf("Ilosc uchodzcow %d\n", ilosc_uchodzcow);
        }
		if(status==6){
            printf("Ilosc uchodzcow %d\n", ilosc_uchodzcow);
        }
    }
    printf("Wszyscy imigranci wkroczyli na terytorium polski\n");
}
void Uchodzca_nowy(){
    int stan,suma,i;
    stan=EXODUS;
    while(1){
        if(stan==1){
            if(rand()%2==1){
                stan=START;
                pieniadze_uchodzca=PIENIADZE;
                printf("Próbuję przeciąć drut kolczasty, uchodzca %d\n",nr_procesu);
                Wyslij(nr_procesu,stan);
            }
            else{
                Wyslij(nr_procesu,stan);
            }
        }
        else if(stan==2){
            printf("Uciekam, uchodzca %d\n",nr_procesu);
            stan=EXODUS;
            Wyslij(nr_procesu,stan);
        }
        else if(stan==3){
            pieniadze_uchodzca-=rand()%500;
            if(pieniadze_uchodzca<=REZERWA){
                stan=DOTARLNIEMCY;
                printf("Prosze o azyl (w Niemczech)\n");
                Wyslij(nr_procesu,stan);
            }
            else{
                for(i=0; rand()%10000;i++);
            }
        }
        else if(stan==4){
			srand(nr_procesu*10);
            if(rand()%3!=1){
                stan=GRANICA; // inny uchodzca przejmuje po poprzednim numer ;D
                printf("Otrzymalem zasilek w Niemczech, uchodzca %d\n", nr_procesu);
            }
            else{
                pieniadze_uchodzca-=rand()%500;  // łapówki itd ;D
                if(pieniadze_uchodzca>0){
                    Wyslij(nr_procesu,stan);
                }
                else{
                    stan=ZGON;
                    printf("%d umarłem\n", nr_procesu); // brak chętnych przejęcia miejsca po zmarłym
                    Wyslij(nr_procesu,stan);
                    return; 
                }
            }
        }
		else if(stan==6){
                stan=GRANICA; // uchodzca wraca na początek ;D
                printf("Ekstradycja spowrotem na granicę, uchodzca %d\n", nr_procesu);
        }
    }
}
int main(int argc, char *argv[])
{
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&nr_procesu);
    MPI_Comm_size(MPI_COMM_WORLD,&liczba_procesow);
    srand(time(NULL));
    if(nr_procesu == 0)
        Baza_uchodzcow(liczba_procesow);
    else
        Uchodzca_nowy();
    MPI_Finalize();
    return 0;
}