% (c) Copyright 2023 Tuna Alikaşifoğlu

function h_opt = Get_Optimal_Filter_Alt(transform_mtx, gfrft_mtx, igfrft_mtx, ...
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

    for m = 1:size(gfrft_mtx, 1)
        wm            = igfrft_mtx(:, m);
        wm_tilde_T    = gfrft_mtx(m, :);
        wm_tilde_conj = gfrft_mtx(m, :)';

        q(m) = trace((transform_mtx' * wm) * (wm_tilde_T * corr_xx) + ...
                     (wm_tilde_conj * (wm' * corr_xn)));

        for n = 1:size(gfrft_mtx, 2)
            wn          = igfrft_mtx(:, n);
            wn_tilde_T  = gfrft_mtx(n, :);

            term1 = (transform_mtx' * wm_tilde_conj) * ...
              ((wn_tilde_T * transform_mtx) * (corr_xx + corr_nx));
            term2 = wm_tilde_conj * (((wn_tilde_T * transform_mtx) * corr_xn) + ...
                                     (wn_tilde_T * corr_nn));
            T(m, n) = (wm' * wn) * trace(term1 + term2);
        end
    end

    h_opt = T \ q;
end
