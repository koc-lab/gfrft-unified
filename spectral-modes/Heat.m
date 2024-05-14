% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Experiment Parameters
index = 1;
use_spectral_ones = false;
vertex_count = 100;
fractional_orders = 1:-0.25:0;
dataset_title = "sensor";
gfrft_strategies = ["normalized laplacian"];

graph = gsp_sensor(vertex_count);
for j_strategy = 1:length(gfrft_strategies)
    strategy = gfrft_strategies(j_strategy);
    [gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(full(graph.W), strategy);
    if use_spectral_ones
        graph_signal = igft_mtx * ones(vertex_count, 1);
    else
        graph_signal = zeros(vertex_count, 1);
        graph_signal(index) = 1;
    end
    for i_order = 1:length(fractional_orders)
        order = fractional_orders(i_order);
        [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, order);
        transformed = gfrft_mtx * graph_signal;

        fig = figure;
        title(sprintf("%s, order %.2f", strategy, order));
        plotparam.climits = [0, 1];
        plotparam.vertex_size = 200;
        gsp_plot_signal(graph, abs(transformed), plotparam);

        set(gcf, 'Units', 'centimeters');
        set(gcf, 'Position', [10, 10, 17.78, 15]);
        set(findall(fig, '-property', 'Box'), 'Box', 'off'); % optional
        set(findall(fig, '-property', 'FontSize'), 'FontSize', 24);
        set(findall(fig, '-property', 'Interpreter'), 'Interpreter', 'latex');
        set(findall(fig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');

        pause(0.1);
        ax = gca;
        words = strsplit(gfrft_strategies(j_strategy), ' ');
        strategy = words{end};
        filename = sprintf('heat-%s-order-%.2f.eps', strategy, order);
        exportgraphics(ax, filename, 'Resolution', 300);
    end
end
ProgressBar.deleteAllTimers();
