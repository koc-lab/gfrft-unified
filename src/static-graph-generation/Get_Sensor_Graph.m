% (c) Copyright 2023 Tuna Alikaşifoğlu

function [graph, x] = Get_Sensor_Graph(node_count, normalize)
    arguments
        node_count(1, 1) {mustBeInteger, mustBePositive} = 128
        normalize(1, :) char{mustBeMember(normalize, ...
                                          {'none', 'zero-mean', 'zero-one', ...
                                           'plus-minus-one'})} = 'none'
    end
    rng('default');
    graph = gsp_sensor(node_count);

    % x = hypot(graph.coords(:, 1), graph.coords(:, 2));
    one_count = floor(node_count / 2);
    x = zeros(node_count, 1);
    random_idx = randi(node_count, one_count, 1);
    x(random_idx) = 1;

    if strcmp(normalize, 'zero-mean')
        x = x - mean(x);
    elseif strcmp(normalize, 'zero-one')
        x = Normalize_Zero_One(x);
    elseif strcmp(normalize, 'plus-minus-one')
        x = Normalize_Plus_Minus_One(x);
    end
end
