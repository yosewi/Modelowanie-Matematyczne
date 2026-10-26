%% =======================================================================
%  MODELOWANIE MATEMATYCZNE - Lab 4: Równania różniczkowe zwyczajne 2. rzędu
%  WERSJA: 25.10.2023, godz. 14.15, wersja A  -> SZEREGOWY obwód RLC
% =======================================================================
%
%  TREŚĆ (skrót):
%    Szeregowy obwód: źródło e(t) -> C -> R -> L -> masa.
%    e(t)  = sin(1e7*t) [V]
%    uC(t) = q(t)/C
%    uR(t) = R*i(t)
%    uL(t) = L*di/dt(t)
%    i(t)  = dq/dt(t)      (prąd = pochodna ładunku na kondensatorze)
%
%    Dane: R = 4 kOhm, C = 0.12 nF, L = 5 mH, t od 0 do 5 us
%    Warunki początkowe: q(0) = 0, i(0) = 0
%
%  Jak uruchomić: otwórz plik w MATLABie i kliknij "Run" (albo uruchamiaj
%  po kolei sekcje: Ctrl+Enter w danej sekcji %%). Wyniki do Zad 5 i 6
%  wypisują się w Command Window.
% =======================================================================

clear; clc; close all;

%% DANE  (UWAGA na przedrostki!)
%  k (kilo)  = 1e3      m (mili)  = 1e-3
%  u (mikro) = 1e-6     n (nano)  = 1e-9
R = 4e3;            % 4 kOhm   = 4000 Ohm
C = 0.12e-9;        % 0.12 nF  = 0.12*10^-9 F
L = 5e-3;           % 5 mH     = 0.005 H
tspan = [0 5e-6];   % t od 0 do 5 us

%% =======================================================================
%  ZADANIE 1 (0,2 p.)  -- ROBI SIĘ NA KARTCE, tu tylko opis
%  "Na podstawie drugiego prawa Kirchhoffa sformułuj równanie różniczkowe
%   zwyczajne drugiego rzędu, opisujące przebieg w czasie ładunku q(t)."
% ========================================================================
%
%  KROK 1 - II prawo Kirchhoffa (prawo napięciowe):
%     W zamkniętym oczku suma napięć = 0. Napięcie źródła rozkłada się
%     na elementy połączone szeregowo:
%
%        e(t) - uC(t) - uR(t) - uL(t) = 0
%
%  KROK 2 - wszystko wyrażamy przez ładunek q(t), korzystając z i = q':
%        uC = q/C
%        uR = R*i   = R*q'
%        uL = L*i'  = L*q''      (bo i' = (q')' = q'')
%
%  KROK 3 - podstawiamy:
%
%        e(t) - q(t)/C - R*q'(t) - L*q''(t) = 0
%
%  >>> ODPOWIEDŹ DO RAMKI (tak wpisać na kartkę):
%
%        sin(10^7 t) - (1/C)*q(t) - R*dq/dt(t) - L*d^2q/dt^2(t) = 0
%
%     albo równoważnie:   L*q'' + R*q' + (1/C)*q = sin(10^7 t)
%
%  Uwaga: samo "e - uC - uR - uL = 0" to dopiero prawo Kirchhoffa,
%  a nie równanie różniczkowe na q(t) - trzeba podstawić wzory!

%% =======================================================================
%  ZADANIE 2 (0,4 p.)
%  "Rozwiąż równanie z Zad. 1 za pomocą dsolve przy q(0)=0, i(0)=0.
%   Narysuj przebiegi napięć uC(t) i uR(t) dla t z [0; 5 us]."
% ========================================================================
%
%  JAK TO DZIAŁA:
%   - syms t q(t)   -> t to zmienna symboliczna, q(t) to szukana funkcja
%   - diff(q,t)     -> q'(t),  diff(q,t,2) -> q''(t)
%   - dsolve(równanie, warunki) zwraca wzór q(t) (rozwiązanie DOKŁADNE)
%   - warunek i(0)=0 zapisujemy jako q'(0)=0, bo i = q'
%   - mając q(t) liczymy: uC = q/C,  uR = R*i = R*q'
%   - fplot rysuje wyrażenie symboliczne na zadanym przedziale

syms t q(t)

e_sym = sin(1e7*t);                    % napięcie źródła (symbolicznie)
dq    = diff(q, t);                    % q'(t) = i(t)

% równanie z Zadania 1:
eq = e_sym - q/C - R*dq - L*diff(q, t, 2) == 0;

% warunki początkowe: q(0)=0, i(0)=q'(0)=0
warunki = [q(0) == 0, dq(0) == 0];

qs  = simplify(dsolve(eq, warunki));   % q(t) - rozwiązanie dokładne
is  = diff(qs, t);                     % i(t) = q'(t)
uCs = qs / C;                          % uC(t) = q(t)/C
uRs = R * is;                          % uR(t) = R*i(t)

% Wykres (rysujemy na figure(1), bo w Zad 4 będziemy na nim dorysowywać)
figure(1); clf; hold on; grid on;
fplot(uCs, tspan, 'b-', 'LineWidth', 1.5, 'DisplayName', 'u_C(t) - dsolve');
fplot(uRs, tspan, 'r-', 'LineWidth', 1.5, 'DisplayName', 'u_R(t) - dsolve');
xlabel('t [s]'); ylabel('u [V]');
title('Szeregowy RLC: u_C(t) i u_R(t)');
legend('show');

%  CO POWINNO WYJŚĆ (sprawdziłem numerycznie):
%   - uC(t) zaczyna od 0, rośnie do ok. 0.10 V około t = 1 us, potem
%     maleje i oscyluje (wolna oscylacja obwodu ~1.3e6 rad/s, tłumiona),
%     z drobnym "ząbkowaniem" od wymuszenia 1e7 rad/s.
%   - uR(t) wyraźnie "faluje" z dużą częstotliwością źródła (okres
%     ok. 0.63 us), amplituda rzędu 0.1 V.
%  Na kartce Zad 2 nie ma ramki - liczy się wykres pokazany prowadzącemu.

%% =======================================================================
%  ZADANIE 3 (0,4 p.)  -- ROBI SIĘ NA KARTCE + przyda się w kodzie
%  "Przekształć równanie z Zad. 1 do układu dwóch równań 1. rzędu,
%   podstawiając y1(t) = q(t), y2(t) = dq/dt(t). Po prawej stronie
%   tylko: y1, y2, e(t), R, L, C."
% ========================================================================
%
%  PO CO: ode45 rozwiązuje TYLKO równania 1. rzędu (postać y' = f(t,y)),
%  więc równanie 2. rzędu zamieniamy na dwa równania 1. rzędu.
%
%  KROK 1 - z równania z Zad 1 wyznaczamy NAJWYŻSZĄ pochodną (q''):
%        e - q/C - R*q' - L*q'' = 0
%        L*q'' = e - q/C - R*q'
%        q''   = e/L - q/(L*C) - (R/L)*q'
%
%  KROK 2 - podstawienie: y1 = q,  y2 = q'
%        y1' = q'  = y2
%        y2' = q'' = e/L - y1/(L*C) - (R/L)*y2
%
%  >>> ODPOWIEDŹ DO RAMKI:
%
%        dy1/dt(t) = y2(t)
%
%        dy2/dt(t) = -(R/L)*y2(t) - (1/(L*C))*y1(t) + (1/L)*e(t)
%
%  !!! UWAGA - w odręcznym rozwiązaniu, które masz na zdjęciu, był BŁĄD:
%      napisano "- sin(10^7 t)/L", a powinno być "+ e(t)/L".
%      Źródło ma znak PLUS (przenosimy je na drugą stronę jako jedyne
%      wymuszenie). Do tego w ramce ma być e(t), a nie wstawiony sinus.

% Ten sam układ w MATLABie (funkcja anonimowa, zwraca WEKTOR KOLUMNOWY):
e = matlabFunction(e_sym, 'Vars', t);   % e(t) jako zwykła funkcja liczbowa

f = @(t, y) [ y(2);                                   % y1' = y2
              -R/L*y(2) - y(1)/(L*C) + e(t)/L ];      % y2' = ...

%% =======================================================================
%  ZADANIE 4 (0,4 p.)
%  "Na podstawie układu z Zad. 3 wyznacz przybliżony przebieg q(t)
%   funkcją ode45. Wylicz z niego uC(t) i uR(t). Dorysuj na obrazku
%   z Zad. 2."
% ========================================================================
%
%  JAK TO DZIAŁA:
%   [tt, y] = ode45(f, tspan, y0)
%     f     - układ z Zad 3
%     tspan - przedział czasu [0 5e-6]
%     y0    - warunki początkowe [y1(0); y2(0)] = [q(0); i(0)] = [0; 0]
%   Wynik:
%     tt     - wektor chwil czasu, w których ode45 policzył rozwiązanie
%     y(:,1) - q(t)  w tych chwilach
%     y(:,2) - q'(t) = i(t) w tych chwilach
%   Potem:  uC = y(:,1)/C,   uR = R*y(:,2)

y0 = [0; 0];                           % q(0) = 0,  i(0) = 0
[tt, y] = ode45(f, tspan, y0);         % ustawienia DOMYŚLNE (tak jak w zadaniu)

q_n  = y(:,1);                         % q(t) przybliżone
i_n  = y(:,2);                         % i(t) przybliżone
uC_n = q_n / C;                        % uC(t) przybliżone
uR_n = R * i_n;                        % uR(t) przybliżone

% Dorysowanie na TYM SAMYM wykresie (figure(1) + hold on)
figure(1); hold on;
plot(tt, uC_n, 'bo--', 'DisplayName', 'u_C(t) - ode45');
plot(tt, uR_n, 'ro--', 'DisplayName', 'u_R(t) - ode45');
legend('show');
hold off;

%  CZEGO SIĘ SPODZIEWAĆ: przy ustawieniach domyślnych ode45 robi
%  BARDZO mało kroków (ok. 10), więc kółka będą rzadko i
%  przebieg z ode45 wyraźnie odstanie od dokładnego, zwłaszcza uR,
%  które szybko oscyluje. To NIE jest błąd w kodzie - wyjaśnienie
%  jest w komentarzu do Zad 6.

%% =======================================================================
%  ZADANIE 5 (0,4 p.)
%  "Wyznacz maksymalne wartości bezwzględne błędów przybliżenia q(t),
%   uC(t), uR(t) z Zad. 4, traktując jako odniesienie wyniki z Zad. 2.
%   Jaki jest zakres długości kroków całkowania ode45?"
% ========================================================================
%
%  BŁĄD: porównujemy rozwiązanie dokładne (dsolve) i przybliżone (ode45)
%  W TYCH SAMYCH CHWILACH tt (tych zwróconych przez ode45):
%
%     Delta_max[q] = max | q_dokładne(tt) - q_ode45(tt) |
%
%  Żeby policzyć q_dokładne(tt), zamieniamy wzór symboliczny na zwykłą
%  funkcję poleceniem matlabFunction. real() usuwa ewentualne śladowe
%  części urojone, które czasem zostają po dsolve.

q_f  = matlabFunction(qs,  'Vars', t);
uC_f = matlabFunction(uCs, 'Vars', t);
uR_f = matlabFunction(uRs, 'Vars', t);

dq_max  = max(abs(real(q_f(tt))  - q_n));
duC_max = max(abs(real(uC_f(tt)) - uC_n));
duR_max = max(abs(real(uR_f(tt)) - uR_n));

fprintf('\n===== ZADANIE 5 =====\n');
fprintf('Delta_max[q(t)]  = %.4e C\n', dq_max);
fprintf('Delta_max[uC(t)] = %.4e V\n', duC_max);
fprintf('Delta_max[uR(t)] = %.4e V\n', duR_max);

%  KROKI CAŁKOWANIA:
%   Krok = odległość między kolejnymi chwilami, w których solver liczył.
%   UWAGA: ode45 domyślnie ma 'Refine' = 4, tzn. w KAŻDYM kroku dokłada
%   3 punkty interpolowane, czyli zwraca 4 punkty na krok. Dlatego:
%     - prawdziwe kroki:  diff(tt(1:4:end))   <- to jest poprawna odpowiedź
%     - diff(tt) da wartości ~4 razy mniejsze (to tylko odstęp punktów
%       wyjściowych, a nie krok całkowania)
%   Jeśli prowadzący liczy po prostu diff(tt), podaj też tę wersję
%   (wypisuję obie).

h_real = diff(tt(1:4:end));            % prawdziwe kroki całkowania
h_out  = diff(tt);                     % odstępy punktów wyjściowych

fprintf('Liczba kroków ode45 = %d\n', numel(h_real));
fprintf('Delta_t_min = %.4e s,  Delta_t_max = %.4e s   (prawdziwe kroki)\n', ...
        min(h_real), max(h_real));
fprintf('[dla porównania diff(tt): min = %.4e s, max = %.4e s]\n', ...
        min(h_out), max(h_out));

%  >>> ODPOWIEDŹ DO RAMEK: przepisz liczby z Command Window, np.
%      Delta_max[q(t)] = ...e-.. C,  Delta_max[uC(t)] = ... V,
%      Delta_max[uR(t)] = ... V,  Delta_t_min = ... s,  Delta_t_max = ... s
%  (zawsze z jednostkami!)
%  Spodziewaj się, że Delta_t_max będzie bliskie 5e-7 s - to domyślny
%  maksymalny krok ode45: MaxStep = 0.1*(5e-6 - 0).

%% =======================================================================
%  ZADANIE 6 (0,2 p.)
%  "Wyznacz q(t) za pomocą ode45 jeszcze raz, zwiększając dokładność
%   (odeset) tak, aby błędy względne i bezwzględne q(t) nie przekraczały
%   1e-10. Jaki jest zakres długości kroków po tej zmianie?"
% ========================================================================
%
%  JAK TO DZIAŁA:
%   odeset ustawia opcje solvera:
%     'RelTol' - dopuszczalny błąd WZGLĘDNY  (domyślnie 1e-3)
%     'AbsTol' - dopuszczalny błąd BEZWZGLĘDNY (domyślnie 1e-6)
%   ode45 w każdym kroku szacuje błąd i dobiera krok tak, żeby
%   błąd <= max(RelTol*|y|, AbsTol). Mniejsze tolerancje -> mniejsze
%   kroki -> więcej kroków -> dokładniejszy wynik.
%
%  DLACZEGO W ZAD 4 BYŁO TAK NIEDOKŁADNIE:
%   q(t) jest rzędu 1e-11 C, a domyślne AbsTol = 1e-6 jest MILION razy
%   większe. Solver uważa więc każdy błąd q za "pomijalny" i robi
%   ogromne kroki. Przy AbsTol = 1e-10 sytuacja się poprawia (wciąż
%   AbsTol > q, ale RelTol = 1e-10 też pilnuje dokładności).

opcje = odeset('RelTol', 1e-10, 'AbsTol', 1e-10);
[tt6, y6] = ode45(f, tspan, y0, opcje);

h6_real = diff(tt6(1:4:end));          % prawdziwe kroki (Refine = 4)
h6_out  = diff(tt6);

fprintf('\n===== ZADANIE 6 =====\n');
fprintf('Liczba kroków ode45 = %d\n', numel(h6_real));
fprintf('Delta_t_min = %.4e s,  Delta_t_max = %.4e s   (prawdziwe kroki)\n', ...
        min(h6_real), max(h6_real));
fprintf('[dla porównania diff(tt): min = %.4e s, max = %.4e s]\n', ...
        min(h6_out), max(h6_out));
fprintf('(dla ciekawości) nowy Delta_max[q(t)] = %.4e C\n', ...
        max(abs(real(q_f(tt6)) - y6(:,1))));

%  >>> ODPOWIEDŹ DO RAMKI: Delta_t_min = ... s,  Delta_t_max = ... s
%  Kroki powinny być wyraźnie mniejsze niż w Zad 5 (kilka razy 1e-8 s
%  zamiast ~5e-7 s), a kroków kilka razy więcej (u mnie ok. 10 -> ok. 60).
%  Opcjonalnie możesz dorysować wynik na wykresie:
%    figure(1); hold on; plot(tt6, y6(:,1)/C, 'k.', 'DisplayName','u_C - ode45 (tol 1e-10)');

%% =======================================================================
%  ŚCIĄGA - JEŚLI DOSTANIESZ INNY WARIANT
% ========================================================================
%  - Inne źródło, np. e(t) = 1 - exp(-1e7*t):  zmień TYLKO linię
%       e_sym = 1 - exp(-1e7*t);
%    (reszta, łącznie z funkcją e(t) dla ode45, zmieni się sama)
%  - Inne R, L, C, tspan: zmień sekcję DANE.
%  - Pytają o inne wielkości (wszystkie z q i jego pochodnych):
%       i(t)  = q'          -> symbolicznie: diff(qs,t);   ode45: y(:,2)
%       uC(t) = q/C         -> qs/C;                       y(:,1)/C
%       uR(t) = R*q'        -> R*diff(qs,t);               R*y(:,2)
%       uL(t) = L*q''       -> L*diff(qs,t,2);             e(tt) - uC - uR
%    (uL z ode45 najprościej z Kirchhoffa: uL = e - uC - uR)
%  - Inna tolerancja w Zad 6: zmień liczby w odeset.