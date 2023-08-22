function [ b, a, rARMA, error ] = agsp_design_ARMA( mu, response, Kb, Ka, radius, show )
%AGSP_DESIGN_ARMA This function finds polynomial coefficients (b,a) such that 
%the ARMA model "rARMA = polyval(wrev(b),mu)./polyval(wrev(a), mu)" 
%approximates the function response() at the points mu.
% 
% REQUIRED INPUTS
% mu the points where the response function is evaluated 
% responce is the desired response function 
% Kb,Ka are the orders of the numberator and denominator, respectively 
% 
% OPTIONAL INPUTS
% radius allows one to control the tradeoff between convergence speed (small)
%       and accuracy (large). Should be below 1 if the standard iterative 
%       implementation is used. With the conj. gradient implementation any 
%       radius is allowed. 
% show set to 1 in order to display the approximation result
% 
% Note that the polynomial coefficients (b/a) are returned in
% increasing power form, contrary to matlab's convention. For instance, here 
% a(0) is the coefficient of L^0. 
% 
% Andreas Loukas
% 12 Nov 2016

if ~exist('show', 'var'),   show   = 0;    end
if ~exist('radius', 'var'), radius = 0.85; end

if size(mu,1) == 1, mu = mu'; end

% -------------------------------------------------------------------------
% Construct various utility matrices
% -------------------------------------------------------------------------

% N is the Vandermonde that will be used to evaluate the numerator.
NM = zeros(length(mu),Kb+1);
NM(:,1) = ones(length(mu),1);
for k=2:Kb+1,
    NM(:,k) = NM(:,k-1).*mu;
end

% M is the Vandermonde that will be used to evaluate the denominator.
MM = zeros(length(mu), Ka);
MM(:,1) = mu;
for k=2:Ka,
    MM(:,k) = MM(:,k-1).*mu;
end

V = zeros(numel(mu),Ka);
for k = 1:Ka,
    V(:,k) = mu.^k;
end

n = numel(mu);
C1 = zeros(n,n*Ka); 
for k = 1:Ka,
    C1( (k-1)*n+1:(k-1)*n+n , (k-1)*n+1:(k-1)*n+n ) = diag(mu.^k);
end

warning off;
cvx_begin quiet
    variable ia(Ka,1)
    variable ib(Kb+1,1)
        minimize( norm(NM*ib - diag(response(mu))*MM*ia - response(mu)) )
    subject to
        max(abs(V * ia)) <= radius;
cvx_end
warning on;
a = [1; ia];
b = ib;

% least-squares (again to find b)
B = fliplr(vander(mu)); 
b = lsqlin(B(:,1:Kb+1)./repmat(B(:,1:Ka+1)*a,1,Kb+1), response(mu));


% -------------------------------------------------------------------------
% Optimize it with newton's iteration
% -------------------------------------------------------------------------
if radius >= 1,
    [a, b] = dlsqrat(mu, response(mu), Kb, Ka, a(2:end)); a = [1; a];
end

% this is the achieved response
rARMA = polyval(wrev(b),mu)./polyval(wrev(a), mu);

% error
error = norm(rARMA - response(mu))./norm(mu);

if show,
    fprintf('ARMA Response Design Error: %.2f%%\n', error * 100);
    figure; 
    plot(mu, rARMA, 'ro--',  mu, response(mu), 'k');
end

end

