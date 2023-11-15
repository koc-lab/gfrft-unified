% (c) Copyright 2023 Tuna Alikaşifoğlu

load('spectral-sensor.mat');

for j_strategy = 1:length(gfrft_strategies)
    x_min = min(graph_frequencies(j_strategy, :)) - 0.1;
    x_max = max(graph_frequencies(j_strategy, :)) + 0.1;
    y_max = ceil(max(abs(coefficents(:))));
    y_min = floor(min(abs(coefficents(:))));

    hfig = figure;
    fname = 'myfigure';
    picturewidth = 20; % set this parameter and keep it forever
    hw_ratio = 0.65; % feel free to play with this ratio
    set(findall(hfig, '-property', 'FontSize'), 'FontSize', 10); % adjust fontsize to your document
    set(findall(hfig, '-property', 'Interpreter'), 'Interpreter', 'latex');
    set(findall(hfig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');

    for i_order = 1:5:length(fractional_orders)
        order = fractional_orders(i_order);
        stem(squeeze(graph_frequencies(j_strategy, :)), ...
             squeeze(abs(coefficents(j_strategy, i_order, :))), 'filled');
        xlim([x_min, x_max]);
        ylim([y_min, y_max]);
        xlabel("Graph Frequency, $\lambda$", 'Interpreter', 'latex');
        ylabel("Coefficent Magnitudes, $|\alpha|$", 'Interpreter', 'latex');
        legend(sprintf("Fractional Order: %.3f", order), ...
               'Location', 'north');
        grid on;
        grid minor;

        if order == 0 || order == 0.25 || order == 0.5 || order == 0.75 || order == 1
            pause(1);
        else
            pause(0.01);
        end
    end
end
