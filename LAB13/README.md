# LAB 13
## pakiet parallel w języku R
Jest wiele pakietów umożliwiających programowanie równoległe w R. Jednymi z pierwszych i "najlepszych" były 'multicore' i 'snow'. Dlatego zostały połączone w pakiet 'parallel' i włączone do podstawowej wersji R.
### W celu wczytania biblioteki używamy:
```
library(parallel)
```
### Aby sprawdzić ile "rdzeni"(procesorów logicznychw) mamy do wykrzystania używamy komendy(próba uzycia większej ilości rdzeni niż posiadamy nie przyniesie żadncyh korzyści):
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
