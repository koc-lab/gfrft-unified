% (c) Copyright 2023 Tuna Alikaşifoğlu

function x_optimal = Logistic_Regressor(mtx, y, lrate)
    n = length(y);
    x_optimal = normrnd(0, 0.1, [n, 1]);

    loss_funct_new = -1 * sum(y .* log(Sigmoid(mtx, x_optimal)) + ...
                              (1 - y) .* log(1 - Sigmoid(mtx, x_optimal)));
    dist = loss_funct_new;
    while dist > 10^-5
        x_optimal = x_optimal - lrate * (mtx' * (Sigmoid(mtx, x_optimal) - y));
        loss_function_old = loss_funct_new;
        loss_funct_new = -1 * sum(y .* log(Sigmoid(mtx, x_optimal)) + ...
                                  (1 - y) .* log(1 - Sigmoid(mtx, x_optimal)));
        dist = abs(loss_funct_new - loss_function_old);
    end

end
