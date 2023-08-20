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
axs = [];
figure;
for i = 1:length(snr_dbs)
    [~, max_zero_count_idx] = Matrix_Idx(squeeze(estimation_snr(:, i, :)), 'max');
    curr_snr = estimation_snr(:, i, max_zero_count_idx);
    max_idx = Matrix_Idx(curr_snr, 'max');

    ax = plot(fractional_orders, curr_snr, 'LineWidth', 2, ...
            'DisplayName',sprintf("Estimation for SNR = %.2f", noisy_snr(i))); 
    axs(end + 1) = ax;
    hold on;
    yline(noisy_snr(i));

    max_point = plot(fractional_orders(max_idx), curr_snr(max_idx), '.');
    datatip(max_point, 'Location', 'southeast');

    labels  = ["$a$", "SNR"];
    formats = ["%.2f", "%.2f"];
    plt = {ax, max_point};

    for j = 1:length(plt)
        for i = 1:length(plt{j}.DataTipTemplate.DataTipRows)
            plt{j}.DataTipTemplate.DataTipRows(i).Label  = labels(i);
            plt{j}.DataTipTemplate.DataTipRows(i).Format = formats(i);
        end
        plt{j}.DataTipTemplate.Interpreter = "latex";
    end
end
title(sprintf("%s", dataset_title));
legend(axs);
grid on;
xlabel("Fractional Order $a$", 'Interpreter', 'latex');
ylabel("SNR (dB)", 'Interpreter', 'latex');
