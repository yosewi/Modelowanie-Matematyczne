clearvars
syms y(t)
eqn = diff(y,t) == (y(t)-3)^2
cond = y(0) == 0.1;
y_sol(t) = dsolve(eqn, cond);

t_val = linspace(0, 4);
y_val = double(y_sol(t_val));
plot(t_val, y_val)