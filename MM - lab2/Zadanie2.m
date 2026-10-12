function [] = zadanie2()

t = linspace(0, 2, 200)*pi;

% a)
a = 1;
x_1 = sin(t);
b = 2;
x_2 = cos(2*t);

% b)
c = 0.1;
d = 0.2;

figure(1);
clf;
% szeregowo a)
subplot(2,2,1)
title("szeregowo a");
hold on;
plot(t, f2(f1(a*x_1 + b*x_2)))
plot(t, a*f2(f1(x_1)) + b*f2(f1(x_2)))
hold off;
% szeregowo b)
subplot(2,2,2)
title("szeregowo b");
hold on;
plot(t, f2(f1(c*x_1 + d*x_2)))
plot(t, c*f2(f1(x_1)) + d*f2(f1(x_2)))
hold off;
% równolegle a
subplot(2,2,3)
title("równolegle a");
hold on;
plot(t, f1(a*x_1 + b*x_2) + f2(a*x_1 + b*x_2));
plot(t, a*f1(x_1) + b*f1(x_2) + a*f2(x_1) + b*f2(x_2));
hold off;
% równolegle b
subplot(2,2,4)
title("równolegle b");
hold on;
plot(t, f1(c*x_1 + d*x_2) + f2(c*x_1 + d*x_2));
plot(t, c*f1(x_1) + d*f1(x_2) + c*f2(x_1) + d*f2(x_2));
hold off;

