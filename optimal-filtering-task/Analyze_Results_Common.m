% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Load data
% dataset_title = "COVID-USA";
dataset_title = "SST";
knn_count = 10;
% shift_mtx_strategy = 'adjacency';
shift_mtx_strategy = 'laplacian';
filename = sprintf("results-common-%s-%dnn-%s.mat", ...
                   dataset_title, knn_count, shift_mtx_strategy);
results = load(filename);

estimation_snrs = results.estimation_snrs;
noisy_snrs = results.noisy_snrs;
fractional_orders = results.fractional_orders;
snr_dbs = results.snr_dbs;

figure;
if false
    start = 1 + floor(length(fractional_orders) / 2);
else
    start = 1;
end
plts = [];
legends = [];
for i_snr = 1:length(snr_dbs)
    snrs = estimation_snrs(start:end, i_snr);
    fractional_orders = fractional_orders(start:end);
    legends = [legends; sprintf("Initial SNR = %.2f dB", noisy_snrs(i_snr))];
    plt = plot(fractional_orders, snrs, 'LineWidth', 2);
    plts = [plts; plt];
    hold on;

    max_idx = Matrix_Idx(snrs, 'max');
    max_point = plot(fractional_orders(max_idx), snrs(max_idx), '.');
    datatip(max_point);
    labels  = ["$a$", "SNR"];
    formats = ["%.2f", "%.2f"];
    for i = 1:length(max_point.DataTipTemplate.DataTipRows)
        max_point.DataTipTemplate.DataTipRows(i).Label  = labels(i);
        max_point.DataTipTemplate.DataTipRows(i).Format = formats(i);
    end
    max_point.DataTipTemplate.Interpreter = "latex";

    gft_idx = (fractional_orders == 1);
    if any(gft_idx) && (fractional_orders(max_idx) ~= 1)
        gft_point = plot(fractional_orders(gft_idx), snrs(gft_idx), '.');
        datatip(gft_point);
        for i = 1:length(gft_point.DataTipTemplate.DataTipRows)
            gft_point.DataTipTemplate.DataTipRows(i).Label  = labels(i);
            gft_point.DataTipTemplate.DataTipRows(i).Format = formats(i);
        end
        gft_point.DataTipTemplate.Interpreter = "latex";
    end
end
title(sprintf("SNR vs fractional order for %s dataset", dataset_title));
xlabel("Fractional order");
ylabel("Average SNR");
legend(plts, legends);
grid on;
