% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Plot
load('spectral-sensor.mat');
desired_orders = [0, 0.25, 0.50, 0.75, 1.00];
indices = zeros(1, length(desired_orders));
for i_order = 1:length(desired_orders)
    indices(i_order) = find(fractional_orders == desired_orders(i_order), 1);
end

for j_strategy = 1:length(gfrft_strategies)
    for i_index = indices
        order = fractional_orders(i_index);
        x = squeeze(graph_frequencies(j_strategy, :));
        y = squeeze(abs(coefficents(j_strategy, i_index, :)));

        hfig = figure;
        stem(x, y, 'filled');
        xlim([x_min, x_max]);
        ylim([y_min, y_max]);
        xlabel("Graph Frequency, $\lambda$", 'Interpreter', 'latex');
        ylabel("Coefficent Magnitudes, $|\alpha|$", 'Interpreter', 'latex');
        legend(sprintf("Fractional Order: %.3f", order), ...
               'Location', 'north');
        grid on;
        grid minor;

        fname = 'myfigure';
        picturewidth = 20; % set this parameter and keep it forever
        hw_ratio = 0.65; % feel free to play with this ratio
        set(findall(hfig, '-property', 'FontSize'), 'FontSize', 10);
        set(findall(hfig, '-property', 'Interpreter'), 'Interpreter', 'latex');
        set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');
    end
end
