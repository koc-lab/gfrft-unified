function Y = naive_jtv_arma_filter_parallel(M, b, a, X, T, verbose)
    if ~exist('verbose', 'var'), verbose = false; end

    Y = zeros(size(X));
    for i = 1:size(X, 2)
        y = agsp_filter_ARMA_parallel(M, b, a, X(:, i), T);
        Y(:, i) = y(:,end);
    end
end


