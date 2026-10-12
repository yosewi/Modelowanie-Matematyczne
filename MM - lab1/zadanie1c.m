clearvars
syms y(t) x(t)
eqn1 = diff(x,t) == y+t
eqn2 = diff(y,t) == -x-2
cond1 = y(0) == 4;
cond2 = x(0) == 10;
[x_sol(t), y_sol(t)] = dsolve([eqn1, eqn2], [cond1, cond2]);

t_val = linspace(0, 3);
x_val = double(x_sol(t_val));
y_val = double(y_sol(t_val));

figure(1)
clf
hold on
plot(t_val, x_val, '-o', DisplayName = '$x(t)$')
plot(t_val, y_val, '-o', DisplayName = '$y(t)$')
hold off