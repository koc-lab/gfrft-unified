% (c) Copyright 2023 Tuna Alikaşifoğlu

function [estimation_snrs, noisy_snrs] = Experiment_Common(gft_mtx, transform_mtx, signals, ...
                                                           fractional_orders, snr_dbs, ...
                                                           uncorrelated)
    arguments
        gft_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        transform_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        signals(:, :) {mustBeNumeric, Must_Be_Multiplicable(gft_mtx, signals)}
        fractional_orders(:, 1) {mustBeNumeric, mustBeVector}
        snr_dbs(:, 1) {mustBeNumeric, mustBeVector}
        uncorrelated(1, 1) logical = false
    end

    use_gpu = isgpuarray(signals);

    % Generate Noises for different SNR values
    noises = zeros([length(snr_dbs) size(signals)], 'like', signals);
    noisy_snrs = zeros(length(snr_dbs), 1);
    for i_snr = 1:length(snr_dbs)
        noises(i_snr, :, :) = Generate_Noise(signals, snr_dbs(i_snr));
        noisy_snrs(i_snr) = Snr(signals, signals + squeeze(noises(i_snr, :, :)));
    end

    corr_xx = Generate_Correlation_Matrix(signals);
    estimation_snrs = zeros(length(fractional_orders), length(snr_dbs), 'like', signals);

    num_outer_iter = length(snr_dbs);
    num_inner_iter = length(fractional_orders);
    outer_bar = ProgressBar(num_outer_iter, 'Title', 'SNR');
    outer_bar.setup([], [], []);
    for j_snr = 1:num_outer_iter
        inner_bar = ProgressBar(num_inner_iter, ...
                                'IsParallel', true, ...
                                'Title', 'Order' ...
                               );
        inner_bar.setup([], [], []);

        % Calculate correlation matrices
        corr_nn = Generate_Correlation_Matrix(noises(j_snr, :, :));
        if uncorrelated
            corr_xn = zeros(size(corr_xx), 'like', corr_xx);
        else
            corr_xn = Generate_Correlation_Matrix(signals, noises(j_snr, :, :));
        end
        corr_nx = corr_xn';

        parfor i_order = 1:num_inner_iter
            [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, fractional_orders(i_order));

            % Filter
            filtered_signals = Optimal_Filter_Known_Corr(transform_mtx, ...
                                                         gfrft_mtx, igfrft_mtx, ...
                                                         corr_xx, corr_xn, corr_nx, corr_nn, ...
                                                         signals, use_gpu);

            % Save SNR
            estimation_snrs(i_order, j_snr) = Snr(signals, filtered_signals);
            updateParallel();
        end
        inner_bar.release();
        outer_bar([], [], []);
    end
    outer_bar.release();
    ProgressBar.deleteAllTimers();
end

function corr_mtx = Generate_Correlation_Matrix(first, second)
    arguments
        first (:, :) {mustBeNumeric}
        second (:, :) {mustBeNumeric, Must_Be_Equal_Size(first, second)} = first
    end

    num_samples = size(first, 2);
    corr_mtx = zeros(size(first, 1), 'like', first);
    for i = 1:num_samples
        corr_mtx = corr_mtx + first(:, i) * second(:, i)';
    end
    corr_mtx = corr_mtx / num_samples;
end

function noise = Generate_Noise(signal, snr_db)
    noise = randn(size(signal), 'like', signal);
    noise = noise .* std(signal) / db2mag(snr_db);
end
