import os
import random
from pathlib import Path
from typing import Callable

import numpy as np
import torch
from pygsp.graphs import NNGraph  # type: ignore
from scipy.io import loadmat


def seed_everything(seed: int) -> None:
    random.seed(seed)
    np.random.seed(seed)
    torch.use_deterministic_algorithms(True)
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.backends.cudnn.benchmark = False
        torch.cuda.manual_seed_all(seed)
        os.environ["CUBLAS_WORKSPACE_CONFIG"] = ":4096:8"


def snr(signal: torch.Tensor, noise: torch.Tensor) -> torch.Tensor:
    return 20 * torch.log10(torch.norm(signal) / torch.norm(noise))


def mse_loss(predictions: torch.Tensor, targets: torch.Tensor) -> torch.Tensor:
    return torch.mean(torch.abs(predictions - targets) ** 2)


def add_gaussian_noise(
    signal: torch.Tensor,
    noise_sigma: float,
    noise_mean: float = 0.0,
) -> torch.Tensor:
    noise = noise_mean + noise_sigma * torch.randn_like(signal)
    return signal + noise


def init_knn_from_mat(
    dataset_path: Path,
    knn_count: int = 5,
    knn_sigma: float | None = None,
    max_node_count: int | None = None,
    max_time_length: int | None = None,
    device: torch.device | None = None,
    verbose: bool = False,
    dtype: torch.dtype = torch.float64,
) -> tuple[NNGraph, torch.Tensor, torch.Tensor]:
    dataset = loadmat(dataset_path)
    if "data" not in dataset.keys() or "position" not in dataset.keys():
        raise ValueError("Invalid dataset format")
    jtv_signal, position = dataset["data"], dataset["position"]

    if max_node_count is not None:
        jtv_signal = jtv_signal[:max_node_count]
        position = position[:max_node_count]
    if max_time_length is not None:
        jtv_signal = jtv_signal[:, :max_time_length]

    if knn_sigma is None:
        graph = NNGraph(position, k=knn_count)
    else:
        graph = NNGraph(position, k=knn_count, sigma=knn_sigma)

    jtv_signal = torch.tensor(jtv_signal, dtype=dtype, device=device)
    adjacency = torch.tensor(graph.W.todense(), dtype=dtype, device=device)
    if verbose:
        print(
            f"Dataset Info:\n\tname: {dataset_path.stem}\n\t"
            f"node count: {jtv_signal.shape[0]}\n\ttime length: {jtv_signal.shape[1]}"
        )
        graph.plot()
    return graph, adjacency, jtv_signal


def sort_graph_and_jtv(
    graph: NNGraph, adjacency: torch.Tensor, signal: torch.Tensor, sort_func: Callable
) -> tuple[NNGraph, torch.Tensor, torch.Tensor]:
    idx, new_coords = zip(*sorted(enumerate(graph.coords), key=lambda t: sort_func(t[1])))
    new_graph = NNGraph(new_coords, k=graph.k, sigma=graph.k)
    return new_graph, adjacency[idx, ...][..., idx], signal[idx, ...]


def complex_round(x: torch.Tensor, decimals: int = 0) -> torch.Tensor:
    if x.is_complex():
        return x.real.round(decimals=decimals) + 1j * x.imag.round(decimals=decimals)
    else:
        return x.round(decimals=decimals)


def get_inverse_degrees(matrix: torch.Tensor) -> torch.Tensor:
    out_degrees = matrix.sum(dim=-1)
    inverse_degrees = torch.zeros_like(out_degrees)
    non_zero_indices = out_degrees != 0
    inv_values = torch.reciprocal(out_degrees[non_zero_indices])
    inverse_degrees = inverse_degrees.type(inv_values.dtype)
    inverse_degrees[non_zero_indices] = inv_values
    return inverse_degrees


def symmetric_degree_normalize(matrix: torch.Tensor) -> torch.Tensor:
    inverse_degrees = get_inverse_degrees(matrix)
    sqrt_inverse_degrees = torch.sqrt(inverse_degrees)
    return torch.einsum("i,ij,j->ij", sqrt_inverse_degrees, matrix, sqrt_inverse_degrees)
