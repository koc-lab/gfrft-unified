% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Load Data
load img_final;
load lbl_final;

%
fractional_orders = 0.9:0.1:1.1;
k = 12;
A = Generate_Adjacency(img_final, k);
N = size(A, 1);
A = A / eigs(A, 1, 'lm');

strategy = 'adjacency';
[gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(A, strategy);

truths = zeros(5, length(fractional_orders));
truths_mean = zeros(5, length(fractional_orders));
X_ground_truth = zeros(N, 10);
for i = 1:N
    X_ground_truth(i, lbl_final(i) + 1) = 1;
end

rng(2);
iter = 2;
for for_loop_var = 1:iter
    truths = zeros(5, length(fractional_orders));
    for t = 1:length(fractional_orders)
        igfrft_mtx = GFRFT_Mtx(gft_mtx, -fractional_orders(t));
        Vi = igfrft_mtx;
        for z = 1:5
            % Optimal sampling operator taken from Chen 2015 Sampling paper. Modified
            % for this paper for the fractional JFTs.
            K = 10 * (z + 2);
            M = 10 * (z + 2);
            V_K =  Vi(:, 1:K);

            tic;
            optimal_sampling_op = Get_Optimal_Sampling_Operator(igfrft_mtx, M, K);
            toc;
            X_Mu = optimal_sampling_op * X_ground_truth;
            A_obt = real(optimal_sampling_op * V_K);
            x_gained = zeros(K, 10);

            for i = 1:10
                x_gained(:, i) = Logistic_Regressor(A_obt, X_Mu(:, i), 0.0001);
            end

            x_rec = real(V_K * x_gained);
            for i = 1:N
                [~, ids] = max(x_rec(i, :));
                x_rec(i, :) = zeros(1, 10);
                x_rec(i, ids) = 1;
            end
            truth = 0;
            for i = 1:N
                if ~any(x_rec(i, :) - X_ground_truth(i, :))
                    truth = truth + 1;
                end
            end
            truths(z, t) = truth;
            disp(z);
            disp(t);
            disp(for_loop_var);
            disp('sampling,order,iter');
        end
    end
    truths_mean = truths_mean + truths / iter;
end

% save('truths_mean.mat','truths_mean')
%

%% Helper Functions
function adjacency = Generate_Adjacency(img_final, k)
    arguments
        img_final(:, :) {mustBeNumeric}
        k(1, 1) {mustBeInteger} = 12
    end
    N = size(img_final, 2);

    dist = zeros(N);
    for i = 1:N
        for j = 1:N
            difference = img_final(:, i) - img_final(:, j);
            dist(i, j) = norm(difference);
        end
    end

    near_k = zeros(k, N);
    dist_k = zeros(k, N);
    for i = 1:N
        [dist_tw, idx] = sort(dist(i, :));
        near_k(:, i) = idx(2:(k + 1));
        dist_k(:, i) = dist_tw(2:(k + 1));
    end

    P = exp(-(N * N) * dist / sum(dist(:)));
    adjacency = zeros(N);
    for i = 1:N
        for j = 1:N
            if ismember(j, near_k(:, i))
                adjacency(i, j) = P(i, j) / sum(P(:, j));
            end
        end
    end
end

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
        for i = 1:N
            if ~ismember(i, sampling_indices)
                smallest_sv = svds([current_set; V_K(i, :)], 1, 'smallest');
                if max_smallest_sv < smallest_sv
                    max_smallest_sv = smallest_sv;
                    idx = i;
                end
            end
        end
        sampling_indices(iSample) = idx;
        sampling_set(iSample, :) = V_K(idx, :);
    end

    sampling_operator = zeros(num_samples, N);
    for i = 1:num_samples
        sampling_operator(i, sampling_indices(i)) = 1;
    end
end
