% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear all;
close all;

%% Parallel Pool
pool = gcp('nocreate');
if isempty(pool)
    parpool();
    disp('Parallel pool created.');
else
    disp('Parallel pool already exists.');
end

%% Graph Generation
node_count = 100;
[graph, signal] = Get_Sensor_Graph(node_count, 'none');
% [graph, signal] = Get_Sensor_Graph(node_count, 'zero-mean');
% [graph, signal] = Get_Sensor_Graph(node_count, 'zero-one');
% [graph, signal] = Get_Sensor_Graph(node_count, 'plus-minus-one');

figure;
plotparam.vertex_size = 300;
gsp_plot_signal(graph, signal, plotparam);
% return

%% Optimal Filtering
strategy = 'laplacian';
seed = 0;
fractional_orders = 0.50:0.01:1.50;
uncorrelated = true;
transform_mtx = eye(graph.N);
sigmas = [0.25, 0.30, 0.40, 0.50, 0.60, 0.75];

% for i_sigma = 1:length(sigmas)
%     noisy_signal = signal + Generate_Noise(signal, sigmas(i_sigma));
%     noisy_snr = Snr(signal, noisy_signal);
%     fprintf("Noisy SNR: %.4f\n", noisy_snr);
% end
% return;

rng('default');
gpurng('default');
snrs = zeros(length(sigmas), length(fractional_orders));
for i_sigma = progress(1:length(sigmas))
    sigma = sigmas(i_sigma);
    noise = Generate_Noise(signal, sigma);
    noisy_signal = signal + noise;

    corr_xx = Generate_Correlation_Matrix(signal);
    corr_nn = Generate_Correlation_Matrix(noise);
    if uncorrelated
        corr_xn = zeros(size(corr_xx), 'like', corr_xx);
    else
        corr_xn = Generate_Correlation_Matrix(signal, noise);
    end
    corr_nx = corr_xn';

    [gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(full(graph.W), strategy);
    parfor i_order = 1:length(fractional_orders)
        order = fractional_orders(i_order);
        [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, order);
        filtered_signal = Optimal_Filter_Known_Corr(transform_mtx, ...
                                                    gfrft_mtx, igfrft_mtx, ...
                                                    corr_xx, corr_xn, corr_nx, corr_nn, ...
                                                    signal);
        snrs(i_sigma, i_order) = Snr(signal, filtered_signal);
    end
end

figure;
for i_sigma = 1:length(sigmas)
    plot(fractional_orders, snrs(i_sigma, :), ...
         'LineWidth', 2);
    hold on;
    grid on;
end

%% Functions
function corr_mtx = Generate_Correlation_Matrix(first, second)
    arguments
        first (:, :) {mustBeNumeric}
        second (:, :) {mustBeNumeric, Must_Be_Equal_Size(first, second)} = first
    end

    num_samples = size(first, 2);
    corr_mtx = zeros(size(first, 1), 'like', first);
    for i = 1:num_samples
        corr_mtx = corr_mtx + first(:, i) * second(:, i)';
    end
    corr_mtx = corr_mtx / num_samples;
end

function noise = Generate_Noise(signal, sigma)
    noise = sigma * randn(size(signal), 'like', signal);
end
