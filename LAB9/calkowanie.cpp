#include <iomanip>
#include <iostream>
#include <cstdlib>
#include <chrono>

using namespace std;

double f(double x)
{
  return(x * x + 2 * x);
}

int main()
{
  int N = 1000; //liczba punktów/prostokątów podziałowych
  double xp,xk,s,dx;
  int i;

  cout << setprecision(3) << fixed;   // 3 cyfry po przecinku     // format stałoprzecinkowy

  cout << "Obliczanie  calki oznaczonej za pomoca metody prostokatow\n"
          "f(x) = x * x + 2 * x\n"
          "Podaj poczatek przedzialu calkowania\n"
          "xp = 1";
    xp=1.0;
  //cin >> xp;
  cout << "\nPodaj koniec przedzialu calkowania\n\n"
          "xk = 2";
    xk=2.0;
  //cin >> xk;
  cout << "\nPodaj dokladnosci calkowania\n"
          "n = ";
    cin >> N;
  cout << endl;
  s  = 0;
  auto start2 = chrono::steady_clock::now(); 
  dx = (xk - xp) / N;
  for(i = 1; i <= N; i++) s += f(xp + i * dx)*dx;
  //s *= dx;
  auto stop = chrono::steady_clock::now();
  cout << "Wartosc calki wynosi : " << setw(8) << s << endl;
    auto diff = stop - start2;
    cout << chrono::duration <double, milli> (diff).count() << endl;
  return 0;
}
