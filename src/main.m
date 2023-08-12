%% Clear
clc, clear, close all;

%% Initialize paths and GSPBox
init();

%% Graph Generation
N = 4;
A = diag(ones(N-1, 1), -1);
A(1, end) = 1;
A = A / sqrt(N);

%% GFT and GFRFT
fractionalOrder = 0.5;
[gftMatrix, igftMatrix, graphFreqs] = gftmtx(A, 'ascend02pi', 'eig', 10);
[gfrftMatrix, igfrftMatrix] = gfrftmtx(gftMatrix, fractionalOrder);
