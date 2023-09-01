% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Load Workspace
dataset_title = "PM-25";
filename = sprintf("comparison-%s", dataset_title);
mat_path = sprintf("%s.mat", filename);
output_path = sprintf("%s.txt", filename);
file_id = fopen(output_path, 'w');
load(mat_path);

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
        fprintf(file_id, "& \\(%.4f\\) ", noisy_snrs(k_knn, i_sigma));
    end
end
fprintf(file_id, "\\\\\\midrule\n");

%% Print Body
for i_arma = 1:length(arma_orders)
    fprintf(file_id, "ARMA%d\t & ", arma_orders(i_arma) + 2);
    for k_knn = 1:length(knn_counts)
        for j_sigma = 1:length(sigmas)
            fprintf(file_id, " & \\(%.4f\\)", arma_snrs(k_knn, j_sigma, i_arma));
        end
    end
    fprintf(file_id, " \\\\\n");
end

for i_median = 1:length(median_orders)
    fprintf(file_id, "Median%d\t & ", median_orders(i_median));
    for k_knn = 1:length(knn_counts)
        for j_sigma = 1:length(sigmas)
            fprintf(file_id, " & \\(%.4f\\)", median_snrs(k_knn, j_sigma, i_median));
        end
    end
    fprintf(file_id, " \\\\\n");
end

gft_results = Get_GFT_Results(gfrft_snrs, fractional_orders);
for i_strat = 1:length(gfrft_strategies)
    fprintf(file_id, "GFT - %s & ", Abbreviation(gfrft_strategies(i_strat)));
    for k_knn = 1:length(knn_counts)
        for j_sigma = 1:length(sigmas)
            fprintf(file_id, " & \\(%.4f\\)", gft_results(k_knn, j_sigma, i_strat));
        end
    end
    fprintf(file_id, " \\\\\n");
end

[gfrft_results, best_frac_orders] = Get_GFRFT_Results(gfrft_snrs, fractional_orders, ...
                                                      knn_counts, sigmas, gfrft_strategies);
for i_strat = 1:length(gfrft_strategies)
    fprintf(file_id, "GFRFT - %s & ", Abbreviation(gfrft_strategies(i_strat)));
    for k_knn = 1:length(knn_counts)
        for j_sigma = 1:length(sigmas)
            fprintf(file_id, " & \\((%.2f)\\, %.4f\\)", ...
                    best_frac_orders(k_knn, j_sigma, i_strat), ...
                    gfrft_results(k_knn, j_sigma, i_strat));
        end
    end
    fprintf(file_id, " \\\\\n");
end
fprintf(file_id, "\\bottomrule\n");
fprintf(file_id, "\\end{tabular}\n");

%% Helper Functions
function gft_results = Get_GFT_Results(gfrft_snrs, fractional_orders)
    gft_results = gfrft_snrs(:, :, :, fractional_orders == 1);
end

function [gfrft_results, best_orders] = Get_GFRFT_Results(gfrft_snrs, fractional_orders, ...
                                                          knn_counts, sigmas, gfrft_strategies)
    gfrft_results = zeros(length(knn_counts), length(sigmas), length(gfrft_strategies));
    best_orders = zeros(length(knn_counts), length(sigmas), length(gfrft_strategies));
    for i_sigma = 1:length(sigmas)
        for j_strat = 1:length(gfrft_strategies)
            for k_knn = 1:length(knn_counts)
                [max_snr, max_idx] = max(gfrft_snrs(k_knn, i_sigma, j_strat, :));
                gfrft_results(k_knn, i_sigma, j_strat) = max_snr;
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
