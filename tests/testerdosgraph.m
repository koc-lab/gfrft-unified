%% Clear
clc, clear, close all;

%% Graph and Graph Signal Generation
N = 100;
p = 0.1;
[G, x] = geterdosgraph(N, p);

%% Add Random Noise
noise = 0.1 * randn(size(x));
xNoisy = x + noise;

%% Plotting
plotoriginalandnoisygraphsignals(G, x, xNoisy);
