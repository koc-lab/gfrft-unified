% (c) Copyright 2023 Tuna Alikaşifoğlu

clear all;
close all;
clc;

load("./../sampling-23-10-19-01-15.mat");
markers = ["d", "o", "."];
figure;
plts = [];
colormap(flipud(parula)); % Cool blues to warm oranges
for i_sample = 1:size(truths_result, 1)
    values = 0.1 * squeeze(truths_result(i_sample, :, :)).';
    means = mean(values, 1);
    stds = std(values, 0, 1);
    upper = means + stds;
    lower = means - stds;

    plt = plot(fractional_orders, means, ...
               'LineWidth', 1.5, ...
               'Marker', markers(i_sample), ...
               'MarkerSize', 7);
    plts = [plts; plt];
    line_color = get(plt, 'Color');
    hold on;
    % fill([fractional_orders, fliplr(fractional_orders)], ...
    %      [upper, fliplr(lower)], line_color, 'FaceAlpha', 0.1);
    errorbar(fractional_orders, means, stds, ...)
             'LineStyle', 'none', ...
             'LineWidth', 1.5, ...
             'Color', line_color);
end
grid on;
legend_strs = cellfun(@(x) [num2str(x), ' samples'], ...
                      num2cell(sample_counts), 'UniformOutput', false);
legend(plts, legend_strs, 'Location', 'best');
xlabel("Fractional order");
ylabel("Accuracy ($\%$) ", "Interpreter", "latex");
xlim([0.9, 1.1]);
% for i = 1:15
%     fontsize("increase");
% end
