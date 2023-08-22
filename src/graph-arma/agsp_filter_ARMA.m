function [ y ] = agsp_filter_ARMA( M, b, a, x, T, tol)
%FILTER_ARMA Simulates a direct ARMA graph filter under a static signal and graph. 
% 
% INPUT ARGUMENTS
%   M:   This is the shifted Laplacian matrix M = 0.5*norm(L)I - L,
%        where L is the combinatorial/normalized Laplacian. 
%        (Shifting the Laplacian helps the stability.) 
%        
%   x:   The graph signal to be filtered.
% 
%   b,a: are the coefficient of the numerator and denominator polynomials 
%        of the filter's spectral response:
%        $$r(mu) = \frac{ sum_{j=0}^{K-1} b(j+1) mu^{j} }{ sum_{j=0}^{K}
%        a(j+1) mu^{j} }$$.
%        Note that mu here should be the eigenvalues of M. This means that
%        since M = 0.5*norm(L)I - L, the polynomials should also
%        be expressed in terms of the eigenvalues mu of M.
% 
%  T:    How many iterations should the ARMA recursions be run for?
% 
%  verbose: Set to 1 to see more information, 0 otherwize
% 
% OUTPUT ARGUMENTS
% 
%  y:    The filtered signal for all iterations
% 
% EXAMPLE USAGE
% 
% Suppose we want to filter a signal x on a path graph G
%     G = gsp_path(100);
%     G = gsp_create_laplacian(G, 'normalized');
%     x = rand(G.N,1);
% 
% To approximate r(lambda) = tau / (tau + lambda), where lambda is an 
% eigenvalue of the normalized Laplacian L: 
%     M = eye(G.N) - G.L;
%     tau = 1; T = 10;
%     y = agsp_filter_ARMA(M, x, [tau], [tau+1, -1], T, 1);
% 
% We can vizualize the filtering output for each iterations as follows: 
%     figure; plot(y')
% 
% Andreas Loukas
% 12 Nov 2016

if ~exist('tol', 'var'), tol = 1e-4; end

% normalize such that a(1) = 1
a = a / a(1);
b = b / a(1);

n = size(M,1); Ka = numel(a)-1; Kb = numel(b)-1;

y = zeros(n,T);
for t = 1:T,
    
    y(:,t) = 0;
            
    % AR terms
    for k = 1:Ka
        if t - 1 > 0,
            if k == 1, 
                z = y(:,t-1); 
            end
            z = M * z;
            y(:,t) = y(:,t) - a(k+1)*z;
        end
    end

    % MA terms
    z = x;
    for k = 0:Kb
         y(:,t) = y(:,t) + b(k+1)*z;
         z = M*z;
    end
    
    if t > 1 && norm(y(:,t) - y(:,t-1))/norm(y(:,t-1)) < tol, break; end
end
y = y(:,1:t);

end

