function Y = naive_jtv_arma_filter(M, b, a, X, T, tol)
    if ~exist('tol', 'var'), tol = 1e-4; end

    Y = zeros(size(X));
    for i = 1:size(X, 2)
        y_all_iterations = agsp_filter_ARMA(M, b, a, X(:, i), T, tol);
        Y(:, i) = y_all_iterations(:, end);
    end
end

