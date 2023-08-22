%% Clear
clc, clear, close all;

%% Load data
[G, X] = init_knn("sea-surface-temperature.mat", 10, 1, false);

%% Parameters
y0 = zeros(size(X, 1), 1);
psi = 0.5;
phi = 0.5;
c = 0;

%% Laplacian
G = gsp_create_laplacian(G, 'normalized');
G = gsp_estimate_lmax(G);
G = gsp_compute_fourier_basis(G);

l = linspace(0, G.lmax, 300);
M = sparse(0.5 * G.lmax * speye(G.N) - G.L);
mu = G.lmax / 2 - l;

%% Add Noise
SNR = 20;
X_noisy = awgn(X, SNR, 'measured');
noise_err = norm(X - X_noisy, 'fro') / norm(X, 'fro');
fprintf("Noise Error: %.2f%%\n", noise_err * 100);

%% Filter
Y = simple_tv_arma_iter(M, X, y0, psi, phi, c);

filter_err = norm(X - Y, 'fro') / norm(X, 'fro');
fprintf("Time-Varying ARMA Filtering Error: %.2f%%\n", filter_err * 100);

%% Plot
index = 20;
figure;
title("");
plot(X(index, :), 'LineWidth', 2);
hold on;
plot(X_noisy(index, :), 'LineWidth', 2);
legend("Original", "Noisy");

figure;
title("");
plot(X(index, :), 'LineWidth', 2);
hold on;
plot(Y(index, :), 'LineWidth', 2);
legend("Original", "Filtered");
