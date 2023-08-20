% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
% close all;

%% Import Results
results = load("results.mat");
estimation_snr = results.estimation_snr;
noisy_snr = results.noisy_snr;
fractional_orders = results.fractional_orders;
zero_counts = results.zero_counts;
snr_dbs = results.snr_dbs;

%% Figure
for i_snr = 1:length(snr_dbs)
    figure;
    [X, Y] = meshgrid(zero_counts, fractional_orders);
    curr_snr = squeeze(estimation_snr(:, i_snr, :));
    [max_row, max_col] = Matrix_Idx(curr_snr, 'max');

    s = surf(X, Y, curr_snr);
    hold on;
    max_point = plot3(X(max_row, max_col), ...
                      Y(max_row, max_col), ...
                      curr_snr(max_row, max_col), ...
                      '.r', 'MarkerSize', 30);
    datatip(max_point, 'Location', 'southeast');

    title(sprintf("PM 2.5, Noisy SNR: %.2f", noisy_snr(i_snr)));
    grid on;
    xlabel("Zero Count", 'Interpreter', 'latex');
    ylabel("Fractional Order $a$", 'Interpreter', 'latex');

    labels  = ["c", "\alpha", "SNR"];
    formats = ["auto", "auto", "percentage"];
    plt = {s, max_point};

    for j = 1:length(plt)
        for i = 1:length(plt{j}.DataTipTemplate.DataTipRows)
            plt{j}.DataTipTemplate.DataTipRows(i).Label  = labels(i);
            plt{j}.DataTipTemplate.DataTipRows(i).Format = formats(i);
        end
        plt{j}.DataTipTemplate.Interpreter = "tex";
    end
end
