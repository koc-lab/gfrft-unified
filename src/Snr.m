% (c) Copyright 2023 Tuna Alikaşifoğlu

function snr_db = Snr(signal, noisy_signal)
    arguments
        signal double {mustBeNumeric}
        noisy_signal double {Must_Be_Equal_Size(signal, noisy_signal)}
    end
    snr_ratio = var(signal(:)) / var(signal(:) - noisy_signal(:));
    snr_db = 10 * log10(snr_ratio);
end
