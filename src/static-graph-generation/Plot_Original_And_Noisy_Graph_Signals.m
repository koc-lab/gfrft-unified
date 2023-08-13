% (c) Copyright 2023 Tuna Alikaşifoğlu

function Plot_Original_And_Noisy_Graph_Signals(graph, original, noisy)
    paramplot.vertex_size = 70;
    paramplot.show_edges = 1;
    paramplot.climits = [min(min(original(:)), min(noisy(:))), ...
                         max(max(original(:)), max(noisy(:)))];
    figure;
    title('Community Graph');

    subplot(211);
    title('Graph Signal');
    gsp_plot_signal(graph, original, paramplot);

    subplot(212);
    noise_error = 100 * norm(original - noisy) / norm(original);
    title(sprintf("Noisy Graph Signal, RMSE = %.2f%%", noise_error));
    gsp_plot_signal(graph, noisy, paramplot);
end
