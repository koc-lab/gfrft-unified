%% Clear
clc, clear, close all;

%% Initialize paths and GSPBox
init("../");

%% Graph and Graph Signal Generation
N = 100;
p = 0.1;
[G, x] = geterdosgraph(N, p);

%% Add Random Noise
noise = 0.1 * randn(size(x));
xNoisy = x + noise;

%% Plotting
plotoriginalandnoisygraphsignals(G, x, xNoisy);
