% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Plotting the results
load("./../sampling-23-10-19-01-15.mat");
markers = ["d", "o", "."];
fig = figure;
plts = [];
colormap(flipud(parula)); % Cool blues to warm oranges
for i_sample = 1:size(truths_result, 1)
    values = 0.1 * squeeze(truths_result(i_sample, :, :)).';
    means = mean(values, 1);
    stds = std(values, 0, 1);
    upper = means + stds;
    lower = means - stds;

    plt = plot(fractional_orders, means, ...
               'LineWidth', 2); % , ...
    % 'Marker', markers(i_sample), ...
    % 'MarkerSize', 5);
    plts = [plts; plt];
    line_color = get(plt, 'Color');
    hold on;
    fill([fractional_orders, fliplr(fractional_orders)], ...
         [upper, fliplr(lower)], line_color, ...
         'FaceAlpha', 0.2, ...
         'LineStyle', ':');
    % errorbar(fractional_orders, means, stds, ...)
    %          'LineStyle', 'none', ...
    %          'LineWidth', 1.2, ...
    %          'Color', line_color);
end
grid on;
grid minor;
legend_strs = cellfun(@(x) [num2str(x), ' samples'], ...
                      num2cell(sample_counts), 'UniformOutput', false);
legend(plts, legend_strs, 'Location', 'south');
xlabel("\textbf{Fractional order}", "Interpreter", "latex");
ylabel("\textbf{Accuracy} (\boldmath$\%$)", "Interpreter", "latex");
xlim([min(fractional_orders), max(fractional_orders)]);
ylim([0.99 * min(0.1 * truths_result(:)), 1.01 * max(0.1 * truths_result(:))]);
xticks(0.9:0.05:1.1);
yticks(50:3:80);
% for i = 1:14
%     fontsize("increase");
% end

set(gcf, 'Units', 'centimeters');
set(gcf, 'Position', [0, 0, 17.78, 10]);
set(gca, 'FontWeight', 'bold', 'FontSize', 22);
set(findall(fig, '-property', 'Box'), 'Box', 'off'); % optional
set(findall(fig, '-property', 'FontSize'), 'FontSize', 22);
set(findall(fig, '-property', 'Interpreter'), 'Interpreter', 'latex');
% set(findall(fig, '-property', 'TickLabelInterpreter'), 'TickLabelInterpreter', 'latex');

ax = gca;
exportgraphics(ax, 'sampling.eps', 'Resolution', 300);
