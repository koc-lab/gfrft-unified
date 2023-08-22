% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
% clc;
clear;
close all;

%%
rng(0);
len = 5;
A = randn(len, len);
A = A + A';
A = A > 0.8;
A = A - diag(diag(A));
A = logical(A);

%% JTV Signal
X = [11 12 13 14 15
     21 22 23 24 25
     31 32 33 34 35
     41 42 43 44 45
     51 52 53 54 55];

%% Median Filtering
tic;
Y1 = Median_Filter(A, X, 1);
toc;

tic;
Y2 = Median_Filter(A, X, 2);
toc;

%% Error
m1_err = norm(X - Y1, 'fro') / norm(X, 'fro');
m2_err = norm(X - Y2, 'fro') / norm(X, 'fro');
fprintf("M1 Error: %g\n", m1_err);
fprintf("M2 Error: %g\n", m2_err);
