% (c) Copyright 2023 Tuna Alikaşifoğlu

function [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx_Hyper(a, gft_mtx, igft_mtx, quiet)
    arguments
        a(1, 1) {mustBeReal}
        gft_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        igft_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix} = inv(gft_mtx)
        quiet(1, 1) {Must_Be_Logical} = true
    end

    if quiet
        warning('off', 'MATLAB:logm:nonPosRealEig');
    end
    mtx_size = size(gft_mtx, 1);
    half_identity = 0.5 * eye(mtx_size, 'like', gft_mtx);
    dg_square_mtx = ((1j * 2 / pi) * logm(gft_mtx) + half_identity) / (2 * pi);
    t_mtx = pi * (dg_square_mtx + gft_mtx * dg_square_mtx * igft_mtx) - half_identity;
    gfrft_mtx = expm(-(1j * a * pi / 2) * t_mtx);
    if nargout > 1
        igfrft_mtx = expm((1j * a * pi / 2) * t_mtx);
    end
end
