% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Experiment Parameters
% ARMA
arma_orders = [1, 2, 3]; % Corresponds to ARMA3,4,5
arma_lambda_cuts = 0:0.01:2;
arma_normalize = true;
% Median
median_orders = [1, 2];
% GFRFT
fractional_orders = -2.0:0.01:2.0;
uncorrelated = true;

%% Graph Generation
dataset = "../../data/tv-graph-datasets/pm25-concentration.mat";
dataset_title = "PM-25";
knn_counts = [2, 5, 10];
sigmas = [0.01, 0.03, 0.05];
knn_sigma = 10000;
max_node_count = 93;
max_time_instance = 304;
verbose = false;
gfrft_strategies = ["adjacency", ...
                    "laplacian", ...
                    "row normalized adjacency", ...
                    "symmetric normalized adjacency", ...
                    "normalized laplacian"];

%% Parallel Pool
pool = gcp('nocreate');
if isempty(pool)
    parpool();
    disp('Parallel pool created.');
else
    disp('Parallel pool already exists.');
end

noisy_snrs      = zeros(length(knn_counts), length(sigmas), 1);
arma_snrs       = zeros(length(knn_counts), length(sigmas), length(arma_orders));
arma_lambdas    = zeros(length(knn_counts), length(sigmas), length(arma_orders));
median_snrs     = zeros(length(knn_counts), length(sigmas), length(median_orders));
gfrft_snrs      = zeros(length(knn_counts), length(sigmas), ...
                        length(gfrft_strategies), length(fractional_orders));

for seed = 0:10
fprintf("Generating results for seed: %d\n", seed);
for k_knn_count = 1:length(knn_counts)
    knn_count = knn_counts(k_knn_count);
    [graph, signals] = Init_KNN_Real(dataset, knn_count, knn_sigma, ...
                                     max_node_count, max_time_instance, verbose);
    rng(seed);
    gpurng(seed);
    % signals = signals / max(signals(:));
    % signals = signals - mean(signals, 2);
    signals = Normalize_Zero_One(signals);
    % signals = Normalize_Plus_Minus_One(signals);

    % for i_sigma = 1:length(sigmas)
    %     noisy_signals = signals + Generate_Noise(signals, sigmas(i_sigma));
    %     noisy_snr = Snr(signals, noisy_signals);
    %     fprintf("Noisy SNR: %.4f\n", noisy_snr);
    % end
    % return;

    fprintf("Generating results for %d-NN Graph...\n", knn_count);
    for i_sigma = 1:length(sigmas)
        %% Generate Noisy Signals
        noisy_signals = signals + Generate_Noise(signals, sigmas(i_sigma));
        noisy_snrs(k_knn_count, i_sigma) = Snr(signals, noisy_signals);
        fprintf("Noisy SNR: %.4f\n", noisy_snrs(k_knn_count, i_sigma));

        %% ARMA Experiment
        for j_arma = 1:length(arma_orders)
            [arma_snr, lambda] = ARMA_Grid_Search(graph, signals, noisy_signals, ...
                                                  arma_lambda_cuts, ...
                                                  arma_orders(j_arma), arma_normalize);
            arma_snrs(k_knn_count, i_sigma, j_arma) = arma_snr;
            arma_lambdas(k_knn_count, i_sigma, j_arma) = lambda;
        end
        fprintf("ARMA3: %.4f, ARMA4: %.4f, ARMA5: %.4f\n", ...
                arma_snrs(k_knn_count, i_sigma, 1), ...
                arma_snrs(k_knn_count, i_sigma, 2), ...
                arma_snrs(k_knn_count, i_sigma, 3));

        %% Median Experiment
        for j_median = 1:length(median_orders)
            median_filtered_signals = Median_Filter(graph.A, noisy_signals, ...
                                                    median_orders(j_median));
            median_snrs(k_knn_count, i_sigma, j_median) = Snr(signals, median_filtered_signals);
        end
        fprintf("Median1: %.4f, Median2: %.4f\n", ...
                median_snrs(k_knn_count, i_sigma, 1), ...
                median_snrs(k_knn_count, i_sigma, 2));

        %% GFRFT Experiment
        for j_strategy = 1:length(gfrft_strategies)
            strategy = gfrft_strategies(j_strategy);
            [gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(full(graph.W), strategy);
            gfrft_transform_mtx = eye(size(signals, 1));

            gfrft_snrs(k_knn_count, i_sigma, j_strategy, :) = ...
                GFRFT_Experiment(gft_mtx, gfrft_transform_mtx, signals, ...
                                 noisy_signals, fractional_orders, uncorrelated);
            [max_snr, max_idx] = max(gfrft_snrs(k_knn_count, i_sigma, j_strategy, :));
            fprintf("Strategy: %s\n\tGFT: %.4f, GFRFT: %.4f (a=%.2f)\n", ...
                    strategy, ...
                    gfrft_snrs(k_knn_count, i_sigma, j_strategy, fractional_orders == 1), ...
                    max_snr, fractional_orders(max_idx));
        end
    end
    fprintf("\n\n\n");
end

%% Save Results
filename = sprintf("comparison-%s-seed-%d.mat", dataset_title, seed);
save(filename);
end

%% Functions
function noise = Generate_Noise(signal, sigma)
    noise = sigma * randn(size(signal), 'like', signal);
end
