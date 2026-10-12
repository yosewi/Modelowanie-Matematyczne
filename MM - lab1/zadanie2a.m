clearvars;
tspan = [0 1];
y0 = 1;
[t, y] = ode45(@(t,y) -3*t, tspan, y0);

figure;
plot(t, y, '-o', 'LineWidth', 1.5);
