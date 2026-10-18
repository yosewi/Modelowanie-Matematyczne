function y = Aprim(z)
% Funkcja wylicza wartość A' dla podanego z
sigma = 0.8;
A0 = 0.2;
L = 5;
eps = 1e-10;
y = (A(A0, sigma, z + eps, L) - A(A0, sigma, z - eps, L)) / (2 * eps);

end