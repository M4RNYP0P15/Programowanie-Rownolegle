import java.util.Scanner;

public class MonteCarlo extends Thread { // pole koła = Pi*r^2
    static int k=0;
    double x,y;

    public static void main(String[] args) {
        Scanner klaw=new Scanner(System.in);
        System.out.print("n = ");
        int n=klaw.nextInt();
        try{
            for(int i =0;i<n; i++){
                new MonteCarlo().start();
            }
        }catch (Exception e){}
        double p=4.*k/n;
        System.out.println(p);
    }
    public void run(){
        x=Math.random();
        y=Math.random();
        if(x*x+y*y<=1) k++;
    }
}

