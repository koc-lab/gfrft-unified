% (c) Copyright 2023 Tuna Alikaşifoğlu

%% Clear
clc;
clear;
% close all;

%% Import Results
results = load("results.mat");
noise_error = results.noise_error;
estimation_error = results.estimation_error;
fractional_orders = results.fractional_orders;
zero_counts = results.zero_counts;
sigmas = results.sigmas;

%% Figure
for i_sigma = 1:length(sigmas)
    figure;
    [X, Y] = meshgrid(zero_counts, fractional_orders);
    err = squeeze(estimation_error(:, i_sigma, :));
    [min_row, min_col] = Matrix_Idx(err, 'min');

    s = surf(X, Y, err);
    hold on;
    min_point = plot3(X(min_row, min_col), ...
                      Y(min_row, min_col), ...
                      err(min_row, min_col), ...
                      '.r', 'MarkerSize', 30);
    datatip(min_point, 'Location', 'southeast');

    title(sprintf("PM 2.5, Noise Error: %.2f", noise_error(i_sigma)));
    grid on;
    xlabel("Zero Count", 'Interpreter', 'latex');
    ylabel("Fractional Order $a$", 'Interpreter', 'latex');

    labels  = ["c", "\alpha", "MSE"];
    formats = ["auto", "auto", "percentage"];
    plt = {s, min_point};

    for j = 1:length(plt)
        for i = 1:length(plt{j}.DataTipTemplate.DataTipRows)
            plt{j}.DataTipTemplate.DataTipRows(i).Label  = labels(i);
            plt{j}.DataTipTemplate.DataTipRows(i).Format = formats(i);
        end
        plt{j}.DataTipTemplate.Interpreter = "tex";
    end
end
