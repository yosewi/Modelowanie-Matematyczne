function zad3latwiej()
L = 5; Q = 2; rho = 1.06; mu = 0.053; A0 = 0.2; P0 = 1.2e5;

% --- wczytanie pomiarow ---
dane  = load('MM_23Z_L3_14B_DANE.mat');
z_pom = dane.z;      % 20 punktow z
A_pom = dane.A;      % 20 zmierzonych pol przekroju

% --- KROK 1: dopasowanie sigma ---
sigmy = 0:0.1:1;
for k = 1:length(sigmy)
    s = sigmy(k);
    A_model = A0*(1 - s + ((z_pom - L/2)/(L/2)).^2 * s);   % wzor (2)
    blad(k) = sum((A_pom - A_model).^2);                   % im mniej, tym lepiej
end
[~, nr] = min(blad);        % nr = numer najmniejszego bledu
s = sigmy(nr);
disp(['Najlepsze sigma = ' num2str(s)])

% --- KROK 2: cisnienie (tak jak w zadaniu 1) ---
syms z P(z)
Az = A0*(1 - s + ((z - L/2)/(L/2))^2 * s);
rownanie = 4*Q^2/3 * diff(1/Az, z) + Az/rho * diff(P, z) ...
    + 8*pi*mu*Q/(rho*Az) == 0;
Psol = dsolve(rownanie, P(0) == P0);
Pf = matlabFunction(Psol);

% --- KROK 3: wynik ---
disp(['P(0) - P(L) = ' num2str(P0 - Pf(L))])

% --- wykresy ---
zz = linspace(0, L, 500);
figure(3); clf
subplot(2,1,1)
plot(z_pom, A_pom, 'ko', zz, A0*(1 - s + ((zz - L/2)/(L/2)).^2 * s), 'r-')
legend('pomiary', 'model (2)'); title('Dopasowanie A(z)')
subplot(2,1,2)
plot(zz, Pf(zz)); title('P(z)')
end