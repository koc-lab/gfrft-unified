% (c) Copyright 2023 Tuna Alikaşifoğlu

function [graph, jtv_signal] = Init_KNN_Real(dataset, knn_count, knn_sigma, ...
                                             max_node_count, max_time_instance, verbose)
    arguments
        dataset(1, :) char {mustBeFile}
        knn_count double {mustBeInteger} = 5
        knn_sigma double {mustBePositive} = 1
        max_node_count double {mustBeInteger} = 100
        max_time_instance double {mustBeInteger} = 100
        verbose logical {islogical} = false
    end

    % Load Data
    dataset = load(dataset, 'data', 'position');
    node_count = min(max_node_count, size(dataset.data, 1));
    time_instance_count = min(max_time_instance, size(dataset.data, 2));
    knn_count = min(knn_count, node_count);

    jtv_signal = dataset.data(1:node_count, 1:time_instance_count);
    positions  = dataset.position(1:node_count, :);
    param.k = knn_count;
    param.sigma = knn_sigma;
    graph = gsp_nn_graph(positions, param);

    if verbose
        disp("Graph Info");
        disp("  - Number of Vertices: " + graph.N);
        disp("  - Number of Edges: " + graph.Ne);

        disp("JTV Signal Info");
        disp("  - Number of Vertices: " + size(jtv_signal, 1));
        disp("  - Number of Time Samples: " + size(jtv_signal, 2));
    end
end
