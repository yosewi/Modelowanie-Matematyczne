clearvars
tspan = [0 4];
y0 = 0.1;
[t,y] = ode45(@(t,y) (y-3)^2, tspan, y0);
plot(t,y)
grid on
grid off