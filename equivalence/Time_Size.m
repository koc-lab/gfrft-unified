% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Experiment Parameters
dataset_title = "swiss";
fractional_orders = [0.65, 1.45];
sizes = [50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300];
num_trials = 20;
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
    fprintf("Size: %d\n", sizes(k_size));
    G = gsp_swiss_roll(sizes(k_size));
    A = full(G.W);
    for j_strategy = 1:length(gfrft_strategies)
        strategy = gfrft_strategies(j_strategy);
        [gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(A, strategy);

        progBar = ProgressBar(length(fractional_orders), ...
                              'IsParallel', true, ...
                              'Title', 'Parallel Processing' ...
                             );
        progBar.setup([], [], []);
        parfor i_order = 1:length(fractional_orders)
            order = fractional_orders(i_order);
            power_durations(k_size, j_strategy, i_order, :) = ...
                Time_GFRFT_Mtx_Power(gft_mtx, order, num_trials);
            hyper_durations(k_size, j_strategy, i_order, :) = ...
                Time_GFRFT_Mtx_Hyper(gft_mtx, igft_mtx, order, num_trials);
            updateParallel();
        end
        progBar.release();
    end
    fprintf("\n");
end
ProgressBar.deleteAllTimers();

%% Save Results
filename = sprintf("time-%s-%s.mat", dataset_title, datestr(now, 'yy-mm-dd-HH-MM'));
save(filename);
Plot_Time_Size(power_durations, hyper_durations, ...
               fractional_orders, sizes, gfrft_strategies);

%% Helper Functions
function durations = Time_GFRFT_Mtx_Power(gft_mtx, order, num_trials)
    durations = zeros(1, num_trials);
    for i_dur = 1:length(durations)
        tic;
        [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, order);
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
