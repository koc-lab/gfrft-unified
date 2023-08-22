function [Z, psi, phi] = agsp_filter_ARMA_parallel(M, b, a, X, y0, verbose)
% INPUT ARGUMENTS
%   M:   This is the shifted Laplacian matrix M = 0.5*norm(L)I - L,
%        where L is the combinatorial/normalized Laplacian. 
%        (Shifting the Laplacian helps the stability.) 
%        
%   b,a: are the coefficient of the numerator and denominator polynomials 
%        of the filter's spectral response:
%        $$r(mu) = \frac{ sum_{j=0}^{K-1} b(j+1) mu^{j} }{ sum_{j=0}^{K}
%        a(j+1) mu^{j} }$$.
%        Note that mu here should be the eigenvalues of M. This means that
%        since M = 0.5*norm(L)I - L, the polynomials should also
%        be expressed in terms of the eigenvalues mu of M.
% 
%  X:   The JTV signal to be filtered.
% 
%  T:    How many iterations should the ARMA recursions be run for?
% 
%  verbose: Set to 1 to see more information, 0 otherwize
% 
% OUTPUT ARGUMENTS
% 
%  Z:    The filtered signal
% 
%  phi,psi: The coefficients of the parallel ARMA recursions.
% 
% Tuna Alikaşifoğlu
% February 2023

if ~exist('verbose', 'var'), verbose = 0; end
if ~exist('y0', 'var'), y0 = zeros(size(X, 1), 1); end

n = size(M, 1);

% first compute the phi/psi coefficients
num = b; den = a;

% partial fraction expansion
[residues,poles,addTerm] = residue(wrev(num), wrev(den));

if isempty(addTerm), addTerm = 0; end
if addTerm ~= 0, disp('warning: addTerm non zero'); addTerm = sum(addTerm); end


% recursion coefficients (y_{t+1} = psi M y_{t} + phi x)
K = numel(poles);
psi = zeros(K,1); phi = zeros(K,1);
for k = 1:K,
    psi(k) = 1/poles(k);
    phi(k) = -residues(k) / poles(k);
end

% test for stability
if verbose,
    poles = 1./psi;
    if min(abs(poles)) > norm(full(M)),
        disp('filter is stable');
    else
        disp('warning: filter is unstable. Unexpected behavior expected!');
    end
end

% parallel ARMA recursion
T = size(X, 2);
Y = zeros(n, K, T + 1);
Z = zeros(n, T + 1);

Y(:, :, 1) = repmat(y0, 1, K);
Z(:, 1) = y0;

for t = 1:T,
    for k = 1:K,
        Y(:,k,t+1) = psi(k) * M * Y(:,k,t) + phi(k) * X(:,t);
    end
    Z(:,t+1) = sum(Y(:,:,t+1), 2) + addTerm*X(:,t);
end

Z = Z(:, 2:end);
end


