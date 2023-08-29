% (c) Copyright 2023 Tuna Alikaşifoğlu

function [b, a] = Get_Arma_Coeff(graph, mu, order, lambda_cut, normalize)
    arguments
        graph (1, 1) struct
        mu (:, 1) {mustBeNumeric}
        order (1, 1) {mustBeInteger, mustBeInRange(order, 1, 3)} = 1
        lambda_cut (1, 1) {mustBeNumeric, mustBeInRange(lambda_cut, 0, 2)} = 1.50
        normalize (1, 1) logical = false
    end

    ar_order  = order;
    ma_order  = order;
    if order == 3
        ma_order = 2;
    end

    radius    = 0.99;
    step     = @(x, a) double(x >= a);
    response = @(x) step(x, graph.lmax / 2 - lambda_cut);
    [b, a, rARMA, design_err] = agsp_design_ARMA(mu, response, ma_order, ...
                                                 ar_order, radius);
    if normalize
        warning('off', 'all');
        [h, w] = freqz(b, a);
        hn = h / max(abs(h));
        [b, a] = invfreqz(hn, w, length(b), length(a));
        warning('on', 'all');
    end

    if order == 3
        b = b(:).';
        b = [b, 0];
    end
end
