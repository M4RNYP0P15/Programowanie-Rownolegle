# LAB 6
## Zad 1
### MPI obliczanie równoległe liczby PI z wzoru Leibniz-a.
![obraz](https://user-images.githubusercontent.com/38810840/143136725-015cc147-58ca-4510-8775-256fcd42a07b.png)

Przykładowe polecenie kompilacji:
```
mpicc -o Zad1 Zad1.c
```
Przykładowe polecenie uruchomienia:
```
mpirun -np 70 ./Zad1
```
Kod:* ![Zad1](Zad1.c)


## Zad 2
### Kod wyznaczający numeryczną wartość całki y=x^2 w przedziale <a,b> metodą trapezów oraz prostokątów  przy  pomocy  N  procesów  w  środowisku  MPI.
![obraz](https://user-images.githubusercontent.com/38810840/143278193-b799e2ba-6279-474c-98fd-7ef033fd78bc.png)

#### Przykładowe polecenie kompilacji:
```
mpicc -o Zad2 Zad2.c
```
#### Przykładowe polecenie uruchomienia:
```
mpirun -np 20 ./Zad2
```
![Zad2](Zad2.c)
