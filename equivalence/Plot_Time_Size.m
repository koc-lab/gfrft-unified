% (c) Copyright 2023 Tuna Alikaşifoğlu

function Plot_Time_Size(power_durations, hyper_durations, ...
                        fractional_orders, sizes, gfrft_strategies)
    marker_list = {'o', '^', 'd', 'v', '>', '<', 'p', 'h'};
    marker_size = 4;
    line_width = 3;

    for i_strategy = 1:length(gfrft_strategies)
        power_vals = squeeze(power_durations(:, i_strategy, :, :));
        hyper_vals = squeeze(hyper_durations(:, i_strategy, :, :));

        figure;
        power_mean = mean(power_vals, ndims(power_vals));
        power_std = std(power_vals, 0, ndims(power_vals));
        power_upper = power_mean + power_std;
        power_lower = power_mean - power_std;

        hyper_mean = mean(hyper_vals, ndims(power_vals));
        hyper_std = std(hyper_vals, 0, ndims(power_vals));
        hyper_upper = hyper_mean + hyper_std;
        hyper_lower = hyper_mean - hyper_std;

        plts = [];
        for j_order = 1:length(fractional_orders)
            marker = marker_list{j_order};
            plt = errorbar(sizes, power_mean(:, j_order), power_std(:, j_order), ...
                           'LineWidth', line_width, ...
                           'Marker', marker, ...
                           'MarkerSize', marker_size, ...
                           'DisplayName', sprintf("Power, $a$ = %.2f", fractional_orders(j_order)));
            plts = [plts; plt];
            hold on;
        end
        for j_order = 1:length(fractional_orders)
            marker = marker_list{j_order};
            plt = errorbar(sizes, hyper_mean(:, j_order), hyper_std(:, j_order), ...
                           'LineWidth', line_width, ...
                           'Marker', marker, ...
                           'MarkerSize', marker_size, ...
                           'DisplayName', sprintf("Hyper, $a$ = %.2f", fractional_orders(j_order)));
            plts = [plts; plt];
            hold on;
        end
        set(gca, 'YScale', 'log');
        legend(plts, 'Location', 'best', 'Interpreter', 'latex');
        xlabel('Vertex Count, $N$', 'Interpreter', 'latex');
        ylabel('Duration (seconds), $\log$-scale', 'Interpreter', 'latex');

        xlim([40, 610]);
        y_min = 0.9 * min([power_lower(:); hyper_lower(:)]);
        y_max = 1.1 * max([power_upper(:); hyper_upper(:)]);
        ylim([y_min, y_max]);
        grid on;
        grid minor;
        for i = 1:8
            fontsize("increase");
        end
        ax = gca;
        filename = sprintf('time_%s.eps', gfrft_strategies{i_strategy});
        exportgraphics(ax, filename, 'Resolution', 300);
    end
end
