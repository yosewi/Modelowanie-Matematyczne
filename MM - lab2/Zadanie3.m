function [] = zadanie3()
load MM_23Z_L2.mat;

t12 = series(T1, T2);
t34 = parallel(T3, T4);
sys = feedback(t12, t34);

clf;
subplot(1,2,1);
impulse(sys);
subplot(1,2,2);
step(sys);
