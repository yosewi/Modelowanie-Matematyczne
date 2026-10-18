function lab3A_task2()
% Zadanie 2 (wersja A, z kodu): ode45, A(z) = A0*(1 - sigma*z/L)
L = 5; Q = 2; rho = 1.06; mu = 0.053; A0 = 0.2; P0 = 1.2e5;
sigmy = [0.3 0.8];
epsi = 1e-6;                          % A(z) jest gladkie, wystarczy male epsilon
zz = linspace(0, L, 500);

figure(2); clf
for k = 1:numel(sigmy)
    s = sigmy(k);

    Af   = @(z) A0*(1 - s*z/L);
    dAdz = @(z) (Af(z + epsi) - Af(z - epsi)) / (2*epsi);   % wzor (5)
    d1A  = @(z) -1 ./ Af(z).^2 .* dAdz(z);                  % wzor (4)

    % dP/dz = -rho/A * ( 4Q^2/3 * d/dz(1/A) + 8*pi*mu*Q/(rho*A) )
    f = @(z, P) -rho ./ Af(z) .* ( 4*Q^2/3 .* d1A(z) + 8*pi*mu*Q ./ (rho*Af(z)) );

    [zs, Ps] = ode45(f, [0 L], P0);

    subplot(2,1,1); hold on; plot(zz, Af(zz), 'LineWidth', 2)
    subplot(2,1,2); hold on; plot(zs, Ps, 'LineWidth', 2)

    fprintf('sigma = %.1f:  P(L) = %.2f   P(0)-P(L) = %.2f\n', s, Ps(end), P0 - Ps(end));
end

subplot(2,1,1); grid on; xlabel('z [cm]'); ylabel('A(z) [cm^2]')
title('Pole przekroju A(z)'); legend('\sigma = 0.3', '\sigma = 0.8')
subplot(2,1,2); grid on; xlabel('z [cm]'); ylabel('P(z) [g/(cm s^2)]')
title('Cisnienie P(z) - ode45'); legend('\sigma = 0.3', '\sigma = 0.8')
end