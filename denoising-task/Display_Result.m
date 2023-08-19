% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Import Results
results = load("results.mat");
noise_error = results.noise_error;
estimation_error = results.estimation_error;
fractional_orders = results.fractional_orders;
sigmas = results.sigmas;

%% Figure
figure;
legends = cell(length(sigmas), 1);
for i = 1:length(sigmas)
    disp(i);
    err = estimation_error(:, i, 8);
    plot(fractional_orders, err, 'LineWidth', 2);
    hold on;
    legends{i} = sprintf("$\\sigma$ = %.2f, noise error = %.2f", ...
                         sigmas(i), noise_error(i));
end
title(sprintf("%s, Noise Error: %.2f", dataset_title, noise_error));
grid on;
legend(legends, 'Interpreter', 'latex');
xlabel("Fractional Order $a$", 'Interpreter', 'latex');
ylabel("MSE ($\%$)", 'Interpreter', 'latex');
