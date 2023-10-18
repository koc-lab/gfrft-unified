% (c) Copyright 2023 Tuna Alikaşifoğlu

function x_optimal = Logistic_Regressor(mtx, y, lrate, seed)
    arguments
        mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        y(:, 1) {mustBeNumeric}
        lrate(1, 1) {mustBeNumeric, mustBePositive} = 0.0001
        seed(1, 1) {mustBeInteger, mustBePositive} = 0
    end
    n = length(y);
    rng(seed);
    x_optimal = normrnd(0, 0.1, [n, 1]);

    loss_funct_new = Sigmoid_Logistic(mtx, x_optimal, y);
    dist = loss_funct_new;
    while dist > 1e-5
        x_optimal = x_optimal - lrate * (mtx' * (Sigmoid(mtx, x_optimal) - y));
        loss_function_old = loss_funct_new;
        loss_funct_new = Sigmoid_Logistic(mtx, x_optimal, y);
        dist = abs(loss_funct_new - loss_function_old);
    end
end

function logistic = Sigmoid_Logistic(mtx, x_optimal, y)
    sigm = Sigmoid(mtx, x_optimal);
    logistic = -sum(y .* log(sigm) + (1 - y) .* log(1 - sigm));
end
