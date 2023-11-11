% (c) Copyright 2023 Tuna Alikaşifoğlu

function Plot_Time(power_durations, hyper_durations, elogm_durations, ...
                   fractional_orders, knn_index, strategy_index)
    power_vals = squeeze(power_durations(knn_index, strategy_index, :, :));
    hyper_vals = squeeze(hyper_durations(knn_index, strategy_index, :, :));
    elogm_vals = squeeze(elogm_durations(knn_index, strategy_index, :, :));

    power_mean = mean(power_vals, 2);
    power_std = std(power_vals, 0, 2);
    hyper_mean = mean(hyper_vals, 2);
    hyper_std = std(hyper_vals, 0, 2);
    elogm_mean = mean(elogm_vals, 2);
    elogm_std = std(elogm_vals, 0, 2);

    figure;
    bar(fractional_orders, 1000 * [power_mean, elogm_mean, hyper_mean]);
    title("Generation Duration Average of 20 Times");
    xlabel("Fractional Order");
    ylabel("GFRFT Generation Duration from given GFT (ms)");
    legend("Power", "Explog", "Hyper");
    xticks(fractional_orders);

end
