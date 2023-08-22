% This script provides an example of an ARMA graph filter of the form: 
% 
%   sum_{k = 0}^{Ka} a(k) L^k y_{t-k} = sum_{k = 0}^{Kb} b(k) L^k x_{t-k}  
% 
% Above L is the normalized graph Laplacian, a and b are coefficients of 
% the autoregressive and moving average polynomials (of orders Ka and Kb 
% respectively) and x is the graph signal to be filtered.
% Note that the actual implementation used a shifted version of L (denoted
% below as M).
% 
% 
% Three graph filters are compared 
%   1. The chebychev polynomial approximation.
%   See also: D. I Shuman, P. Vandergheynst, D. Kressner, and P. Frossard, 
%       "Distributed signal processing via Chebyshev polynomial approximation."
%   and D. I Shuman, P. Vandergheynst, and P. Frossard, "Chebyshev polynomial 
%       approximation for distributed signal processing," in Proceedings of 
%       the IEEE International Conference on Distributed Computing in 
%       Sensor Systems (DCOSS), Barcelona, Spain, Jun. 2011.   
% 
%   2. ARMA: A parallel implementation   
%   See also: A. Loukas, A. Simonetto, and G. Leus, "Distributed 
%       autoregressive moving average graph filters," IEEE Signal Process. Lett., 
%       vol. 22, no. 11, pp. 1931-1935, 2015.
%   and Autoregressive Moving Average Graph Filtering
%       E Isufi, A Loukas, A Simonetto, G Leus
%       IEEE Transactions on Signal Processing 65(2), 274-288, 2017.
% 
%   3. ARMA cg: A more computationally efficient implementation based on the
%   conjugate gradient method (this is suggested for centralized
%   computations of high accuracy).
% 
% Requirements: gspbox, cvx
% Andreas Loukas
% 12 Nov 2016
% 

clc; clear; close all;
GSP_TOOLBOX_PATH = "../gspbox/";
addpath(GSP_TOOLBOX_PATH, '-frozen');
gsp_start;

n = 2000;    % number of nodes

paramgraph.distribute = 1;
G = gsp_sensor(n, paramgraph); 
G = gsp_create_laplacian(G, 'normalized');
G = gsp_estimate_lmax(G);

% compute GFT in order to measure error. For larger problems, only report timing. 
x = rand(n,1);
if n <= 2000,
    G = gsp_compute_fourier_basis(G);
    lambda = G.e;
    U = G.U;
    figure; set(gcf, 'Position', [1000 500 850 650], 'Color', [1 1 1]); 
    x = U*ones(n,1);
end

% For stability, we will work with a shifted version of the Laplacian
M = sparse(0.5*G.lmax*speye(n) - G.L);

% desired graph frequency response
lambda_cut = 0.5;
step     = @(x,a) double(x>=a);  
response = @(x) step(x, G.lmax/2 - lambda_cut); 

% Since the eigenvalues might change, sample eigenvalue domain uniformly
l = linspace(0, G.lmax, 300); mu = G.lmax/2-l; 

% ------------------------------------------------------------------------
% Run filters and compare complexity / error
% While considering the comparison results note that
%   1. the different methods pursue difference complexity / error tradeoffs
%   2. For a more fair complexity comparison, the chebychev design time should be also 
%   excluded from the timing.
% -------------------------------------------------------------------------

% ARMA parallel implementation
Ka     = 2;      % AR filter order (decrease radius for larger values)
Kb     = 18;     % MA filter order
radius = 0.95;   % for speed make small, for accuracy increase. Should be below 1 
                 % if the distributed implementation is used. With the (faster) 
                 % conj. gradient implementation, any radius is allowed. 
[b, a, rARMA] = agsp_design_ARMA(mu, response, Kb, Ka, radius);
T = max([5*max(Ka,Kb) 30]);
tic; y = agsp_filter_ARMA(M, b, a, x, T); time = toc;
error = nan;
if exist('U', 'var'),
    error = norm( (U'*y(:,end))./(U'*x) - response(G.lmax/2-lambda)) / norm(response(G.lmax/2-lambda));
end
fprintf('ARMA parallel: N = %d, time = %3.4f, error = %3.4f, K = [%d %d]\n', n, time, error, Ka, Kb); 
if exist('U', 'var'),
    subplot(3,1,1); hold on;
    set(gca, 'FontSize', 12);
    plot(lambda, (U'*y(:,end))./(U'*x), 'k-', 'DisplayName', 'ARMA PL');
    plot(lambda, response(G.lmax/2-lambda), 'k.', 'DisplayName', 'ideal');
    xlabel('\lambda'); ylabel('freq response');
    l = legend('ARMA PL');
    set(l, 'EdgeColor', [1 1 1], 'FontSize', 12);
    ylim([-0.3 1.3])
end

% ARMA conj gradient (sparse) implementation
Ka     = 2;      % AR filter order (decrease radius for larger values)
Kb     = 18;     % MA filter order
radius = 1;   % for speed make small, for accuracy increase. Should be below 1 
                 % if the distributed implementation is used. With the (faster) 
                 % conj. gradient implementation, any radius is allowed. 
[ b, a, rARMA] = agsp_design_ARMA(mu, response, Kb, Ka, radius);
tic; y = agsp_filter_ARMA_cgrad(M, b, a, x, 1e-4); time = toc;

error = nan;
if exist('U', 'var'),
    error = norm( (U'*y(:,end))./(U'*x) - response(G.lmax/2-lambda)) / norm(response(G.lmax/2-lambda));
end
fprintf('ARMA cgrad: N = %d, time = %3.4f, error = %3.4f, K = [%d %d]\n', n, time, error, Ka, Kb); 
if exist('U', 'var'),
    subplot(3,1,2); hold on;
    set(gca, 'FontSize', 12);
    plot(lambda, (U'*y(:,end))./(U'*x), 'b-', 'DisplayName', 'ARMA CG');
    plot(lambda, response(G.lmax/2-lambda), 'k.', 'DisplayName', 'ideal');
    xlabel('\lambda'); ylabel('freq response');
    l = legend('ARMA CG');
    set(l, 'EdgeColor', [1 1 1], 'FontSize', 12);
    ylim([-0.3 1.3])
end

% chebychev implementation
param.method  = 'cheby';     
param.order   = 150;
param.verbose = 0;
response = @(x) double(x<=lambda_cut);
tic; y = gsp_filter(G, response, x, param); time = toc;
error = nan;
if exist('U', 'var'),
    error = norm( (U'*y(:,end))./(U'*x) - response(lambda)) / norm(response(lambda));
end
fprintf('cheby: N = %d, time = %3.4f, error = %3.4f, K = %d\n', n, time, error, param.order); 
if exist('U', 'var'),
    subplot(3,1,3); hold on;
    set(gca, 'FontSize', 12);
    plot(lambda, (U'*y(:,end))./(U'*x), 'r-', 'DisplayName', 'Tchebychev');
    plot(lambda, response(lambda), 'k.', 'DisplayName', 'ideal')
    xlabel('\lambda'); ylabel('freq response');
    l = legend('Tchebychev');
    set(l, 'EdgeColor', [1 1 1], 'FontSize', 12);
    ylim([-0.3 1.3])
end

% export_fig('low-pass.png', '-r200');

%%
radius = 1;   
T = 3:1:40;
Ka = 1:1:3;
Kb = 1:1:24;

% ARMA conj gradient (sparse) implementation
error_ARMA = zeros(numel(Ka), numel(Kb), numel(T));
time_ARMA  = zeros(numel(Ka), numel(Kb), numel(T));
for KaIdx = 1:numel(Ka)
for KbIdx = 1:numel(Kb),    
    
    [Ka(KaIdx) Kb(KbIdx)]
    [b, a] = agsp_design_ARMA(mu, response, Kb(KbIdx), Ka(KaIdx), radius); 

    for TIdx = 1:numel(T),
       
        t = T(TIdx);
        tic; y = agsp_filter_ARMA_cgrad(M, b, a, x, 1e-30, t); 
        
        time_ARMA(KaIdx, KbIdx, TIdx) = toc;
        error_ARMA(KaIdx, KbIdx, TIdx) = norm( (U'*y(:,end))./(U'*x) - response(G.lmax/2-lambda)) / norm(response(G.lmax/2-lambda));
    end
    error_ARMA(KaIdx, KbIdx, TIdx)
end
end

%%
K = 1:250;
param.method  = 'cheby';
param.verbose = 0;
response = @(x) double(x<=lambda_cut);

% chebychev implementation
error_cheby = zeros(numel(K), 1);
time_cheby  = zeros(numel(K), 1);
for KIdx = 1:numel(K),
    
    param.order = K(KIdx);
    tic; y = gsp_filter(G, response, x, param); 
    
    time_cheby(KIdx) = toc;
    
    error_cheby(KIdx) = norm( (U'*y(:,end))./(U'*x) - response(lambda)) / norm(response(lambda));
end
    
%
figure; hold on; set(gcf, 'Position', [200 100 850 350], 'Color', [1 1 1]);

plot(vec(time_ARMA),  vec(error_ARMA), 'bo', 'MarkerFaceColor', 'b', 'LineWidth', 1, 'MarkerSize', 3);
plot(vec(time_cheby), vec(error_cheby), 'ro', 'MarkerFaceColor', 'r', 'LineWidth', 1, 'MarkerSize', 3);

set(gca, 'YScale', 'log', 'fontSize', 12);
l = legend('ARMA CG', 'Tchebychev', ...
    'Location','NorthEast'); 
set(l, 'EdgeColor', [1 1 1], 'FontSize', 12);
xlabel('computation time (sec)');
ylabel('error');

% export_fig('low-pass_paretto.png', '-r200');