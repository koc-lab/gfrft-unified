% (c) Copyright 2023 Tuna Alikaşifoğlu

function [G, x] = geterdosgraph(N, p)
rng('default');
connectionMaxIter = 10;
param = struct('connected', 1, 'maxit', connectionMaxIter, 'verbose', 0);

G = gsp_erdos_renyi(N, p, param);
if ~G.connected
    error('Graph cannot be connected');
end

G.coords = gsp_compute_coordinates(G);
gsp_plot_graph(G);

x = [ones(fix(N/2), 1); zeros(N-fix(N/2), 1)];
end
