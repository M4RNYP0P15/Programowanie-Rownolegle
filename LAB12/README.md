# LAB 12
## Zadanie. Poeksperymentuj z algorytmem Neural Style Transfer (NTS)
### Obrazy wykoszystane:
![obraz](https://user-images.githubusercontent.com/38810840/150690057-19a64beb-c7e2-475e-aada-135eaf1ab87e.png)

![obraz](https://user-images.githubusercontent.com/38810840/150690269-c784578e-2b2f-4494-8261-4e0d09d6cd4d.png)

![obraz](https://user-images.githubusercontent.com/38810840/150691755-78c39330-dbce-4719-a04c-633ac39ec973.png)

#
### Przy 4000 iteracjach i 
##### total_variation_weight = 1e-6
##### style_weight = 1e-6
##### content_weight = 2.5e-8

![obraz](https://user-images.githubusercontent.com/38810840/150690187-ffb20f25-3a69-4253-9cb0-e98d19ed92fe.png)
#
### Przy 3000 iteracjach i takich samych wagach

![obraz](https://user-images.githubusercontent.com/38810840/150690501-19acda03-f8c4-453f-b6fa-d3a03690a93d.png)
#
### 3000 iteracji i total_variation_weight = 1e-6
##### style_weight = 1e-6
##### content_weight = 2.5e-5   czyli zwiększamy wagę zdjęcia podstawowego.

![obraz](https://user-images.githubusercontent.com/38810840/150690822-49eab7b4-e780-418b-8845-86370bd282fe.png)
#
### 3000 iteracji i total_variation_weight = 1e-7
##### style_weight = 1e-6
##### content_weight = 2.5e-5

![obraz](https://user-images.githubusercontent.com/38810840/150691543-d1f2b594-940d-483c-a12c-cbf40ba7d8e2.png)

# Warstwy sieci
Zwiększając wagę wcześniejszych warstw (conv1_1 i conv2_1), możesz spodziewać się większych artefaktów stylu w wynikowym obrazie docelowym. Jeśli zdecydujesz się na ważenie późniejszych warstw, większy nacisk położysz na mniejsze funkcje. Dzieje się tak, ponieważ każda warstwa ma inny rozmiar i razem tworzą wieloskalową reprezentację stylu.

Utrata treści będzie średnią kwadratową różnicy między cechami docelowymi i treściowymi w warstwie conv4_2. 

# Źródło:https://keras.io/examples/generative/neural_style_transfer/
