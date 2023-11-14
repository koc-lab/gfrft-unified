% (c) Copyright 2023 Tuna Alikaşifoğlu

function Plot_Time(power_durations, hyper_durations, eigen_durations, ...
                   fractional_orders, size_index, strategy_index)
    power_vals = squeeze(power_durations(size_index, strategy_index, :, :));
    hyper_vals = squeeze(hyper_durations(size_index, strategy_index, :, :));
    eigen_vals = squeeze(eigen_durations(size_index, strategy_index, :, :));

    power_mean = mean(power_vals, 2);
    power_std = std(power_vals, 0, 2);
    hyper_mean = mean(hyper_vals, 2);
    hyper_std = std(hyper_vals, 0, 2);
    eigen_mean = mean(eigen_vals, 2);
    eigen_std = std(eigen_vals, 0, 2);

    figure;
    bar(fractional_orders, 1000 * [power_mean, hyper_mean, eigen_mean]);
    title("Generation Duration Average of 20 Times");
    xlabel("Fractional Order");
    ylabel("GFRFT Generation Duration from given GFT (ms)");
    legend("Power", "Hyper", "Eigen");
    xticks(fractional_orders);

end
