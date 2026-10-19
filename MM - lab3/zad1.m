function zad1()
%ZAD1 Summary of this function goes here
%   Detailed explanation goes here
figure; clf
L = 5; Q = 2; rho = 1.06; mu = 0.053; A0 = 0.2; P0 = 1.2e5;
sigma = 0.3;
punkty = linspace(0, L, 500);

syms z P(z)

Az = A0 * (1-sigma + ((z - L/2) / (L/2))^2 * sigma);

wzor = 4*Q^2/3 * diff(1/Az, z) + Az/rho * diff(P, z) ...
    + 8*pi*mu*Q/(rho*Az) == 0;

solve = dsolve(wzor, P(0) == P0);

Ap = matlabFunction(Az);
Pp = matlabFunction(solve);

subplot(2, 1, 1);
hold on;
plot(punkty, Ap(punkty));
subplot(2, 1, 2)
hold on;
plot(punkty, Pp(punkty));


sigma = 0.8;
Az = A0 * (1-sigma + ((z - L/2) / (L/2))^2 * sigma);

wzor = 4*Q^2/3 * diff(1/Az, z) + Az/rho * diff(P, z) ...
    + 8*pi*mu*Q/(rho*Az) == 0;

solve = dsolve(wzor, P(0) == P0);

Ap = matlabFunction(Az);
Pp = matlabFunction(solve);

subplot(2, 1, 1);
hold on;

plot(punkty, Ap(punkty));
subplot(2, 1, 2)
hold on;
plot(punkty, Pp(punkty));
hold off;

