% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Load all mat files in into results cell array
dataset_path = 'synthetic-zero-mean-valid';
filename = dataset_path;
mat_files = dir(fullfile(dataset_path, '*.mat'));
num_seeds = length(mat_files);
results = cell(num_seeds, 1);

noisy_snrs_cell = cell(num_seeds, 1);
arma_snrs_cell = cell(num_seeds, 1);
median_snrs_cell = cell(num_seeds, 1);
gfrft_snrs_cell = cell(num_seeds, 1);

for iFile = 1:length(mat_files)
    results{iFile} = load(fullfile(dataset_path, mat_files(iFile).name));
    noisy_snrs_cell{iFile} = results{iFile}.noisy_snrs;
    arma_snrs_cell{iFile} = results{iFile}.arma_snrs;
    median_snrs_cell{iFile} = results{iFile}.median_snrs;
    gfrft_snrs_cell{iFile} = results{iFile}.gfrft_snrs;
end

%%
[noisy_snrs_means, noisy_snrs_stds] = Get_Mean_Std_Pair(noisy_snrs_cell);
[arma_snrs_means, arma_snrs_stds] = Get_Mean_Std_Pair(arma_snrs_cell);
[median_snrs_means, median_snrs_stds] = Get_Mean_Std_Pair(median_snrs_cell);
[gfrft_snrs_means, gfrft_snrs_stds] = Get_Mean_Std_Pair(gfrft_snrs_cell);

%%
output_path = sprintf("%s.txt", filename);
file_id = fopen(output_path, 'w');
knn_counts = results{1}.knn_counts;
sigmas = results{1}.sigmas;

%% Print Head
fprintf(file_id, "\\begin{tabular}{@{}lr");
for i = 1:(length(knn_counts) * length(sigmas))
    fprintf(file_id, "r");
end
fprintf(file_id, "@{}}\\toprule\n");

fprintf(file_id, "& ");
for k_count = knn_counts
    fprintf(file_id, "& \\multicolumn{%d}{c}{\\(%d\\)-NN} ", length(sigmas), k_count);
end
fprintf(file_id, " \\\\");
start = 3;
for k_knn = 0:(length(knn_counts) - 1)
    fprintf(file_id, " \\cmidrule(lr){%d-%d}", ...
            start + k_knn * length(sigmas), ...
            start + (k_knn + 1) * length(sigmas) - 1);
end
fprintf(file_id, "\n");

fprintf(file_id, " & \\(\\boldsymbol{\\sigma}\\) ");
for k_counts = knn_counts
    for sigma = sigmas
        fprintf(file_id, "& \\(%.2f\\) ", sigma);
    end
end
fprintf(file_id, "\\\\\n");

fprintf(file_id, " & \\textbf{SNR (dB)} ");
for k_knn = 1:length(knn_counts)
    for i_sigma = 1:length(sigmas)
        fprintf(file_id, "& \\(%.3f\\pm %.3f\\) ", ...
                noisy_snrs_means(k_knn, i_sigma), ...
                noisy_snrs_stds(k_knn, i_sigma));
    end
end
fprintf(file_id, "\\\\\\midrule\n");

%% Print Body
arma_orders = results{1}.arma_orders;
for i_arma = 1:length(arma_orders)
    fprintf(file_id, "ARMA%d\t & ", arma_orders(i_arma) + 2);
    for k_knn = 1:length(knn_counts)
        for j_sigma = 1:length(sigmas)
            fprintf(file_id, " & \\(%.3f\\pm %.3f\\)", ...
                    arma_snrs_means(k_knn, j_sigma, i_arma), ...
                    arma_snrs_stds(k_knn, j_sigma, i_arma));
        end
    end
    fprintf(file_id, " \\\\\n");
end

median_orders = results{1}.median_orders;
for i_median = 1:length(median_orders)
    fprintf(file_id, "Median%d\t & ", median_orders(i_median));
    for k_knn = 1:length(knn_counts)
        for j_sigma = 1:length(sigmas)
            fprintf(file_id, " & \\(%.3f\\pm %.3f\\)", ...
                    median_snrs_means(k_knn, j_sigma, i_median), ...
                    median_snrs_stds(k_knn, j_sigma, i_median));
        end
    end
    fprintf(file_id, " \\\\\n");
end

fractional_orders = results{1}.fractional_orders;
gfrft_strategies = results{1}.gfrft_strategies;
[gft_results_means, gft_results_stds] = Get_GFT_Results(gfrft_snrs_means, ...
                                                        gfrft_snrs_stds, fractional_orders);
for i_strat = 1:length(gfrft_strategies)
    fprintf(file_id, "GFT - %s & ", Abbreviation(gfrft_strategies(i_strat)));
    for k_knn = 1:length(knn_counts)
        for j_sigma = 1:length(sigmas)
            fprintf(file_id, " & \\(%.3f\\pm %.3f\\)", ...
                    gft_results_means(k_knn, j_sigma, i_strat), ...
                    gft_results_stds(k_knn, j_sigma, i_strat));
        end
    end
    fprintf(file_id, " \\\\\n");
end

[gfrft_results, best_frac_orders] = Get_GFRFT_Results(gfrft_snrs_means, fractional_orders, ...
                                                      knn_counts, sigmas, gfrft_strategies);
for i_strat = 1:length(gfrft_strategies)
    fprintf(file_id, "GFRFT - %s & ", Abbreviation(gfrft_strategies(i_strat)));
    for k_knn = 1:length(knn_counts)
        for j_sigma = 1:length(sigmas)
            fprintf(file_id, " & \\((%.2f)\\, %.3f\\pm %.3f\\)", ...
                    best_frac_orders(k_knn, j_sigma, i_strat), ...
                    gfrft_results(k_knn, j_sigma, i_strat), ...
                    gfrft_snrs_stds(k_knn, j_sigma, i_strat));
        end
    end
    fprintf(file_id, " \\\\\n");
end
fprintf(file_id, "\\bottomrule\n");
fprintf(file_id, "\\end{tabular}\n");

%% Helper Functions
function [means, stds] = Get_Mean_Std_Pair(matrices_cell)
    matrices_combined = cat(ndims(matrices_cell{1}) + 1, matrices_cell{:});
    means = mean(matrices_combined, ndims(matrices_combined));
    stds = std(matrices_combined, 0, ndims(matrices_combined));
end

function [gft_results_means, gft_results_stds] = Get_GFT_Results(gfrft_snrs_means, ...
                                                                 gfrft_snrs_stds, ...
                                                                 fractional_orders)
    gft_results_means = gfrft_snrs_means(:, :, :, fractional_orders == 1);
    gft_results_stds = gfrft_snrs_stds(:, :, :, fractional_orders == 1);
end

function [gfrft_results_means, best_orders] = Get_GFRFT_Results(gfrft_snrs_means, ...
                                                                fractional_orders, knn_counts, ...
                                                                sigmas, gfrft_strategies)
    gfrft_results_means = zeros(length(knn_counts), length(sigmas), length(gfrft_strategies));
    best_orders = zeros(length(knn_counts), length(sigmas), length(gfrft_strategies));
    for i_sigma = 1:length(sigmas)
        for j_strat = 1:length(gfrft_strategies)
            for k_knn = 1:length(knn_counts)
                [max_snr, max_idx] = max(gfrft_snrs_means(k_knn, i_sigma, j_strat, :));
                gfrft_results_means(k_knn, i_sigma, j_strat) = max_snr;
                best_orders(k_knn, i_sigma, j_strat) = fractional_orders(max_idx);
            end
        end
    end
end

function result = Abbreviation(input_str)
    % Split the input string into words
    words = strsplit(input_str);

    % Initialize an empty array to store the first 3 characters of each word
    first_chars = {};

    % Iterate through each word and extract the first 3 characters
    for i = 1:length(words)
        word = words{i};
        % If the word has at least 3 characters, extract the first 3 characters
        if length(word) >= 3
            first_chars{end + 1} = word(1:3);
        end
    end
    % Combine the extracted characters into a new string
    result = strjoin(first_chars);
end
