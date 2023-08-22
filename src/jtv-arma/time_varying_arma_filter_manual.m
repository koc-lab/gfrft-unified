function [Z, psi, phi] = agsp_filter_ARMA_parallel_manual(M, residues, poles, X, y0, verbose)
% INPUT ARGUMENTS
%   M:   This is the shifted Laplacian matrix M = 0.5*norm(L)I - L,
%        where L is the combinatorial/normalized Laplacian.
%        (Shifting the Laplacian helps the stability.)
%
%   residues, poles: are the manually provided residues and poles of
%                    the filter's spectral response:
%
%   X: The JTV signal to be filtered.
%
%   y0: The initial time estimate.
%
%   verbose: Set to 1 to see more information, 0 otherwize
%
% OUTPUT ARGUMENTS
%
%  Z:    The filtered signal
%
% Tuna Alikaşifoğlu
% February 2023

if ~exist('verbose', 'var'), verbose = 0; end
if ~exist('y0', 'var'), y0 = zeros(size(X, 1), 1); end
n = size(M, 1);

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
    Z(:,t+1) = sum(Y(:,:,t+1), 2);
end

Z = Z(:, 2:end);
end

