% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Load Data
load img_final;
load lbl_final;

%
learning_rate = 0.0001;
fractional_orders = 0.9:0.1:1.1;
sample_counts = [30, 50, 70];
seeds = 1:5;

num_of_classes = 10;
k = 12;
A = Generate_Adjacency(img_final, k);
N = size(A, 1);
A = A / eigs(A, 1, 'lm');

strategy = 'adjacency';
[gft_mtx, igft_mtx, graph_freqs] = Get_GFT_With_Strategy(A, strategy);

truths_result = zeros(length(sample_counts), length(fractional_orders));
X_ground_truth = zeros(N, num_of_classes);
for i = 1:N
    X_ground_truth(i, lbl_final(i) + 1) = 1;
end

truths_result = zeros(length(sample_counts), length(fractional_orders), length(seeds));
for i_order = 1:length(fractional_orders)
    igfrft_mtx = GFRFT_Mtx(gft_mtx, -fractional_orders(i_order));
    for i_sample = 1:length(sample_counts)
        K = sample_counts(i_sample);
        M = sample_counts(i_sample);
        V_K =  igfrft_mtx(:, 1:K);

        tic;
        optimal_sampling_op = Get_Optimal_Sampling_Operator(igfrft_mtx, M, K);
        toc;
        X_Mu = optimal_sampling_op * X_ground_truth;
        A_obt = real(optimal_sampling_op * V_K);

        x_gained = zeros(K, num_of_classes, length(seeds));
        for i_seed = 1:length(seeds)
            tic;
            parfor i = 1:num_of_classes
                seed = seeds(i_seed);
                x_gained(:, i, i_seed) = Logistic_Regressor(A_obt, X_Mu(:, i), learning_rate, seed);
            end
            toc;

            x_rec = real(V_K * x_gained(:, :, i_seed));
            for i = 1:N
                [~, ids] = max(x_rec(i, :));
                x_rec(i, :) = zeros(1, num_of_classes);
                x_rec(i, ids) = 1;
            end
            truth = 0;
            for i = 1:N
                if ~any(x_rec(i, :) - X_ground_truth(i, :))
                    truth = truth + 1;
                end
            end
            truths_result(i_sample, i_order, i_seed) = truth;
        end
    end
end

save('truths_result.mat', 'truths_result');

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
