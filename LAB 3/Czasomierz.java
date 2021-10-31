public class Czasomierz  extends Thread{
    public static void main(String[] args) {
        new Czasomierz().start();
    }

    @Override
    public void run() {
        int sec =0, min=0,hr=0;
        while (true){
            try{
                Thread.sleep(1000);
            }catch (Exception exception){}
            sec++;
            if(sec==60){
                min++;
                sec=0;
                if(min==60){
                    hr++;
                    min=0;
                    if (hr==24) hr=0;
                }
            }
            System.out.println("Czas:"+hr+":"+min+":"+sec);
        }
    }
}
