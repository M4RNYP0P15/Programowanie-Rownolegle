# LAB 11
# Zad. Znajdź i opisz/przetestuj/może rozwiń inne ciekawe zastosowanie biblioteki pyTorch/Tensorflow
## 1. Tworzenie sztucznych twarzy za pomoca modelu CelebA Progressive GAN
Moduł odwzorowuje wektory N-wymiarowe, zwane przestrzenią utajoną, na obrazy RGB.

Skrypt:

Mapuje z przestrzeni utajnionej do obrazów
Prezentuje obraz (docelowy) oraz uzywa gradientu spadkowego by znalezc "utajniony" wektor który wygeneruje podobny obraz do docelowego.

Przykład użycia

![obraz](https://user-images.githubusercontent.com/38810840/150658853-4f8cfc9e-fead-44a6-8c87-b8d44879af87.png)


## 2. Rozpoznawanie działań z wykorzystaniem Inflated 3D CNN
Model sprawdza jakie działania są wykonywane na materiale wejściowym w postaci wideo/filmiku. 

Dla filmiku: ![filmik](https://commons.wikimedia.org/wiki/File:End_of_a_jam.ogv)

![obraz](https://user-images.githubusercontent.com/38810840/150655534-9f2de70a-be82-4933-aa20-4f7486c1f339.png)

Dla:
![filmik](https://upload.wikimedia.org/wikipedia/commons/transcoded/7/72/Biljartwedstrijd.webm/Biljartwedstrijd.webm.480p.vp9.webm)

![obraz](https://user-images.githubusercontent.com/38810840/150655819-1907b28b-a261-49b0-8ce4-575ae5b0974e.png)

Dla:

[![Filmik]((https://upload.wikimedia.org/wikipedia/commons/transcoded/1/10/Ommegang_Bruselas_2017_07_video.ogv/Ommegang_Bruselas_2017_07_video.ogv.480p.vp9.webm))](https://upload.wikimedia.org/wikipedia/commons/transcoded/1/10/Ommegang_Bruselas_2017_07_video.ogv/Ommegang_Bruselas_2017_07_video.ogv.480p.vp9.webm)

![obraz](https://user-images.githubusercontent.com/38810840/150655847-7b44ebdf-a0bb-4174-b076-af70198b87c6.png)




Inne modele można sprawdzić: https://tfhub.dev/s?module-type=video-classification
