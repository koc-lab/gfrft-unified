% (c) Copyright 2023 Tuna Alikaşifoğlu

function mse_percent = MSE_Percent(signal, noisy_signal)
    arguments
        signal double {mustBeNumeric}
        noisy_signal double {Must_Be_Equal_Size(signal, noisy_signal)}
    end
    ratio = norm(signal - noisy_signal, 'fro') / norm(signal, 'fro');
    mse_percent = 100 * ratio;
end
