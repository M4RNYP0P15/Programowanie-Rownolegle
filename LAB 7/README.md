# LAB 7
## Zad 1
### Symulator Exodus'a (uchodźców) (MPI)
![obraz](https://user-images.githubusercontent.com/38810840/144750375-c4346d1c-b64d-4531-9c9d-d0ead5e23018.png)


Przykładowe polecenie kompilacji:
```
mpicc -o Zad1 Zad1.c
```
Przykładowe polecenie uruchomienia:
```
mpirun -np 70 ./Zad1
```
Kod: ![Zad1](Zad1.c)

## Zad 2
### Fraktal mandelbrota (MPI)
![obraz](https://user-images.githubusercontent.com/38810840/144714421-b7a2bccc-f8de-4344-9c8e-5daa606f36fc.png)
Wymaga biblioteki: libpng-dev
```
sudo apt install libpng-dev
```

Przykładowe polecenie kompilacji:
```
mpicc -o Zad2 Zad2.c -lm -lpng
```
Przykładowe polecenie uruchomienia:
```
mpirun -np 70 ./Zad1
```
Program dzieli obliczenie fraktala na zadaną ilość wątków po czym tworzy obrazek fraktala w formacie png.
Kod: ![Zad2](Zad2.c)
