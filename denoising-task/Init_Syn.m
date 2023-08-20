% (c) Copyright 2023 Tuna Alikaşifoğlu

function [graph, jtv_signal] = Init_Syn(node_count, verbose)
    arguments
        node_count double {mustBeInteger}
        verbose logical {islogical} = false
    end

    % Load Data
    [graph, jtv_signal] = Get_Community_Graph(node_count);
    if verbose
        disp("Graph Info");
        disp("  - Number of Vertices: " + graph.N);
        disp("  - Number of Edges: " + graph.Ne);

        disp("JTV Signal Info");
        disp("  - Number of Vertices: " + size(jtv_signal, 1));
        disp("  - Number of Time Samples: " + size(jtv_signal, 2));
    end
end
