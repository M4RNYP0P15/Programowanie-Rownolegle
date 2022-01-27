# LAB 13
## pakiet parallel w języku R
Jest wiele pakietów umożliwiających programowanie równoległe w R. Jednymi z pierwszych i "najlepszych" były 'multicore' i 'snow'. Dlatego zostały połączone w pakiet 'parallel' i włączone do podstawowej wersji R.
### W celu wczytania biblioteki używamy:
```
library(parallel)
```
### Aby sprawdzić ile "rdzeni"(procesorów logicznychw) mamy do wykorzystania, używamy komendy(próba uzycia większej ilości rdzeni niż posiadamy nie przyniesie żadnych korzyści):
```
detectCores()
```
## Metody zrównoleglania
Są 2 główne sposoby poprzez:
* sockets (tzw. gniazda) - uruchamia nową wersje R na każdym rdzeniu. Technicznie odbywa się poprzez sieć( tak jak byśmy łączyli się z serwerem zdalnym), jednakże połączenie odbywasię na tym samym komputerze(można otrzymać zapytanie z firewalla o akceptację połączenia przychodzącego).
* forking (rozwidlające) - kopiuje obecną wersje R i przenosi ją do nowego rdzenia.

### Plusy i minusy
#### Socket:
* + Działa na każdym systemie.
* + Każdy proces w każdym korzeniu jest unikalny więc nie dochodzi do cross-contaminate.
* - Każdy proces jest unikalny więc będzie wolniej.
* - Każdy pakiet musi być wczytany na każdym procesie oddzielnie. Zmienne zdefiniowane w głównej wersji(sesji) R nie istnieją na innych jeżeli nie zostaną tam umieszczone.
* - Bardziej skomplikowana implementacja.

#### Forking:
* - Tylko systemy POSIX (Mac, Linux, Unix, BSD) (nie działa na dosie - Windows)
* - Procesy są duplikowane więc sprawiają problemy (np przy generowaniu liczb losowych lub przy używaniu GUI do R - Rstudio.
*  + Są szybsze niż Sockets
*  + Cały "workspace" istnieje w każdym procesie ponieważ jest powielany.
*  + Trywialny w implementacji

***Ogólnie lepiej używać forking(widełek) jeżeli nie korzystamy z Windowsa (systemów DOS)***
## Przykłady
### Forking używając mclapply
Do sprawdzenia różnicy czasu wykonania użyjemy prostej funkcji:
```
f <- function(i) {
  lmer(Petal.Width ~ . - Species + (1 | Species), data = iris)
}
```
funkcja dopasowuje model mieszany korzystając z danych zawartych w zbiorze "iris" która posiada kolumny(zmienne):
"Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width"  "Species"
##### Uruchamiamy bez równoległości:
```
system.time(save1 <- lapply(1:100, f))
```

##### użytkownik system upłyneło
##### 1.890      0.02   1.92
##### Uruchamiamy z równoległością (domyślnie mcapply używa argumentu mc.cores (ilość rdzeni do obliczeń)   równego detectCores() ):
```
system.time(save2 <- mclapply(1:100, f))
```
##### użytkownik system upłyneło
##### 1.195      0.150   1.321

***Na Windows'ie mclapply wywoła lapply więc nie otrzymamy żadnego przyśpieszenia(forking nie działa na Windows'ie)***
### Sockets używając parLapply
Główny proces:
1. Zaczynamy(startujemy) klaster z n korzeni(węzłów).
2. Wykonujemy(wprowadzamy) cały potrzebny kod do funkcjonowania naszej "funkcji" w każdym "korzeniu" np. wczytywanie pakietu.
3. Używamy par*apply jako zamiennika dla *apply.
4. Niszczymy klaster
#### 1.Tworzymy klaster
```
clu <- makeCluster(detectCores())
```
Funkcja przyjmuje argument type która może być zarówno PSOCK (wersja sockets) lub FORK (wersja forking).
W przypadku uruchomienia kodu na wielu komputerach w sieci ustawiamy reszte opcji( w przypadku wykonania lokalnego można zostawić domyślne wartości)
#### 2.Wymagane funkcje i pakiety
Każdy proces jest pusty więc musimy załadować wszystkie biblioteki i własne funkcje zmienne na każdym procesie. Najłatwiej to zrobić funkcją:
```
clusterEvalQ(clu, 2+2) # każdy z procesów obliczy wynik (tj. 4)
```
***(nie możemy przy jej pomocy przenosić zmiennych zadeklarowanych w procesie głównym poprzez nazwe odniesienia )***
Możemy użyć funkcji:
```
x <- 1
clusterExport(clu, "x") # podajemy obiekty do procesów
clusterEvalQ(clu,x) 
```
W celu załadowania bilbiotek używamy:
```
clusterEvalQ(cl, {
  library(ggplot2)
  library(stringr)
})
```
### Uzywamy par*apply
Mamy odpowiedniki funkcji "apply, lapply i sapply" w postaci "parApply, parLapply i parSapply" (odpowiednio).
```
parSapply(clu, Orange, mean, na.rm = TRUE)
```
### Pracę z klastrem kończymym komendą:
```
stopCluster(clu)
```
Nie wymagane (przy wyłączeniu R procesy zostaną zamknięte również). Komenda nie usuwa objektu clu tylko odniesienie. Zamykanie klastra jest równoważne wyjściu z R przez każdy proces. Wszystkie dane tam przechowywane zostaja utracone, a pakiety muszą zostać załadowane ponownie.

### Przykład właściwy
```
clu <- makeCluster(detectCores())
clusterEvalQ(clu, library(lme4))
system.time(save3 <- parLapply(clu, 1:100, f))
stopCluster(clu)
```
#### użytkownik     system   upłynęło 
####      0.16       0.02       0.62
