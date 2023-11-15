% (c) Copyright 2023 Tuna Alikaşifoğlu

function Plot_Time(power_durations, hyper_durations, ...
                   fractional_orders, sizes, strategy_index)
    for size_index = 1:length(sizes)
    power_vals = squeeze(power_durations(size_index, strategy_index, :, :));
    hyper_vals = squeeze(hyper_durations(size_index, strategy_index, :, :));

    power_mean = mean(power_vals, 2);
    power_std = std(power_vals, 0, 2);
    hyper_mean = mean(hyper_vals, 2);
    hyper_std = std(hyper_vals, 0, 2);

    fig = figure;
    bar(fractional_orders, 1000 * [power_mean, hyper_mean]);
    max_val = max(max(power_mean), max(hyper_mean));
    ylim([0, 1500 * max_val]);
    xlabel("Fractional Order");
    ylabel("Duration (ms)");
    legend(["Power", "Hyper"], 'Orientation','horizontal');
    xticks(fractional_orders(1:2:end));
    if size_index == 1
        yticks([0, 25, 50]);
    else
        yticks([0, 100, 200]);
    end
    grid on;
    grid minor;

    set(gcf, 'Units', 'centimeters');
    set(gcf, 'Position', [0, 0, 17.78, 3])
    set(findall(fig,'-property','Box'),'Box','off') % optional
    set(findall(fig, '-property', 'FontSize'), 'FontSize', 10);
    set(findall(fig, '-property', 'Interpreter'), 'Interpreter', 'latex');
    set(findall(fig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');

    ax = gca;
    filename = sprintf('time_frac_n%d.eps', sizes(size_index));
    exportgraphics(ax, filename, 'Resolution', 300);
    end
end
