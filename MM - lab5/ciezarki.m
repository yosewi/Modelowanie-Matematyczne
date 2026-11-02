function ciezarki()
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