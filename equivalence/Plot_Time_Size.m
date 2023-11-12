% (c) Copyright 2023 Tuna Alikaşifoğlu

function Plot_Time_Size(power_durations, hyper_durations, ...
                        fractional_orders, sizes, gfrft_strategies)
    marker_list = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h'};
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
            plt = plot(sizes, power_mean(:, j_order), 'r', ...
                       'LineWidth', 2, ...
                       'Marker', marker, ...
                       'DisplayName', sprintf("Power, \\sigma = %.2f", fractional_orders(j_order)));
            plts = [plts; plt];
            hold on;

            line_color = get(plt, 'Color');
            fill([sizes, fliplr(sizes)], ...
                 [power_upper(:, j_order).', fliplr(power_lower(:, j_order).')], ...
                 line_color, 'FaceAlpha', 0.2);
        end
        for j_order = 1:length(fractional_orders)
            marker = marker_list{j_order};
            plt = plot(sizes, hyper_mean(:, j_order), 'b', ...
                       'LineWidth', 2, ...
                       'Marker', marker, ...
                       'DisplayName', sprintf("Hyper, \\sigma = %.2f", fractional_orders(j_order)));
            plts = [plts; plt];
            hold on;

            line_color = get(plt, 'Color');
            fill([sizes, fliplr(sizes)], ...
                 [hyper_upper(:, j_order).', fliplr(hyper_lower(:, j_order).')], ...
                 line_color, 'FaceAlpha', 0.2);
        end
        legend(plts, 'Location', 'best');
    end
end
