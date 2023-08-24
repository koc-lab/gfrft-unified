% (c) Copyright 2023 Tuna Alikaşifoğlu

function filtered_signal = Optimal_Filter_Empirical(transform_mtx, gfrft_mtx, igfrft_mtx, ...
                                                    graph_signal, noise, uncorrelated, use_gpu)
    arguments
        transform_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        gfrft_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix, ...
                         Must_Be_Equal_Size(gfrft_mtx, transform_mtx)}
        igfrft_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix, ...
                          Must_Be_Equal_Size(igfrft_mtx, gfrft_mtx)}
        graph_signal(:, 1) {mustBeNumeric, mustBeVector, ...
                            Must_Be_Multiplicable(gfrft_mtx, graph_signal)}
        noise(:, 1) {mustBeNumeric, mustBeVector, Must_Be_Equal_Size(noise, graph_signal)}
        uncorrelated(1, 1) logical {Must_Be_Logical} = false
        use_gpu(1, 1) logical {Must_Be_Logical} = false
    end

    % Generating empirical auto- and cross-correlations
    corr_xx = graph_signal * graph_signal';
    corr_nn = noise * noise';
    if uncorrelated
        corr_xn = zeros(length(graph_signal), length(noise));
    else
        corr_xn = graph_signal * noise';
    end
    corr_nx = corr_xn';

    % Filtering
    filtered_signal = Optimal_Filter_Known_Correlation(transform_mtx, gfrft_mtx, igfrft_mtx, ...
                                                       corr_xx, corr_xn, corr_nx, corr_nn, ...
                                                       graph_signal, use_gpu);
end
