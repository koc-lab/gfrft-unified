function plotoriginalandnoisygraphsignals(G, original, noisy)
paramplot.vertex_size = 70;
paramplot.show_edges = 1;
paramplot.climits = [min(min(original(:)), min(noisy(:))), ...
    max(max(original(:)), max(noisy(:)))];
figure;
title('Community Graph');

subplot(211);
title('Graph Signal');
gsp_plot_signal(G, original, paramplot);

subplot(212);
noiseError = 100 * norm(original-noisy) / norm(original);
title(sprintf("Noisy Graph Signal, RMSE = %.2f%%", noiseError));
gsp_plot_signal(G, noisy, paramplot);
end
