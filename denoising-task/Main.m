% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Graph Generation
dataset = "../data/tv-graph-datasets/pm25-concentration.mat";
dataset_title = "PM-2.5";
knn_count = 2;
rng(0);
knn_sigma = 1;
max_node_count = 100;
max_time_instance = 100;
verbose = false;
[graph, signals] = Init_Real(dataset, knn_count, knn_sigma, ...
                             max_node_count, max_time_instance, verbose);

shift_mtx_strategy = 'adjacency';
% shift_mtx_strategy = 'laplacian';

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
snr_dbs = [4, 5, 6, 7];
fractional_orders = 0.0:0.01:2.0;
zero_counts = 1:size(signals, 1) - 1;

[estimation_snr, noisy_snr] = Experiment(signals, gft_mtx, ...
                                         fractional_orders, snr_dbs, zero_counts);

results = struct();
results.dataset_title = dataset_title;
results.graph = graph;
results.knn_count = knn_count;
results.knn_sigma = knn_sigma;
results.max_node_count = max_node_count;
results.max_time_instance = max_time_instance;
results.fractional_orders = fractional_orders;
results.snr_dbs = snr_dbs;
results.zero_counts = zero_counts;
results.estimation_snr = estimation_snr;
results.noisy_snr = noisy_snr;

save(sprintf("results.mat"), "-struct", "results");

