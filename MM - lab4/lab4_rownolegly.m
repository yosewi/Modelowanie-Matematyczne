%% =======================================================================
%  MODELOWANIE MATEMATYCZNE - Lab 4: Równania różniczkowe zwyczajne 2. rzędu
%  WERSJA: 25.10.2023, godz. 16.15, wersja A  -> RÓWNOLEGŁY obwód RLC
% =======================================================================
%
%  TREŚĆ (skrót):
%    Źródło prądowe i(t), kondensator C, opornik R i cewka L połączone
%    RÓWNOLEGLE - na wszystkich jest to samo napięcie u(t).
%    i(t)  = 10*sin(1e6*t) [uA]
%    iC(t) = C*du/dt(t)
%    iR(t) = u(t)/R
%    iL(t) = (1/L) * całka od 0 do t z u(tau) dtau
%
%    Dane: R = 4 kOhm, C = 1.3 nF, L = 1 mH, t od 0 do 10 us
%    Warunki początkowe: u(0) = 0, du/dt(0) = 0
%
%  (Mamy zdjęcie tylko pierwszej strony tej wersji. Zad 3-6 są takie
%   same jak w wersji 14.15, tylko dla u(t) zamiast q(t). Tolerancję
%   w Zad 6 = 1e-8 wziąłem z cudzego rozwiązania lab4_zad.m - sprawdź
%   w treści na kartce!)
%
%  Jak uruchomić: Run (albo sekcjami Ctrl+Enter). Wyniki do Zad 5 i 6
%  wypisują się w Command Window.
% =======================================================================

clear; clc; close all;

%% DANE  (UWAGA na przedrostki!)
R = 4e3;             % 4 kOhm  = 4000 Ohm
C = 1.3e-9;          % 1.3 nF  = 1.3*10^-9 F
L = 1e-3;            % 1 mH    = 0.001 H
tspan = [0 10e-6];   % t od 0 do 10 us

%% =======================================================================
%  ZADANIE 1 (0,2 p.)  -- ROBI SIĘ NA KARTCE, tu tylko opis
%  "Na podstawie pierwszego prawa Kirchhoffa sformułuj równanie
%   różniczkowe zwyczajne drugiego rzędu, opisujące przebieg u(t)."
% ========================================================================
%
%  KROK 1 - I prawo Kirchhoffa (prawo prądowe):
%     Prąd ze źródła rozpływa się na trzy gałęzie:
%
%        i(t) = iC(t) + iR(t) + iL(t)
%
%  KROK 2 - podstawiamy wzory (wszystko przez u):
%
%        i(t) = C*u'(t) + u(t)/R + (1/L)*całka_0^t u(tau) dtau
%
%  KROK 3 - w równaniu jest CAŁKA, a chcemy równanie różniczkowe.
%     Różniczkujemy obie strony po t:
%        (C*u')'                = C*u''
%        (u/R)'                 = u'/R
%        ((1/L)*całka_0^t u)'   = u/L      (pochodna całki z górną
%                                           granicą t to funkcja podcałkowa)
%     czyli:
%        di/dt(t) = C*u''(t) + u'(t)/R + u(t)/L
%
%  KROK 4 - liczymy di/dt (UWAGA NA JEDNOSTKI: uA -> A):
%        i(t)     = 10*sin(1e6*t) uA = 10e-6*sin(1e6*t) A
%        di/dt(t) = 10e-6 * 1e6 * cos(1e6*t) = 10*cos(1e6*t)   [A/s]
%
%  >>> ODPOWIEDŹ DO RAMKI (tak wpisać na kartkę):
%
%        10*cos(10^6 t) - C*d^2u/dt^2(t) - (1/R)*du/dt(t) - (1/L)*u(t) = 0
%
%     albo równoważnie:   C*u'' + (1/R)*u' + (1/L)*u = 10*cos(10^6 t)
%
%  (Tak samo było w odręcznym rozwiązaniu na zdjęciu - to jest dobrze.)

%% =======================================================================
%  ZADANIE 2 (0,4 p.)
%  "Rozwiąż równanie z Zad. 1 za pomocą dsolve przy u(0)=0, u'(0)=0.
%   Narysuj przebiegi iC(t) i iR(t) dla t z [0; 10 us]."
% ========================================================================
%
%  JAK TO DZIAŁA:
%   - syms t u(t) -> t zmienna symboliczna, u(t) szukana funkcja
%   - prąd źródła wpisuję w AMPERACH i każę MATLABowi samemu policzyć
%     pochodną (diff) - wtedy nie da się pomylić przy liczeniu di/dt
%   - dsolve(równanie, warunki) -> wzór na u(t) (rozwiązanie DOKŁADNE)
%   - potem: iC = C*u',  iR = u/R
%   - na wykresie mnożę przez 1e6, żeby oś była w uA (czytelniej)

syms t u(t)

i_sym  = 10e-6 * sin(1e6*t);           % i(t) w AMPERACH (10 uA = 10e-6 A)
di_sym = diff(i_sym, t);               % di/dt = 10*cos(1e6*t)
du     = diff(u, t);                   % u'(t)

% równanie z Zadania 1:
eq = di_sym - C*diff(u, t, 2) - du/R - u/L == 0;

% warunki początkowe
warunki = [u(0) == 0, du(0) == 0];

us  = simplify(dsolve(eq, warunki));   % u(t) - rozwiązanie dokładne
iCs = C * diff(us, t);                 % iC(t) = C*u'(t)
iRs = us / R;                          % iR(t) = u(t)/R

figure(1); clf; hold on; grid on;
fplot(iCs*1e6, tspan, 'b-', 'LineWidth', 1.5, 'DisplayName', 'i_C(t) - dsolve');
fplot(iRs*1e6, tspan, 'r-', 'LineWidth', 1.5, 'DisplayName', 'i_R(t) - dsolve');
xlabel('t [s]'); ylabel('i [\muA]');
title('Równoległy RLC: i_C(t) i i_R(t)');
legend('show');

%  CO POWINNO WYJŚĆ (sprawdziłem numerycznie):
%   - oba prądy oscylują, a ich amplituda w tym przedziale ROŚNIE
%     (częstotliwość źródła 1e6 rad/s jest blisko rezonansu obwodu
%     1/sqrt(LC) ~ 8.8e5 rad/s, a tłumienie jest słabe),
%   - iC jest duży: dochodzi do ok. 30 uA (więcej niż prąd źródła -
%     to normalne w pobliżu rezonansu, prąd "krąży" między L i C),
%   - iR jest mały: kilka uA (max ok. 5.6 uA).

%% =======================================================================
%  ZADANIE 3 (0,4 p.)  -- ROBI SIĘ NA KARTCE + przyda się w kodzie
%  "Przekształć równanie z Zad. 1 do układu dwóch równań 1. rzędu,
%   podstawiając y1(t) = u(t), y2(t) = du/dt(t). Po prawej stronie
%   tylko: y1, y2, i(t) (lub di/dt), R, L, C."
% ========================================================================
%
%  PO CO: ode45 rozwiązuje TYLKO równania 1. rzędu (y' = f(t,y)).
%
%  KROK 1 - wyznaczamy najwyższą pochodną (u''):
%        di/dt - C*u'' - u'/R - u/L = 0
%        C*u'' = di/dt - u'/R - u/L
%        u''   = (1/C)*di/dt - u'/(R*C) - u/(L*C)
%
%  KROK 2 - podstawienie: y1 = u,  y2 = u'
%        y1' = u'  = y2
%        y2' = u'' = (1/C)*di/dt - y2/(R*C) - y1/(L*C)
%
%  >>> ODPOWIEDŹ DO RAMKI:
%
%        dy1/dt(t) = y2(t)
%
%        dy2/dt(t) = -(1/(R*C))*y2(t) - (1/(L*C))*y1(t) + (1/C)*di/dt(t)
%
%     (di/dt(t) = 10*cos(10^6 t) - jeśli w ramce wolno wstawiać liczby)
%
%  Pamiętaj: wymuszenie (źródło) ma znak PLUS po prawej stronie.

di = matlabFunction(di_sym, 'Vars', t);   % di/dt jako zwykła funkcja liczbowa

f = @(t, y) [ y(2);                                        % y1' = y2
              -y(2)/(R*C) - y(1)/(L*C) + di(t)/C ];        % y2' = ...

%% =======================================================================
%  ZADANIE 4 (0,4 p.)
%  "Na podstawie układu z Zad. 3 wyznacz przybliżony przebieg u(t)
%   funkcją ode45. Wylicz z niego iC(t) i iR(t). Dorysuj na obrazku
%   z Zad. 2."
% ========================================================================
%
%  [tt, y] = ode45(f, tspan, y0)
%     y0 = [u(0); u'(0)] = [0; 0]
%     y(:,1) = u(t),  y(:,2) = u'(t)
%  Potem: iC = C*y(:,2),  iR = y(:,1)/R

y0 = [0; 0];
[tt, y] = ode45(f, tspan, y0);         % ustawienia DOMYŚLNE

u_n  = y(:,1);                         % u(t) przybliżone
iC_n = C * y(:,2);                     % iC(t) przybliżone
iR_n = u_n / R;                        % iR(t) przybliżone

figure(1); hold on;
plot(tt, iC_n*1e6, 'bo--', 'DisplayName', 'i_C(t) - ode45');
plot(tt, iR_n*1e6, 'ro--', 'DisplayName', 'i_R(t) - ode45');
legend('show');
hold off;

%  CZEGO SIĘ SPODZIEWAĆ: przy domyślnych ustawieniach kroków jest
%  ok. 10, więc kółka leżą rzadko, ale przebiegi z grubsza pokrywają
%  się z dokładnymi.

%% =======================================================================
%  ZADANIE 5 (0,4 p.)
%  "Wyznacz maksymalne wartości bezwzględne błędów przybliżenia u(t),
%   iC(t), iR(t) z Zad. 4 (odniesienie: Zad. 2). Jaki jest zakres
%   długości kroków całkowania ode45?"
% ========================================================================
%
%  BŁĄD: porównujemy dokładne i przybliżone W TYCH SAMYCH chwilach tt:
%     Delta_max[u] = max | u_dokładne(tt) - u_ode45(tt) |
%  matlabFunction zamienia wzór symboliczny na funkcję, którą można
%  policzyć dla całego wektora tt naraz.

u_f  = matlabFunction(us,  'Vars', t);
iC_f = matlabFunction(iCs, 'Vars', t);
iR_f = matlabFunction(iRs, 'Vars', t);

du_max  = max(abs(real(u_f(tt))  - u_n));
diC_max = max(abs(real(iC_f(tt)) - iC_n));
diR_max = max(abs(real(iR_f(tt)) - iR_n));

fprintf('\n===== ZADANIE 5 =====\n');
fprintf('Delta_max[u(t)]  = %.4e V\n', du_max);
fprintf('Delta_max[iC(t)] = %.4e A  (= %.4f uA)\n', diC_max, diC_max*1e6);
fprintf('Delta_max[iR(t)] = %.4e A  (= %.4f uA)\n', diR_max, diR_max*1e6);

%  KROKI CAŁKOWANIA:
%   ode45 domyślnie ma 'Refine' = 4 -> zwraca 4 punkty na każdy krok
%   (3 interpolowane + koniec kroku). Dlatego:
%     - prawdziwe kroki:  diff(tt(1:4:end))
%     - diff(tt) da wartości ~4 razy mniejsze
%   (w cudzym rozwiązaniu było mean(...) - a pytają o MIN i MAX!)

h_real = diff(tt(1:4:end));
h_out  = diff(tt);

fprintf('Liczba kroków ode45 = %d\n', numel(h_real));
fprintf('Delta_t_min = %.4e s,  Delta_t_max = %.4e s   (prawdziwe kroki)\n', ...
        min(h_real), max(h_real));
fprintf('[dla porównania diff(tt): min = %.4e s, max = %.4e s]\n', ...
        min(h_out), max(h_out));

%  >>> ODPOWIEDŹ DO RAMEK: przepisz liczby z Command Window
%  (z jednostkami). Delta_t_max powinno wyjść blisko 1e-6 s, bo to
%  domyślny maksymalny krok: MaxStep = 0.1*(10e-6 - 0).

%% =======================================================================
%  ZADANIE 6 (0,2 p.)
%  "Wyznacz u(t) za pomocą ode45 jeszcze raz, zwiększając dokładność
%   (odeset) tak, aby błędy względne i bezwzględne nie przekraczały
%   1e-8. Jaki jest zakres długości kroków po tej zmianie?"
% ========================================================================
%
%  odeset:
%    'RelTol' - dopuszczalny błąd WZGLĘDNY   (domyślnie 1e-3)
%    'AbsTol' - dopuszczalny błąd BEZWZGLĘDNY (domyślnie 1e-6)
%  Mniejsze tolerancje -> solver bierze mniejsze kroki -> więcej kroków
%  -> mniejszy błąd.

opcje = odeset('RelTol', 1e-8, 'AbsTol', 1e-8);
[tt6, y6] = ode45(f, tspan, y0, opcje);

h6_real = diff(tt6(1:4:end));
h6_out  = diff(tt6);

fprintf('\n===== ZADANIE 6 =====\n');
fprintf('Liczba kroków ode45 = %d\n', numel(h6_real));
fprintf('Delta_t_min = %.4e s,  Delta_t_max = %.4e s   (prawdziwe kroki)\n', ...
        min(h6_real), max(h6_real));
fprintf('[dla porównania diff(tt): min = %.4e s, max = %.4e s]\n', ...
        min(h6_out), max(h6_out));
fprintf('(dla ciekawości) nowy Delta_max[u(t)] = %.4e V\n', ...
        max(abs(real(u_f(tt6)) - y6(:,1))));

%  >>> ODPOWIEDŹ DO RAMKI: Delta_t_min = ... s,  Delta_t_max = ... s
%  Kroki będą wyraźnie mniejsze niż w Zad 5, kroków dużo więcej,
%  błąd u(t) dużo mniejszy.

%% =======================================================================
%  ŚCIĄGA - JEŚLI DOSTANIESZ INNY WARIANT
% ========================================================================
%  - Inny prąd źródła: zmień TYLKO linię i_sym = ... (w amperach!),
%    pochodna i funkcja di(t) dla ode45 policzą się same.
%  - Inne R, L, C, tspan: sekcja DANE.
%  - Pytają o inne wielkości:
%       u(t)  -> symbolicznie: us;               ode45: y(:,1)
%       iC(t) -> C*diff(us,t);                   C*y(:,2)
%       iR(t) -> us/R;                           y(:,1)/R
%       iL(t) -> i_sym - iCs - iRs;              (z Kirchhoffa, bez całki)
%                ode45: i_f(tt) - iC_n - iR_n, gdzie
%                i_f = matlabFunction(i_sym,'Vars',t);
%  - Inna tolerancja w Zad 6: zmień liczby w odeset.