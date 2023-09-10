% (c) Copyright 2023 Tuna Alikaşifoğlu

function [graph, x] = Get_David_Graph(node_count, normalize)
    arguments
        node_count(1, 1) {mustBeInteger}
        normalize(1, :) char{mustBeMember(normalize, ...
                                          {'none', 'zero-mean', 'zero-one', ...
                                           'plus-minus-one'})} = 'none'
    end
    graph = gsp_david_sensor_network(node_count);

    x = hypot(graph.coords(:, 1), graph.coords(:, 2));
    if strcmp(normalize, 'zero-mean')
        x = x - mean(x);
    elseif strcmp(normalize, 'zero-one')
        x = Normalize_Zero_One(x);
    elseif strcmp(normalize, 'plus-minus-one')
        x = Normalize_Plus_Minus_One(x);
    end
end
