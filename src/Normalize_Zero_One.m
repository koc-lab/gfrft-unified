% (c) Copyright 2023 Tuna Alikaşifoğlu

function y = Normalize_Zero_One(x)
    min_value = min(x(:));
    max_value = max(x(:));
    y = (x - min_value) / (max_value - min_value);
end
