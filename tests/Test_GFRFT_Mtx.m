% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Graph Generation
len = 4;
shift_mtx = diag(ones(len - 1, 1), -1);
shift_mtx(1, end) = 1;
shift_mtx = shift_mtx / sqrt(len);

%% GFT and GFRFT
fractional_order = 0.5;
[gft_mtx, igft_mtx, graph_freqs] = GFT_Mtx(shift_mtx, 'ascend02pi', 'eig', 10);
[gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, fractional_order);

%% Display
disp('Shift Matrix');
disp(shift_mtx);
disp('GFT');
disp(gft_mtx);
disp('GFRFT');
disp(gfrft_mtx);
