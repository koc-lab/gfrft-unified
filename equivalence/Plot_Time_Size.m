% (c) Copyright 2023 Tuna Alikaşifoğlu

function Plot_Time_Size(power_durations, hyper_durations, ...
                        fractional_orders, sizes, gfrft_strategies)
    marker_list = {'^', 'o', 'd', 'v', '>', '<', 'p', 'h'};
    marker_sizes = {8, 5};
    line_width = 3;
    color_list = {'#ee9b00', '#9b2226', '#001219', '#005f73'};

    for j_order = 1:length(fractional_orders)
        fig = figure;
        set(gcf, 'Units', 'centimeters');
        set(gcf, 'Position', [0, 0, 17.78, 13]);

        plts = [];
        for i_strategy = 1:length(gfrft_strategies)
            power_vals = squeeze(power_durations(:, i_strategy, j_order, :));
            power_mean = mean(power_vals, ndims(power_vals));
            power_std = std(power_vals, 0, ndims(power_vals));
            power_upper = power_mean + power_std;
            power_lower = power_mean - power_std;
            color = color_list{i_strategy};
            marker = marker_list{i_strategy};
            marker_size = marker_sizes{i_strategy};
            strategy_name = char(gfrft_strategies(i_strategy));
            short_name = [upper(strategy_name(1)), strategy_name(2:3), '.'];

            plt = errorbar(sizes, power_mean, power_std, ...
                           'LineWidth', line_width, ...
                           'Color', color, ...
                           'Marker', marker, ...
                           'MarkerSize', marker_size, ...
                           'DisplayName', sprintf("Power, %s", short_name));
            plts = [plts; plt];
            hold on;
        end

        for i_strategy = 1:length(gfrft_strategies)
            hyper_vals = squeeze(hyper_durations(:, i_strategy, j_order, :));
            hyper_mean = mean(hyper_vals, ndims(power_vals));
            hyper_std = std(hyper_vals, 0, ndims(power_vals));
            hyper_upper = hyper_mean + hyper_std;
            hyper_lower = hyper_mean - hyper_std;
            color = color_list{length(gfrft_strategies) + i_strategy};
            marker = marker_list{i_strategy};
            marker_size = marker_sizes{i_strategy};
            strategy_name = char(gfrft_strategies(i_strategy));
            short_name = [upper(strategy_name(1)), strategy_name(2:3), '.'];

            plt = errorbar(sizes, hyper_mean, hyper_std, ...
                           'LineWidth', line_width, ...
                           'Color', color, ...
                           'Marker', marker, ...
                           'MarkerSize', marker_size, ...
                           'DisplayName', sprintf("Hyper, %s", short_name));
            plts = [plts; plt];
            hold on;
        end
        set(gca, 'YScale', 'log');
        legend(plts, 'Location', 'southeast');
        xlabel('\textbf{Vertex Count,} \boldmath$N$');
        ylabel('\textbf{Duration (s)}');

        xlim([min(sizes) - 10, max(sizes) + 10]);
        xticks([0:100:600]);
        yticks([1e-3, 1e-2, 1e-1, 1e0, 1e1]);
        y_min = 0.9 * min([power_lower(:); hyper_lower(:)]);
        y_max = 1.1 * max([power_upper(:); hyper_upper(:)]);
        ylim([y_min, y_max]);
        grid on;
        grid minor;
        set(gca, 'FontWeight', 'bold', 'FontSize', 28);
        set(findall(fig, '-property', 'Box'), 'Box', 'off'); % optional
        set(findall(fig, '-property', 'FontSize'), 'FontSize', 28);
        set(findall(fig, '-property', 'Interpreter'), 'Interpreter', 'latex');
        % set(findall(fig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');

        ax = gca;
        filename = sprintf('time_size_%.2f.eps', fractional_orders(j_order));
        exportgraphics(ax, filename, 'Resolution', 300);
    end
end
