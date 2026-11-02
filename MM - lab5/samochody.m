function samochody()
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


% Zadanie 1 i 2
% Zad 1: lider ma zadane przyspieszenie:
%   0-2 s: 0,  2-4 s: -a0,  4-6 s: 0,  6-8 s: a0,  potem 0
% T < 4 a nie T <= 4, bo inaczej hamuje o jeden krok za długo.
% v i x liczymy Eulerem. Po hamowaniu v = 22.2 - 2*1 = 20.2, potem wraca do 22.2.
%
% Zad 2: reszta samochodów
% - na początku co 8 m: x = 0, -8, -16, -24, -32, -40
% - do t = TR jadą ze stałą v0 (a = 0), bo p - d byłoby < 1
% - potem a ze wzoru (1)
% Pętla po czasie na zewnątrz, po samochodach w środku.
a0 = 1; % [m/s^2]

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
        end
        v(i, p+1) = v(i, p) + dt*a(i, p);
        x(i, p+1) = x(i, p) + dt*v(i, p);
    end
end

figure(1);
clf;
plot(T, a(1, :));
title("Zad 1 - przyspieszenie a(t)");
xlabel("t, [s]");
ylabel("a, [m/s^2]");
grid on;

figure(2);
clf;
plot(T, v(1, :));
title("Zad 1 - prędkość v(t)");
xlabel("t, [s]");
ylabel("v, [m/s]");
grid on;

figure(3);
clf;
plot(T, x(1, :));
title("Zad 1 - położenie x(t)");
xlabel("t, [s]");
ylabel("x, [m]");
grid on;

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
% y = x - (x1(0) + v1(0)*t) = x - v0*t
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
% Zwiększamy a0 co 0.1 i dla każdego liczymy wszystko od nowa.
% Jak gdzieś x(i-1) - x(i) <= 0 to kolizja -> przerywamy (dalej odległość
% jest ujemna i ^lambda daje liczby zespolone).
% Ostatnie a0 bez kolizji to wynik. Wychodzi 1.6 (przy 1.7 jest kolizja).
a0max = 0;
for a0 = 0.1:0.1:5
    a = zeros(6, N);
    v = zeros(6, N);
    x = zeros(6, N);
    a(1, T >= 2 & T < 4) = -a0;
    a(1, T >= 6 & T < 8) = a0;
    v(:, 1) = v0;
    x(:, 1) = -(0:5)*dx;

    kolizja = false;
    for p = 1:N-1
        v(1, p+1) = v(1, p) + dt*a(1, p);
        x(1, p+1) = x(1, p) + dt*v(1, p);
        for i = 2:6
            if p > d
                a(i, p) = alpha*(v(i, p)^u)...
                    *(v(i-1, p-d) - v(i, p-d))...
                    /((x(i-1, p-d) - x(i, p-d))^lambda);
            end
            v(i, p+1) = v(i, p) + dt*a(i, p);
            x(i, p+1) = x(i, p) + dt*v(i, p);
        end
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
% Kierowca patrzy też w lusterko. Dodaję drugi człon, taki sam jak
% w (1), tylko liczony względem samochodu z tyłu (i+1):
%
%   + beta * v_i^u * (v_{i+1} - v_i) / (x_i - x_{i+1})^lambda
%
% Jak ten z tyłu się zbliża (v_{i+1} > v_i) to człon jest dodatni
% -> hamuję łagodniej, żeby we mnie nie wjechał.
% Samochód 6 nie ma nikogo za sobą, więc u niego tego członu nie ma.
% beta = 0.1 działa (najmniejszy odstęp ok 2.9 m). Działa od ok 0.02 do 0.1,
% za duże (>= 0.12) znowu daje kolizję, bo za bardzo ucieka do przodu.
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
    v(1, p+1) = v(1, p) + dt*a(1, p);
    x(1, p+1) = x(1, p) + dt*v(1, p);
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