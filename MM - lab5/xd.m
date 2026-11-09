function [] = lab5_samochody()
% Lab 5 - model jazdy za liderem (wersja z samochodami)
%
% Mamy 6 samochodów jeden za drugim. Samochód 1 (lider) jedzie tak jak mu
% każemy, a każdy następny reaguje na ten przed nim:
%
%   a_i = alpha * v_i(t)^u * (v_{i-1}(t-TR) - v_i(t-TR)) / (x_{i-1}(t-TR) - x_i(t-TR))^lambda
%
% - jak ten przede mną jedzie wolniej (licznik < 0) to hamuję
% - im bliżej jestem (mały mianownik) tym mocniej reaguję
% - kierowca reaguje z opóźnieniem TR, więc bierzemy wartości sprzed TR
%
% Euler: v(p+1) = v(p) + dt*a(p),  x(p+1) = x(p) + dt*v(p)
% Opóźnienie TR w krokach: d = TR/dt = 70, czyli (t - TR) to indeks p - d.
% round() bo 0.7/0.01 = 69.99999... i nie da się tego użyć jako indeksu.

% Definiujemy stałe
dt = 0.01;
T = 0:dt:30;
N = length(T);

v0 = 22.2; % [m/s]
dx = 8; % [m]
TR = 0.7; % [s]
alpha = 0.3;
u = 0.9;
lambda = 0.8;
d = round(TR/dt); % opóźnienie w krokach


% Zadanie 1
% Liczymy TYLKO samochód 1 (lidera). Przyspieszenie jest zadane:
%   0-2 s: 0,  2-4 s: -a0,  4-6 s: 0,  6-8 s: a0,  potem 0
% T < 4 a nie T <= 4, bo inaczej hamuje o jeden krok za długo.
% Prędkość i położenie liczymy Eulerem, zaczynając od v = v0, x = 0.
% Po hamowaniu v = 22.2 - 2*1 = 20.2, potem wraca do 22.2.
a0 = 1; % [m/s^2]

a1 = zeros(1, N);
a1(T >= 2 & T < 4) = -a0;
a1(T >= 6 & T < 8) = a0;

v1 = zeros(1, N);
x1 = zeros(1, N);
v1(1) = v0;
x1(1) = 0;

for p = 1:N-1
    v1(p+1) = v1(p) + dt*a1(p);
    x1(p+1) = x1(p) + dt*v1(p);
end

figure(1);
clf;
plot(T, a1);
title("Zad 1 - przyspieszenie a(t)");
xlabel("t, [s]");
ylabel("a, [m/s^2]");
grid on;

figure(2);
clf;
plot(T, v1);
title("Zad 1 - prędkość v(t)");
xlabel("t, [s]");
ylabel("v, [m/s]");
grid on;

figure(3);
clf;
plot(T, x1);
title("Zad 1 - położenie x(t)");
xlabel("t, [s]");
ylabel("x, [m]");
grid on;


% Zadanie 2
% Teraz samochody 2-6. Lidera już mamy z zadania 1 (wiersz 1 macierzy).
% - na początku co 8 m: x = 0, -8, -16, -24, -32, -40
% - do t = TR jadą ze stałą v0 (a = 0), bo p - d byłoby < 1
% - potem a ze wzoru (1), a v i x Eulerem
% Pętla po czasie na zewnątrz, po samochodach w środku.
a = zeros(6, N);
v = zeros(6, N);
x = zeros(6, N);

a(1, :) = a1; % lider z zadania 1
v(1, :) = v1;
x(1, :) = x1;

v(2:6, 1) = v0;
x(2:6, 1) = -(1:5)*dx;

for p = 1:N-1
    for i = 2:6
        if p > d
            a(i, p) = alpha*(v(i, p)^u)...
                *(v(i-1, p-d) - v(i, p-d))...
                /((x(i-1, p-d) - x(i, p-d))^lambda);
        end
        v(i, p+1) = v(i, p) + dt*a(i, p);
        x(i, p+1) = x(i, p) + dt*v(i, p);
    end
end

% Każdy kolejny hamuje później i mocniej niż poprzedni
figure(4);
clf;
plot(T, v);
title("Zad 2 - prędkości pojazdów 1-6");
xlabel("t, [s]");
ylabel("v, [m/s]");
legend("1", "2", "3", "4", "5", "6");
grid on;


% Zadanie 3
% Bierzemy x z zadania 2 i liczymy:
%   y = x - (x1(0) + v1(0)*t) = x - v0*t
% Odejmujemy jazdę ze stałą prędkością, żeby było widać odstępy
% (same x to prawie proste linie). Jak się dwie linie przetną to jest kolizja.
y = x - v0*T;

figure(5);
clf;
plot(T, y);
title("Zad 3 - znormalizowane położenie y(t)");
xlabel("t, [s]");
ylabel("y, [m]");
legend("1", "2", "3", "4", "5", "6");
grid on;


% Zadanie 4
% Powtarzamy zadanie 1 i 2 dla a0 = 0.1, 0.2, 0.3, ...
% Po każdym kroku sprawdzamy odstępy. Jak gdzieś x(i-1) - x(i) <= 0
% to kolizja -> przerywamy. Ostatnie a0 bez kolizji to wynik.
% Wychodzi 1.6 (przy 1.7 jest kolizja).
a0max = 0;
for a0 = 0.1:0.1:5
    % lider (jak w zad 1)
    a = zeros(6, N);
    v = zeros(6, N);
    x = zeros(6, N);
    a(1, T >= 2 & T < 4) = -a0;
    a(1, T >= 6 & T < 8) = a0;
    v(:, 1) = v0;
    x(:, 1) = -(0:5)*dx;

    kolizja = false;
    for p = 1:N-1
        % Samochód 1
        v(1, p+1) = v(1, p) + dt*a(1, p);
        x(1, p+1) = x(1, p) + dt*v(1, p);

        % Inne (jak w zad 2)
        for i = 2:6
            if p > d
                a(i, p) = alpha*(v(i, p)^u)...
                    *(v(i-1, p-d) - v(i, p-d))...
                    /((x(i-1, p-d) - x(i, p-d))^lambda);
            end
            v(i, p+1) = v(i, p) + dt*a(i, p);
            x(i, p+1) = x(i, p) + dt*v(i, p);
        end

        % Sprawdzamy kolizję
        if any(x(1:5, p+1) - x(2:6, p+1) <= 0)
            kolizja = true;
            break;
        end
    end

    if kolizja
        break;
    end
    a0max = a0;
end
disp("Zad 4: a0 = " + a0max);


% Zadanie 5
% To samo co zad 2, ale kierowca patrzy też w lusterko. Dodaję drugi
% człon, taki sam jak w (1), tylko względem samochodu z tyłu (i+1):
%
%   + beta * v_i^u * (v_{i+1} - v_i) / (x_i - x_{i+1})^lambda
%
% Jak ten z tyłu się zbliża (v_{i+1} > v_i) to człon jest dodatni
% -> hamuję łagodniej, żeby we mnie nie wjechał.
% Samochód 6 nie ma nikogo za sobą, więc u niego tego członu nie ma.
% beta = 0.1 działa (najmniejszy odstęp ok 2.9 m).
a0 = 1.8; % [m/s^2]
beta = 0.1;

a = zeros(6, N);
v = zeros(6, N);
x = zeros(6, N);
a(1, T >= 2 & T < 4) = -a0;
a(1, T >= 6 & T < 8) = a0;
v(:, 1) = v0;
x(:, 1) = -(0:5)*dx;

for p = 1:N-1
    % Samochód 1
    v(1, p+1) = v(1, p) + dt*a(1, p);
    x(1, p+1) = x(1, p) + dt*v(1, p);

    % Inne
    for i = 2:6
        if p > d
            a(i, p) = alpha*(v(i, p)^u)...
                *(v(i-1, p-d) - v(i, p-d))...
                /((x(i-1, p-d) - x(i, p-d))^lambda);
            if i < 6 % ten z tyłu
                a(i, p) = a(i, p) + beta*(v(i, p)^u)...
                    *(v(i+1, p-d) - v(i, p-d))...
                    /((x(i, p-d) - x(i+1, p-d))^lambda);
            end
        end
        v(i, p+1) = v(i, p) + dt*a(i, p);
        x(i, p+1) = x(i, p) + dt*v(i, p);
    end
end
disp("Zad 5: najmniejszy odstęp = " + min(min(x(1:5, :) - x(2:6, :))));

y = x - v0*T;
figure(6);
clf;
plot(T, y);
title("Zad 5 - zmodyfikowany model, a0 = 1.8");
xlabel("t, [s]");
ylabel("y, [m]");
legend("1", "2", "3", "4", "5", "6");
grid on;

end % Function

function [] = lab06()
% Lab 6 - model drapieżnik-ofiara (Lotki-Volterry)
%
% Mamy dwa gatunki: x - ofiary (np. zające), y - drapieżniki (np. lisy).
%
%   dx/dt = p1*x - p2*x*y
%   dy/dt = p3*x*y - p4*y
%
% - p1*x   : ofiary się rozmnażają (im więcej ich jest, tym szybciej)
% - p2*x*y : drapieżniki zjadają ofiary (im częściej się spotykają, tym więcej)
% - p3*x*y : drapieżniki rozmnażają się dzięki zjedzonym ofiarom
% - p4*y   : drapieżniki umierają, jak nie mają co jeść
%
% Co się dzieje: dużo ofiar -> drapieżniki mają jedzenie i ich przybywa ->
% zjadają ofiary i ofiar ubywa -> drapieżniki nie mają co jeść i ich ubywa
% -> ofiary znowu się rozmnażają ... i tak w kółko. Wychodzą drgania,
% drapieżniki są trochę "spóźnione" względem ofiar.
%
% Punkt równowagi (nic się nie zmienia): x = p4/p3 = 270, y = p1/p2 = 80.
% Zaczynamy od x = 100, y = 60, więc układ krąży wokół tego punktu.
% Okres drgań wychodzi ok 0.53, więc w t od 0 do 1 widać prawie 2 okresy.
%
% Zapisujemy oba równania razem jako wektor z = [x; y]:
%   z' = f(t, z),  gdzie z(1) = x, z(2) = y
 
% Definiujemy parametry
p1 = 12;
p2 = 0.15;
p3 = 0.05;
p4 = 13.5;
 
% Warunki początkowe
x0 = 100;
y0 = 60;
z0 = [x0; y0];
 
tspan = [0, 1]; % Przebieg czasu
 
% Prawa strona równań jako funkcja anonimowa.
% Zwraca wektor kolumnowy [x'; y'].
f = @(t, z)[p1 * z(1) - p2 * z(1) * z(2); p3 * z(1) * z(2) - p4 * z(2)];
 
 
% Zadanie 1
% Rozwiązujemy wbudowaną funkcją ode45 (metoda Rungego-Kutty rzędu 4/5,
% sama dobiera krok). To traktujemy jako wynik "dokładny" do porównań.
% options: RelTol i AbsTol to dopuszczalny błąd. Dajemy bardzo mały
% (1e-12), żeby wynik był jak najdokładniejszy.
% ode45 zwraca: t - chwile czasu (sama je wybiera, nie są równo co 0.01),
%               z - macierz, kolumna 1 to x, kolumna 2 to y.
options = odeset('RelTol', 1e-12, 'AbsTol', 1e-12);
 
[t, z] = ode45(f, tspan, z0, options);
 
x = z(:, 1);
y = z(:, 2);
 
figure(1);
clf;
hold on;
grid on;
plot(t, x, 'r--', 'DisplayName', 'ode45');
legend;
title('Liczebność ofiar x(t)');
xlabel('t, [s]');
ylabel('n, populacja');
 
figure(2);
clf;
hold on;
grid on;
plot(t, y, 'r--', 'DisplayName', 'ode45');
legend;
title('Liczebność drapieżników y(t)');
xlabel('t, [s]');
ylabel('n, populacja');
 
% Wynik: ofiary rosną od 100 do ok 587, drapieżniki od 60 do ok 181.
% Maksimum drapieżników (t = ok 0.37) jest PO maksimum ofiar (t = ok 0.28),
% bo drapieżniki najpierw muszą się najeść.
 
 
% Zadanie 2
% To samo, ale jawną metodą Eulera ze stałym krokiem h = 0.01.
%   z(i) = z(i-1) + h * f(t(i-1), z(i-1))
% czyli: nowa wartość = stara + krok * pochodna w starym punkcie.
%
% Z to macierz N x 2: wiersz i to [x, y] w chwili t(i).
% f chce wektor KOLUMNOWY i zwraca kolumnowy, a w Z trzymamy WIERSZE,
% dlatego są apostrofy (transpozycja): Z(i-1, :)' -> kolumna, f(...)' -> wiersz.
h = 0.01;
t = 0:h:1;
N = length(t);
Z = zeros(N, 2);
Z(1, :) = z0;
 
for i = 2:N
    Z(i, :) = Z(i-1, :) + h * f(t(i-1), Z(i-1, :)')';
end % for
 
X = Z(:, 1);
Y = Z(:, 2);
 
figure(1);
plot(t, X, 'b', 'DisplayName', 'Euler');
 
figure(2);
plot(t, Y, 'b', 'DisplayName', 'Euler');
 
% Wynik: Euler bardzo się rozjeżdża z ode45. Drgania zamiast się
% powtarzać ROSNĄ (ofiary do ok 977 zamiast 587, drapieżniki do ok 354
% zamiast 181). Euler idzie po stycznej, a rozwiązanie jest "zakrzywione"
% (krąży), więc w każdym kroku trochę wypada na zewnątrz i błąd się sumuje.
% Mniejsze h by pomogło, ale Euler jest tylko rzędu 1 (błąd ~ h).
 
 
% Zadanie 3
% Zmodyfikowana metoda Eulera (metoda punktu środkowego):
%   1) robimy pół kroku zwykłym Eulerem:
%        z_pol = z(i-1) + (h/2) * f(t(i-1), z(i-1))
%   2) liczymy pochodną w tym środkowym punkcie i dopiero nią robimy
%      cały krok:
%        z(i) = z(i-1) + h * f(t(i-1) + h/2, z_pol)
% Pochodna ze środka kroku lepiej pasuje do całego kroku niż ta z początku,
% więc metoda jest rzędu 2 (błąd ~ h^2) - dużo dokładniejsza.
Z_ = zeros(N, 2);
Z_(1, :) = z0;
 
for i = 2:N
    z_pol = Z_(i-1, :) + 0.5 * h * f(t(i-1), Z_(i-1, :)')'; % pół kroku
    Z_(i, :) = Z_(i-1, :) + h * f(t(i-1) + 0.5 * h, z_pol')'; % cały krok
end % for
 
X_ = Z_(:, 1);
Y_ = Z_(:, 2);
 
figure(1);
plot(t, X_, 'm-.', 'DisplayName', 'Euler zmodyfikowany');
 
figure(2);
plot(t, Y_, 'm-.', 'DisplayName', 'Euler zmodyfikowany');
 
% Wynik: prawie pokrywa się z ode45 (max ofiar ok 589 zamiast 587,
% największy błąd ok 6 dla ofiar i ok 2 dla drapieżników, a w zwykłym
% Eulerze ponad 700 i 200). Przy tym samym kroku h jest dużo lepszy.
 
end % Function
 