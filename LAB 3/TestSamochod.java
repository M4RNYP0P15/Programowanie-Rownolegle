import java.io.InputStream;
import java.util.Random;
import java.util.Scanner;

class Samochod extends Thread {
    private String nrRej;
    private int pojZbiornika;
    private int paliwo;
    Random rand = new Random();

    public Samochod(String nr, int _pojZbiornika) {
        nrRej = nr;
        pojZbiornika = _pojZbiornika;
        start1();
    }

    public void tankowanie(int _paliwo) {
        paliwo = (rand.nextInt() % pojZbiornika)+1;
        if(paliwo<0)
            paliwo=-paliwo;
        System.out.println("Tankowanie pojazdu");
    }

    public void start1() {
        tankowanie(rand.nextInt());
        System.out.println("Samochód zatankowany: " +paliwo);
    } //start samochodu, uruchamiamy wątek zużycia paliwa
    public void zatrzymaj(){
        this.stop();
    }

//    public void stop(){
//
//    } //zatrzymanie samochodu, zatrzymujemy wątek zużycia paliwa

    public void run() {
        while (paliwo>0){
            try {
                paliwo--;
                System.out.println(nrRej+" Ilość paliwa: "+paliwo+"/"+pojZbiornika);
                Thread.sleep(1000);
            } catch (Exception exception) {}
        }
    } //kod, który wykonuje się w odrębnym wątku, co 1 s programu zużywany jest 1 litr paliwa
}
public class TestSamochod {// symulacja działania klasy Samochod dla 1,2,3, ... samochodów
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.println("Podaj ilość pojazdów: ");
        int n=sc.nextInt();
        Samochod sam[]= new Samochod[n];
        for(int i =0;i<n; i++){
            sam[i] = new Samochod("BI AA32"+i, 100);
            sam[i].start();
        }
    }
}

