import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.Scanner;
import java.awt.*;

public class Main {
    public static BufferedImage image;
    static int Width=3000;
    static int Height=3000;

    public static void main(String[] args) throws IOException {
        Scanner skan= new Scanner(System.in);
        System.out.println("Podaj szerokość obrazka wyjściowego:");
        Width= skan.nextInt();
        System.out.println("Podaj wysokość obrazka wyjściowego:");
        Height= skan.nextInt();
        image = new BufferedImage(Width, Height, BufferedImage.TYPE_INT_RGB);
        System.out.println("Podaj część rzeczywistą:");
        double cR= skan.nextDouble();
        System.out.println("Podaj część urojoną:");
        double cI=skan.nextDouble();

        JuliaSet j1 = new JuliaSet(0, Width/2,0,Height/2,cR,cI);
        JuliaSet j2 = new JuliaSet(Width/2, Width,Height/2,Height,cR,cI);
        JuliaSet j3 = new JuliaSet(Width/2, Width,0,Height/2,cR,cI);
        JuliaSet j4 = new JuliaSet(0, Width/2,Height/2,Height,cR,cI);
        j1.start();
        j2.start();
        j3.start();
        j4.start();
        try {
            j1.join();
            j2.join();
            j3.join();
            j4.join();

            File output = new File("Juli_out.png");
            ImageIO.write(image, "png", output);
        }catch (Exception e){}
    }
}

class JuliaSet extends Thread{
    int xp, xk;
    int yp, yk;
    double cR, cI;

    public JuliaSet(int xp, int xk, int yp, int yk, double cR, double cI) {
        this.xp = xp;
        this.xk = xk;
        this.yp = yp;
        this.yk= yk;
        this.cR=cR;
        this.cI=cI;
    }

    @Override
    public void run() {
        double dy = (1.25 - (-1.25)) / 3000;
        double dx = (1.5 - (-1.5)) / 3000;
        int red=0, green=0, blue=0;

        double re, im;
        int k;
        double newR,newI;

        for (int x = xp; x < xk; x++) {
            for (int y = yp; y < yk; y++) {
                k = 0;
                re = x * dx + (-1.5);
                im = y * dy + (-1.25);

                while (k < 300 && (re*re + im*im) < 4.0) {
                    newR = re*re-im*im;
                    newI = re*im+re*im;

                    re=newR;
                    im=newI;

                    re=re+cR;
                    im=im+cI;

                    k++;
                }
                if(k<50){
                    red = 0;
                    green = 0;
                    blue = 0;
                }
                if(k>50&&k<100){
                    red = 51;
                    green = 102;
                    blue = 255;
                }
                else
                if(k>100){
                    red = 0;
                    green = 0;
                    blue = 153;
                }
                Color color = new Color(red,green,blue);
                Main.image.setRGB(x,y,color.getRGB());
            }
        }
    }
}
