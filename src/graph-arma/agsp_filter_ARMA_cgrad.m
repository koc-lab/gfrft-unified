function [ y ] = agsp_filter_ARMA_cgrad( L, b, a, x, tol, Tmax )
%AGSP_FILTER_ARMA_CGRAD Efficient implementation of an ARMA graph filter
% 
% INPUT ARGUMENTS
%   L:   This is the Laplacian matrix.
%        
%   x:   The graph signal to be filtered.
% 
%   b,a: are the coefficient of the numerator and denominator polynomials 
%        of the filter's spectral response:
%        $$r(lambda) = \frac{ sum_{j=0}^{K-1} b(j+1) lambda^{j} }{ sum_{j=0}^{K}
%        a(j+1) lambda^{j} }$$.
%        Note that the polynomial coefficients (AR/MA) should be provided in
%        increasing power form contrary to matlab's convention. For instance, here 
%        a(0) is the coefficient of L^0. 
%  
% OPTIONAL INPUTS
% 
%   tol:  is the tolerance of the iteration
% 
%   y0:   is an initial guess for the solution
% 
%   Tmax: is the maximum number of iterations
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
%     tau = 1; Tmax = 10;
%     y = agsp_filter_ARMA_cgrad(M, [tau], [tau, 1], c);
% 
% Andreas Loukas
% 12 Nov 2016

if ~exist('tol', 'var'), tol = 1e-10; end
if ~exist('Tmax', 'var'), Tmax = size(L,1); end

if ~issparse(L), L = sparse(L); end

    % sparse polynomial multiplication 
    function y = L_mult(coef, x)
        y = coef(1) * x;
        for i = 2:size(coef),
            x = L * x;
            y = y + coef(i) * x;
        end
    end

b = L_mult(b, x);

% initialization 
y0 = b;

y = y0;
r = b - L_mult(a, y);
p = r;
rsold = r'*r;

for k = 1:Tmax,

    Ap = L_mult(a, p); 
    alpha = rsold /(p' * Ap);

    y = y + alpha * p;
    r = r - alpha * Ap;
    rsnew = r'*r;
    
    if sqrt(rsnew) <= tol, break; end
    
    p = r + (rsnew/rsold)*p;
    rsold = rsnew;
end

end

