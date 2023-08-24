%% Clear
clc, clear, close all;

%% Load data

dataset_title = "PM-25";
knn_count = 2;
shift_mtx_strategy = 'adjacency';
filename = sprintf("results-%s-%dnn-%s.mat", ...
                   dataset_title, knn_count, shift_mtx_strategy);
results = load(filename);

estimation_snrs = results.estimation_snrs;
fractional_orders = results.fractional_orders;
snr_dbs = results.snr_dbs;
snr_idx = 1;

figure;
[X, Y] = meshgrid(1:100, fractional_orders);
surf(X, Y, squeeze(estimation_snrs(:, snr_idx, :)));
xlabel("Signal Index");
ylabel("Fractional order");

for i_snr = 1:length(snr_dbs)
    figure;
    snrs = squeeze(estimation_snrs(:, i_snr, :));
    for j_signal = 1:size(estimation_snrs, 3)
        plot(fractional_orders, snrs(:, j_signal));
        hold on;
    end
    xlabel("Fractional order");
    ylabel("Average SNR");
    grid on;
end

figure;
mean_estimation_snrs = squeeze(mean(estimation_snrs, 3));
for i_snr = 1:length(snr_dbs)
    plot(fractional_orders, mean_estimation_snrs(:, i_snr));
    hold on;
end
xlabel("Fractional order");
ylabel("Average SNR");
grid on;



