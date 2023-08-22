function [graph, jtv_signal] = init_knn(dataset_name, knn_count, knn_sigma, verbose)
% Parameters
if ~exist('dataset_name', 'var')
    dataset_name = "sea-surface-temperature.mat";
end
if ~exist('knn_count', 'var'), knn_count = 10; end
if ~exist('knn_sigma', 'var'), knn_sigma =  1; end
if ~exist('verbose', 'var'), verbose =  false; end

% Load Paths
DATA_PATH = "../datasets/";
GRAPH_ARMA_PATH = "../graph-arma/";
GRAPH_CONSTRUCTION_PATH = "../graph-construction/";
GSP_TOOLBOX_PATH = "../gspbox/";
addpath(DATA_PATH, GSP_TOOLBOX_PATH, '-frozen');
addpath(GRAPH_ARMA_PATH, GRAPH_CONSTRUCTION_PATH, '-begin');
gsp_start;

% Load Data
dataset = load(dataset_name, 'data', 'position');
graph = knn_graph_construction(dataset.position, knn_count, knn_sigma);
jtv_signal = dataset.data;

if verbose
    disp("Graph Info");
    disp("  - Number of Vertices: " + graph.N);
    disp("  - Number of Edges: " + graph.Ne);

    disp("JTV Signal Info");
    disp("  - Number of Vertices: " + size(jtv_signal, 1));
    disp("  - Number of Time Samples: " + size(jtv_signal, 2));
end

end
