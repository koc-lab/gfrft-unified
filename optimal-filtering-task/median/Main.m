% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Graph Generation
seed = 0;
use_gpu = false;
dataset = "../../data/tv-graph-datasets/sea-surface-temperature.mat";
dataset_title = "SST";
knn_count = 5;
rng(seed);
gpurng(seed);
knn_sigma = 10000;
max_node_count = 100;
max_time_instance = 120;
verbose = false;
[graph, signals] = Init_KNN_Real(dataset, knn_count, knn_sigma, ...
                                 max_node_count, max_time_instance, verbose);

signals = signals / max(signals(:));
%% Median Filtering
snr_dbs = [1, 2, 3];
for snr_db = snr_dbs
    noisy_signals = Add_Noise(signals, snr_db);
    noisy_snr = Snr(signals, noisy_signals);
    fprintf("Noisy SNR: %.4f\n", noisy_snr);
    for order = [1, 2]
        filtered_signals = Median_Filter(graph.A, noisy_signals, order);
        filtered_snr = Snr(signals, filtered_signals);
        fprintf("\tM%d Filtered SNR: %.4f\n", order, filtered_snr);
    end
end

%% Helper functions
function noisy = Add_Noise(signal, snr_db)
    noise = randn(size(signal)) .* std(signal) / db2mag(snr_db);
    noisy = signal + noise;
end
