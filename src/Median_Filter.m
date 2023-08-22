% (c) Copyright 2023 Tuna Alikaşifoğlu

function filtered_jtv_signal = Median_Filter(unweighted_adj_mat, jtv_signal, order)
    arguments
        unweighted_adj_mat(:, :) {Must_Be_Logical, Must_Be_Square_Matrix}
        jtv_signal(:, :) {mustBeNumeric}
        order (1, 1) {mustBeInteger, mustBeMember(order, [1, 2])} = 1
    end

    filtered_jtv_signal = zeros(size(jtv_signal));
    for node_idx = 1:size(jtv_signal, 1)
        for time_idx = 1:size(jtv_signal, 2)
            multiset = Get_Multiset(unweighted_adj_mat, jtv_signal, node_idx, time_idx, order);
            filtered_jtv_signal(node_idx, time_idx) = median(multiset);
        end
    end
end

function joint_multiset = Get_Multiset(unweighted_adj_mat, jtv_signal, node_idx, time_idx, p)
    if ~exist('p', 'var')
        p = 1;
    end

    neighborhood_multiset = Get_Neighborhood_Multiset(unweighted_adj_mat, ...
                                                      jtv_signal(:, time_idx), node_idx);
    time_multiset = Get_Time_Multiset(jtv_signal(node_idx, :), time_idx);
    joint_multiset = [neighborhood_multiset; time_multiset];

    if p == 2
        if time_idx == 1
            prev_neighbor_multiset = [];
        else
            prev_neighbor_multiset = Get_Neighborhood_Multiset(unweighted_adj_mat, ...
                                                               jtv_signal(:, time_idx - 1), ...
                                                               node_idx);
        end

        if time_idx == size(jtv_signal, 2)
            next_neighbor_multiset = [];
        else
            next_neighbor_multiset = Get_Neighborhood_Multiset(unweighted_adj_mat, ...
                                                               jtv_signal(:, time_idx + 1), ...
                                                               node_idx);
        end

        joint_multiset = [joint_multiset; prev_neighbor_multiset; next_neighbor_multiset];
    end
end

function multiset = Get_Time_Multiset(time_signal, time_idx)
    if time_idx == 1
        multiset = time_signal(1:2);
    elseif time_idx == length(time_signal)
        multiset = time_signal(end - 1:end);
    else
        multiset = time_signal(time_idx - 1:time_idx + 1);
    end
    multiset = multiset(:);
end

function multiset = Get_Neighborhood_Multiset(unweighted_adj_mat, graph_signal, node_idx)
    logic_map = logical(unweighted_adj_mat(node_idx, :));
    multiset = graph_signal(logic_map);
    multiset = multiset(:);
end
