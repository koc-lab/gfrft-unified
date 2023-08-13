% (c) Copyright 2023 Tuna Alikaşifoğlu

function [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, a)
    arguments
        gft_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        a(1, 1) double{mustBeReal}
    end

    gfrft_mtx = mpower(gft_mtx, a);
    if nargout > 1
        igfrft_mtx = mpower(gft_mtx, -a);
    end
end
