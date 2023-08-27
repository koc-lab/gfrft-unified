% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Graph Generation
rng("default");
use_gpu = false;
dataset = "../../data/tv-graph-datasets/sea-surface-temperature.mat";
dataset_title = "SST";
knn_count = 5;
rng(0);
gpurng(0);
knn_sigma = 10000;
max_node_count = 100;
max_time_instance = 120;
verbose = false;
[graph, signals] = Init_KNN_Real(dataset, knn_count, knn_sigma, ...
                                 max_node_count, max_time_instance, verbose);

% shift_strategy = 'adjacency';
% [gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(full(graph.W), shift_strategy);

%% Load data
signals = signals / max(signals(:));

%% Graph ARMA Laplacian
graph = gsp_create_laplacian(graph, 'normalized');
graph = gsp_estimate_lmax(graph);
graph = gsp_compute_fourier_basis(graph);

l  = linspace(0, graph.lmax, 300);
M  = sparse(0.5 * graph.lmax * speye(graph.N) - graph.L);
mu = graph.lmax / 2 - l;

%% Graph ARMA Parameters
order = 2;
normalize = false;
[b, a] = Get_Arma_Coeff(graph, mu, order, normalize);
fprintf("Generating Results for ARMA%d Filter:\n", length(a));

%% Noise Parameters
snr_dbs = [1, 2, 3];
for snr_db = snr_dbs
    % Noise and Covariance matrices
    signals_noisy = Add_Noise(signals, snr_db);
    noisy_snr = Snr(signals, signals_noisy);
    fprintf("\tNoisy  SNR: %.2f dB\n", noisy_snr);

    % Filter
    signals_filtered = time_varying_arma_filter(M, b, a, signals_noisy);
    signals_filtered = real(signals_filtered);
    filtered_snr = Snr(signals, signals_filtered);
    fprintf("\tFiltered SNR: %.2f dB\n", filtered_snr);
end

%% Helper functions
function noisy = Add_Noise(signal, snr_db)
    noise = randn(size(signal)) .* std(signal) / db2mag(snr_db);
    noisy = signal + noise;
end
