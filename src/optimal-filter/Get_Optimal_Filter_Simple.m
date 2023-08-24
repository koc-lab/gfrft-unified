% (c) Copyright 2023 Tuna Alikaşifoğlu

function h_opt = Get_Optimal_Filter_Simple(transform_mtx, gfrft_mtx, igfrft_mtx, ...
                                           corr_xx, corr_xn, corr_nx, corr_nn)
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
    end

    T = zeros(size(gfrft_mtx));
    q = zeros(size(gfrft_mtx, 1), 1);
    W = zeros([size(gfrft_mtx, 1), size(gfrft_mtx)]);

    for i = 1:size(W, 1)
        W(i, :, :) = igfrft_mtx(:, i) * gfrft_mtx(i, :);
    end

    for m = 1:size(T, 1)
        Wm = squeeze(W(m, :, :));

        q1 = trace(transform_mtx' * Wm  * corr_xx);
        q2 = trace(Wm' * corr_xn);
        q(m) = q1 + q2;

        for n = 1:size(T, 2)
            Wn = squeeze(W(n, :, :));
            Wmn = Wm' * Wn;
            T1 = trace(transform_mtx' * Wmn * transform_mtx * corr_xx);
            T2 = trace(Wmn * transform_mtx * corr_xn);
            T3 = trace(transform_mtx' * Wmn * corr_nx);
            T4 = trace(Wmn * corr_nn);
            T(m, n) = T1 + T2 + T3 + T4;
        end
    end

    h_opt = T \ q;
end
