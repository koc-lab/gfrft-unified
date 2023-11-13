% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Experiment Parameters
vertex_count = 100;
fractional_orders = 0:0.01:2;
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
graph_signal = ones(vertex_count, 1);

coefficents = zeros(length(gfrft_strategies), length(fractional_orders), vertex_count);
graph_frequencies = zeros(length(gfrft_strategies), vertex_count);
for j_strategy = 1:length(gfrft_strategies)
    strategy = gfrft_strategies(j_strategy);
    [gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(full(graph.W), strategy);
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

%% Plot Results
for j_strategy = 1:length(gfrft_strategies)
    x_min = min(graph_frequencies(j_strategy, :)) - 0.1;
    x_max = max(graph_frequencies(j_strategy, :)) + 0.1;
    y_max = max(abs(coefficents(:)));
    y_min = min(abs(coefficents(:)));

    hfig = figure;
    fname = 'myfigure';
    picturewidth = 20; % set this parameter and keep it forever
    hw_ratio = 0.65; % feel free to play with this ratio
    set(findall(hfig, '-property', 'FontSize'), 'FontSize', 10); % adjust fontsize to your document
    set(findall(hfig, '-property', 'Interpreter'), 'Interpreter', 'latex');
    set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');

    for i_order = 1:length(fractional_orders)
        order = fractional_orders(i_order);
        stem(squeeze(graph_frequencies(j_strategy, :)), ...
             squeeze(abs(coefficents(j_strategy, i_order, :))), 'filled');
        xlim([x_min, x_max]);
        ylim([y_min, y_max]);
        xlabel("Graph Frequency, $\lambda$", 'Interpreter', 'latex');
        ylabel("Coefficent Magnitudes, $|\alpha|$", 'Interpreter', 'latex');
        legend(sprintf("Fractional Order: %.2f", order));
        grid on;
        grid minor;

        if order == 0 || order == 1
            pause(1);
        else
            pause(0.05);
        end
    end
end

%% Helper Functions
