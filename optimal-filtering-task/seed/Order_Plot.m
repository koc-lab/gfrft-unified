% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Load all mat files in into results cell array
% dataset_path = 'sst';
% dataset_path = 'pm25';
dataset_path = 'covid-usa';
% dataset_path = 'synthetic-zero-mean-valid';
mat_files = dir(fullfile(dataset_path, '*.mat'));
num_seeds = length(mat_files);
results = cell(num_seeds, 1);
gfrft_snrs_cell = cell(num_seeds, 1);

for iFile = 1:length(mat_files)
    results{iFile} = load(fullfile(dataset_path, mat_files(iFile).name));
    gfrft_snrs_cell{iFile} = results{iFile}.gfrft_snrs;
end
knn_counts = results{1}.knn_counts;
sigmas = results{1}.sigmas;
gfrft_strategies = results{1}.gfrft_strategies;
fractional_orders = results{1}.fractional_orders;

%%
combined = cat(ndims(gfrft_snrs_cell{1}) + 1, gfrft_snrs_cell{:});
start = 1;
i_knn = 2;
% i_sigma = 3;
i_strategy = 5;

figure;
plts = [];
for i_sigma = start:length(sigmas)
    values = squeeze(combined(i_knn, i_sigma, i_strategy, :, :)).';
    means = mean(values, 1);
    stds = std(values, 0, 1);
    upper = means + stds;
    lower = means - stds;

    plt = plot(fractional_orders, means, 'LineWidth', 2.5);
    plts = [plts; plt];
    line_color = get(plt, 'Color');
    hold on;
    fill([fractional_orders, fliplr(fractional_orders)], ...
         [upper, fliplr(lower)], line_color, 'FaceAlpha', 0.2);
end
grid on;
legend_strs = cellfun(@(x) ['\sigma = ', num2str(x)], ...
                      num2cell(sigmas(start:end)), 'UniformOutput', false);
legend(plts, legend_strs);
xlabel('Fractional Order $a$', 'interpreter', 'latex');
ylabel('SNR (dB)', 'interpreter', 'latex');
for i = 1:15
    fontsize("increase");
end
