import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.*;
import javax.imageio.ImageIO;
import javax.swing.JFrame;

public class GrayScale extends Thread{
    static BufferedImage image;
    static int width;
    static int height;
    int j, i;

    public GrayScale() {
        try {
            //odczyt obrazu z pliku
            File input = new File("photo.jpg");
            image = ImageIO.read(input);
            width = image.getWidth();
            height = image.getHeight();
        } catch (Exception e) {e.printStackTrace();}
    }
    public GrayScale(int x, int y){
        i=x;j=y;
    }

    public void run(){
        Color c = new Color(image.getRGB(j, i));
        System.out.println(i);
        Color newC = new Color(255-(int)(c.getRed()), 255-(int)(c.getGreen()), 255-(int)(c.getBlue()));
        image.setRGB(j,i,newC.getRGB());
    }

    static public void main(String args[]) throws Exception
    {
        GrayScale o = new GrayScale();
        try {
            //odczyt pixeli obrazu w dwóch pętlach po kolumnach i wierszach
            for(int i=1; i<height-1; i++){
                for(int j=1; j<width-1; j++){
                    new GrayScale(i,j).start();
                }
            }
            //zapis do pliku zmodyfikowanego obrazu
            File ouptut = new File("grayscale.jpg");
            ImageIO.write(image, "jpg", ouptut);
        } catch (Exception e) {}
    }
}
