% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Graph Generation
dataset = "../data/tv-graph-datasets/pm25-concentration.mat";
dataset_title = "PM-2.5";
knn_count = 2;
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

%% Functions
function [estimation_snr, noisy_snr] = Experiment(signals, gft_mtx, ...
                                                  fractional_orders, snr_dbs, zero_counts)
    arguments
        signals(:, :) double
        gft_mtx(:, :) double {Must_Be_Square_Matrix}
        fractional_orders(:, 1) double {mustBeReal}
        snr_dbs(:, 1) double {mustBeReal}
        zero_counts(:, 1) double {mustBeReal, mustBePositive}
    end

    estimation_snr = zeros(length(fractional_orders), length(snr_dbs), length(zero_counts));
    noisy_snr = zeros(length(snr_dbs), 1);
    noisy_signals_cell = cell(1, length(snr_dbs));
    for i = 1:length(snr_dbs)
        noisy_signals_cell{i} = Add_Noise(signals, snr_dbs(i));
        noisy_snr(i) = Snr(signals, noisy_signals_cell{i});
    end

    for i_frac = 1:length(fractional_orders)
        [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, fractional_orders(i_frac));

        for j_snr = 1:length(snr_dbs)
            noisy_signals = noisy_signals_cell{j_snr};

            for k_zero = 1:length(zero_counts)
                filter_vec = Get_Ideal_Lowpass_Filter(size(signals, 1), zero_counts(k_zero));
                filtered_signals = igfrft_mtx * ((gfrft_mtx * noisy_signals) .* filter_vec);
                curr_snr = Snr(signals, filtered_signals);
                estimation_snr(i_frac, j_snr, k_zero) = curr_snr;
            end
        end
    end
end

function noisy = Add_Noise(signal, snr_db)
    rng('default');
    noise = randn(size(signal)) .* std(signal) / db2mag(snr_db);
    noisy = signal + noise;
end

function filter_vec = Get_Ideal_Lowpass_Filter(node_count, zero_count)
    arguments
        node_count double {mustBePositive, mustBeInteger}
        zero_count double {mustBeNonnegative, mustBeInteger, ...
                           mustBeLessThanOrEqual(zero_count, node_count)}
    end
    filter_vec = zeros(node_count, 1);
    one_count = node_count - zero_count;
    filter_vec(1:one_count) = 1;
end
