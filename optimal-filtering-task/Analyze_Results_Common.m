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
for i_snr = 1:length(snr_dbs)
    plot(fractional_orders(start:end), estimation_snrs(start:end, i_snr));
    hold on;
    yline(noisy_snrs(i_snr), '--');
end
xlabel("Fractional order");
ylabel("Average SNR");
grid on;

