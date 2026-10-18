function lab3A_task3()
% Zadanie 3 (wersja A, z kodu): roznica cisnien P(0)-P(L) w funkcji sigma
% dla Q = 1, 2, 3, 4, 5;  A(z) = A0*(1 - sigma*z/L)
L = 5; rho = 1.06; mu = 0.053; A0 = 0.2; P0 = 1.2e5;
Qs    = 1:5;
sigmy = 0.1:0.01:0.9;

figure(3); clf; hold on; grid on
for q = Qs
    dP = zeros(size(sigmy));
    for k = 1:numel(sigmy)
        dP(k) = P0 - P_koniec(sigmy(k), q, L, rho, mu, A0, P0);
    end
    plot(sigmy, dP, 'LineWidth', 2)
end
xlabel('\sigma'); ylabel('P(0) - P(L) [g/(cm s^2)]')
title('Spadek cisnienia w funkcji stopnia zwezenia')
legend(arrayfun(@(q) sprintf('Q = %d', q), Qs, 'UniformOutput', false), ...
    'Location', 'northwest')
end

function PL = P_koniec(s, Q, L, rho, mu, A0, P0)
% Zwraca P(L) dla danego sigma i Q (ode45, jak w Zadaniu 2)
epsi = 1e-6;
Af   = @(z) A0*(1 - s*z/L);
dAdz = @(z) (Af(z + epsi) - Af(z - epsi)) / (2*epsi);
d1A  = @(z) -1 ./ Af(z).^2 .* dAdz(z);
f    = @(z, P) -rho ./ Af(z) .* ( 4*Q^2/3 .* d1A(z) + 8*pi*mu*Q ./ (rho*Af(z)) );
[~, Ps] = ode45(f, [0 L], P0);
PL = Ps(end);
end