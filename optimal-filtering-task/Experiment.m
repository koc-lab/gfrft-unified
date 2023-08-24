% (c) Copyright 2023 Tuna Alikaşifoğlu

function [estimation_snrs, noisy_snrs] = Experiment(gft_mtx, transform_mtx, signals, ...
                                                    fractional_orders, snr_dbs, uncorrelated)
    arguments
        gft_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        transform_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        signals(:, :) {mustBeNumeric, Must_Be_Multiplicable(gft_mtx, signals)}
        fractional_orders(:, 1) {mustBeNumeric, mustBeVector}
        snr_dbs(:, 1) {mustBeNumeric, mustBeVector}
        uncorrelated(1, 1) logical = false
    end

    use_gpu = isgpuarray(gft_mtx);

    noise_cell = cell(length(snr_dbs), 1);
    noisy_snrs = zeros(length(snr_dbs), 1);
    for i_snr = 1:length(snr_dbs)
        noise_cell{i_snr} = Generate_Noise(signals, snr_dbs(i_snr), use_gpu);
        noisy_snrs(i_snr) = Snr(signals, signals + noise_cell{i_snr});
    end

    if use_gpu
        estimation_snrs = zeros(length(fractional_orders), length(snr_dbs), ...
                                size(signals, 2), 'gpuArray');
    else
        estimation_snrs = zeros(length(fractional_orders), length(snr_dbs), size(signals, 2));
    end
    for i_order = progress(1:length(fractional_orders), 'Title', 'Order')
        [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, fractional_orders(i_order));

        for j_snr = progress(1:length(snr_dbs), 'Title', 'SNR')
            noises = noise_cell{j_snr};
            parfor k_signal = 1:size(signals, 2)
                graph_signal = signals(:, k_signal);
                noise = noises(:, k_signal);
                filtered_signal = Optimal_Filter_Empirical(transform_mtx, gfrft_mtx, igfrft_mtx, ...
                                                           graph_signal, noise, ...
                                                           uncorrelated, use_gpu);
                estimation_snrs(i_order, j_snr, k_signal) = Snr(graph_signal, filtered_signal);
            end
        end
    end
end

function noise = Generate_Noise(signal, snr_db, use_gpu)
    if use_gpu
        noise = randn(size(signal), 'gpuArray');
    else
        noise = randn(size(signal));
    end
    noise = noise .* std(signal) / db2mag(snr_db);
end
