% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Load all mat files in into results cell array
dataset_path = 'pm25';
mat_files = dir(fullfile(dataset_path, '*.mat'));
num_seeds = length(mat_files);
results = cell(num_seeds, 1);

noisy_snrs_cell = cell(num_seeds, 1);
arma_snrs_cell = cell(num_seeds, 1);
median_snrs_cell = cell(num_seeds, 1);
gfrft_snrs_cell = cell(num_seeds, 1);

for iFile = 1:length(mat_files)
    results{iFile} = load(fullfile(dataset_path, mat_files(iFile).name));
    arma_snrs_cell{iFile} = results{iFile}.arma_snrs;
    median_snrs_cell{iFile} = results{iFile}.median_snrs;
    gfrft_snrs_cell{iFile} = results{iFile}.gfrft_snrs;
end

%%
i_result = 3;
for i_median = 1:length(results{i_result}.median_orders)
    fprintf("Median%d\n", results{i_result}.median_orders(i_median));
    for k_knn = 1:length(results{i_result}.knn_counts)
        for j_sigma = 1:length(results{i_result}.sigmas)
            fprintf("%.4f\n", results{i_result}.median_snrs(k_knn, j_sigma, i_median));
        end
    end
end

%%
[noisy_snrs_means, noisy_snrs_stds] = Get_Mean_Std_Pair(noisy_snrs_cell);
[arma_snrs_means, arma_snrs_stds] = Get_Mean_Std_Pair(arma_snrs_cell);
[median_snrs_means, median_snrs_stds] = Get_Mean_Std_Pair(median_snrs_cell);
[gfrft_snrs_means, gfrft_snrs_stds] = Get_Mean_Std_Pair(gfrft_snrs_cell);

function [means, stds] = Get_Mean_Std_Pair(matrices_cell)
    matrices_combined = cat(ndims(matrices_cell{1}) + 1, matrices_cell{:});
    means = mean(matrices_combined, ndims(matrices_combined));
    stds = std(matrices_combined, 0, ndims(matrices_combined));
end
