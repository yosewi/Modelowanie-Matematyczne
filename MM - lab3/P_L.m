function y = P_L(sigma, Q)

syms z A_(z) P(z); % Definiujemy zmienne symboliczne

L = 5; % Wprowadzamy dane
rho = 1.06;
mu = 0.053;
A0 = 0.2;


% Definiujemy funkcje pola przekroju naczynia A_(z)
A_(z) = A0 * (1 - sigma * z ./ L); 

dPzdz = diff(P(z), z); % Pochodna funkcji P(z)

% Tworzymy równanie różniczkowe symboliczne
equ_diff = (4 * Q^2 ./ 3) * diff(1 / A_(z), z) + A_(z) / rho * dPzdz ...
    + 8 * pi * mu * Q / rho / A_(z) == 0;

% Rozwiązujemy równanie różniczkowe
P_sol = dsolve(equ_diff, P(0) == 1.2e5, 'z');
g = matlabFunction(P_sol); % Tworzymy funkcję anonimową dla P

% Powyższy kod jest wzięty z funkcji lab3_task1.m i jest częściowo
% zmieniony na potrzeby tej funkcji 

y = g(L);

end