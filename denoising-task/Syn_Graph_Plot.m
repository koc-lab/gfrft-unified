% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Graph Generation
rng('default');
node_count = 100;
snr = 5;
[graph, x] = Get_Community_Graph(node_count);
x_noisy = Add_Noise(x, snr);

results = load("syn_results.mat");
x_filtered = Filter_With_Best(results, x_noisy);

param.show_edges = 1;
min_lim = min([min(x(:)), min(x_noisy(:)), min(x_filtered(:))]);
max_lim = max([max(x(:)), max(x_noisy(:)), max(x_filtered(:))]);
param.climits = [min_lim max_lim];

val = 1.2;
figure;
sgtitle("100 Node - Community Graph (Synthetic)");
subplot(131);
title('Original Signal');
gsp_plot_signal(graph, x, param);
pbaspect([val 1 1]);
subplot(132);
title(sprintf("Noisy Signal, SNR = %.2fdB", Snr(x, x_noisy)));
gsp_plot_signal(graph, x_noisy, param);
pbaspect([val 1 1]);
subplot(133);
title(sprintf("Filtered, SNR = %.2fdB", Snr(x, x_filtered)));
gsp_plot_signal(graph, x_filtered, param);
pbaspect([val 1 1]);

%% Functions
function filtered_signals = Filter_With_Best(results, noisy_signals)
    [order_idx, zero_idx] = Matrix_Idx(squeeze(results.estimation_snr(:, 2, :)), 'max');
    order = results.fractional_orders(order_idx);
    zero_count = results.zero_counts(zero_idx);
    filter_vec = Get_Ideal_Lowpass_Filter(results.graph.N, zero_count);

    shift_mtx_strategy = 'adjacency';
    % shift_mtx_strategy = 'laplacian';
    if strcmp(shift_mtx_strategy, 'laplacian')
        disp("Using Laplacian matrix and ascending ordered graph frequency.");
        full_adj_mtx = full(results.graph.W);
        shift_mtx = diag(sum(full_adj_mtx, 2)) - full_adj_mtx;
        [gft_mtx, igft_mtx, graph_freqs] = GFT_Mtx(shift_mtx, 'ascend');
    else
        disp("Using weighted adjacency matrix and TV ordered graph frequency.");
        shift_mtx = full(results.graph.W);
        [gft_mtx, igft_mtx, graph_freqs] = GFT_Mtx(shift_mtx, 'tv');
    end

    [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, order);
    filtered_signals = igfrft_mtx * ((gfrft_mtx * noisy_signals) .* filter_vec);
end

function noisy = Add_Noise(signal, snr_db)
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
