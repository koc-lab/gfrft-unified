% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Graph Generation
use_gpu = false;
dataset = "../data/tv-graph-datasets/sea-surface-temperature.mat";
dataset_title = "SST";
knn_count = 10;
rng(0);
gpurng(0);
knn_sigma = 1000;
max_node_count = 100;
max_time_instance = 302;
verbose = false;
[graph, signals] = Init_Real(dataset, knn_count, knn_sigma, ...
                             max_node_count, max_time_instance, verbose);

signals = signals - mean(signals, 2);

% shift_mtx_strategy = 'adjacency';
shift_mtx_strategy = 'laplacian';

if strcmp(shift_mtx_strategy, 'laplacian')
    disp("Using Laplacian matrix and ascending ordered graph frequency.");
    full_adj_mtx = full(graph.W);
    shift_mtx = diag(sum(full_adj_mtx, 2)) - full_adj_mtx;
    [gft_mtx, igft_mtx, graph_freqs] = GFT_Mtx(shift_mtx, 'ascend');
else
    disp("Using weighted adjacency matrix and TV ordered graph frequency.");
    shift_mtx = full(graph.W);
    [gft_mtx, igft_mtx, graph_freqs] = GFT_Mtx(shift_mtx, 'tv');
end

%% Experiment
transform_mtx = eye(size(signals, 1));
uncorrelated = true;
% snr_dbs = [3, 4, 5, 7, 8, 10, 12, 15];
snr_dbs = [4, 5];
fractional_orders = -2.0:0.1:2.0;

pool = gcp('nocreate');
if isempty(pool)
    parpool();
    disp('Parallel pool created.');
else
    disp('Parallel pool already exists.');
end

if use_gpu
    gft_mtx = gpuArray(gft_mtx);
    transform_mtx = gpuArray(transform_mtx);
    signals = gpuArray(signals);
    fractional_orders = gpuArray(fractional_orders);
    snr_dbs = gpuArray(snr_dbs);
end
[estimation_snrs, noisy_snrs] = Experiment_Common(gft_mtx, transform_mtx, signals, ...
                                                  fractional_orders, snr_dbs, uncorrelated);

results = struct();
results.dataset_title = dataset_title;
results.graph = graph;
results.knn_count = knn_count;
results.knn_sigma = knn_sigma;
results.max_node_count = max_node_count;
results.max_time_instance = max_time_instance;
results.fractional_orders = fractional_orders;
results.snr_dbs = snr_dbs;
results.uncorrelated = uncorrelated;
results.transform_mtx = transform_mtx;
results.estimation_snrs = estimation_snrs;
results.noisy_snrs = noisy_snrs;

filename = sprintf("results-common-%s-%dnn-%s.mat", ...
                   dataset_title, knn_count, shift_mtx_strategy);
save(filename, "-struct", "results");
