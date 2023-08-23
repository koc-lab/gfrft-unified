% (c) Copyright 2023 Tuna Alikaşifoğlu

function snr_db = Snr(signal, noisy_signal)
    arguments
        signal double {mustBeNumeric}
        noisy_signal double {Must_Be_Equal_Size(signal, noisy_signal)}
    end
    snr_db = mag2db(rssq(signal(:)) / rssq(signal(:) - noisy_signal(:)));
end
