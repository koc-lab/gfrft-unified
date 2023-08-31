% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Load Workspace
dataset_title = "PM-25";
knn_count = 5;
filepath = sprintf("comparison-%s-%dnn.mat", dataset_title, knn_count);
load(filepath);

%% Noise Info
fprintf("Sigmas\t :");
for i_sigma = 1:length(sigmas)
    fprintf(" %.2f ", sigmas(i_sigma));
end
fprintf("\nNoise SNR:");
for i_noise = 1:length(noisy_snrs)
    fprintf(" %.2f ", noisy_snrs(i_noise));
end
fprintf("\n\n");

%% Results
for i_arma = 1:length(arma_orders)
    fprintf("ARMA%d\t", arma_orders(i_arma) + 2);
    for j_sigma = 1:length(sigmas)
        fprintf(" & \\(%.4f\\)", arma_snrs(j_sigma, i_arma));
    end
    fprintf(" \\\\\n");
end

for i_median = 1:length(median_orders)
    fprintf("Median%d\t", median_orders(i_median));
    for j_sigma = 1:length(sigmas)
        fprintf(" & \\(%.4f\\)", median_snrs(j_sigma, i_median));
    end
    fprintf(" \\\\\n");
end

gft_results = Get_GFT_Results(gfrft_snrs, fractional_orders);
for i_strat = 1:length(gfrft_strategies)
    fprintf("GFT - %s ", Abbreviation(gfrft_strategies(i_strat)));
    for j_sigma = 1:length(sigmas)
        fprintf(" & \\(%.4f\\)", gft_results(j_sigma, i_strat));
    end
    fprintf(" \\\\\n");
end

[gfrft_results, best_frac_orders] = Get_GFRFT_Results(gfrft_snrs, fractional_orders, ...
                                                      sigmas, gfrft_strategies);
for i_strat = 1:length(gfrft_strategies)
    fprintf("GFRFT - %s ", Abbreviation(gfrft_strategies(i_strat)));
    for j_sigma = 1:length(sigmas)
        fprintf(" & \\((%.2f)\\, %.4f\\)", best_frac_orders(j_sigma, i_strat), ...
                gft_results(j_sigma, i_strat));
    end
    fprintf(" \\\\\n");
end

%% Helper Functions
function gft_results = Get_GFT_Results(gfrft_snrs, fractional_orders)
    gft_results = gfrft_snrs(:, :, fractional_orders == 1);
end

function [gfrft_results, best_orders] = Get_GFRFT_Results(gfrft_snrs, fractional_orders, ...
                                                          sigmas, gfrft_strategies)
    gfrft_results = zeros(length(sigmas), length(gfrft_strategies));
    best_orders = zeros(length(sigmas), length(gfrft_strategies));
    for i_sigma = 1:length(sigmas)
        for j_strat = 1:length(gfrft_strategies)
            [max_snr, max_idx] = max(gfrft_snrs(i_sigma, j_strat, :));
            gfrft_results(i_sigma, j_strat) = max_snr;
            best_orders(i_sigma, j_strat) = fractional_orders(max_idx);
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
