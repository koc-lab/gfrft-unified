% (c) Copyright 2023 Tuna Alikaşifoğlu

function [graph, x] = Get_Community_Graph(node_count, normalize)
    arguments
        node_count(1, 1) {mustBeInteger}
        normalize(1, :) char{mustBeMember(normalize, ...
                                          {'none', 'zero-mean', 'zero-one', ...
                                           'plus-minus-one'})} = 'none'
    end
    rng('default');
    community_count = round(sqrt(node_count) / 2);
    param = struct('Nc', community_count);
    graph = gsp_community(node_count, param);

    community_limits = graph.info.com_lims;
    x = zeros(node_count, 1);
    for i = 1:length(community_limits) - 1
        x(1 + community_limits(i):community_limits(i + 1)) = i;
    end

    if strcmp(normalize, 'zero-mean')
        x = x - mean(x);
    elseif strcmp(normalize, 'zero-one')
        x = Normalize_Zero_One(x);
    elseif strcmp(normalize, 'plus-minus-one')
        x = Normalize_Plus_Minus_One(x);
    end
end
