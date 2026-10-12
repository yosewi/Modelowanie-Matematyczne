clearvars
f = @(t, z) [
  z(2) + t;
  -z(1) - 2;
];
tspan = [0,3]
z0 = [10;4]
[t,z] = ode45(f, tspan, z0);
figure(1)
clf
hold on
plot(t, z(:,1), '-o', DisplayName = '$x(t)$')
plot(t, z(:,2), '-o', DisplayName = '$y(t)$')
hold off