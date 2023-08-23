% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
close all;

%% Parameters
use_gpu = true;
rng(0);
len = 100;
noise_sigma = 0.5;
threshold = 0.8;
fractional_orders = 0:0.1:2;
shift_mtx_strategy = 'adjacency';

% Graph Generation
A = randn(len, len);
A = A + A';
A = A > threshold;
A = A - diag(diag(A));

%% Graph Signal
G = eye(len);
x = ones(len, 1);
n = noise_sigma * randn(size(x));
y = G * x + n;
noisy_snr = Snr(x, y);

Cxx = x * x';
Cxn = zeros(size(Cxx));
Cnx = Cxn';
Cnn = noise_sigma^2 * eye(size(Cxx, 1));

if false
    G = gpuArray(G);
    A = gpuArray(A);
    x = gpuArray(x);
    n = gpuArray(n);
    y = gpuArray(y);

    Cxx = gpuArray(Cxx);
    Cxn = gpuArray(Cxn);
    Cnx = gpuArray(Cnx);
    Cnn = gpuArray(Cnn);
end

%% Experiment
if strcmp(shift_mtx_strategy, 'adjacency')
    shift_mtx = A;
    gft_mtx = GFT_Mtx(shift_mtx, 'tv');
elseif strcmp(shift_mtx_strategy, 'laplacian')
    shift_mtx = diag(sum(A, 2)) - A;
    gft_mtx = GFT_Mtx(shift_mtx, 'ascend');
end

num_iterations = length(fractional_orders);
snrs = zeros(num_iterations, 1);
b = ProgressBar(num_iterations, ...
                'IsParallel', true, ...
                'WorkerDirectory', pwd(), ...
                'Title', 'Optimal Filtering' ...
               );
b.setup([], [], []);
parfor i = 1:num_iterations
    [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, fractional_orders(i));
    x_filtered = Optimal_Filter_Known_Corr(G, gfrft_mtx, igfrft_mtx, ...
                                           Cxx, Cxn, Cnx, Cnn, y);
    snrs(i) = Snr(x, x_filtered);
    updateParallel([], pwd);
end
b.release();
ProgressBar.deleteAllTimers();

%% Plot
max_idx = Matrix_Idx(snrs, 'max');

figure;
legends = ['Filtered SNR', sprintf("Noisy SNR: %.2f", noisy_snr)];
plot(fractional_orders, snrs, 'LineWidth', 2);
hold on;
yline(noisy_snr, '--', 'LineWidth', 2);

max_point = plot(fractional_orders(max_idx), snrs(max_idx), '.');
datatip(max_point);
labels  = ["$a$", "SNR"];
formats = ["%.2f", "%.2f"];
for i = 1:length(max_point.DataTipTemplate.DataTipRows)
    max_point.DataTipTemplate.DataTipRows(i).Label  = labels(i);
    max_point.DataTipTemplate.DataTipRows(i).Format = formats(i);
end
max_point.DataTipTemplate.Interpreter = "latex";

gft_idx = (fractional_orders == 1);
if any(gft_idx) && (fractional_orders(max_idx) ~= 1)
    gft_point = plot(fractional_orders(gft_idx), snrs(gft_idx), '.');
    datatip(gft_point);
    for i = 1:length(gft_point.DataTipTemplate.DataTipRows)
        gft_point.DataTipTemplate.DataTipRows(i).Label  = labels(i);
        gft_point.DataTipTemplate.DataTipRows(i).Format = formats(i);
    end
    gft_point.DataTipTemplate.Interpreter = "latex";
end

title('Fractional Order vs. SNRs');
legend(legends);
grid on;
