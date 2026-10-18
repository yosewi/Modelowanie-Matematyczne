function y = A(A0, sigma, z, L)
% Funkcja wylicza wartość funkcji A w zależności od podanego z
y = A0 * (1 - sigma * z / L);

end