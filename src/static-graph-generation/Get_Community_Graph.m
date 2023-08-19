% (c) Copyright 2023 Tuna Alikaşifoğlu

function [graph, x] = Get_Community_Graph(node_count)
    rng('default');
    community_count = round(sqrt(node_count) / 2);
    param = struct('Nc', community_count);
    graph = gsp_community(node_count, param);

    community_limits = graph.info.com_lims;
    x = zeros(node_count, 1);
    for i = 1:length(community_limits) - 1
        x(1 + community_limits(i):community_limits(i + 1)) = i;
    end

    x = Normalize_Plus_Minus_One(x);
end
