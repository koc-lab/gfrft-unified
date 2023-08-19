% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Graph Generation
dataset = "../data/tv-graph-datasets/pm25-concentration.mat";
dataset_title = "PM-2.5";
knn_count = 5;
knn_sigma  = 1;
max_node_count = 100;
max_time_instance = 100;
verbose = false;
[graph, signals] = Init_Real(dataset, knn_count, knn_sigma, ...
                             max_node_count, max_time_instance, verbose);

shift_mtx_strategy = 'adjacency';
% shift_mtx_strategy = 'laplacian';

if strcmp(shift_mtx_strategy, 'laplacian')
    disp("Using Laplacian matrix and ascending ordered graph frequency.")
    shift_mtx = eye(size(graph.W)) - full(graph.W);
    [gft_mtx, igft_mtx, graph_freqs] = GFT_Mtx(shift_mtx, 'ascend');
else
    disp("Using weighted adjacency matrix and TV ordered graph frequency.")
    shift_mtx = full(graph.W);
    [gft_mtx, igft_mtx, graph_freqs] = GFT_Mtx(shift_mtx, 'tv');
end

%% Experiment
sigmas = [0.5, 1.0, 1.5, 2.0];
fractional_orders = 0.0:0.05:2;
zero_counts = 1:10;

[estimation_error, noise_error] = Experiment(signals, gft_mtx, ...
                                             fractional_orders, sigmas, zero_counts);

results = struct();
results.dataset_title = dataset_title;
results.graph = graph;
results.knn_count = knn_count;
results.knn_sigma = knn_sigma;
results.max_node_count = max_node_count;
results.max_time_instance = max_time_instance;
results.fractional_orders = fractional_orders;
results.sigmas = sigmas;
results.zero_counts = zero_counts;
results.estimation_error = estimation_error;
results.noise_error = noise_error;

save(sprintf("results.mat"), "-struct", "results");

%% Functions
function [estimation_error, noise_error] = Experiment(signals, gft_mtx, ...
                                                      fractional_orders, sigmas, zero_counts)
    arguments
        signals(:, :) double
        gft_mtx(:, :) double {Must_Be_Square_Matrix}
        fractional_orders(:, 1) double {mustBeReal}
        sigmas(:, 1) double {mustBeReal, mustBePositive}
        zero_counts(:, 1) double {mustBeReal, mustBePositive}
    end

    estimation_error = zeros(length(fractional_orders), length(sigmas), length(zero_counts));
    noise_error = zeros(length(sigmas), 1);
    noisy_signals_cell = cell(1, length(sigmas));
    for i = 1:length(sigmas)
        noisy_signals_cell{i} = Add_Noise(signals, sigmas(i));
        noise_error(i) = Get_MSE_Percent(signals, noisy_signals_cell{i});
    end

    for i_frac = 1:length(fractional_orders)
        [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, fractional_orders(i_frac));

        for j_sigma = 1:length(sigmas)
            noisy_signals = noisy_signals_cell{j_sigma};

            for k_zero = 1:length(zero_counts)
                filter_vec = Get_Ideal_Lowpass_Filter(size(signals, 1), zero_counts(k_zero));
                filtered_signals = igfrft_mtx * ((gfrft_mtx * noisy_signals) .* filter_vec);
                err = Get_MSE_Percent(signals, filtered_signals);
                estimation_error(i_frac, j_sigma, k_zero) = err;
            end
        end
    end
end

function noisy = Add_Noise(signal, sigma)
    rng('default');
    noisy = signal + sigma * randn(size(signal));
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

function err = Get_MSE_Percent(signals, estimated_signals)
    arguments
        signals(:, :) double
        estimated_signals(:, :) double {Must_Be_Equal_Size(signals, estimated_signals)}
    end
    rmse_ratio = norm(signals - estimated_signals, 'fro') / norm(signals, 'fro');
    err = 100 * rmse_ratio^2;
end
