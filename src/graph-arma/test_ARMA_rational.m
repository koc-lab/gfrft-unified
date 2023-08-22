% This script provides a graph filtering example, where the filter objective takes the form: 
% 
%   g(lambda) = tau/(tau+lambda);  
% 
% Above L is the normalized graph Laplacian.
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
% Thanks to David I Shuman for providing code: this example is partly based
% on his code https://www.macalester.edu/~dshuman1/Code/Shuman_Distributed_2017_MATLAB.zip
% 
% Requirements: gspbox
% Andreas Loukas
% 01 Aug 2017

clear; close all; close all;

N = 20000;                            % number of nodes
paramgraph.distribute = 1;
G = gsp_sensor(N, paramgraph); 
G = gsp_create_laplacian(G, 'normalized');
G = gsp_estimate_lmax(G);

% desired smoothing response
tau = 0.5; g = @(x) tau./(tau+x);

% Define y by filtering by 1/g(lambda)
x = randn(N,1);
y = (1/tau)*(tau*eye(N)+G.L) * x;

% Now try different iterative methods to recover x from y and 
% L by solving system of linear equations: (tau*I+L)*x=tau*y

% The number of iterations to test
Tmax = 100;

% Chebyshev approximation
cheby_errors = zeros(1, Tmax);
cheby_time = zeros(1, Tmax);
for t = 1:Tmax
    param.method = 'cheby';
    param.order = t;
    
    tic;
    x_cheby = gsp_filter(G, g, y, param); % Perform the approximate filtering
    cheby_time(t) = toc;
    cheby_errors(t) = norm(x-x_cheby) / norm(x);
end

% ARMA parallel
% For stability, we will work with a shifted version of the Laplacian
arma_errors = zeros(Tmax, 1);
arma_time   = zeros(Tmax, 1);
M = sparse(G.lmax*speye(N)/2 - G.L);
b = tau; a = [tau+G.lmax/2, -1];
for t=1:Tmax

    tic; 
    x_arma = agsp_filter_ARMA_parallel(M, b, a, y, t);
    arma_time(t) = toc;
    
    x_arma = x_arma(:,end); arma_errors(t) = norm(x - x_arma) / norm(x);
end

% ARMA conjugate gradient implementation
b = [tau, 0]'*2; a = [tau, 1]'*2;
armacg_errors=zeros(Tmax, 1);
armacg_time=zeros(Tmax, 1);
for t=1:Tmax
    
    tic; 
    armacg_k = agsp_filter_ARMA_cgrad(G.L, b, a, y, 1e-50, t);
    armacg_time(t) = toc;
    
    armacg_errors(t) = norm(x-armacg_k) / norm(x);
end

%% Plot error curves
figure; hold on; set(gcf, 'Position', [200 100 1000 500], 'Color', [1 1 1]);
plot(1:Tmax, cheby_errors, 'r',...
    1:Tmax, arma_errors,'k--',...
    1:Tmax, armacg_errors,'b:', 'LineWidth',2);
set(gca, 'YScale', 'log', 'FontSize', 12);
l = legend('Tchebychev', 'ARMA PL', 'ARMA CG', ...
    'Location','best'); 
set(l, 'EdgeColor', [1 1 1], 'FontSize', 12);
xlabel('number of iterations / polynomial order');
ylabel('error');

%%  Plot paretto front
figure; hold on; set(gcf, 'Position', [200 100 850 350], 'Color', [1 1 1]);
plot(cheby_time, cheby_errors, 'ro', 'MarkerFaceColor', 'r', 'LineWidth', 1, 'MarkerSize', 5);
plot(arma_time, arma_errors,'ko', 'MarkerFaceColor', 'k', 'LineWidth', 1, 'MarkerSize', 5);
plot(armacg_time, armacg_errors,'bo', 'MarkerFaceColor', 'b', 'LineWidth', 1, 'MarkerSize', 5);
set(gca, 'YScale', 'log', 'fontSize', 12);
l = legend('Tchebychev', 'ARMA PL', 'ARMA CG', ...
    'Location','NorthEast'); 
set(l, 'EdgeColor', [1 1 1], 'FontSize', 12);
xlabel('computation time (sec)');
ylabel('error');
ylim([1e-16, 1]); 

% export_fig('rational.png', '-r200');