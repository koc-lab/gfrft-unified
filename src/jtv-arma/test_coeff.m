%% Clear
clc, clear, close all;

%% Load data
[G, X] = init_knn("sea-surface-temperature.mat", 10, 1, false);

%% Parameters
residues = [10.954, 1.275 + 1j * 1.005, 1.275 - 1j * 1.005];
poles    = [-6.666, 0.202 + 1j * 1.398, 0.202 - 1j * 1.398];
% residues = [-7.025, -1.884 -1j * 1.298, -1.884 + 1j * 1.298, 1.433 - 1j * 1.568, 1.433 + 1j * 1.568];
% poles    = [-3.674, -0.420 +1j * 1.269, -0.420 - 1j * 1.269, 0.703 + 1j * 1.129, 0.703 + 1j * 1.568];

%% Laplacian
G = gsp_create_laplacian(G, 'normalized');
G = gsp_estimate_lmax(G);
G = gsp_compute_fourier_basis(G);

l = linspace(0, G.lmax, 300);
M = sparse(0.5 * G.lmax * speye(G.N) - G.L);
mu = G.lmax / 2 - l;

%% Add Noise
SNR = 15;
X_noisy = awgn(X, SNR, 'measured');
noise_err = norm(X - X_noisy, 'fro') / norm(X, 'fro');
fprintf("Noise Error: %.2f%%\n", noise_err * 100);

%% Filter
[Y, psi, phi] = time_varying_arma_filter_manual(M, residues, poles, X_noisy, zeros(G.N, 1), 1);
filter_err = norm(X - Y, 'fro') / norm(X, 'fro');
fprintf("Time-Varying ARMA Filtering Error: %.2f%%\n", filter_err * 100);

%%
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

