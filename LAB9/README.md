# LAB 9 
Przedstaw efektywnosc srodowiska CUDA w Google Colab na podstawie 2 niebanalnych przykladow(porownanie efektywnosci obliczen na CPU i GPU
z zależności od rozmiaru problemu -> opis problemu, kod CPU GPU, wykres, wnioski)
## Mandelbrot
### Opis:
Obliczanie fraktala mandelbrota. Wyliczanie "koloru" dla fraktala.
Głównym problemem jest czas potrzebny na wykonanie takich obliczen na CPU (ponieważ liczy sekwencyjnie tj. iteracja po iteracji - w tym wydaniu "jednowatkowym")
 Liczony jest tylko czas wykonania obliczeń!
Czas wykonania na CPU do porównań: 1550.96 dla 1000x1000 = 1000000
Sprostowanie co do wykresu: 1000 iteracji to 1000^2 iteracji itd
![obraz](https://user-images.githubusercontent.com/38810840/146681673-1bc1a1ed-ffac-4c71-8800-3d7b4dffc3be.png)
Czerwona linia: CPU
Niebieska linia: GPU
Mniej=Lepiej

### Wnioski:
Ponieważ rdzenie CUDA liczą równolegle (teoretycznie) i jest ich znacznie więcej możemy dużo szybciej policzyc (ok. 400krotnie) wartości potrzebne do narysowania obrazka.
Niestety w moim przypadku kosztem dokładności obliczeń (mniejsza dokładność jeżeli chodzi o liczby zmienno przecinkowe), jednakże jest on na poziomie 99,82% więc przy tak wielkich liczbach rozbieżność nie jest zbyt istotna.


## Calkowanie
### Opis
Obliczanie całki numerycznie metodą prostokątów.

### Wykres
![obraz](https://user-images.githubusercontent.com/38810840/146683747-b6dad383-3ae7-4525-af99-e57a38bc32b4.png)

### Wnioski
Jak się można domyślić zrównoleglony kod wykonuje się szybciej dla wiekszej ilosci "iteracji". Dla mniejszej czas przenoszenia obliczen na kartę graficzną zajmuje więcej niż czs obliczenia przez CPU. Więc jeżeli potrzebujemy obliczenia czegoś "małego" (dokładność lub "atomowość" obliczenia) jak najszybciej powinniśmy to obliczać na CPU/host lub jeżeli mamy obliczenia które nie mogą zostać zrównoleglone. W innym wypadku możemy używać kart graficznych (rdzeni CUDA).  
