% (c) Copyright 2023 Tuna Alikaşifoğlu

function sampling_operator = Get_Optimal_Sampling_Operator(igfrft_mtx, num_samples, bandwidth)
    arguments
        igfrft_mtx(:, :) {mustBeNumeric, Must_Be_Square_Matrix}
        num_samples(1, 1) {mustBeInteger, mustBePositive} = size(igfrft_mtx, 1)
        bandwidth(1, 1) {mustBeInteger, mustBePositive} = num_samples
    end

    N = size(igfrft_mtx, 1);
    V_K = igfrft_mtx(:, 1:bandwidth);
    sampling_indices = zeros(num_samples, 1, 'like', V_K);
    sampling_set = zeros(num_samples, bandwidth, 'like', V_K);

    for iSample = 1:num_samples
        max_smallest_sv = -Inf;
        current_set = sampling_set(1:(iSample - 1), :);
        candidate_indices = setdiff(1:N, sampling_indices(1:(iSample - 1)));

        smallest_svs = zeros(length(candidate_indices), 1);
        parfor i = 1:length(candidate_indices)
            candidate_idx = candidate_indices(i);
            smallest_svs(i) = svds([current_set; V_K(candidate_idx, :)], 1, 'smallest');
        end
        [~, idx] = max(smallest_svs);
        selected_idx = candidate_indices(idx);
        sampling_indices(iSample) = selected_idx;
        sampling_set(iSample, :) = V_K(selected_idx, :);
    end

    sampling_operator = zeros(num_samples, N);
    for i = 1:num_samples
        sampling_operator(i, sampling_indices(i)) = 1;
    end
end
