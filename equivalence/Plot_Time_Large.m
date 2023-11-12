% (c) Copyright 2023 Tuna Alikaşifoğlu

function Plot_Time_Large(power_durations, hyper_durations, elogm_durations, ...
                         fractional_orders, gfrft_strategies)
    for i_strategy = 1:length(gfrft_strategies)
        power_vals = squeeze(power_durations(i_strategy, :, :));
        hyper_vals = squeeze(hyper_durations(i_strategy, :, :));
        elogm_vals = squeeze(elogm_durations(i_strategy, :, :));

        power_mean = mean(power_vals, 2);
        power_std = std(power_vals, 0, 2);
        hyper_mean = mean(hyper_vals, 2);
        hyper_std = std(hyper_vals, 0, 2);
        elogm_mean = mean(elogm_vals, 2);
        elogm_std = std(elogm_vals, 0, 2);

        figure;
        bar(fractional_orders, 1000 * [power_mean, elogm_mean, hyper_mean]);
        title(sprintf("Generation Duration Average of 20 Times, %s", ...
                      gfrft_strategies(i_strategy)));
        xlabel("Fractional Order");
        ylabel("GFRFT Generation Duration from given GFT (ms)");
        legend("Power", "Explog", "Hyper");
        xticks(fractional_orders);
    end
end
