clear all;
close all;
clc;

load truths_mean.mat
truths = truths_mean;
truths = truths';

figure()
plot(0.9:0.005:1.0, 0.1*truths(1:21,1),"LineWidth",1.25,"Marker","d"); hold on;
plot(0.9:0.005:1.0, 0.1*truths(1:21,3),"LineWidth",1.25,"Marker","^"); hold on;
plot(0.9:0.005:1.0, 0.1*truths(1:21,5),"LineWidth",1.25,"Marker","o"); hold off;
xlabel("Fractional order")
ylabel("Accuracy ($\%$) ","Interpreter","latex")
legend("30 samples","50 samples","70 samples","Location","best")
% xlim([0.9,1.1])
grid on;


