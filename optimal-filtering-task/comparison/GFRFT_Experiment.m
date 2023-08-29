% (c) Copyright 2023 Tuna Alikaşifoğlu

function estimation_snrs = GFRFT_Experiment(gft_mtx, transform_mtx, ...
                                            signals, noisy_signals, ...
                                            fractional_orders, uncorrelated)
    arguments
        gft_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        transform_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        signals(:, :) {mustBeNumeric, Must_Be_Multiplicable(gft_mtx, signals)}
        noisy_signals(:, :) {mustBeNumeric, Must_Be_Equal_Size(signals, noisy_signals)}
        fractional_orders(:, 1) {mustBeNumeric, mustBeVector}
        uncorrelated(1, 1) logical = false
    end

    use_gpu = isgpuarray(signals);

    % Calculate correlation matrices
    noises = noisy_signals - signals;
    corr_xx = Generate_Correlation_Matrix(signals);
    corr_nn = Generate_Correlation_Matrix(noises);
    if uncorrelated
        corr_xn = zeros(size(corr_xx), 'like', corr_xx);
    else
        corr_xn = Generate_Correlation_Matrix(signals, noises);
    end
    corr_nx = corr_xn';

    estimation_snrs = zeros(length(fractional_orders), 1, 'like', signals);
    num_inner_iter = length(fractional_orders);
    inner_bar = ProgressBar(num_inner_iter, ...
                            'IsParallel', true, ...
                            'Title', 'Order');
    inner_bar.setup([], [], []);
    parfor i_order = 1:num_inner_iter
        [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, fractional_orders(i_order));
        filtered_signals = Optimal_Filter_Known_Corr(transform_mtx, ...
                                                     gfrft_mtx, igfrft_mtx, ...
                                                     corr_xx, corr_xn, corr_nx, corr_nn, ...
                                                     signals, use_gpu);
        estimation_snrs(i_order) = Snr(signals, filtered_signals);
        updateParallel();
    end
    inner_bar.release();
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
