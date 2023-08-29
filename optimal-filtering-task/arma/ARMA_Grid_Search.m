% (c) Copyright 2023 Tuna Alikaşifoğlu

function [best_snr, best_lambda_cut] = ARMA_Grid_Search(graph, signals, noisy_signals, ...
                                                        order, normalize)
    arguments
        graph (1, 1) struct
        signals(:, :) {mustBeNumeric}
        noisy_signals(:, :) {mustBeNumeric, Must_Be_Equal_Size(signals, noisy_signals)}
        order (1, 1) {mustBeInteger, mustBeInRange(order, 1, 3)} = 1
        normalize (1, 1) logical = false
    end

    %% Graph ARMA Laplacian
    graph = gsp_create_laplacian(graph, 'normalized');
    graph = gsp_estimate_lmax(graph);
    graph = gsp_compute_fourier_basis(graph);

    l  = linspace(0, graph.lmax, 300);
    M  = sparse(0.5 * graph.lmax * speye(graph.N) - graph.L);
    mu = graph.lmax / 2 - l;

    lambda_cuts = 0:0.01:2;
    filtered_snrs = zeros(length(lambda_cuts), 1);
    num_iter = length(lambda_cuts);
    pbar = ProgressBar(num_iter, ...
                       'IsParallel', true, ...
                       'UpdateRate', 100, ...
                       'WorkerDirectory', pwd(), ...
                       'Title', 'lambda');
    pbar.setup([], [], []);
    parfor i_lambda = 1:num_iter
        [b, a] = Get_Arma_Coeff(graph, mu, order, lambda_cuts(i_lambda), normalize);
        filtered_signals = time_varying_arma_filter(M, b, a, noisy_signals);
        filtered_signals = real(filtered_signals);
        filtered_snrs(i_lambda) = Snr(signals, filtered_signals);
        updateParallel([], pwd);
    end
    pbar.release();

    best_idx = Matrix_Idx(filtered_snrs, 'max');
    best_snr = filtered_snrs(best_idx);
    best_lambda_cut = lambda_cuts(best_idx);
    assert(best_snr == max(filtered_snrs));
end
