% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Experiment Parameters
% GFRFT
fractional_orders = -1.5:0.1:1.5;
num_trials = 20;

%% Graph Generation
dataset = "../data/tv-graph-datasets/sea-surface-temperature.mat";
dataset_title = "SST";
knn_counts = [5];
knn_sigma = 10000;
max_node_count = 200;
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

power_durations = zeros(length(knn_counts), length(gfrft_strategies), ...
                        length(fractional_orders), num_trials);
hyper_durations = zeros(length(knn_counts), length(gfrft_strategies), ...
                        length(fractional_orders), num_trials);
elogm_durations = zeros(length(knn_counts), length(gfrft_strategies), ...
                        length(fractional_orders), num_trials);

for k_knn_count = 1:length(knn_counts)
    knn_count = knn_counts(k_knn_count);
    [graph, ~] = Init_KNN_Real(dataset, knn_count, knn_sigma, ...
                               max_node_count, max_time_instance, verbose);

    fprintf("Generating results for %d-NN Graph...\n", knn_count);
    for j_strategy = 1:length(gfrft_strategies)
        strategy = gfrft_strategies(j_strategy);
        [gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(full(graph.W), strategy);

        parfor i_order = 1:length(fractional_orders)
            order = fractional_orders(i_order);
            power_durations(k_knn_count, j_strategy, i_order, :) = ...
              Time_GFRFT_Mtx_Power(gft_mtx, order, num_trials);
            hyper_durations(k_knn_count, j_strategy, i_order, :) = ...
              Time_GFRFT_Mtx_Hyper(gft_mtx, igft_mtx, order, num_trials);
            elogm_durations(k_knn_count, j_strategy, i_order, :) = ...
              Time_GFRFT_Mtx_Explog(gft_mtx, order, num_trials);
        end
    end
    fprintf("\n");
end
ProgressBar.deleteAllTimers();

%% Save Results
filename = sprintf("time-%s.mat", dataset_title);
save(filename);
Plot_Time(power_durations, hyper_durations, elogm_durations, fractional_orders, 1, 1);

%% Helper Functions
function durations = Time_GFRFT_Mtx_Power(gft_mtx, order, num_trials)
    durations = zeros(1, num_trials);
    for i_dur = 1:length(durations)
        tic;
        [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, order);
        durations(i_dur) = toc;
    end
end

function durations = Time_GFRFT_Mtx_Explog(gft_mtx, order, num_trials)
    durations = zeros(1, num_trials);
    for i_dur = 1:length(durations)
        tic;
        [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx_Explog(gft_mtx, order);
        durations(i_dur) = toc;
    end
end

function durations = Time_GFRFT_Mtx_Hyper(gft_mtx, igft_mtx, order, num_trials)
    durations = zeros(1, num_trials);
    for i_dur = 1:length(durations)
        tic;
        [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx_Hyper(order, gft_mtx, igft_mtx);
        durations(i_dur) = toc;
    end
end
