% (c) Copyright 2023 Tuna Alikaşifoğlu

function value = Sigmoid(mtx, vector)
    value = 1 ./ (1 + exp(-1 * mtx * vector));
end
