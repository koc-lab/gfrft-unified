% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Experiment Parameters
% GFRFT
fractional_orders = -1.5:0.1:1.5;
num_trials = 20;
sizes = [100, 200];

%% Graph Generation
dataset_title = "sensor";
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

power_durations = zeros(length(sizes), length(gfrft_strategies), ...
                        length(fractional_orders), num_trials);
hyper_durations = zeros(length(sizes), length(gfrft_strategies), ...
                        length(fractional_orders), num_trials);

for k_size = 1:length(sizes)
    graph = gsp_sensor(sizes(k_size));
    fprintf("Generating results for size %d ...\n", sizes(k_size));
    for j_strategy = 1:length(gfrft_strategies)
        strategy = gfrft_strategies(j_strategy);
        [gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(full(graph.W), strategy);

        parfor i_order = 1:length(fractional_orders)
            order = fractional_orders(i_order);
            power_durations(k_size, j_strategy, i_order, :) = ...
              Time_GFRFT_Mtx_Power(gft_mtx, order, num_trials);
            hyper_durations(k_size, j_strategy, i_order, :) = ...
              Time_GFRFT_Mtx_Hyper(gft_mtx, igft_mtx, order, num_trials);
            elogm_durations(k_size, j_strategy, i_order, :) = ...
              Time_GFRFT_Mtx_Explog(gft_mtx, order, num_trials);
        end
    end
    fprintf("\n");
end
ProgressBar.deleteAllTimers();

%% Save Results
filename = sprintf("time-%s.mat", dataset_title);
save(filename);

for k_size = 1:length(sizes)
    Plot_Time(power_durations, hyper_durations, fractional_orders, k_size, 1);
end

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
