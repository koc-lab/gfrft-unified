% (c) Copyright 2023 Tuna Alikaşifoğlu

function [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx_Explog(gft_mtx, a)
    arguments
        gft_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        a(1, 1) {mustBeReal}
    end

    gfrft_mtx = expm(a * logm(gft_mtx));
    if nargout > 1
        igfrft_mtx = expm(-a * logm(gft_mtx));
    end
end
