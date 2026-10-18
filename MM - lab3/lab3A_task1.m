function lab3A_task1()
% Zadanie 1 (wersja A, z kodu): dsolve, A(z) = A0*(1 - sigma*z/L)
L = 5; Q = 2; rho = 1.06; mu = 0.053; A0 = 0.2; P0 = 1.2e5;
sigmy = [0.3 0.8];
zz = linspace(0, L, 500);

syms z P(z)

figure(1); clf
for k = 1:numel(sigmy)
    s = sigmy(k);

    Az = A0*(1 - s*z/L);                                 % zwezenie liniowe

    rownanie = 4*Q^2/3 * diff(1/Az, z) + Az/rho * diff(P, z) ...
        + 8*pi*mu*Q/(rho*Az) == 0;                  % wzor (1)

    Psol = dsolve(rownanie, P(0) == P0);

    Af = matlabFunction(Az);
    Pf = matlabFunction(Psol);

    subplot(2,1,1); hold on; plot(zz, Af(zz), 'LineWidth', 2)
    subplot(2,1,2); hold on; plot(zz, Pf(zz), 'LineWidth', 2)

    fprintf('sigma = %.1f:  P(L) = %.2f   P(0)-P(L) = %.2f\n', s, Pf(L), P0 - Pf(L));
end

subplot(2,1,1); grid on; xlabel('z [cm]'); ylabel('A(z) [cm^2]')
title('Pole przekroju A(z)'); legend('\sigma = 0.3', '\sigma = 0.8')
subplot(2,1,2); grid on; xlabel('z [cm]'); ylabel('P(z) [g/(cm s^2)]')
title('Cisnienie P(z) - dsolve'); legend('\sigma = 0.3', '\sigma = 0.8')
end