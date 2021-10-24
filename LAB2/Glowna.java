import java.util.Random;

public class Glowna {
    static int ilosc_uchodzcow =50;
    static int ilosc_furtek =5;
    static Exodus exodus;
    public Glowna(){}
    public static void main(String[] args) {
        exodus =new Exodus(ilosc_furtek, ilosc_uchodzcow);
        for(int i = 0; i< ilosc_uchodzcow; i++)
            new Uchodzca(i,1000, exodus).start();
    }
}

class Exodus {
    static int GRANICA_BIALORUS =1;
    static int WTARGNIECIE =2;
    static int EXODUS =3;
    static int GRANICA_NIEMCY =4;
    static int ZLAPANY =5;
    static int TEMPERATURA=20;
    int ilosc_furtek;
    int ilosc_zajetych;
    int ilosc_uchodzcow;
    Exodus(int ilosc_pasow, int ilosc_samolotow){
        this.ilosc_furtek =ilosc_pasow;
        this.ilosc_uchodzcow =ilosc_samolotow;
        this.ilosc_zajetych=0;
    }
    synchronized int start(int numer){
        ilosc_zajetych--;
        System.out.println("Wtargnięcie na teren Polski przez uchodźcę nr. "+numer);
        return WTARGNIECIE;
    }
    synchronized int przyjety(){
        try{
            Thread.currentThread().sleep(1000);//sleep for 1000 ms
        }
        catch(Exception ie){}
        if(ilosc_zajetych< ilosc_furtek){
            ilosc_zajetych++;
            System.out.println("Przyznano zasiłek uchodzcy "+ilosc_zajetych);
            return GRANICA_BIALORUS;  // kolejny uchodzca wchodzi na miejsce
        }
        else {return GRANICA_NIEMCY;}
    }
    synchronized void zmniejsz() {
        ilosc_uchodzcow--;
        //System.out.println("ZABILEM");
        if (ilosc_uchodzcow == ilosc_furtek)
            System.out.println("____ Ilość uchodźców taka sama jak ilość furtek ____");
    }
}

class Uchodzca extends Thread {
    static int GRANICA_BIALORUS = 1;
    static int START = 2;
    static int EXODUS = 3;
    static int GRANICA_NIEMCY = 4;
    static int ZLAPANY = 5;
    static int SZPITAL = 6;
    static int ZGON = 7;
    static int ZDROWY = 1000;
    static int POWAZNIE_CHORY = 200;
    static int POSTRZELONY = 200;

    int numer;
    int zycie;
    int stan;
    Exodus l;
    Random rand;

    public Uchodzca(int numer, int zycie, Exodus l) {
        this.numer = numer;
        this.zycie = zycie;
        this.stan = EXODUS;
        this.l = l;
        rand = new Random();
    }

    public void run() {
        while (true) {
            if (rand.nextInt(2) == 1) {
                l.TEMPERATURA-=rand.nextInt(2);
            }
            else{
                l.TEMPERATURA+=rand.nextInt(2);
            }

            if (stan == GRANICA_BIALORUS) {
                if (rand.nextInt(2) == 1) {
                    stan = START;
                    zycie = ZDROWY;
                    System.out.println("Zaczynam uciekać (uchodźca nr. " + numer+")");
                    stan = l.start(numer);
                } else {
                    System.out.println("Nie mam jak uciekać.");
                }
            } else if (stan == START) {
                System.out.println("Przez granicę przebiegł, uchodźca nr. " + numer);
                stan = EXODUS;
            } else if (stan == SZPITAL) {
                stan=GRANICA_BIALORUS;
                System.out.println("Deportowano uchodźcę nr."+numer);
            } else if (stan == EXODUS) {
                if(l.TEMPERATURA<8){
                    zycie-=100;
                    if(zycie<=0){
                        if (rand.nextInt(2) == 1) {
                            stan=ZGON;
                        }
                        else{
                            stan=SZPITAL;
                        }
                    }
                }else if (rand.nextInt(2) == 1) {
                    zycie -= rand.nextInt(500);
                    if (zycie <= POSTRZELONY) {
                        if (rand.nextInt(2) == 1) {
                            stan = GRANICA_BIALORUS;
                        }
                        else{
                            stan=SZPITAL;
                        }
                    }
                    else if(zycie <= POWAZNIE_CHORY) {
                        if (rand.nextInt(2) == 1) {
                            stan=ZGON;
                        }
                        else{
                            stan=SZPITAL;
                        }
                    }
                    else{
                    } try {
                        sleep(rand.nextInt(1000));
                    } catch (Exception e) {}
                } else {
                    System.out.println("Nie mam jak uciekać.");
                }
            } else if (stan == GRANICA_NIEMCY) {
                System.out.println("Prosze o zasiłek uchodźca nr. " + numer + " ilosc życia " + zycie+"/1000");
                if (zycie <= 0)
                    stan = ZLAPANY;
                else
                    stan = l.przyjety();
            } else if (stan == ZLAPANY) {
                System.out.println("ZŁAPANY uchodzca nr." + numer);
                l.zmniejsz();
            }else if (stan == ZGON) {
                System.out.println("Uchodzca umarł (wyziębienie lub rany postrzalowe)");
                l.zmniejsz();
            }
            }

        }
    }
}