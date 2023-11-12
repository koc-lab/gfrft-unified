% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Experiment Parameters
% GFRFT
fractional_orders = -1.5:0.25:1.5;
num_trials = 20;

%% Graph Generation
dataset_title = "swiss";
% A = rand(100);
G = gsp_swiss_roll(200);
A = full(G.W);
% gfrft_strategies = ["adjacency", ...
%                     "laplacian", ...
%                     "row normalized adjacency", ...
%                     "symmetric normalized adjacency", ...
%                     "normalized laplacian"];
gfrft_strategies = ["adjacency"];

%% Parallel Pool
pool = gcp('nocreate');
if isempty(pool)
    parpool();
    disp('Parallel pool created.');
else
    disp('Parallel pool already exists.');
end

power_durations = zeros(length(gfrft_strategies), ...
                        length(fractional_orders), num_trials);
hyper_durations = zeros(length(gfrft_strategies), ...
                        length(fractional_orders), num_trials);
elogm_durations = zeros(length(gfrft_strategies), ...
                        length(fractional_orders), num_trials);

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
        power_durations(j_strategy, i_order, :) = ...
            Time_GFRFT_Mtx_Power(gft_mtx, order, num_trials);
        hyper_durations(j_strategy, i_order, :) = ...
            Time_GFRFT_Mtx_Hyper(gft_mtx, igft_mtx, order, num_trials);
        elogm_durations(j_strategy, i_order, :) = ...
            Time_GFRFT_Mtx_Explog(gft_mtx, order, num_trials);
        updateParallel();
    end
    progBar.release();
end
fprintf("\n");
ProgressBar.deleteAllTimers();

%% Save Results
filename = sprintf("time-%s.mat", dataset_title);
save(filename);
Plot_Time_Large(power_durations, hyper_durations, elogm_durations, fractional_orders, 1);

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
