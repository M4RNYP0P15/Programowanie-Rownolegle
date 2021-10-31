import java.util.Scanner;
import java.util.concurrent.Semaphore;
import java.util.Random;

public class Filozofowie {
    public static void main(String[] args) {
        Scanner skan = new Scanner(System.in);
        System.out.println("Wybierz sposób rozwiązania\n 1.Pierwszy sposób\n 2.Drugi sposób\n 3.Trzeci sposób");
        int wybor= skan.nextInt();

        boolean a=false;
        int liczba=2;

        while(a==false){
            System.out.println("Podaj liczbe filozofów(min 2, max 100)");
            liczba = skan.nextInt();
            if(liczba >1 && liczba <101) a=true;
        }

        switch(wybor){
            case 1->{
                for ( int i =0; i<liczba; i++)
                    new Filozof1(i,liczba).start();
            }
            case 2->{
                for ( int i =0; i<liczba; i++)
                    new Filozof2(i,liczba).start();
            }
            case 3->{
                for ( int i =0; i<liczba; i++)
                    new Filozof3(i,liczba).start();
            }
        }
    }
}

class Filozof1 extends Thread {
    int MAX1;
    static Semaphore [] widelec1;
    int mojNum;
    public Filozof1 ( int nr, int max ) {
        mojNum=nr ;
        this.MAX1=max;
        widelec1 = new Semaphore [MAX1] ;
        for ( int i =0; i<MAX1; i++) {
            widelec1[i]=new Semaphore( 1 ) ;
        }
    }
    public void run() {
        while(true) {
// myslenie
            System.out.println("Mysle ¦ " + mojNum);
            try {
                Thread.sleep((long) (7000 * Math.random()));
            } catch (InterruptedException e) {}
            widelec1[mojNum].acquireUninterruptibly(); //przechwycenie L widelca
            widelec1[(mojNum + 1) % MAX1].acquireUninterruptibly(); //przechwycenie P widelca
// jedzenie
            System.out.println("Zaczyna jesc " + mojNum);
            try {
                Thread.sleep((long) (5000 * Math.random()));
            } catch (InterruptedException e) {}
            System.out.println("Konczy jesc " + mojNum);
            widelec1[mojNum].release(); //zwolnienie L widelca
            widelec1[(mojNum + 1) % MAX1].release(); //zwolnienie P widelca
        }
    }
}

class Filozof2 extends Thread {
    int MAX2;
    static Semaphore [] widelec2 ;
    int mojNum;
    public Filozof2 ( int nr, int max ) {
        mojNum=nr ;
        this.MAX2=max;
        widelec2 = new Semaphore [MAX2] ;
        for ( int i =0; i<MAX2; i++) {
            widelec2 [ i ]=new Semaphore( 1 ) ;
        }
    }
    public void run() {
        while(true) {
// myslenie
            System.out.println ( "Mysle ¦ " + mojNum) ;
            try {
                Thread.sleep ( ( long ) (5000 * Math.random( ) ) ) ;
            } catch ( InterruptedException e ) {}
            if (mojNum == 0) {
                widelec2 [ (mojNum+1)%MAX2].acquireUninterruptibly ( ) ;
                widelec2 [mojNum].acquireUninterruptibly ( ) ;
            } else {
                widelec2 [mojNum].acquireUninterruptibly ( ) ;
                widelec2 [ (mojNum+1)%MAX2].acquireUninterruptibly ( ) ;
            }
            System.out.println ( "Zaczyna jesc "+mojNum) ;
            try {
                Thread.sleep ( ( long ) (3000 * Math.random( ) ) ) ;
            } catch ( InterruptedException e ) {}
            System.out.println ( "Konczy jesc "+mojNum) ;
            widelec2 [mojNum].release ( ) ;
            widelec2 [ (mojNum+1)%MAX2].release ( ) ;
        }
    }
}

class Filozof3 extends Thread {
    int MAX3;
    static Semaphore [] widelec3  ;
    int mojNum;
    Random losuj ;
    public Filozof3 ( int nr, int max ) {
        mojNum=nr ;
        losuj = new Random(mojNum) ;
        this.MAX3=max;
        widelec3 = new Semaphore [MAX3] ;
        for ( int i =0; i<MAX3; i++) {
            widelec3 [ i ]=new Semaphore( 1 ) ;
        }
    }
    public void run () {
        while (true) {
            System.out.println ( "Mysle ¦ " + mojNum) ;
            try {
                Thread.sleep ( ( long ) (5000 * Math.random() ) ) ;
            } catch ( InterruptedException e ) {}
            int strona = losuj.nextInt ( 2 ) ;
            boolean podnioslDwaWidelce = false ;
            do {
                if ( strona == 0) {
                    widelec3 [mojNum].acquireUninterruptibly () ;
                    if( !( widelec3 [ (mojNum+1)%MAX3].tryAcquire () ) ) {
                        widelec3[mojNum].release() ;
                    } else {
                        podnioslDwaWidelce = true ;
                    }
                } else {
                    widelec3[(mojNum+1)%MAX3].acquireUninterruptibly () ;
                    if ( !(widelec3[mojNum].tryAcquire () ) ) {
                        widelec3[(mojNum+1)%MAX3].release() ;
                    } else {
                        podnioslDwaWidelce = true ;
                    }
                }
            } while ( podnioslDwaWidelce == false ) ;
            System.out.println ( "Zaczyna jesc "+mojNum) ;
            try {
                Thread.sleep ( (long) (3000 * Math.random() ) ) ;
            } catch ( InterruptedException e ) {}
            System.out.println ( "Konczy jesc "+mojNum) ;
            widelec3[mojNum].release();
            widelec3[ (mojNum+1)%MAX3].release();
        }
    }
}
