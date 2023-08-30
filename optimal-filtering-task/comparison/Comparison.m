% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Experiment Parameters
% ARMA
arma_orders = [1, 2, 3]; % Corresponds to ARMA3,4,5
arma_lambda_cuts = 0:0.1:2;
arma_normalize = true;
% Median
median_orders = [1, 2];
% GFRFT
fractional_orders = -2.0:0.1:2.0;
uncorrelated = true;

%% Graph Generation
seed = 0;
dataset = "../../data/tv-graph-datasets/sea-surface-temperature.mat";
dataset_title = "SST";
knn_count = 5;
knn_sigma = 10000;
max_node_count = 100;
max_time_instance = 120;
verbose = false;
rng(seed);
gpurng(seed);
[graph, signals] = Init_KNN_Real(dataset, knn_count, knn_sigma, ...
                                 max_node_count, max_time_instance, verbose);

%% Setup
% signals = signals - mean(signals, 2);
% signals = Normalize_Plus_Minus_One(signals);
% signals = signals / max(signals(:));
strategy = 'laplacian';
[gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(full(graph.W), strategy);
gfrft_transform_mtx = eye(size(signals, 1));

%% Parallel Pool
pool = gcp('nocreate');
if isempty(pool)
    parpool();
    disp('Parallel pool created.');
else
    disp('Parallel pool already exists.');
end

deviation = std(signals(:));
sigmas = deviation * [0.5, 1.0, 1.5];
arma_snrs       = zeros(length(sigmas), length(arma_orders));
arma_lambdas    = zeros(length(sigmas), length(arma_orders));
median_snrs     = zeros(length(sigmas), length(median_orders));
gfrft_snrs      = zeros(length(sigmas), length(fractional_orders));

for i_sigma = 1:length(sigmas)
    %% Generate Noisy Signals
    noisy_signals = signals + Generate_Noise(signals, sigmas(i_sigma));
    noisy_snr = Snr(signals, noisy_signals);
    fprintf("Noisy SNR: %.4f\n", noisy_snr);

    %% ARMA Experiment
    for j_arma = 1:length(arma_orders)
        [arma_snr, lambda] = ARMA_Grid_Search(graph, signals, noisy_signals, arma_lambda_cuts, ...
                                              arma_orders(j_arma), arma_normalize);
        arma_snrs(i_sigma, j_arma) = arma_snr;
        arma_lambdas(i_sigma, j_arma) = lambda;
    end
    fprintf("ARMA3: %.4f, ARMA4: %.4f, ARMA5: %.4f\n", ...
            arma_snrs(i_sigma, 1), arma_snrs(i_sigma, 2), arma_snrs(i_sigma, 3));

    %% Median Experiment
    for j_median = 1:length(median_orders)
        median_filtered_signals = Median_Filter(graph.A, noisy_signals, median_orders(j_median));
        median_snrs(i_sigma, j_median) = Snr(signals, median_filtered_signals);
    end
    fprintf("Median1: %.4f, Median2: %.4f\n", ...
            median_snrs(i_sigma, 1), median_snrs(i_sigma, 2));

    %% GFRFT Experiment
    gfrft_snrs(i_sigma, :) = GFRFT_Experiment(gft_mtx, gfrft_transform_mtx, ...
                                              signals, noisy_signals, ...
                                              fractional_orders, uncorrelated);
    max_idx = Matrix_Idx(gfrft_snrs(i_sigma, :).', 'max');
    assert(max(gfrft_snrs(i_sigma, :)) == gfrft_snrs(i_sigma, max_idx));
    fprintf("GFT: %.4f, GFRFT: %.4f (a=%.2f)\n", ...
            gfrft_snrs(i_sigma, fractional_orders == 1), ...
            gfrft_snrs(i_sigma, max_idx), fractional_orders(max_idx));
end

%% Save Results
% results = struct();
% results.dataset_title = dataset_title;
% results.graph = graph;
% results.knn_count = knn_count;
% results.knn_sigma = knn_sigma;
% results.max_node_count = max_node_count;
% results.max_time_instance = max_time_instance;
% results.fractional_orders = fractional_orders;
% results.snr_dbs = snr_dbs;
% results.uncorrelated = uncorrelated;
% results.transform_mtx = transform_mtx;
% results.estimation_snrs = estimation_snrs;
% results.noisy_snrs = noisy_snrs;
%
% filename = sprintf("comparison-%s-%dnn-%s.mat", ...
%                    dataset_title, knn_count, shift_mtx_strategy);
% save(filename, "-struct", "results");

%% Functions
function noise = Generate_Noise(signal, sigma)
    noise = sigma * randn(size(signal), 'like', signal);
end
