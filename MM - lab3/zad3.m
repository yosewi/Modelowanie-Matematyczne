function zad3()
%ZAD3 Summary of this function goes here
%   Detailed explanation goes here
L = 5; Q = 2; rho = 1.06; mu = 0.053; A0 = 0.2; P0 = 1.2e5;

dane = load('MM_23Z_L3_14B_DANE.mat');
z_pom = dane.z;      % 20 punktow z
A_pom = dane.A;

A2 = @(z, s) A0 * (1 - s + ((z - L/2)/(L/2)).^2 * s);                          % wzor (2)
A3 = @(z, s) A0 * ((z < 0.3*L | z > 0.7*L) + (1 - s)*(z >= 0.3*L & z <= 0.7*L)); % wzor (3)

sigmy = 0:0.1:1;
for k = 1:length(sigmy)
    s = sigmy(k);
    A_model = A0*(1 - s + ((z_pom - L/2)/(L/2)).^2 * s);
    blad(k) = sum((A_pom - A_model).^2); 
end
[~, nr] = min(blad); 
s = sigmy(nr);

syms z P(z)

Az = A0*(1 - s + ((z - L/2)/(L/2))^2 * s);
rownanie = 4*Q^2/3 * diff(1/Az, z) + Az/rho * diff(P, z) ...
    + 8*pi*mu*Q/(rho*Az) == 0;
Psol = dsolve(rownanie, P(0) == P0);
Pf = matlabFunction(Psol);

disp(['P(0) - P(L) = ' num2str(P0 - Pf(L))])