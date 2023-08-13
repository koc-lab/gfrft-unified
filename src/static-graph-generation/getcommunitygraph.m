% (c) Copyright 2023 Tuna Alikaşifoğlu

function [G, x] = getcommunitygraph(N)
rng('default');
communityNumber = round(sqrt(N)/2);
param = struct('Nc', communityNumber);
G = gsp_community(N, param);

communityLimits = G.info.com_lims;
x = zeros(N, 1);
for i = 1:length(communityLimits) - 1
    x(1+communityLimits(i):communityLimits(i + 1)) = i;
end

x = normalizepm1(x);
end

function y = normalizepm1(x)
y = 2 * (x - min(x)) / (max(x) - min(x)) - 1;
end
