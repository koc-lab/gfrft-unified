from typing import Iterable

import torch as th
import torch.nn as nn
from torch_gfrft.gfrft import GFRFT
from torch_gfrft.layer import GFRFTLayer
from utils import mse_loss


def generate_adjecency(
    num_nodes: int,
    device: th.device,
    symmetric: bool = False,
    self_loops: bool = False,
):
    A = th.rand(num_nodes, num_nodes, device=device)
    if symmetric:
        A = 0.5 * (A + A.T)
    if not self_loops:
        A = A - th.diag(th.diag(A))
    return A


def get_order_info(model: nn.Sequential, show_sum: bool = False, sep: str = " | ") -> str:
    orders = [layer.order.item() for layer in model]
    info_str = sep.join(f"a{i + 1} = {order: >7.4f}" for i, order in enumerate(orders))
    if show_sum:
        info_str += f"{sep}sum = {sum(orders): >7.4f}"
    return info_str


def experiment(
    gfrft: GFRFT,
    original_signals: th.Tensor,
    original_order: float,
    initial_orders: Iterable[float],
    *,
    dim: int = -1,
    lr: float = 5e-4,
    epochs: int = 1000,
    display_epochs: Iterable[int] | None = None,
    show_sum_during_training: bool = False,
):
    if display_epochs is None:
        display_epochs = (e for e in range(0, epochs, 100))
    display_epochs = set(display_epochs)
    transformed_signals = gfrft.gfrft(original_signals, original_order, dim=dim)
    model = nn.Sequential(*[GFRFTLayer(gfrft, order, dim=dim) for order in initial_orders])
    print(model)
    print(f"original order: {original_order:.4f}")
    print(f"learning rate: {lr}")
    optim = th.optim.Adam(model.parameters(), lr=lr)

    start_str = f"initial orders: {get_order_info(model, show_sum=show_sum_during_training)}"
    print(start_str)
    print("-" * len(start_str))
    for epoch in range(1, 1 + epochs):
        optim.zero_grad()
        output = mse_loss(model(original_signals), transformed_signals)
        if epoch in display_epochs:
            info = get_order_info(model, show_sum=show_sum_during_training)
            print(f"Epoch {epoch:4d} | Loss {output.item(): >8.2e} | {info}")
        output.backward()
        optim.step()
    print("-" * len(start_str))
    print(f"final orders: {get_order_info(model)}")
    final_sum = sum(layer.order.item() for layer in model)
    print(f"original order: {original_order:.4f}, final order sum: {final_sum:.4f}")
