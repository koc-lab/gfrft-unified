% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Experiment Parameters
% GFRFT
fractional_orders = -2.0:0.01:2.0;

%% Graph Generation
dataset = "../data/tv-graph-datasets/pm25-concentration.mat";
dataset_title = "PM-25";
knn_counts = [2, 5, 10];
knn_sigma = 10000;
max_node_count = 100;
max_time_instance = 10000;
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

gfrft_errors = zeros(length(knn_counts), length(gfrft_strategies), length(fractional_orders));
for k_knn_count = 1:length(knn_counts)
    knn_count = knn_counts(k_knn_count);
    [graph, ~] = Init_KNN_Real(dataset, knn_count, knn_sigma, ...
                               max_node_count, max_time_instance, verbose);

    fprintf("Generating results for %d-NN Graph...\n", knn_count);
    for j_strategy = 1:length(gfrft_strategies)
        strategy = gfrft_strategies(j_strategy);
        [gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(full(graph.W), strategy);

        parfor i_order = 1:length(fractional_orders)
            gfrft_mtx_power = GFRFT_Mtx(gft_mtx, fractional_orders(i_order));
            gfrft_mtx_hyper = GFRFT_Mtx_Hyper(fractional_orders(i_order), gft_mtx, igft_mtx);

            ratio = norm(gfrft_mtx_power - gfrft_mtx_hyper, 'fro') / norm(gfrft_mtx_power, 'fro');
            err = ratio^2 * 100;
            gfrft_errors(k_knn_count, j_strategy, i_order) = err;
            updateParallel();
        end

        mean_error = mean(gfrft_errors(k_knn_count, j_strategy, :));
        std_error = std(gfrft_errors(k_knn_count, j_strategy, :));
        max_error = max(gfrft_errors(k_knn_count, j_strategy, :));
        % fprintf("%s: %e±%e (max: %e)\n", strategy, mean_error, std_error, max_error);
        fprintf("%s\t: %e\n", strategy, mean_error);
    end
    fprintf("\n\n\n");
end
ProgressBar.deleteAllTimers();

%% Save Results
filename = sprintf("equivalence-%s.mat", dataset_title);
save(filename);
