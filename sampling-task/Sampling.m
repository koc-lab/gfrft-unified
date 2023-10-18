% (c) Copyright 2023 Tuna Alikaşifoğlu

clear all;
close all;
clc;
%%% The below commented code were some preprocessing and labelling of the
%%% codes. Extracted data can be found in img_final.mat and lbl_final.mat
%%% files. The code was run on te servers, it might take a long time to
%%% finish (3-5 days).

% addpath("gsp_toolbox/gspbox-0.7.5/gspbox")
% addpath("mnist_exp/")
% imgvec = loadMNISTImages("D:\research\gsp\code_and_data\MNIST\t10k-images.idx3-ubyte");
% trainimgvec = loadMNISTImages("D:\research\gsp\code_and_data\MNIST\train-images.idx3-ubyte");
% labelvec = loadMNISTLabels("D:\research\gsp\code_and_data\MNIST\t10k-labels.idx1-ubyte");
% trainlabelvec = loadMNISTLabels("D:\research\gsp\code_and_data\MNIST\train-labels.idx1-ubyte");
%
% loc0 = zeros(60000,1) == trainlabelvec;
% loc1 = ones(60000,1) == trainlabelvec;
% loc2 = (2*ones(60000,1)) == trainlabelvec;
% loc3 = (3*ones(60000,1)) == trainlabelvec;
% loc4 = (4*ones(60000,1)) == trainlabelvec;
% loc5 = (5*ones(60000,1)) == trainlabelvec;
% loc6 = (6*ones(60000,1)) == trainlabelvec;
% loc7 = (7*ones(60000,1)) == trainlabelvec;
% loc8 = (8*ones(60000,1)) == trainlabelvec;
% loc9 = (9*ones(60000,1)) == trainlabelvec;
%
% img0 = trainimgvec(:,loc0);
% img1 = trainimgvec(:,loc1);
% img2 = trainimgvec(:,loc2);
% img3 = trainimgvec(:,loc3);
% img4 = trainimgvec(:,loc4);
% img5 = trainimgvec(:,loc5);
% img6 = trainimgvec(:,loc6);
% img7 = trainimgvec(:,loc7);
% img8 = trainimgvec(:,loc8);
% img9 = trainimgvec(:,loc9);
% N = 100;
% m = size(img0);
% seq = randperm(m(2),N);
% img0 = img0(:,seq);
% m = size(img1);
% seq = randperm(m(2),N);
% img1 = img1(:,seq);
% m = size(img2);
% seq = randperm(m(2),N);
% img2 = img2(:,seq);
% m = size(img3);
% seq = randperm(m(2),N);
% img3 = img3(:,seq);
% m = size(img4);
% seq = randperm(m(2),N);
% img4 = img4(:,seq);
% m = size(img5);
% seq = randperm(m(2),N);
% img5 = img5(:,seq);
% m = size(img6);
% seq = randperm(m(2),N);
% img6 = img6(:,seq);
% m = size(img7);
% seq = randperm(m(2),N);
% img7 = img7(:,seq);
% m = size(img8);
% seq = randperm(m(2),N);
% img8 = img8(:,seq);
% m = size(img9);
% seq = randperm(m(2),N);
% img9 = img9(:,seq);
%
% img_total = [img0, img1, img2, img3, img4, img5, img6, img7, img8 ,img9];
% % img1 = img1(:,[1:1000]);
% % img2 = img2(:,[1:1000]);
% % img3 = img3(:,[1:1000]);
% % img4 = img4(:,[1:1000]);
% % img5 = img5(:,[1:1000]);
% % img6 = img6(:,[1:1000]);
% % img7 = img7(:,[1:1000]);
% % img8 = img8(:,[1:1000]);
% % img9 = img9(:,[1:1000]);
% %
% %
% % img_pre = [img0 img1 img2 img3 img4 img5 img6 img7 img8 img9];
% lbl_pre = [0 * ones(N, 1); ones(N, 1); 2 * ones(N, 1); 3 * ones(N, 1); 4 * ones(N, 1); ...
%            5 * ones(N, 1); 6 * ones(N, 1); 7 * ones(N, 1); 8 * ones(N, 1); 9 * ones(N, 1)];
% % p = randperm(10000);
% %
% % img = img_pre(:,p);
% % lbl = lbl_pre(p);
% %
%
% l = randperm(10*N);
% img_final = img_total(:,l);
% lbl_final = lbl_pre(l);

%
load img_final;
load lbl_final;
% load dist
% load A
%% & Below code extracts the adjacency matrix
N = 1000;
dist = zeros(N);

for i = 1:N
    for j = 1:N
        dist(i, j) = sqrt((img_final(:, i) - img_final(:, j))' * ...
                          (img_final(:, i) - img_final(:, j)));
    end
end

near12 = zeros(12, N);
dist12 = zeros(12, N);
for i = 1:N
    [dist_tw, idx] = sort(dist(i, :));
    near12(:, i) = idx(2:13);
    dist12(:, i) = dist_tw(2:13);
end
m = sum(sum(dist));
P = zeros(N);
for i = 1:N
    for j = 1:N
        P(i, j) = exp(-(10^5) * dist(i, j) / m);
    end
end

A = zeros(N);
for i = 1:N
    for j = 1:N
        if ismember(j, near12(:, i))
            A(i, j) = P(i, j) / sum(P(:, j));
        end
    end
end
%
ls = max(abs(eig(A)));
A = (1 / ls) * A;
[V, D] = eig(A);

% d = diag(D);
% [~, indx] = sort(real(d),'descend');
% V = V(:,indx);
%%% GFRT is constructed below.
invV = inv(V);
c = -1j * (pi / 2);
C = V * (logm(invV) / (pi * c) + (1 / (2 * pi)) * eye(N));
D_2 = lyap(V, V, -C);
truths = zeros(5, 41);
truths_mean = zeros(5, 41);

X_ground_truth = zeros(N, 10);
for i = 1:N
    X_ground_truth(i, lbl_final(i) + 1) = 1;
end
rng(2);
iter = 10;
for for_loop_var = 1:iter
    truths = zeros(5, 41);
    for t = 1:41
        Vi = expm(-c * (0.895 + 0.005 * t) * (pi * (D_2 + (V \ D_2 * V)) - 0.5 * eye(N)));
        for z = 1:5

            % Optimal sampling operator taken from Chen 2015 Sampling paper. Modified
            % for this paper for the fractional JFTs.
            K = 10 * (z + 2);
            M = 10 * (z + 2);
            V_K =  Vi(:, 1:K);
            [~, max_least_sig, ~] = svd(V_K(1, :), 'econ');
            max_least_sig = diag(max_least_sig);
            max_idx = max_least_sig == zeros(size(max_least_sig));
            max_least_sig(max_idx) = 10000;
            max_least_sig = min(max_least_sig);
            idx = 1;
            for i = 2:N
                [~, lm, ~] = svd(V_K(i, :), 'econ');
                lm = diag(lm);
                lm_idx = lm == zeros(size(lm));
                lm(lm_idx) = 10000;
                lm = min(lm);
                if lm > max_least_sig
                    max_least_sig = lm;
                    idx = i;
                end
            end
            sampled_indx_set = [idx];
            sampled_set = V_K(idx, :);

            while length(sampled_indx_set) < M
                max_least_sig = 0;
                idx = 0;
                for i = 1:N
                    if ~ismember(i, sampled_indx_set)
                        [~, lm, ~] = svd([sampled_set; V_K(i, :)], 'econ');
                        lm = diag(lm);
                        lm_idx = lm == zeros(size(lm));
                        lm(lm_idx) = 10000;
                        lm = min(lm);
                        if lm > max_least_sig
                            max_least_sig = lm;
                            idx = i;
                        end
                    end
                end
                sampled_indx_set = [sampled_indx_set; idx];
                sampled_set = [sampled_set; V_K(idx, :)];
            end

            optimal_sampling_op = zeros(K, N);
            for i = 1:K
                optimal_sampling_op(i, sampled_indx_set(i)) = 1;
            end

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
