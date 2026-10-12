function [] = zadanie1()

t = linspace(0, 2, 200)*pi;

a = 1;
x_1 = sin(t);
b = 2;
x_2 = cos(2*t);

subplot(2,2,1);
hold on;
title("f_1a")
plot(t, f1(a*x_1 + b*x_2))
subplot(2,2,1);
plot(t, a*f1(x_1) + b*f1(x_2))
hold off;

c = 0.1;
x_3 = sin(t);
d = 0.2;
x_4 = cos(2*t);

subplot(2,2,2);
hold on;
title("f_1b")
plot(t, f1(c*x_3 + d*x_4))
subplot(2,2,2);
plot(t, c*f1(x_3) + d*f1(x_4))
hold off;

subplot(2,2,3);
hold on;
title("f_2a")
plot(t, f2(a*x_1 + b*x_2))
subplot(2,2,3);
plot(t, a*f2(x_1) + b*f2(x_2))
hold off;

subplot(2,2,4);
hold on;
title("f_2b")
plot(t, f2(c*x_3 + d*x_4))
subplot(2,2,4);
plot(t, c*f2(x_3) + d*f2(x_4))
hold off;

end % function