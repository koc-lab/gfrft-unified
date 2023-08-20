% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Import Results
results = load("results.mat");
dataset_title = results.dataset_title;
noisy_snr = results.noisy_snr;
estimation_snr = results.estimation_snr;
fractional_orders = results.fractional_orders;
snr_dbs = results.snr_dbs;

%% Figure
figure;
legends = cell(2 * length(snr_dbs), 1);
for i = 1:length(snr_dbs)
    [~, max_zero_count_idx] = Matrix_Idx(squeeze(estimation_snr(:, i, :)), 'max');
    curr_snr = estimation_snr(:, i, max_zero_count_idx);
    plot(fractional_orders, curr_snr, 'LineWidth', 2);
    hold on;
    legends{2 * i - 1} = sprintf("Estimation for SNR = %.2f", noisy_snr(i));
    yline(noisy_snr(i));
    legends{2 * i} = sprintf("Noisy SNR = %.2f", noisy_snr(i));
end
title(sprintf("%s", dataset_title));
grid on;
legend(legends, 'Interpreter', 'latex');
xlabel("Fractional Order $a$", 'Interpreter', 'latex');
ylabel("SNR (dB)", 'Interpreter', 'latex');
