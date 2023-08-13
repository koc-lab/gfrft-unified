%% Clear
clc, clear, close all;

%% Graph and Graph Signal Generation
N = 100;
[G, x] = getcommunitygraph(N);

%% Add Random Noise
noise = 0.2 * randn(size(x));
xNoisy = x + noise;

%% Plotting
plotoriginalandnoisygraphsignals(G, x, xNoisy);
