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

%% Pool
pool = gcp('nocreate');
if isempty(pool)
    parpool();
    disp('Parallel pool created.');
else
    disp('Parallel pool already exists.');
end

%% Load data
signals = signals / max(signals(:));
order = 3;
normalize = true;
fprintf("Generating Results for order: %d\n", order);

%% Noise Parameters
snr_dbs = [1, 2, 3];
num_outer_iter = length(snr_dbs);
outer_bar = ProgressBar(num_outer_iter, 'Title', 'SNR');
outer_bar.setup([], [], []);
for i_snr = 1:num_outer_iter
    % Noise and Covariance matrices
    snr_db = snr_dbs(i_snr);
    noisy_signals = Add_Noise(signals, snr_db);
    noisy_snr = Snr(signals, noisy_signals);

    % Filter
    [filtered_snr, lambda] = ARMA_Grid_Search(graph, signals, noisy_signals, ...
                                              order, normalize);
    outer_bar.printMessage( ...
                           sprintf("\tNoisy: %.2f dB, Filtered: %.2f dB (lambda=%.2f)", ...
                                   noisy_snr, filtered_snr, lambda) ...
                          );
    outer_bar([], [], []);
end
outer_bar.release();
ProgressBar.deleteAllTimers();

%% Helper functions
function noisy = Add_Noise(signal, snr_db)
    noise = randn(size(signal)) .* std(signal) / db2mag(snr_db);
    noisy = signal + noise;
end
