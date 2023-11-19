% (c) Copyright 2023 Tuna Alikaşifoğlu

function Plot_Time(power_durations, hyper_durations, ...
                   fractional_orders, sizes, strategy_index)
    for size_index = 1:length(sizes)
        power_vals = 1000 * squeeze(power_durations(size_index, strategy_index, :, :));
        hyper_vals = 1000 * squeeze(hyper_durations(size_index, strategy_index, :, :));

        power_mean = mean(power_vals, ndims(power_vals));
        power_std = std(power_vals, 0, ndims(power_vals));
        power_upper = power_mean + power_std;

        hyper_mean = mean(hyper_vals, ndims(power_vals));
        hyper_std = std(hyper_vals, 0, ndims(power_vals));
        hyper_upper = hyper_mean + hyper_std;

        fig = figure;
        plt = bar(fractional_orders, [power_mean, hyper_mean]);
        hold on;

        power_err = errorbar(plt(1).XData + plt(1).XOffset, power_mean, power_std);
        power_err.Color = [0 0 0];
        power_err.LineStyle = 'none';

        hyper_err = errorbar(plt(2).XData + plt(2).XOffset, hyper_mean, hyper_std);
        hyper_err.Color = [0 0 0];
        hyper_err.LineStyle = 'none';

        max_val = max(max(power_upper), max(hyper_upper));
        ylim([0, 1.3 * max_val]);
        xlabel("Fractional Order");
        ylabel("Duration (ms)");
        legend(["Power", "Hyper"], 'Orientation', 'horizontal');
        xticks(fractional_orders(1:2:end));
        if size_index == 1
            yticks([0, 25, 50]);
        else
            yticks([0, 100, 200]);
        end
        grid on;
        grid minor;

        set(gcf, 'Units', 'centimeters');
        set(gcf, 'Position', [0, 0, 17.78, 6]);
        set(findall(fig, '-property', 'Box'), 'Box', 'off'); % optional
        set(findall(fig, '-property', 'FontSize'), 'FontSize', 12);
        set(findall(fig, '-property', 'Interpreter'), 'Interpreter', 'latex');
        set(findall(fig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');

        ax = gca;
        filename = sprintf('time_frac_n%d.eps', sizes(size_index));
        exportgraphics(ax, filename, 'Resolution', 300);
    end
end
