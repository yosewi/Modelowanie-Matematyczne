function zad2()
%ZAD2 Summary of this function goes here
%   Detailed explanation goes here
L = 5; Q = 2; rho = 1.06; mu = 0.053; A0 = 0.2; P0 = 1.2e5;
s = 0.3;
epsi = 1e-3;
zz = linspace(0,L,2000);

figure(2); clf

Af = @(z) A0 * ( (z < 0.3*L | z > 0.7*L) + (1 - s)*(z >= 0.3*L & z <= 0.7*L) );

dAdz = @(z) (Af(z + epsi) - Af(z - epsi)) / (2*epsi);
d1A  = @(z) -1 ./ Af(z).^2 .* dAdz(z);  

f = @(z, P) -rho ./ Af(z) .* ( 4*Q^2/3 .* d1A(z) + 8*pi*mu*Q ./ (rho*Af(z)) );

opcje = odeset('MaxStep', epsi/5);
[zs, Ps] = ode45(f, [0 L], P0, opcje);

subplot(2,1,1); hold on; plot(zz, Af(zz), 'LineWidth', 2)
subplot(2,1,2); hold on; plot(zs, Ps, 'LineWidth', 2)

s = 0.8

epsi = 1e-3;
zz = linspace(0,L,2000);

Af = @(z) A0 * ( (z < 0.3*L | z > 0.7*L) + (1 - s)*(z >= 0.3*L & z <= 0.7*L) );

dAdz = @(z) (Af(z + epsi) - Af(z - epsi)) / (2*epsi);
d1A  = @(z) -1 ./ Af(z).^2 .* dAdz(z);  

f = @(z, P) -rho ./ Af(z) .* ( 4*Q^2/3 .* d1A(z) + 8*pi*mu*Q ./ (rho*Af(z)) );

opcje = odeset('MaxStep', epsi/5);
[zs, Ps] = ode45(f, [0 L], P0, opcje);

subplot(2,1,1); hold on; plot(zz, Af(zz), 'LineWidth', 2)
subplot(2,1,2); hold on; plot(zs, Ps, 'LineWidth', 2)