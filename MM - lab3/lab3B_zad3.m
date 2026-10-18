function lab3B_zad3()
% Zadanie 3 (wersja B): dopasowanie modelu A(z) do pomiarow i obliczenie P(0)-P(L)
L = 5; Q = 2; rho = 1.06; mu = 0.053; A0 = 0.2; P0 = 1.2e5;

% Wczytanie do struktury -- nie zasmieca przestrzeni nazw
% (zmienna A z pliku zaslonilaby funkcje A.m, gdyby taka byla w folderze)
dane = load('MM_23Z_L3_14B_DANE.mat');
zd = dane.z(:);  Ad = dane.A(:);

% Oba modele jako funkcje (z, sigma)
A2 = @(z, s) A0 * (1 - s + ((z - L/2)/(L/2)).^2 * s);                          % wzor (2)
A3 = @(z, s) A0 * ((z < 0.3*L | z > 0.7*L) + (1 - s)*(z >= 0.3*L & z <= 0.7*L)); % wzor (3)

% Przeszukanie sigma co 0.1 -- blad = suma kwadratow odchylen (SSE)
sig  = 0:0.1:1;
err2 = arrayfun(@(s) sum((Ad - A2(zd, s)).^2), sig);
err3 = arrayfun(@(s) sum((Ad - A3(zd, s)).^2), sig);
[e2, i2] = min(err2);  [e3, i3] = min(err3);
fprintf('Model (2): najlepsze sigma = %.1f, SSE = %.5f\n', sig(i2), e2);
fprintf('Model (3): najlepsze sigma = %.1f, SSE = %.5f\n', sig(i3), e3);

if e2 <= e3
    s = sig(i2); Af = @(z) A2(z, s); nazwa = '(2)';
else
    s = sig(i3); Af = @(z) A3(z, s); nazwa = '(3)';
end
fprintf('Wybrano model %s z sigma = %.1f\n', nazwa, s);

% P(z) przez ode45 (jak w Zadaniu 2, tylko z dopasowanym A)
epsi = 1e-3;
dAdz = @(z) (Af(z + epsi) - Af(z - epsi)) / (2*epsi);
d1A  = @(z) -1 ./ Af(z).^2 .* dAdz(z);
f    = @(z, P) -rho ./ Af(z) .* ( 4*Q^2/3 .* d1A(z) + 8*pi*mu*Q ./ (rho*Af(z)) );
[zs, Ps] = ode45(f, [0 L], P0, odeset('MaxStep', epsi/5));

fprintf('P(0) - P(L) = %.2f g/(cm s^2)\n', P0 - Ps(end));

% Kontrola: gdy A(0) = A(L), czlon inercyjny sie zeruje i zostaje tylko lepkosc
kontrola = 8*pi*mu*Q * integral(@(z) 1 ./ Af(z).^2, 0, L, 'Waypoints', [0.3 0.7]*L);
fprintf('Kontrola (wzor zamkniety): %.2f\n', kontrola);

% Wykresy
zz = linspace(0, L, 1000);
figure(3); clf
subplot(2,1,1); hold on; grid on
plot(zd, Ad, 'ko', 'MarkerFaceColor', 'k')
plot(zz, A2(zz, sig(i2)), 'LineWidth', 2)
plot(zz, A3(zz, sig(i3)), 'LineWidth', 2)
legend('pomiary', sprintf('model (2), \\sigma = %.1f', sig(i2)), ...
    sprintf('model (3), \\sigma = %.1f', sig(i3)))
xlabel('z [cm]'); ylabel('A(z)'); title('Dopasowanie modelu do danych')
subplot(2,1,2); plot(zs, Ps, 'LineWidth', 2); grid on
xlabel('z [cm]'); ylabel('P(z)'); title('Cisnienie dla dopasowanego modelu')
end