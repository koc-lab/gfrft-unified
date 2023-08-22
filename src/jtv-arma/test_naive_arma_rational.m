%% Clear
clc, clear, close all;

%% Load data
[G, X] = init_knn("sea-surface-temperature.mat", 10, 1, false);

%% ARMA Filter Design
G = gsp_create_laplacian(G, 'normalized');
G = gsp_estimate_lmax(G);

% desired smoothing response
tau = 0.5; g = @(x) tau./(tau+x);

% Define y by filtering by 1/g(lambda)
X_noisy = (1/tau)*(tau*eye(G.N)+G.L) * X;

% Now try different iterative methods to recover x from y and 
% L by solving system of linear equations: (tau*I+L)*x=tau*y

% The number of iterations to test
Tmax = 100;

% ARMA parallel
% For stability, we will work with a shifted version of the Laplacian
arma_errors = zeros(Tmax, 1);
arma_time   = zeros(Tmax, 1);
M = sparse(G.lmax*speye(G.N)/2 - G.L);
b = tau; a = [tau+G.lmax/2, -1];

%% Filter
Y = naive_jtv_arma_filter_parallel(M, b, a, X_noisy, Tmax);
filter_err = norm(X - Y, 'fro') / norm(X, 'fro');
fprintf("Naive ARMA Filtering Error: %.2f%%\n", filter_err * 100);


%% Plot
figure;
plot(X(:, 1), 'LineWidth', 2);
hold on;
plot(Y(:, 1), 'LineWidth', 2);
legend('Original', 'Filtered');
