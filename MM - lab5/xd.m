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

function [] = lab5_ciezarek()
% Lab 5 - ciężarek na sprężynie
%
% Ciężarek o masie m na sprężynie (k) z tłumieniem (b), działa siła F(t):
%
%   m*x'' + b*x' + k*x = F(t)
%
% m*x'' - masa razy przyspieszenie
% b*x'  - tłumienie (opór proporcjonalny do prędkości)
% k*x   - siła sprężyny

% Definiujemy stałe
m = 0.5; % [kg]
k = 1; % [N/m]
b = 0.1; % [N * s / m]
F0 = 0.1; % [N]


% Zadanie 1
% F(t) = F0*(1 - exp(-0.2*t)) dla t >= 0, czyli siła rośnie od 0 do F0.
% Rozwiązujemy Fourierem. Fourier zamienia pochodne na mnożenie przez i*w:
%   x' -> i*w*X(w),   x'' -> -w^2*X(w)
% więc dostajemy zwykłe równanie:
%   (k - m*w^2 + i*b*w) * X(w) = F(w)
% isolate() wyciąga X(w), ifourier() wraca do x(t).
% Na wykresie: ciężarek drga, drgania gasną i ustala się w x = F0/k = 0.1 m.
syms x(t) F(t) w t % Definiujemy zmienne symboliczne
tspan = [0, 60];

dx = diff(x, t); % Definiujemy pochodne 1. i 2. rzędu
d2x = diff(x, t, 2);

% Funkcja przełożenia siły
F(t) = F0 * (1 - exp((-1) * 0.2 * t)) * heaviside(t);

eqn = m * d2x + b * dx + k * x == F(t); % Równanie różniczkowe

eqnF = fourier(lhs(eqn)) == fourier(rhs(eqn));
eqnF = isolate(eqnF, fourier(x(t), t, w));

yF = ifourier(rhs(eqnF));

figure(1);
clf;
hold on;
fplot(yF, tspan);
title("Zad 1 - Ruch ciężarka x(t)");
xlabel("t, [s]");
ylabel("x, [m]");
grid on;


% Zadanie 2
% Z zadania 1: X(w) = F(w) / (k - m*w^2 + i*b*w)
% Moduł |a + i*c| = sqrt(a^2 + c^2), więc charakterystyka amplitudowa:
%   A(w) = 1 / sqrt((k - m*w^2)^2 + (b*w)^2)
% Mówi ile razy drgania są większe niż siła przy częstości w.
% - w = 0: A = 1/k = 1
% - w = sqrt(k/m) = 1.41: rezonans, A = ok 7.07
% - duże w: A -> 0
syms A(w)
wspan = [0, 10];
A(w) = 1 / sqrt((k - m * w^2)^2 + (b * w)^2);

figure(2); % Szkicujemy wykres A(w)
clf;
fplot(A, wspan);
title("Zad 2 - Charakterystyka amplitudowa A(w)");
xlabel("w, [rad/s]");
ylabel("A");
grid on;


% Zadanie 3
% Siła okresowa F = F0*cos(w0*t) dla w0 = 0.1, 1.4, 3.2 (z kodu kolegi).
% 0.1 - poniżej rezonansu, 1.4 - prawie rezonans, 3.2 - powyżej.
% Po ustaleniu amplituda = F0*A(w0): ok 0.1 m, 0.71 m, 0.024 m.
% Ciężarek na początku stoi: x(0) = 0, x'(0) = 0.
% Używam dsolve zamiast Fouriera, bo Fourier z cos daje delty Diraca
% i ifourier często sobie z tym nie radzi.
w0 = [0.1 1.4 3.2];
figure(3);
clf;
for i = 1:3
    fc = F0 * cos(w0(i) * t);
    eqn = m * d2x + b * dx + k * x == fc;
    xc = dsolve(eqn, [x(0) == 0, dx(0) == 0]);
    subplot(3, 1, i);
    fplot(xc, tspan);
    title("Zad 3 - w0 = " + w0(i));
    xlabel("t, [s]");
    ylabel("x, [m]");
    grid on;
end


% Zadanie 4
% Zadanie 1 numerycznie metodą Eulera i porównanie z Fourierem.
% Euler jest dla 1. rzędu, więc rozbijamy na dwa równania (v = x'):
%   x' = v
%   v' = (F - b*v - k*x) / m
% Euler: x(p+1) = x(p) + dt*v(p)
%        v(p+1) = v(p) + dt*(F(p) - b*v(p) - k*x(p))/m
% Przy dt = 0.01 pokrywa się z Fourierem. Przy dt >= 0.1 drgania
% zamiast gasnąć rosną (Euler jest niestabilny).
dt = 0.01;
T = 0:dt:60;
N = length(T);

Fn = F0 * (1 - exp(-0.2 * T));
xn = zeros(1, N);
vn = zeros(1, N);

for p = 1:N-1
    xn(p+1) = xn(p) + dt*vn(p);
    vn(p+1) = vn(p) + dt*(Fn(p) - b*vn(p) - k*xn(p))/m;
end

figure(4);
clf;
hold on;
plot(T, xn);
fplot(yF, tspan, '--');
title("Zad 4 - Euler vs Fourier");
xlabel("t, [s]");
ylabel("x, [m]");
legend("Euler", "Fourier");
grid on;


% Zadanie 5
% Wpływ tłumienia b na A(w). Im mniejsze b tym wyższy i węższy pik
% rezonansowy (w rezonansie A = 1/(b*w), więc zależy od b).
bb = [0.05 0.1 0.2 0.5];
figure(5);
clf;
hold on;
for i = 1:4
    Ab(w) = 1 / sqrt((k - m * w^2)^2 + (bb(i) * w)^2);
    fplot(Ab, wspan);
end
title("Zad 5 - A(w) dla różnych b");
xlabel("w, [rad/s]");
ylabel("A");
legend("b = 0.05", "b = 0.1", "b = 0.2", "b = 0.5");
grid on;

end % Function