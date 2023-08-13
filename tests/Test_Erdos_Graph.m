% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Graph and Graph Signal Generation
N = 100;
p = 0.1;
[G, x] = Get_Erdos_Graph(N, p);

%% Add Random Noise
noise = 0.1 * randn(size(x));
xNoisy = x + noise;

%% Plotting
Plot_Original_And_Noisy_Graph_Signals(G, x, xNoisy);
