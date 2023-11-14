% (c) Copyright 2023 Tuna Alikaşifoğlu

function [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx_Eigen(gft_mtx, a)
    arguments
        gft_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        a(1, 1) {mustBeReal}
    end

    [evec_mtx, evals_vec] = eig(gft_mtx, 'vector');
    if ishermitian(gft_mtx)
        inv_evec_mtx = evec_mtx.';
    else
        inv_evec_mtx = inv(evec_mtx);
    end

    gfrft_mtx = evec_mtx * ((evals_vec.^a) .* inv_evec_mtx);
    if nargout > 1
        igfrft_mtx = evec_mtx * ((evals_vec.^(-a)) .* inv_evec_mtx);
    end
end
