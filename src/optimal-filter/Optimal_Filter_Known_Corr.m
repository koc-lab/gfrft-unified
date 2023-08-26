% (c) Copyright 2023 Tuna Alikaşifoğlu

function filtered_signal = Optimal_Filter_Known_Corr(transform_mtx, ...
                                                     gfrft_mtx, igfrft_mtx, ...
                                                     corr_xx, corr_xn, corr_nx, corr_nn, ...
                                                     graph_signal, use_gpu)
    arguments
        transform_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        gfrft_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix, ...
                         Must_Be_Equal_Size(gfrft_mtx, transform_mtx)}
        igfrft_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix, ...
                          Must_Be_Equal_Size(igfrft_mtx, gfrft_mtx)}
        corr_xx(:, :) {mustBeNumeric, Must_Be_Equal_Size(corr_xx, gfrft_mtx)}
        corr_xn(:, :) {mustBeNumeric, Must_Be_Equal_Size(corr_xn, corr_xx)}
        corr_nx(:, :) {mustBeNumeric, Must_Be_Equal_Size(corr_nx, corr_xx)}
        corr_nn(:, :) {mustBeNumeric, Must_Be_Equal_Size(corr_nn, corr_xx)}
        graph_signal(:, :) {mustBeNumeric, Must_Be_Multiplicable(gfrft_mtx, graph_signal)}
        use_gpu(1, 1) logical {Must_Be_Logical} = false
    end

    if use_gpu
        h_opt = Get_Optimal_Filter_GPU(transform_mtx, gfrft_mtx, igfrft_mtx, ...
                                       corr_xx, corr_xn, corr_nx, corr_nn);
    else
        h_opt = Get_Optimal_Filter(transform_mtx, gfrft_mtx, igfrft_mtx, ...
                                   corr_xx, corr_xn, corr_nx, corr_nn);
    end
    h_opt = h_opt(:); % make sure column vector
    filtered_signal = igfrft_mtx * (h_opt .* (gfrft_mtx * graph_signal));
end
