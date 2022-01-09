# LAB 10
## Zad 1 Calkowanie metodami Prostokatow, Trapezow, Simpsona.
### CPU
Kod: ![Calkowanie_CPU](Calkowanie.cpp)

### GPU
Kod: ![Calkowanie_GPU](Calkowanie.cu)
```
!pip install git+git://github.com/andreinechaev/nvcc4jupyter.git

%load_ext nvcc_plugin
```
Calkowanie odbywa sie w następujący sposób:
1. Obliczana jest każda wartość z n (dokladność) w oddzielnym wątku po czym zapisywana jest w tablicy o wielkości n.
2. Tablica jest sumowana przy wykorzystaniu pamięci współdzielonej na GPU.
3. Zwracamy wartość sumowania i w niektórych przypadkach (metoda simpsona) wyliczany jest wzór korzystający z wartości wyliczonych przez GPU.

### Wykresy
Na górze wykresu jest dokładność obliczeń całki. ( dot. wykresu "mniej = szybciej" przedstawia czas wykonania)

![obraz](https://user-images.githubusercontent.com/38810840/148698614-c0454018-b28a-4ea0-af3f-4dbb8c9b8f20.png)
![obraz](https://user-images.githubusercontent.com/38810840/148698626-277772c9-978c-4350-92ce-0a8650f5c760.png)
![obraz](https://user-images.githubusercontent.com/38810840/148698633-14e33064-5ec1-45b0-a246-27aa98072439.png)
![obraz](https://user-images.githubusercontent.com/38810840/148698683-313b8eaf-0ca3-4633-ae36-0439910ff456.png)
![obraz](https://user-images.githubusercontent.com/38810840/148698694-2f1c3446-4a24-489e-a148-2679c3de8e76.png)
![obraz](https://user-images.githubusercontent.com/38810840/148698704-35112a18-a09a-4a5e-8b61-6c6ea093be03.png)


### Wnioski

Dla dokładności n=1000 szybsza jest wersja na CPU (jednowątkowa). Jednak wraz z wzrostem dokładności widzimy dominację GPU.
