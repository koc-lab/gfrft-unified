% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Experiment Parameters
vertex_count = 100;
fractional_orders = 0:0.001:1;
dataset_title = "sensor";
gfrft_strategies = ["symmetric normalized adjacency", "normalized laplacian"];

%% Parallel Pool
pool = gcp('nocreate');
if isempty(pool)
    parpool();
    disp('Parallel pool created.');
else
    disp('Parallel pool already exists.');
end

graph = gsp_sensor(vertex_count);
coefficents = zeros(length(gfrft_strategies), length(fractional_orders), vertex_count);
graph_frequencies = zeros(length(gfrft_strategies), vertex_count);
for j_strategy = 1:length(gfrft_strategies)
    strategy = gfrft_strategies(j_strategy);
    [gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(full(graph.W), strategy);
    graph_signal = gft_mtx * ones(vertex_count, 1);
    graph_frequencies(j_strategy, :) = graph_freqs;
    parfor i_order = 1:length(fractional_orders)
        order = fractional_orders(i_order);
        [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, order);
        coefficents(j_strategy, i_order, :) = igfrft_mtx * graph_signal;
    end
end
ProgressBar.deleteAllTimers();

%% Save Results
filename = sprintf("spectral-%s.mat", dataset_title);
save(filename);
