% (c) Copyright 2023 Tuna Alikaşifoğlu

function [gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(weighted_adj_mtx, ...
                                                                  strategy)
    arguments
        weighted_adj_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        strategy(1, :) char{mustBeMember(strategy, ...
                                         {'adjacency', 'laplacian', ...
                                          'row normalized adjacency', ...
                                          'symmetric normalized adjacency', ...
                                          'normalized laplacian'})} = 'adjacency'
    end

    % Generate shift matrix
    if strcmp(strategy, 'adjacency')
        shift_mtx = weighted_adj_mtx;
    elseif strcmp(strategy, 'laplacian')
        shift_mtx = Get_Laplacian(weighted_adj_mtx);
    elseif strcmp(strategy, 'row normalized adjacency')
        shift_mtx = Get_Row_Normalized_Adjacency(weighted_adj_mtx);
    elseif strcmp(strategy, 'symmetric normalized adjacency')
        shift_mtx = Get_Sym_Normalized_Adjacency(weighted_adj_mtx);
    elseif strcmp(strategy, 'normalized laplacian')
        normalized_adj = Get_Sym_Normalized_Adjacency(weighted_adj_mtx);
        identity = eye(size(normalized_adj, 1), 'like', normalized_adj);
        shift_mtx = identity - normalized_adj;
    end

    % Generate GFT with given startegy
    if isempty(strfind(strategy, 'laplacian'))
        [gft_mtx, igft_mtx, graph_freqs] = GFT_Mtx(shift_mtx, 'tv');
    else
        [gft_mtx, igft_mtx, graph_freqs] = GFT_Mtx(shift_mtx, 'ascend');
    end
end

function degrees = Get_Degrees(weighted_adj_mtx, dim)
    arguments
        weighted_adj_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        dim(1, 1) {mustBeInteger} = 2
    end
    degrees = sum(weighted_adj_mtx, dim);
end

function laplacian = Get_Laplacian(weighted_adj_mtx)
    degree_mtx = diag(Get_Degrees(weighted_adj_mtx));
    laplacian = degree_mtx - weighted_adj_mtx;
end

function normalized_adj = Get_Row_Normalized_Adjacency(weighted_adj_mtx)
    degrees = sum(weighted_adj_mtx, 2);
    inverse_degrees = Inverse_Degrees(degrees);
    normalized_adj = inverse_degrees .* weighted_adj_mtx;
end

function normalized_adj = Get_Sym_Normalized_Adjacency(weighted_adj_mtx)
    degrees = sum(weighted_adj_mtx, 2);
    inverse_degrees = Inverse_Degrees(degrees);
    inverse_sqrt_degrees = sqrt(inverse_degrees);
    normalized_adj = (inverse_sqrt_degrees .* weighted_adj_mtx) .* inverse_sqrt_degrees.';
end

function reciprocal_values = Inverse_Degrees(degree_vector)
    non_zero_indices = degree_vector ~= 0;
    reciprocal_values = zeros(size(degree_vector), 'like', degree_vector);
    reciprocal_values(non_zero_indices) = 1 ./ degree_vector(non_zero_indices);
end
