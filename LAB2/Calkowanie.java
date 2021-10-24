import java.util.Scanner;

public class Calkowanie {
    public static void main(String[] args) {
        double start, stop, dx;
        int n;
        Scanner scanin = new Scanner(System.in);
        System.out.println("Podaj przedzial calkowania: ");
        start = scanin.nextDouble(); //xp
        System.out.println("Podaj koniec przedzialu calkowania: ");
        stop = scanin.nextDouble(); // xk
        System.out.println("Podaj dokladnosc calkowania(n):");
        n = scanin.nextInt();
        System.out.println(start + " " + stop +" "+n);
        dx = (stop - start) / (double)n;
        System.out.println("Wybierz metodę:\n0-Simpson\n1-Prostokatow\n2-Trapezow");
        int metoda = scanin.nextInt();
        switch (metoda){
            case 0:
                M_Simpson klasa = new M_Simpson(start, stop, dx);
                try{
                    for (int a=1;a<n;a++){
                        Thread ai = new M_Simpson(a);
                        ai.start();
                        ai.join();
                    }
                }catch (InterruptedException ex){}
                klasa.licz();
                break;
            case 1:
                M_prostokatow klas = new M_prostokatow(start, stop, dx);
                try{
                    for (int a=1;a<=n;a++){
                        Thread ai = new M_prostokatow(a);
                        ai.start();
                        ai.join();
                    }
                }catch (InterruptedException ex){}
                klas.licz();
                break;
            case 2:
                M_trapezow kla = new M_trapezow(start, stop, dx);
                try{
                    for (int a=1;a<n;a++){
                        Thread ai = new M_trapezow(a);
                        ai.start();
                        ai.join();
                    }
                }catch (InterruptedException ex){}
                kla.licz();
                break;
        }
    }
}

class M_Simpson extends Thread{
    static double xk, xp, dx, calka, s;
    int n;
    double x;

    static double func(double x) {return x * x + 3;}
    public M_Simpson(double start, double stop, double dx){
        xk=stop;
        xp=start;
        this.dx = dx;
        s=func(xk - dx/2);
        calka=0;
    }
    public M_Simpson(int n){this.n=n;}

    public void licz(){
        calka = (dx/6) * (func(xp) + func(xk) + 2*calka + 4*s);
        System.out.println("Wynik = "+calka);
    }

    public void run(){
        x = xp + n*dx;
        s += func(x - dx / 2);
        calka += func(x);
        System.out.println("Wątek: " + Thread.currentThread().getId()+" : "+calka);
    }
}

class M_prostokatow extends Thread {
    static double xk, xp, dx, calka;
    int n;

    static double func(double x) {return x * x + 3;}
    public M_prostokatow(int n){this.n=n;}

    public M_prostokatow(double start, double stop, double dx){
        xk=stop;
        xp=start;
        this.dx = dx;
    }

    public void licz(){
        calka *= dx;
        System.out.println("Wynik = "+calka);
    }

    public void run(){
        calka += func(xp + n * dx);
        System.out.println("Wątek: "+n+" " + Thread.currentThread().getId()+" : "+calka);
    }
}

class M_trapezow extends Thread {
    static double xk, xp, dx, calka;
    int n;

    static double func(double x) {return x * x + 3;}

    public M_trapezow(int n){this.n=n;}

    public M_trapezow(double start, double stop, double dx){
        xk=stop;
        xp=start;
        this.dx = dx;
        calka=(func(xp) + func(xk)) / 2;
    }

    public void licz(){
        calka *= dx;
        System.out.println("Wynik = "+calka);
    }

    public void run(){
        calka += func(xp + n * dx);
        System.out.println("Wątek: " + Thread.currentThread().getId()+" : "+calka);
    }
}
