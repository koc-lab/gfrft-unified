# Datasets

These are the possible joint time-vertex datasets that can be used for the experiments of the GFRFT paper. It contains a synthetic dataset, and four real datasets, which consist of two COVID-19-related discrete datasets, and two manifolds, where one of them is sea surface temperatures, and the other is air quality data. Details of the datasets may be further cleared in the future.

## Data Structure

The `.mat` files contain two matrices which are named `data` and `position`, which hold the following information, where $N$ is the number of vertices in the graph, and $T$ is the length of the time-varying graph signal:

- `data`: $N\times T$ matrix, which corresponds to a joint time-vertex signal, where a column is a graph signal, and a row is a time-series signal.
- `position`: $N\times 2$ matrix, where each tuple entry corresponds to the coordinate of the sensor.

## Acknowledgment

The `.mat` files are obtained from the [GitHub Page](https://github.com/jhonygiraldo/GraphTRSS) of the paper _Reconstruction of Time-Varying Graph Signals via Sobolev Smoothness (GraphTRSS)_, and updated according to usage of this codebase.
