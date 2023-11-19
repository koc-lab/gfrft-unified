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
    indices(i_order) = find(abs(fractional_orders - desired_orders(i_order)) < eps, 1);
end

for j_strategy = 1:length(gfrft_strategies)
    if gfrft_strategies(j_strategy) == "row normalized adjacency"
        x_min = -1;
        x_max = 1;
    elseif gfrft_strategies(j_strategy) == "normalized laplacian"
        x_min = 0;
        x_max = 2;
    else
        x_min = min(graph_frequencies(j_strategy, :));
        x_max = max(graph_frequencies(j_strategy, :));
    end
    y_max = 1.1 * max(abs(coefficents(:)));
    y_min = floor(min(abs(coefficents(:))));

    for i_index = indices
        order = fractional_orders(i_index);
        x = squeeze(graph_frequencies(j_strategy, :));
        y = squeeze(abs(coefficents(j_strategy, i_index, :)));

        fig = figure;
        stem(x, y, 'filled');
        xlim([x_min - 0.1, x_max + 0.1]);
        ylim([y_min, y_max]);
        xlabel("Frequency, $\lambda$", 'Interpreter', 'latex');
        ylabel("Magnitudes, $|\alpha|$", 'Interpreter', 'latex');
        xticks(x_min:0.4:x_max);
        yticks([1, 5, 10]);
        grid on;
        grid minor;

        set(gcf, 'Units', 'centimeters');
        set(gcf, 'Position', [10, 10, 17.78, 8]);
        set(findall(fig, '-property', 'Box'), 'Box', 'off'); % optional
        set(findall(fig, '-property', 'FontSize'), 'FontSize', 24);
        set(findall(fig, '-property', 'Interpreter'), 'Interpreter', 'latex');
        set(findall(fig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');

        pause(0.1);
        ax = gca;
        words = strsplit(gfrft_strategies(j_strategy), ' ');
        strategy = words{end};
        filename = sprintf('%s-order-%.2f.eps', strategy, order);
        exportgraphics(ax, filename, 'Resolution', 300);
    end
end
