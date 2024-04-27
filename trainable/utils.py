import os
import random
from pathlib import Path

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


def rmse_loss(predictions: torch.Tensor, targets: torch.Tensor) -> torch.Tensor:
    return torch.sqrt(torch.mean((predictions - targets) ** 2))


def mse_loss(predictions: torch.Tensor, targets: torch.Tensor) -> torch.Tensor:
    return torch.norm(predictions - targets, p="fro", dim=0).mean()


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
) -> tuple[torch.Tensor, torch.Tensor]:
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

    jtv_signal = torch.tensor(jtv_signal, dtype=torch.float32, device=device)
    adjacency = torch.tensor(graph.W.todense(), dtype=torch.float32, device=device)
    if verbose:
        print(
            f"Dataset Info:\n\tname: {dataset_path.stem}\n\t"
            f"node count: {jtv_signal.shape[0]}\n\ttime length: {jtv_signal.shape[1]}"
        )
        graph.plot()
    return adjacency, jtv_signal
