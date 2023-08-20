% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Graph Generation
rng(0);
dataset_title = "Community Graph (Synthetic)";
node_count = 100;
verbose = false;
[graph, signals] = Init_Syn(node_count, verbose);

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
results.node_count = node_count;
results.fractional_orders = fractional_orders;
results.snr_dbs = snr_dbs;
results.zero_counts = zero_counts;
results.estimation_snr = estimation_snr;
results.noisy_snr = noisy_snr;

save(sprintf("syn_results.mat"), "-struct", "results");
