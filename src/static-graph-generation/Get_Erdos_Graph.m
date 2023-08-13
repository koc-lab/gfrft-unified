% (c) Copyright 2023 Tuna Alikaşifoğlu

function [graph, x] = Get_Erdos_Graph(node_count, connection_probability)
    rng('default');
    connection_max_iter = 10;
    param = struct('connected', 1, ...
                   'maxit', connection_max_iter, ...
                   'verbose', 0);

    graph = gsp_erdos_renyi(node_count, connection_probability, param);
    if ~graph.connected
        error('Graph cannot be connected');
    end

    graph.coords = gsp_compute_coordinates(graph);
    gsp_plot_graph(graph);

    x = [ones(fix(node_count / 2), 1); ...
         zeros(node_count - fix(node_count / 2), 1)];
end
