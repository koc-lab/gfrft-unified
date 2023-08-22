function filtered = simple_tv_arma_iter(matrix, jtv_signal, y0, psi, phi, c)
    filtered = zeros(size(jtv_signal));
    filtered(:, 1) = psi * matrix * y0 + phi * jtv_signal(:, 1);
    for i = 2:size(jtv_signal, 2)
        filtered(:, i) = psi * matrix * filtered(:, i - 1) + phi * jtv_signal(:, i - 1);
    end
end
