% (c) Copyright 2023 Tuna Alikaşifoğlu

function [estimation_snr, noisy_snr] = Experiment(signals, gft_mtx, ...
                                                  fractional_orders, snr_dbs, zero_counts)
    arguments
        signals(:, :) double
        gft_mtx(:, :) double {Must_Be_Square_Matrix}
        fractional_orders(:, 1) double {mustBeReal}
        snr_dbs(:, 1) double {mustBeReal}
        zero_counts(:, 1) double {mustBeReal, mustBePositive}
    end

    estimation_snr = zeros(length(fractional_orders), length(snr_dbs), length(zero_counts));
    noisy_snr = zeros(length(snr_dbs), 1);
    noisy_signals_cell = cell(1, length(snr_dbs));
    for i = 1:length(snr_dbs)
        noisy_signals_cell{i} = Add_Noise(signals, snr_dbs(i));
        noisy_snr(i) = Snr(signals, noisy_signals_cell{i});
    end

    for i_frac = 1:length(fractional_orders)
        [gfrft_mtx, igfrft_mtx] = GFRFT_Mtx(gft_mtx, fractional_orders(i_frac));

        for j_snr = 1:length(snr_dbs)
            noisy_signals = noisy_signals_cell{j_snr};

            for k_zero = 1:length(zero_counts)
                filter_vec = Get_Ideal_Lowpass_Filter(size(signals, 1), zero_counts(k_zero));
                filtered_signals = igfrft_mtx * ((gfrft_mtx * noisy_signals) .* filter_vec);
                curr_snr = Snr(signals, filtered_signals);
                estimation_snr(i_frac, j_snr, k_zero) = curr_snr;
            end
        end
    end
end

function noisy = Add_Noise(signal, snr_db)
    rng('default');
    noise = randn(size(signal)) .* std(signal) / db2mag(snr_db);
    noisy = signal + noise;
end

function filter_vec = Get_Ideal_Lowpass_Filter(node_count, zero_count)
    arguments
        node_count double {mustBePositive, mustBeInteger}
        zero_count double {mustBeNonnegative, mustBeInteger, ...
                           mustBeLessThanOrEqual(zero_count, node_count)}
    end
    filter_vec = zeros(node_count, 1);
    one_count = node_count - zero_count;
    filter_vec(1:one_count) = 1;
end
