% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
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
display = true;
node_count = 100;
% normalization = 'none';
normalization = 'zero-mean';
% normalization = 'zero-one';
% normalization = 'plus-minus-one';
[graph, signal] = Get_Sensor_Graph(node_count, normalization);

%% Optimal Filtering
gft_strategies = ["adjacency", ...
                  "laplacian", ...
                  "row normalized adjacency", ...
                  "symmetric normalized adjacency", ...
                  "normalized laplacian"];
strategy = 'row normalized adjacency';
seed = 0;
fractional_orders = -2.0:2:2.0;
uncorrelated = true;
transform_mtx = eye(graph.N);
sigmas = [0.35];

for i_sigma = 1:length(sigmas)
    noisy_signal = signal + Generate_Noise(signal, sigmas(i_sigma));
    if display
        min_limit = min(min(signal(:)), min(noisy_signal(:)));
        max_limit = max(max(signal(:)), max(noisy_signal(:)));
        figure;
        plotparam.climits = [min_limit, max_limit];
        plotparam.vertex_size = 200;
        plotparam.bar = 0;
        gsp_plot_signal(graph, signal, plotparam);
        for iFont = 1:5
            fontsize("increase");
        end
        ax = gca;
        exportgraphics(ax, 'original.eps');

        figure;
        gsp_plot_signal(graph, noisy_signal, plotparam);
        for iFont = 1:5
            fontsize("increase");
        end
        ax = gca;
        exportgraphics(ax, 'noisy.eps');
    end
    noisy_snr = Snr(signal, noisy_signal);
    fprintf("Noisy SNR: %.4f\n", noisy_snr);
end
return

rng('default');
gpurng('default');

num_outer_iter = length(sigmas);
num_inner_iter = length(fractional_orders);
outer_bar = ProgressBar(num_outer_iter, 'Title', 'sigmas');
outer_bar.setup([], [], []);

for strategy = gft_strategies
    snrs = zeros(length(sigmas), length(fractional_orders));
    [gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(full(graph.W), strategy);
    for i_sigma = 1:num_outer_iter
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

        inner_bar = ProgressBar(num_inner_iter, ...
                                'IsParallel', true, ...
                                'Title', 'Order');
        inner_bar.setup([], [], []);
        parfor i_order = 1:num_inner_iter
            order = fractional_orders(i_order);
            [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, order);
            filtered_signal = Optimal_Filter_Known_Corr(transform_mtx, ...
                                                        gfrft_mtx, igfrft_mtx, ...
                                                        corr_xx, corr_xn, corr_nx, corr_nn, ...
                                                        signal);
            snrs(i_sigma, i_order) = Snr(signal, filtered_signal);
            updateParallel();
        end
        inner_bar.release();
        outer_bar([], [], []);
    end
    outer_bar.release();
    ProgressBar.deleteAllTimers();

    filename = sprintf("main-sensor-%s-%s.mat", strategy, normalization);
    filename = strrep(filename, ' ', '-');
    save(filename);
    fprintf("\n\n\n");
end

if display
    figure;
    for i_sigma = 1:length(sigmas)
        plot(fractional_orders, snrs(i_sigma, :), ...
             'LineWidth', 2);
        hold on;
        grid on;
    end
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
