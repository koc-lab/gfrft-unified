%% Clear
clc, clear, close all;

%% Load data
[G, X] = init_knn("sea-surface-temperature.mat", 10, 1, false);

%% Graph ARMA Parameters
ar_order  = 10;
ma_order  = 20;
arma_iter = 100;
radius    = 0.95;
if true
    arma_iter = max([5 * max(ar_order, ma_order) 30]);
    disp(['arma_iter not specified, using default value of ' num2str(arma_iter)]);
else
    arma_iter = 30;
end

%% Design Graph ARMA Filter
G = gsp_create_laplacian(G, 'normalized');
G = gsp_estimate_lmax(G);
G = gsp_compute_fourier_basis(G);

% Since the eigenvalues might change, sample eigenvalue domain uniformly
l = linspace(0, G.lmax, 300);

% For stability, use a shifted version of the Laplacian
M = sparse(0.5 * G.lmax * speye(G.N) - G.L);
mu = G.lmax / 2 - l;

% desired graph frequency response
% lambda_cut = 0.0;
lambda_cut = 1.5;
step       = @(x, a) double(x >= a);
response   = @(x) step(x, G.lmax / 2 - lambda_cut);
[b, a, rARMA, design_err] = agsp_design_ARMA(mu, response, ma_order, ...
                                             ar_order, radius, 1);

%% Add Noise
SNR = 15;
X_noisy = awgn(X, SNR, 'measured');
noise_err = norm(X - X_noisy, 'fro') / norm(X, 'fro');
fprintf("Noise Error: %.2f%%\n", noise_err * 100);

%% Filter
Y = naive_jtv_arma_filter(M, b, a, X_noisy, arma_iter);
filter_err = norm(X - Y, 'fro') / norm(X, 'fro');
fprintf("Naive ARMA Filtering Error: %.2f%%\n", filter_err * 100);

%% Plot
for i = [1, 50, 60]
    figure;
    plot(X(:, i), 'LineWidth', 2);
    hold on;
    plot(Y(:, i), 'LineWidth', 2);
    legend('Original', 'Filtered');
end

